// VIT Test-Validate: AFI_ValidateInitInput
// Tests every error branch. Calls BOTH C++ and Fortran, asserts they agree.

#include <cstdio>
#include <cstring>
#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"
#include "afi_validateinitinput.hpp"

static constexpr int ErrID_None = 0;
static constexpr int ErrID_Fatal = 4;

// Fortran bridge: receives struct as void*, returns ErrStat only
// CHARACTER args are handled locally in the bridge (not exposed to C++)
extern "C" void afi_validateinitinput_f90(void* InitInput_ptr, int* ErrStat);

struct TestResult { const char* name; bool passed; const char* detail; };

afi_initinputtype_t make_valid_input() {
    afi_initinputtype_t input = {};
    input.InCol_Alfa = 1;
    input.InCol_Cl = 1;
    input.InCol_Cd = 1;
    input.InCol_Cm = 0;
    input.InCol_Cpmin = 0;
    input.AFTabMod = AFITable_1;
    return input;
}

struct DualResult { int err_cpp; int err_f90; };

DualResult run_both(afi_initinputtype_t* input) {
    DualResult r;
    char msg_cpp[ErrMsgLen + 1] = {};
    r.err_cpp = 0;
    AFI_ValidateInitInput(input, &r.err_cpp, msg_cpp);
    r.err_f90 = 0;
    afi_validateinitinput_f90(input, &r.err_f90);
    return r;
}

#define TEST(name, setup) \
TestResult test_##name() { \
    auto input = make_valid_input(); \
    setup; \
    auto r = run_both(&input); \
    if (r.err_cpp != r.err_f90) return {#name, false, "C++/Fortran disagree"}; \
    if (r.err_cpp != ErrID_Fatal) return {#name, false, "expected Fatal"}; \
    return {#name, true, ""}; \
}

TestResult test_happy_path() {
    auto input = make_valid_input();
    auto r = run_both(&input);
    if (r.err_cpp != r.err_f90) return {"happy_path", false, "C++/Fortran disagree"};
    if (r.err_cpp != ErrID_None) return {"happy_path", false, "expected ErrStat=0"};
    return {"happy_path", true, ""};
}

TEST(InCol_Alfa_negative, input.InCol_Alfa = -1)
TEST(InCol_Cl_negative, input.InCol_Cl = -1)
TEST(InCol_Cd_negative, input.InCol_Cd = -1)
TEST(InCol_Cm_negative, input.InCol_Cm = -1)
TEST(InCol_Cpmin_negative, input.InCol_Cpmin = -1)
TEST(AFTabMod_invalid, input.AFTabMod = 99)

int main() {
    TestResult tests[] = {
        test_happy_path(),
        test_InCol_Alfa_negative(),
        test_InCol_Cl_negative(),
        test_InCol_Cd_negative(),
        test_InCol_Cm_negative(),
        test_InCol_Cpmin_negative(),
        test_AFTabMod_invalid(),
    };
    int n = sizeof(tests) / sizeof(tests[0]);
    int passed = 0, failed = 0;
    for (int i = 0; i < n; i++) {
        if (tests[i].passed) { passed++; printf("  PASS %s\n", tests[i].name); }
        else { failed++; printf("  FAIL %s: %s\n", tests[i].name, tests[i].detail); }
    }
    printf("\n%d passed, %d failed\n", passed, failed);
    return failed > 0 ? 1 : 0;
}
