// VIT File-Output Test: AFI_WrTables
// Calls both C++ and Fortran with identical mock data, diffs output files.

#include <cstdio>
#include <cstring>
#include <cmath>
#include <string>
#include <fstream>
#include <vector>
#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"

extern "C" {
void afi_wrtables_c(afi_parametertype_view_t* p, int UAMod, const char* OutRootName);

void afi_wrtables_f90(int NumAlf, int NumCoefCols, int ColCl, int ColCd, int ColCm, int ColUAf,
                      int UAMod, const double* Alpha_array, const double* Coefs_array,
                      const char* OutRootName);
}

static bool is_skip_line(const std::string& line) {
    if (line.find("generated") != std::string::npos) return true;
    if (line.find("Predictions") != std::string::npos) return true;
    if (line.find("AirfoilInfo") != std::string::npos) return true;
    // Skip column header lines (contain Alpha, Cl, (deg), (-) etc.)
    if (line.find("Alpha") != std::string::npos) return true;
    if (line.find("(deg)") != std::string::npos) return true;
    // Skip blank/whitespace lines
    std::string trimmed = line;
    while (!trimmed.empty() && trimmed.back() == ' ') trimmed.pop_back();
    while (!trimmed.empty() && trimmed.front() == ' ') trimmed.erase(trimmed.begin());
    if (trimmed.empty()) return true;
    return false;
}

static std::string rtrim(std::string s) {
    while (!s.empty() && (s.back() == ' ' || s.back() == '\t')) s.pop_back();
    return s;
}

static std::vector<std::string> read_data_lines(const char* filename) {
    std::vector<std::string> lines;
    std::ifstream f(filename);
    std::string line;
    while (std::getline(f, line)) {
        if (!is_skip_line(line)) lines.push_back(rtrim(line));
    }
    return lines;
}

static bool diff_files(const char* file1, const char* file2,
                       int& total_lines, int& diff_lines, std::string& first_diff) {
    auto lines1 = read_data_lines(file1);
    auto lines2 = read_data_lines(file2);

    total_lines = (int)std::max(lines1.size(), lines2.size());
    diff_lines = 0;

    size_t n = std::max(lines1.size(), lines2.size());
    for (size_t i = 0; i < n; i++) {
        std::string l1 = (i < lines1.size()) ? lines1[i] : "";
        std::string l2 = (i < lines2.size()) ? lines2[i] : "";
        if (l1 != l2) {
            diff_lines++;
            if (first_diff.empty()) {
                first_diff = "data line " + std::to_string(i + 1) + ":\n  C++: " +
                             l1.substr(0, 80) + "\n  F90: " + l2.substr(0, 80);
            }
        }
    }
    return diff_lines == 0;
}

