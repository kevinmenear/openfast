// VIT File-Output Test: AFI_WrHeader + AFI_WrData
// Calls both C++ and Fortran with identical mock data, diffs output files.

#include <cstdio>
#include <cstring>
#include <cstdint>
#include <string>
#include <fstream>
#include <vector>
#include "vit_types.h"
#include "vit_nwtc.h"

// C++ functions (from production library)
extern "C" {
void afi_wrheader_c(const char* delim, const char* filename, int* errStat, char* errMsg);
void afi_wrdata_c(int k, const char* filename, const char* delim, afi_parametertype_view_t* p);

// Fortran bridge
void afi_wrheaderdata_f90(const char* filename, const char* delim,
                          int NumAirfoils, int NumTabs_per_airfoil,
                          const int* InclUAdata, const double* Re_vals,
                          const double* UserProp_vals, const double* alpha0_vals,
                          const double* Cn1_vals);
}

static afi_ua_bl_type_t make_mock_ua_bl(double alpha0, double Cn1) {
    afi_ua_bl_type_t bl = {};
    bl.alpha0 = alpha0;
    bl.alpha1 = 0.2; bl.alpha2 = -0.2; bl.eta_e = 0.95;
    bl.C_nalpha = 6.28; bl.C_lalpha = 6.28;
    bl.T_f0 = 3.0; bl.T_V0 = 6.0; bl.T_p = 1.7; bl.T_VL = 11.0;
    bl.b1 = 0.14; bl.b2 = 0.53; bl.b5 = 5.0;
    bl.A1 = 0.3; bl.A2 = 0.7; bl.A5 = 1.0;
    bl.S1 = 0.0; bl.S2 = 0.0; bl.S3 = 0.0; bl.S4 = 0.0;
    bl.Cn1 = Cn1; bl.Cn2 = -0.5; bl.St_sh = 0.19;
    bl.Cd0 = 0.01; bl.Cm0 = -0.05;
    bl.k0 = 0.0; bl.k1 = 0.0; bl.k2 = 0.0; bl.k3 = 0.0;
    bl.k1_hat = 0.0; bl.x_cp_bar = 0.25;
    bl.UACutout = 0.524; bl.UACutout_delta = 0.087; bl.UACutout_blend = 0.0;
    bl.filtCutOff = 0.5;
    bl.alphaLower = -0.1; bl.alphaUpper = 0.3;
    bl.c_alphaLower = 0.0; bl.c_alphaUpper = 0.0;
    bl.alpha0ReverseFlow = 0.0;
    bl.alphaBreakUpper = 0.25; bl.CnBreakUpper = 1.2;
    bl.alphaBreakLower = -0.15; bl.CnBreakLower = -0.8;
    return bl;
}

static bool is_skip_line(const std::string& line) {
    if (line.find("generated on") != std::string::npos) return true;
    if (line.find("Predictions were") != std::string::npos) return true;
    // ProgName line: Fortran writes blank (uninitialized global), C++ writes "AeroDyn"
    std::string trimmed = line;
    while (!trimmed.empty() && trimmed.back() == ' ') trimmed.pop_back();
    while (!trimmed.empty() && trimmed.front() == ' ') trimmed.erase(trimmed.begin());
    if (trimmed.empty() || trimmed == "AeroDyn") return true;
    return false;
}

static bool diff_files_skip_timestamps(const char* file1, const char* file2,
                                        int& total_lines, int& diff_lines) {
    std::ifstream f1(file1), f2(file2);
    if (!f1.is_open() || !f2.is_open()) return false;

    std::string line1, line2;
    total_lines = 0; diff_lines = 0;

    while (true) {
        bool has1 = (bool)std::getline(f1, line1);
        bool has2 = (bool)std::getline(f2, line2);
        if (!has1 && !has2) break;
        if (has1 != has2) { diff_lines++; total_lines++; continue; }
        total_lines++;
        if (is_skip_line(line1) || is_skip_line(line2)) continue;
        // Trim trailing whitespace before comparing (Fortran WRITE may add trailing spaces)
        auto rtrim = [](std::string s) {
            while (!s.empty() && (s.back() == ' ' || s.back() == '\t')) s.pop_back();
            return s;
        };
        if (rtrim(line1) != rtrim(line2)) diff_lines++;
    }
    return diff_lines == 0;
}

int main() {
    const char* cpp_file = "/tmp/afi_wrheaderdata_cpp.dat";
    const char* f90_file = "/tmp/afi_wrheaderdata_f90.dat";
    const char* delim = " ";
    int NumAirfoils = 2;
    int NumTabs = 1;

    // Mock data arrays (flat: [airfoil1_tab1, airfoil2_tab1])
    int InclUAdata[] = {1, 1};
    double Re_vals[] = {1e5, 2e5};
    double UserProp_vals[] = {0.0, 0.0};
    double alpha0_vals[] = {0.05, 0.07};
    double Cn1_vals[] = {1.5, 1.3};

    // --- C++ side ---
    int errStat = 0;
    char errMsg[ErrMsgLen + 1] = {};
    afi_wrheader_c(delim, cpp_file, &errStat, errMsg);
    if (errStat >= 4) {
        printf("  FAIL C++ WrHeader error: errStat=%d\n", errStat);
        return 1;
    }

    for (int k = 0; k < NumAirfoils; k++) {
        afi_table_type_view_t tab = {};
        tab.InclUAdata = InclUAdata[k];
        tab.Re = Re_vals[k];
        tab.UserProp = UserProp_vals[k];
        tab.UA_BL = make_mock_ua_bl(alpha0_vals[k], Cn1_vals[k]);

        afi_parametertype_view_t p = {};
        p.Table = &tab;
        p.n_Table = 1;
        p.NumTabs = 1;

        afi_wrdata_c(k + 1, cpp_file, delim, &p);
    }

    // --- Fortran side ---
    afi_wrheaderdata_f90(f90_file, delim, NumAirfoils, NumTabs,
                         InclUAdata, Re_vals, UserProp_vals,
                         alpha0_vals, Cn1_vals);

    // --- Diff ---
    int total_lines = 0, diff_lines = 0;
    bool match = diff_files_skip_timestamps(cpp_file, f90_file, total_lines, diff_lines);

    if (match) {
        printf("  PASS AFI_WrHeader+WrData: %d data lines identical (timestamps skipped)\n", total_lines);
        return 0;
    } else {
        printf("  FAIL AFI_WrHeader+WrData: %d/%d lines differ\n", diff_lines, total_lines);
        printf("  C++:     %s\n  Fortran: %s\n", cpp_file, f90_file);
        return 1;
    }
}
