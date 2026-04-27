// VIT Translation
// Function: ReadAFfile
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Approach: Idiomatic C++ file parser (keyword-based, not line-by-line Fortran replica)
// Status: unverified

#include <cmath>
#include <cstring>
#include <cstdio>
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
#include <algorithm>
#include <cctype>

#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"

static constexpr int ErrID_None   = 0;
static constexpr int ErrID_Warn   = 2;
static constexpr int ErrID_Fatal  = 4;

static void setErrMsg(char* errMsg, const std::string& msg) {
    std::memset(errMsg, ' ', ErrMsgLen);
    size_t n = std::min(msg.size(), (size_t)ErrMsgLen);
    std::memcpy(errMsg, msg.c_str(), n);
}

extern "C" {
    void calculateuacoeffs_c(afi_ua_bl_default_type_t* CalcDefaults,
                             afi_table_type_view_t* p,
                             int ColCl, int ColCd, int ColCm, int ColUAf, int UAMod);
}

// ============================================================
// String utilities
// ============================================================

static std::string trim(const std::string& s) {
    size_t a = s.find_first_not_of(" \t\r\n");
    if (a == std::string::npos) return "";
    return s.substr(a, s.find_last_not_of(" \t\r\n") - a + 1);
}

static std::string toUpper(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(), ::toupper);
    return s;
}

static std::string getParentDir(const std::string& path) {
    size_t pos = path.find_last_of("/\\");
    return (pos != std::string::npos) ? path.substr(0, pos + 1) : "";
}

// ============================================================
// File reader: loads file, strips comments, resolves @includes
// ============================================================

static bool readAndDecomment(const std::string& filename, std::vector<std::string>& lines,
                             std::string& errMsg) {
    std::ifstream f(filename);
    if (!f.is_open()) {
        errMsg = "Error opening file: " + filename;
        return false;
    }
    std::string parentDir = getParentDir(filename);
    std::string line;
    while (std::getline(f, line)) {
        size_t bang = line.find('!');
        if (bang != std::string::npos) line = line.substr(0, bang);
        std::string t = trim(line);
        if (t.empty()) continue;

        if (t[0] == '@') {
            // Extract quoted filename from @"filename" VarName
            std::string rest = t.substr(1);
            std::string incName;
            size_t q1 = rest.find('"');
            if (q1 != std::string::npos) {
                size_t q2 = rest.find('"', q1 + 1);
                incName = (q2 != std::string::npos) ? rest.substr(q1+1, q2-q1-1) : rest.substr(q1+1);
            } else {
                std::istringstream iss(rest);
                iss >> incName;
            }
            if (!incName.empty() && incName[0] != '/' && incName.find(':') == std::string::npos)
                incName = parentDir + incName;
            if (!readAndDecomment(incName, lines, errMsg)) return false;
            continue;
        }
        lines.push_back(line);  // keep original whitespace for numeric parsing
    }
    return true;
}

// ============================================================
// AirfoilFileParser: keyword-based parser for OpenFAST airfoil files
// ============================================================
//
// File format: each non-data line is "value  VarName" (value first, then name).
// The parser reads lines sequentially but identifies each by the keyword
// (second token). For pure data rows (coefficients), it reads positionally.

class AirfoilFileParser {
    std::vector<std::string> lines_;
    int pos_ = 0;  // current line position

    // Get next line, advance position
    std::string nextLine() {
        if (pos_ < (int)lines_.size()) return lines_[pos_++];
        return "";
    }

    // Peek at the first token of the current line without consuming it
    std::string peekFirstToken() const {
        if (pos_ >= (int)lines_.size()) return "";
        std::istringstream iss(lines_[pos_]);
        std::string tok;
        iss >> tok;
        return tok;
    }

    // Get the second token (keyword/variable name) from a line
    static std::string getKeyword(const std::string& line) {
        std::istringstream iss(line);
        std::string tok1, tok2;
        iss >> tok1 >> tok2;
        return toUpper(tok2);
    }

