// VIT Test-Validate: AFI_Init multi-table validation
// Tests every error branch in pass1. Calls BOTH C++ and Fortran, asserts they agree.

#include <cstdio>
#include <cstring>
#include <cstdint>
#include <cmath>
#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"

// afi_init_pass1_c and afi_init_pass2_c are linked from production libbasicaerolib.a.
// Declare them here rather than #including afi_init.hpp (which has static constants
// that conflict with vit_nwtc.cpp's).
extern "C" {
void afi_init_pass1_c(
    const afi_initinputtype_t* InitInput, afi_parametertype_view_t* p,
    int* n_secondVals_out, double* secondVals_buf,
    int* spline_dim1_out, int* spline_dim2_out,
    int* errStat, char* errMsg);
}

static constexpr int ErrID_None  = 0;
static constexpr int ErrID_Warn  = 2;
static constexpr int ErrID_Fatal = 4;

struct TestResult { const char* name; bool passed; const char* detail; };

// Fortran bridge
extern "C" void afi_init_validate_multitable_f90(
    int NumTabs, int AFTabMod,
    const double* Re_array, const double* UserProp_array,
    const char* filename, int* ErrStat);

struct DualResult { int err_cpp; int err_f90; };

// Populate a filename buffer (space-padded to 1024)
static void fill_filename(char* buf, const char* name) {
    std::memset(buf, ' ', 1024);
    size_t n = std::strlen(name);
    if (n > 1024) n = 1024;
    std::memcpy(buf, name, n);
}

// Call both C++ and Fortran with the same mock data, return both ErrStat values
static DualResult run_both(int NumTabs, int AFTabMod,
                           const double* Re, const double* UserProp,
                           const char* filename) {
    DualResult r;

    // --- C++ side: build view structs and call afi_init_pass1_c ---
    afi_table_type_view_t tables[10] = {};
    for (int i = 0; i < NumTabs; i++) {
        tables[i].Re = Re[i];
        tables[i].UserProp = UserProp[i];
        tables[i].NumAlf = 10;
        tables[i].n_Coefs_cols = 2;
        tables[i].ConstData = 0;
    }

    afi_parametertype_view_t p = {};
    p.NumTabs = NumTabs;
    p.AFTabMod = AFTabMod;
    p.Table = tables;
    p.n_Table = NumTabs;
    fill_filename(p.FileName, filename);

    afi_initinputtype_t initinput = {};
    fill_filename(initinput.FileName, filename);
    initinput.AFTabMod = AFTabMod;

    int n_secondVals = 0;
    double secondVals_buf[100] = {};
    int spline_dim1[100] = {};
    int spline_dim2[100] = {};
    char errMsg_cpp[ErrMsgLen + 1] = {};

    r.err_cpp = 0;
    afi_init_pass1_c(&initinput, &p, &n_secondVals, secondVals_buf,
                     spline_dim1, spline_dim2, &r.err_cpp, errMsg_cpp);

    // --- Fortran side: call bridge with same data ---
    char fname_f90[1024];
    fill_filename(fname_f90, filename);
    r.err_f90 = 0;
    afi_init_validate_multitable_f90(NumTabs, AFTabMod, Re, UserProp,
                                     fname_f90, &r.err_f90);

    return r;
}

// --- Test cases ---

TestResult test_happy_path_2re() {
    double Re[] = {1e5, 2e5, 3e5};
    double UserProp[] = {0.0, 0.0, 0.0};
    auto r = run_both(3, AFITable_2Re, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"happy_path_2re", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_None) return {"happy_path_2re", false, "expected ErrStat=0"};
    return {"happy_path_2re", true, ""};
}

TestResult test_happy_path_2user() {
    double Re[] = {1e5, 1e5, 1e5};
    double UserProp[] = {0.1, 0.2, 0.3};
    auto r = run_both(3, AFITable_2User, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"happy_path_2user", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_None) return {"happy_path_2user", false, "expected ErrStat=0"};
    return {"happy_path_2user", true, ""};
}

TestResult test_happy_path_single_table() {
    double Re[] = {1e5};
    double UserProp[] = {0.0};
    auto r = run_both(1, AFITable_1, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"happy_path_single_table", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_None) return {"happy_path_single_table", false, "expected ErrStat=0"};
    return {"happy_path_single_table", true, ""};
}

TestResult test_warn_multitab_aftabmod1() {
    double Re[] = {1e5, 2e5, 3e5};
    double UserProp[] = {0.0, 0.0, 0.0};
    auto r = run_both(3, AFITable_1, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"warn_multitab_aftabmod1", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Warn) return {"warn_multitab_aftabmod1", false, "expected ErrStat=Warn"};
    return {"warn_multitab_aftabmod1", true, ""};
}