int main() {
    const char* cpp_root = "/tmp/wrtables_cpp";
    const char* f90_root = "/tmp/wrtables_f90";

    int NumAlf = 5;
    int NumCoefCols = 7;
    int ColCl = 1, ColCd = 2, ColCm = 3, ColUAf = 5;
    int UAMod = UA_HGM;

    double Alpha[] = {-0.2, -0.1, 0.0, 0.1, 0.2};

    // Column-major Coefs: Coefs[col * NumAlf + row]
    double Coefs[7 * 5];
    // Col 1 (Cl): index 0-4
    Coefs[0*5+0] = 0.5; Coefs[0*5+1] = 0.8; Coefs[0*5+2] = 1.0; Coefs[0*5+3] = 0.8; Coefs[0*5+4] = 0.5;
    // Col 2 (Cd): index 5-9
    Coefs[1*5+0] = 0.02; Coefs[1*5+1] = 0.015; Coefs[1*5+2] = 0.01; Coefs[1*5+3] = 0.015; Coefs[1*5+4] = 0.02;
    // Col 3 (Cm): index 10-14
    Coefs[2*5+0] = -0.05; Coefs[2*5+1] = -0.04; Coefs[2*5+2] = -0.03; Coefs[2*5+3] = -0.04; Coefs[2*5+4] = -0.05;
    // Col 4 (Cpmin): index 15-19
    Coefs[3*5+0] = 0.0; Coefs[3*5+1] = 0.0; Coefs[3*5+2] = 0.0; Coefs[3*5+3] = 0.0; Coefs[3*5+4] = 0.0;
    // Col 5 (f_st): index 20-24
    Coefs[4*5+0] = 0.9; Coefs[4*5+1] = 0.95; Coefs[4*5+2] = 1.0; Coefs[4*5+3] = 0.95; Coefs[4*5+4] = 0.9;
    // Col 6 (FullySep): index 25-29
    Coefs[5*5+0] = 0.1; Coefs[5*5+1] = 0.15; Coefs[5*5+2] = 0.2; Coefs[5*5+3] = 0.15; Coefs[5*5+4] = 0.1;
    // Col 7 (FullyAtt): index 30-34
    Coefs[6*5+0] = 0.8; Coefs[6*5+1] = 0.85; Coefs[6*5+2] = 0.9; Coefs[6*5+3] = 0.85; Coefs[6*5+4] = 0.8;

    // --- C++ side ---
    afi_ua_bl_type_t ua_bl = {};
    ua_bl.alpha0 = 0.0; ua_bl.alpha1 = 0.2; ua_bl.alpha2 = -0.2;
    ua_bl.C_nalpha = 6.28; ua_bl.C_lalpha = 6.28; ua_bl.Cd0 = 0.01;
    ua_bl.alphaBreakLower = -0.15; ua_bl.alphaBreakUpper = 0.15;
    ua_bl.Cn1 = 1.5; ua_bl.Cn2 = -0.5;

    afi_table_type_view_t tab = {};
    tab.NumAlf = NumAlf;
    tab.InclUAdata = 1;
    tab.Alpha = Alpha;
    tab.n_Alpha = NumAlf;
    tab.Coefs = Coefs;
    tab.n_Coefs_rows = NumAlf;
    tab.n_Coefs_cols = NumCoefCols;
    tab.UA_BL = ua_bl;

    afi_parametertype_view_t p = {};
    p.ColCl = ColCl; p.ColCd = ColCd; p.ColCm = ColCm; p.ColUAf = ColUAf;
    p.NumTabs = 1; p.n_Table = 1;
    p.Table = &tab;

    // Pad OutRootName to 1024 chars (C++ afi_wrtables_c trims trailing spaces)
    char cpp_root_padded[1024];
    std::memset(cpp_root_padded, ' ', 1024);
    std::memcpy(cpp_root_padded, cpp_root, std::strlen(cpp_root));

    afi_wrtables_c(&p, UAMod, cpp_root_padded);

    // --- Fortran side ---
    // Null-terminated root name for Fortran bridge
    char f90_root_nt[256];
    snprintf(f90_root_nt, sizeof(f90_root_nt), "%s%c", f90_root, '\0');

    afi_wrtables_f90(NumAlf, NumCoefCols, ColCl, ColCd, ColCm, ColUAf,
                     UAMod, Alpha, Coefs, f90_root_nt);

    // --- Diff output files (table 1) ---
    std::string cpp_file = std::string(cpp_root) + ".Coefs.1.out";
    std::string f90_file = std::string(f90_root) + ".Coefs.1.out";

    int total_lines = 0, diff_lines = 0;
    std::string first_diff;
    bool match = diff_files(cpp_file.c_str(), f90_file.c_str(), total_lines, diff_lines, first_diff);

    if (match) {
        printf("  PASS AFI_WrTables: %d data lines identical (timestamps/blanks skipped)\n", total_lines);
        return 0;
    } else {
        printf("  FAIL AFI_WrTables: %d/%d lines differ\n", diff_lines, total_lines);
        if (!first_diff.empty()) printf("  First diff: %s\n", first_diff.c_str());
        printf("  C++:     %s\n  Fortran: %s\n", cpp_file.c_str(), f90_file.c_str());
        return 1;
    }
}