    // Check if current line's keyword matches (case-insensitive)
    bool currentLineHasKeyword(const std::string& keyword) const {
        if (pos_ >= (int)lines_.size()) return false;
        return getKeyword(lines_[pos_]) == toUpper(keyword);
    }

public:
    explicit AirfoilFileParser(std::vector<std::string> lines) : lines_(std::move(lines)) {}

    // Parse a double from the first token of the next line.
    // Returns false if "DEFAULT" or parse failure.
    bool parseDouble(double& val) {
        std::string line = nextLine();
        std::istringstream iss(line);
        std::string tok;
        if (!(iss >> tok)) return false;
        if (toUpper(tok) == "DEFAULT" || toUpper(tok) == "\"DEFAULT\"") return false;
        try { val = std::stod(tok); return true; }
        catch (...) { return false; }
    }

    // Parse a double, using default if "DEFAULT" or missing
    double parseDoubleWithDefault(double def) {
        double v;
        return parseDouble(v) ? v : def;
    }

    // Parse an integer from the first token
    bool parseInt(int& val) {
        std::string line = nextLine();
        std::istringstream iss(line);
        std::string tok;
        if (!(iss >> tok)) return false;
        if (toUpper(tok) == "DEFAULT" || toUpper(tok) == "\"DEFAULT\"") return false;
        try { val = std::stoi(tok); return true; }
        catch (...) { return false; }
    }

    int parseIntWithDefault(int def) {
        int v;
        return parseInt(v) ? v : def;
    }

    // Parse a boolean (True/False/.TRUE./.FALSE./T/F)
    bool parseBool(bool& val) {
        std::string line = nextLine();
        std::istringstream iss(line);
        std::string tok;
        if (!(iss >> tok)) return false;
        std::string u = toUpper(tok);
        if (u == "TRUE" || u == "T" || u == ".TRUE.") { val = true; return true; }
        if (u == "FALSE" || u == "F" || u == ".FALSE.") { val = false; return true; }
        return false;
    }

    // Parse a string (first token, unquoted)
    bool parseString(std::string& val) {
        std::string line = nextLine();
        std::string t = trim(line);
        if (t.empty()) return false;
        if (t[0] == '"') {
            size_t end = t.find('"', 1);
            val = (end != std::string::npos) ? t.substr(1, end-1) : t.substr(1);
        } else {
            std::istringstream iss(t);
            iss >> val;
        }
        return !val.empty();
    }

    // Parse N doubles from a single line (coefficient data row)
    bool parseDoubleRow(double* arr, int n) {
        std::string line = nextLine();
        std::istringstream iss(line);
        for (int i = 0; i < n; i++) {
            if (!(iss >> arr[i])) return false;
        }
        return true;
    }

    // Try to parse a double from the current line. If the keyword
    // doesn't match what we expect, DON'T consume the line (for optional fields).
    bool tryParseDouble(const std::string& expectedKeyword, double& val) {
        if (pos_ >= (int)lines_.size()) return false;
        std::string kw = getKeyword(lines_[pos_]);
        // If keyword matches or is empty (pure numeric line), consume and parse
        if (!kw.empty() && kw != toUpper(expectedKeyword)) return false;
        return parseDouble(val);
    }

    // ---------------------------------------------------------------
    // Fortran ParseVar-compatible: keyword-checked, non-consuming on failure
    // ---------------------------------------------------------------
    // Matches Fortran's ParseVar behavior exactly:
    // 1. Check if either word on the line matches the expected keyword
    // 2. If keyword matches: parse the value, advance the line → return true
    // 3. If keyword doesn't match: DON'T advance → return false
    // This is critical for files where UA parameters are missing — the
    // Fortran parser skips missing parameters without consuming lines.
    bool parseVarDouble(const std::string& expectedKeyword, double& val) {
        if (pos_ >= (int)lines_.size()) return false;
        // Check if the expected keyword appears in either word position
        std::istringstream iss(lines_[pos_]);
        std::string w1, w2;
        iss >> w1 >> w2;
        std::string uw1 = toUpper(w1), uw2 = toUpper(w2);
        std::string uexp = toUpper(expectedKeyword);
        int nameIdx = 0;
        if (uw1 == uexp) nameIdx = 1;       // first word is keyword, second is value
        else if (uw2 == uexp) nameIdx = 2;   // second word is keyword, first is value
        else return false;                    // keyword not found — DON'T consume

        std::string valueStr = (nameIdx == 1) ? w2 : w1;
        try { val = std::stod(valueStr); }
        catch (...) { return false; }  // value parse failed — DON'T consume
        pos_++;  // success — consume the line
        return true;
    }