TestResult test_fatal_userprop_mismatch_2re() {
    double Re[] = {1e5, 2e5, 3e5};
    double UserProp[] = {0.0, 0.5, 0.0};  // Table 2 has different UserProp
    auto r = run_both(3, AFITable_2Re, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"fatal_userprop_mismatch_2re", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Fatal) return {"fatal_userprop_mismatch_2re", false, "expected Fatal"};
    return {"fatal_userprop_mismatch_2re", true, ""};
}

TestResult test_fatal_negative_re_2re() {
    double Re[] = {1e5, -1.0, 3e5};  // Table 2 has negative Re
    double UserProp[] = {0.0, 0.0, 0.0};
    auto r = run_both(3, AFITable_2Re, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"fatal_negative_re_2re", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Fatal) return {"fatal_negative_re_2re", false, "expected Fatal"};
    return {"fatal_negative_re_2re", true, ""};
}

TestResult test_fatal_nonmonotonic_re_2re() {
    double Re[] = {1e5, 3e5, 2e5};  // Out of order
    double UserProp[] = {0.0, 0.0, 0.0};
    auto r = run_both(3, AFITable_2Re, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"fatal_nonmonotonic_re_2re", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Fatal) return {"fatal_nonmonotonic_re_2re", false, "expected Fatal"};
    return {"fatal_nonmonotonic_re_2re", true, ""};
}

TestResult test_fatal_duplicate_re_2re() {
    double Re[] = {1e5, 2e5, 2e5};  // Duplicate
    double UserProp[] = {0.0, 0.0, 0.0};
    auto r = run_both(3, AFITable_2Re, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"fatal_duplicate_re_2re", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Fatal) return {"fatal_duplicate_re_2re", false, "expected Fatal"};
    return {"fatal_duplicate_re_2re", true, ""};
}

TestResult test_fatal_re_mismatch_2user() {
    double Re[] = {1e5, 2e5, 1e5};  // Table 2 has different Re
    double UserProp[] = {0.1, 0.2, 0.3};
    auto r = run_both(3, AFITable_2User, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"fatal_re_mismatch_2user", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Fatal) return {"fatal_re_mismatch_2user", false, "expected Fatal"};
    return {"fatal_re_mismatch_2user", true, ""};
}

TestResult test_fatal_nonmonotonic_userprop_2user() {
    double Re[] = {1e5, 1e5, 1e5};
    double UserProp[] = {0.1, 0.3, 0.2};  // Out of order
    auto r = run_both(3, AFITable_2User, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"fatal_nonmonotonic_userprop_2user", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Fatal) return {"fatal_nonmonotonic_userprop_2user", false, "expected Fatal"};
    return {"fatal_nonmonotonic_userprop_2user", true, ""};
}

TestResult test_fatal_duplicate_userprop_2user() {
    double Re[] = {1e5, 1e5, 1e5};
    double UserProp[] = {0.1, 0.2, 0.2};  // Duplicate
    auto r = run_both(3, AFITable_2User, Re, UserProp, "test.dat");
    if (r.err_cpp != r.err_f90) return {"fatal_duplicate_userprop_2user", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_Fatal) return {"fatal_duplicate_userprop_2user", false, "expected Fatal"};
    return {"fatal_duplicate_userprop_2user", true, ""};
}

// --- Test runner ---

int main() {
    TestResult tests[] = {
        test_happy_path_2re(),
        test_happy_path_2user(),
        test_happy_path_single_table(),
        test_warn_multitab_aftabmod1(),
        test_fatal_userprop_mismatch_2re(),
        test_fatal_negative_re_2re(),
        test_fatal_nonmonotonic_re_2re(),
        test_fatal_duplicate_re_2re(),
        test_fatal_re_mismatch_2user(),
        test_fatal_nonmonotonic_userprop_2user(),
        test_fatal_duplicate_userprop_2user(),
    };

    int n = sizeof(tests) / sizeof(tests[0]);
    int passed = 0, failed = 0;
    for (int i = 0; i < n; i++) {
        if (tests[i].passed) {
            passed++;
            printf("  PASS %s\n", tests[i].name);
        } else {
            failed++;
            printf("  FAIL %s: %s\n", tests[i].name, tests[i].detail);
        }
    }
    printf("\n%d/%d passed\n", passed, n);
    return failed > 0 ? 1 : 0;
}