    // ParseVarWDefault-compatible: keyword-checked, handles "DEFAULT", non-consuming on keyword mismatch
    bool parseVarDoubleWDefault(const std::string& expectedKeyword, double& val, double defVal) {
        if (pos_ >= (int)lines_.size()) { val = defVal; return false; }
        std::istringstream iss(lines_[pos_]);
        std::string w1, w2;
        iss >> w1 >> w2;
        std::string uw1 = toUpper(w1), uw2 = toUpper(w2);
        std::string uexp = toUpper(expectedKeyword);
        int nameIdx = 0;
        if (uw1 == uexp) nameIdx = 1;
        else if (uw2 == uexp) nameIdx = 2;
        else { val = defVal; return false; }  // keyword not found — DON'T consume, use default

        std::string valueStr = (nameIdx == 1) ? w2 : w1;
        std::string uvs = toUpper(valueStr);
        if (uvs == "DEFAULT" || uvs == "\"DEFAULT\"") {
            val = defVal;
            pos_++;
            return true;
        }
        try { val = std::stod(valueStr); }
        catch (...) { val = defVal; pos_++; return true; }  // parse failed but keyword matched — consume, use default
        pos_++;
        return true;
    }

    // Skip lines until we find one whose keyword matches (for resilience)
    // Returns false if not found within maxLines
    bool skipToKeyword(const std::string& keyword, int maxLines = 5) {
        for (int i = 0; i < maxLines && pos_ < (int)lines_.size(); i++) {
            if (currentLineHasKeyword(keyword)) return true;
            pos_++;
        }
        return false;
    }

    int position() const { return pos_; }
    int lineCount() const { return (int)lines_.size(); }
};

// ============================================================
// Cached parsed data (persists between Pass 1 and Pass 2)
// ============================================================

struct ParsedTable {
    double Re;
    double UserProp;
    bool InclUAdata;
    bool ConstData;
    int NumAlf;
    int NumCoefsTab;
    afi_ua_bl_type_t UA_BL;
    afi_ua_bl_default_type_t CalcDefaults;
    std::vector<double> Alpha;
    std::vector<double> Coefs;  // column-major [NumAlf * NumCoefsTab]
};

struct ParsedFile {
    int InterpOrd = 1;
    double RelThickness = -1.0;
    double NonDimArea = 1.0;
    int NumCoords = 0;
    std::vector<double> X_Coord, Y_Coord;
    char BL_file[1024] = {};
    int NumTabs = 0;
    int ColUAf = 0;
    int ColCl = 1, ColCd = 2, ColCm = 0, ColCpmin = 0;
    std::vector<ParsedTable> tables;
};

static ParsedFile g_cache;

// ============================================================
// Pass 1: Parse file, cache data, return sizes
// ============================================================

void ReadAFfile_pass1(const afi_initinputtype_t* InitInp, int NumCoefsIn,
                      afi_parametertype_view_t* p,
                      int* numalf_out, int* ncoefstab_out,
                      int* errStat, char* errMsg) {
    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);

    std::string filename = trim(std::string(InitInp->FileName,
        std::find(InitInp->FileName, InitInp->FileName + 1024, ' ')));
    std::string parentDir = getParentDir(filename);


    // Read and decomment file (resolving @includes)
    std::vector<std::string> lines;
    std::string err;
    if (!readAndDecomment(filename, lines, err)) {
        *errStat = ErrID_Fatal;
        setErrMsg(errMsg, "ReadAFfile C++: " + err + " [file: " + filename + "]");
        return;
    }

    AirfoilFileParser parser(std::move(lines));
    ParsedFile& pf = g_cache;
    pf = ParsedFile{};

    // --- Header ---
    pf.InterpOrd = parser.parseIntWithDefault(1);

    // RelThickness is optional — check if the keyword is present
    { double v;
      if (parser.tryParseDouble("RelThickness", v)) {
          pf.RelThickness = v;
      } else {
          pf.RelThickness = -1.0;  // not found, will trigger error in BV model
      }
    }

    // NonDimArea
    { double v;
      if (!parser.parseDouble(v)) { *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: failed to parse NonDimArea in " + filename); return; }
      pf.NonDimArea = v;
    }

    // NumCoords (from @include, the first line of the included file has the count)
    { int v;
      if (!parser.parseInt(v)) { pf.NumCoords = 0; }
      else { pf.NumCoords = v; }
    }

    // Read coordinates if present
    if (pf.NumCoords > 0) {
        pf.X_Coord.resize(pf.NumCoords);
        pf.Y_Coord.resize(pf.NumCoords);
        for (int i = 0; i < pf.NumCoords; i++) {
            double coords[2];
            if (!parser.parseDoubleRow(coords, 2)) { *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: failed to parse coords row in " + filename); return; }
            pf.X_Coord[i] = coords[0];
            pf.Y_Coord[i] = coords[1];
        }
    }

    // BL_file
    { std::string bl;
      if (parser.parseString(bl)) {
          if (!bl.empty() && bl[0] != '/' && bl.find(':') == std::string::npos)
              bl = parentDir + bl;
          std::memset(pf.BL_file, ' ', 1024);
          std::memcpy(pf.BL_file, bl.c_str(), std::min(bl.size(), (size_t)1024));
      } else {
          const char* def = "NOT_SET_IN_AIRFOIL_FILE";
          std::memset(pf.BL_file, ' ', 1024);
          std::memcpy(pf.BL_file, def, std::strlen(def));
      }
    }

    int Cols2Parse = std::max({InitInp->InCol_Alfa, InitInp->InCol_Cl,
                               InitInp->InCol_Cd, InitInp->InCol_Cm, InitInp->InCol_Cpmin});

    // Compute output column indices (same logic as AFI_Init)
    int colCl = 1, colCd = 2, colCm = 0, colCpmin = 0;
    if (InitInp->InCol_Cm > 0) {
        colCm = 3;
        if (InitInp->InCol_Cpmin > 0) colCpmin = 4;
    } else if (InitInp->InCol_Cpmin > 0) {
        colCpmin = 3;
    }
    pf.ColCl = colCl; pf.ColCd = colCd; pf.ColCm = colCm; pf.ColCpmin = colCpmin;

    // NumTabs
    { int v;
      if (!parser.parseInt(v) || v < 1) { *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: failed to parse NumTabs in " + filename); return; }
      pf.NumTabs = v;
    }

    pf.ColUAf = 0;
    pf.tables.resize(pf.NumTabs);

    // --- Per-table parsing ---
    for (int iTable = 0; iTable < pf.NumTabs; iTable++) {
        ParsedTable& tab = pf.tables[iTable];
        std::memset(&tab.CalcDefaults, 0, sizeof(tab.CalcDefaults));
        std::memset(&tab.UA_BL, 0, sizeof(tab.UA_BL));
        int NumCoefsTab = NumCoefsIn;

        // Re (in millions)
        { double v;
          if (!parser.parseDouble(v)) { *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: failed to parse Re for table " + std::to_string(iTable+1) + " in " + filename); return; }
          tab.Re = v * 1.0e6;
          if (tab.Re <= 0.0) { *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: Re <= 0 in " + filename); return; }
        }

        // UserProp
        { double v;
          if (!parser.parseDouble(v)) { *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: failed to parse UserProp in " + filename); return; }
          tab.UserProp = v;
        }

        // InclUAdata
        { bool v;
          if (!parser.parseBool(v)) v = false;
          tab.InclUAdata = v;
        }

        if (tab.InclUAdata) {
            // Parse UA parameters using keyword-checked ParseVar semantics.
            // If the expected keyword is NOT found on the current line, the line
            // is NOT consumed and CalcDefaults is set to 1 (calculate default).
            // This matches Fortran's ParseVar/ParseVarWDefault behavior exactly.
            auto readUA = [&](const char* kw, double& field, int32_t& calcDef, double d2r = 1.0) {
                double v;
                if (parser.parseVarDouble(kw, v)) { field = v * d2r; calcDef = 0; }
                else { calcDef = 1; }
            };
            auto readUADef = [&](const char* kw, double& field, int32_t& calcDef, double defVal, double d2r = 1.0) {
                double v;
                if (parser.parseVarDoubleWDefault(kw, v, defVal)) { field = v * d2r; calcDef = 0; }
                else { field = defVal; calcDef = 1; }
            };

            readUA("alpha0", tab.UA_BL.alpha0, tab.CalcDefaults.alpha0, D2R);
            readUA("alpha1", tab.UA_BL.alpha1, tab.CalcDefaults.alpha1, D2R);
            readUA("alpha2", tab.UA_BL.alpha2, tab.CalcDefaults.alpha2, D2R);
            readUA("alphaUpper", tab.UA_BL.alphaUpper, tab.CalcDefaults.alphaUpper, D2R);
            readUA("alphaLower", tab.UA_BL.alphaLower, tab.CalcDefaults.alphaLower, D2R);
            readUA("eta_e", tab.UA_BL.eta_e, tab.CalcDefaults.eta_e);
            readUA("C_nalpha", tab.UA_BL.C_nalpha, tab.CalcDefaults.C_nalpha);
            readUA("C_lalpha", tab.UA_BL.C_lalpha, tab.CalcDefaults.C_lalpha);
            readUADef("T_f0", tab.UA_BL.T_f0, tab.CalcDefaults.T_f0, 3.0);
            readUADef("T_V0", tab.UA_BL.T_V0, tab.CalcDefaults.T_V0, 6.0);
            readUADef("T_p", tab.UA_BL.T_p, tab.CalcDefaults.T_p, 1.7);
            readUADef("T_VL", tab.UA_BL.T_VL, tab.CalcDefaults.T_VL, 11.0);
            readUADef("b1", tab.UA_BL.b1, tab.CalcDefaults.b1, 0.14);
            readUADef("b2", tab.UA_BL.b2, tab.CalcDefaults.b2, 0.53);
            readUADef("b5", tab.UA_BL.b5, tab.CalcDefaults.b5, 5.0);
            readUADef("A1", tab.UA_BL.A1, tab.CalcDefaults.A1, 0.3);
            readUADef("A2", tab.UA_BL.A2, tab.CalcDefaults.A2, 0.7);
            readUADef("A5", tab.UA_BL.A5, tab.CalcDefaults.A5, 1.0);
            readUA("S1", tab.UA_BL.S1, tab.CalcDefaults.S1);
            readUA("S2", tab.UA_BL.S2, tab.CalcDefaults.S2);
            readUA("S3", tab.UA_BL.S3, tab.CalcDefaults.S3);
            readUA("S4", tab.UA_BL.S4, tab.CalcDefaults.S4);
            readUA("Cn1", tab.UA_BL.Cn1, tab.CalcDefaults.Cn1);
            readUA("Cn2", tab.UA_BL.Cn2, tab.CalcDefaults.Cn2);
            readUADef("St_sh", tab.UA_BL.St_sh, tab.CalcDefaults.St_sh, 0.19);
            readUA("Cd0", tab.UA_BL.Cd0, tab.CalcDefaults.Cd0);
            readUA("Cm0", tab.UA_BL.Cm0, tab.CalcDefaults.Cm0);
            readUA("k0", tab.UA_BL.k0, tab.CalcDefaults.k0);
            readUA("k1", tab.UA_BL.k1, tab.CalcDefaults.k1);
            readUA("k2", tab.UA_BL.k2, tab.CalcDefaults.k2);
            readUA("k3", tab.UA_BL.k3, tab.CalcDefaults.k3);
            readUA("k1_hat", tab.UA_BL.k1_hat, tab.CalcDefaults.k1_hat);
            readUADef("x_cp_bar", tab.UA_BL.x_cp_bar, tab.CalcDefaults.x_cp_bar, 0.2);
            readUADef("UACutout", tab.UA_BL.UACutout, tab.CalcDefaults.UACutout, 45.0, D2R);
            readUADef("UACutout_delta", tab.UA_BL.UACutout_delta, tab.CalcDefaults.UACutout_delta, 5.0, D2R);
            readUADef("filtCutOff", tab.UA_BL.filtCutOff, tab.CalcDefaults.filtCutOff, 0.5);
        } else {
            // No UA data in file — mark all for calculation
            std::memset(&tab.CalcDefaults, 1, sizeof(tab.CalcDefaults));
            tab.InclUAdata = true;
        }

        if (tab.InclUAdata) {
            pf.ColUAf = NumCoefsIn + 1;
            NumCoefsTab = NumCoefsIn + 3;
        }

        // NumAlf
        { int v;
          if (!parser.parseInt(v) || v < 1) { *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: failed to parse NumAlf for table " + std::to_string(iTable+1) + " in " + filename); return; }
          tab.NumAlf = v;
        }
        tab.NumCoefsTab = NumCoefsTab;

        // Coefficient data rows
        tab.Alpha.resize(tab.NumAlf);
        tab.Coefs.assign(tab.NumAlf * NumCoefsTab, 0.0);

        std::vector<double> rowBuf(Cols2Parse);
        for (int row = 0; row < tab.NumAlf; row++) {
            if (!parser.parseDoubleRow(rowBuf.data(), Cols2Parse)) {
                *errStat = ErrID_Fatal; setErrMsg(errMsg, "ReadAFfile C++: failed to parse coeff row " + std::to_string(row+1) + " of table " + std::to_string(iTable+1) + " in " + filename); return;
            }
            tab.Alpha[row] = rowBuf[InitInp->InCol_Alfa - 1] * D2R;
            // Column-major: Coefs[(col-1) * NumAlf + row], using 1-based colCl/colCd/etc.
            tab.Coefs[(colCl-1) * tab.NumAlf + row] = rowBuf[InitInp->InCol_Cl - 1];
            tab.Coefs[(colCd-1) * tab.NumAlf + row] = rowBuf[InitInp->InCol_Cd - 1];
            if (colCm > 0)
                tab.Coefs[(colCm-1) * tab.NumAlf + row] = rowBuf[InitInp->InCol_Cm - 1];
            if (colCpmin > 0)
                tab.Coefs[(colCpmin-1) * tab.NumAlf + row] = rowBuf[InitInp->InCol_Cpmin - 1];
        }

        // Detect constant data
        if (tab.NumAlf < 3) {
            tab.ConstData = true;
        } else {
            tab.ConstData = true;
            for (int row = 0; row < tab.NumAlf - 1 && tab.ConstData; row++) {
                for (int col = 0; col < NumCoefsIn; col++) {
                    if (!EqualRealNos(tab.Coefs[col * tab.NumAlf + row],
                                      tab.Coefs[col * tab.NumAlf + row + 1])) {
                        tab.ConstData = false;
                        break;
                    }
                }
            }
        }

        if (tab.ConstData) tab.InclUAdata = false;

        numalf_out[iTable] = tab.NumAlf;
        ncoefstab_out[iTable] = tab.NumCoefsTab;
    }

    // Set scalar fields on view struct
    p->InterpOrd = pf.InterpOrd;
    p->RelThickness = pf.RelThickness;
    p->NonDimArea = pf.NonDimArea;
    p->NumCoords = pf.NumCoords;
    p->NumTabs = pf.NumTabs;
    p->ColUAf = pf.ColUAf;
    std::memcpy(p->BL_file, pf.BL_file, 1024);
}

// ============================================================
// Pass 2: Fill Fortran-allocated arrays from cache
// ============================================================

void ReadAFfile_fill(afi_parametertype_view_t* p,
                     const afi_initinputtype_t* InitInp, int NumCoefsIn,
                     int* errStat, char* errMsg) {
    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);

    ParsedFile& pf = g_cache;

    // Fill coordinate arrays
    if (pf.NumCoords > 0 && p->X_Coord && p->Y_Coord) {
        for (int i = 0; i < pf.NumCoords; i++) {
            p->X_Coord[i] = pf.X_Coord[i];
            p->Y_Coord[i] = pf.Y_Coord[i];
        }
    }

    // Fill per-table data
    for (int iTable = 0; iTable < pf.NumTabs; iTable++) {
        ParsedTable& tab = pf.tables[iTable];
        afi_table_type_view_t* tv = &p->Table[iTable];

        tv->Re = tab.Re;
        tv->UserProp = tab.UserProp;
        tv->NumAlf = tab.NumAlf;
        tv->ConstData = tab.ConstData ? 1 : 0;
        tv->InclUAdata = tab.InclUAdata ? 1 : 0;
        tv->UA_BL = tab.UA_BL;

        if (tv->Alpha)
            std::memcpy(tv->Alpha, tab.Alpha.data(), tab.NumAlf * sizeof(double));
        if (tv->Coefs)
            std::memcpy(tv->Coefs, tab.Coefs.data(), tab.NumAlf * tab.NumCoefsTab * sizeof(double));

        // Calculate UA coefficients for non-constant tables
        if (!tab.ConstData && tab.InclUAdata) {
            calculateuacoeffs_c(&tab.CalcDefaults, tv,
                                pf.ColCl, pf.ColCd, pf.ColCm,
                                pf.ColUAf, InitInp->UAMod);
        }
    }

    // Validate periodic continuity
    for (int iTable = 0; iTable < pf.NumTabs; iTable++) {
        ParsedTable& tab = pf.tables[iTable];
        if (tab.NumAlf > 1) {
            bool bad = false;
            if (!tab.ConstData) {
                if (!EqualRealNos(tab.Alpha[0], -Pi)) bad = true;
                if (!EqualRealNos(tab.Alpha[tab.NumAlf - 1], Pi)) bad = true;
            }
            for (int col = 0; col < NumCoefsIn; col++) {
                if (!EqualRealNos(tab.Coefs[col * tab.NumAlf],
                                  tab.Coefs[col * tab.NumAlf + tab.NumAlf - 1]))
                    bad = true;
            }
            if (bad && *errStat < ErrID_Warn)
                *errStat = ErrID_Warn;
        }
    }

    // If any table lacks UA data, set ColUAf=0 globally
    for (int iTable = 0; iTable < pf.NumTabs; iTable++) {
        if (!pf.tables[iTable].InclUAdata) {
            p->ColUAf = 0;
            break;
        }
    }

    pf = ParsedFile{};  // clear cache
}

// ============================================================
// extern "C" wrappers
// ============================================================

extern "C" {
    void readaffile_pass1_c(const afi_initinputtype_t* InitInp, int NumCoefsIn,
                            afi_parametertype_view_t* p,
                            int* numalf_out, int* ncoefstab_out,
                            int* errStat, char* errMsg) {
        ReadAFfile_pass1(InitInp, NumCoefsIn, p, numalf_out, ncoefstab_out, errStat, errMsg);
    }

    void readaffile_fill_c(afi_parametertype_view_t* p,
                           const afi_initinputtype_t* InitInp, int NumCoefsIn,
                           int* errStat, char* errMsg) {
        ReadAFfile_fill(p, InitInp, NumCoefsIn, errStat, errMsg);
    }
}
