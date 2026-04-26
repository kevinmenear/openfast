// VIT Test-Validate: AFI_ValidateInitInput
// Tests every error branch in the C++ translation.
// Note: AFI_ValidateInitInput is PRIVATE in the AirfoilInfo module,
// so Fortran-side comparison is not possible. C++-only testing.
// Production verification via 16/16 baselines after integration.

#include <cstdio>
#include <cstring>
#include "vit_types.h"
#include "vit_nwtc.h"
#include "vit_aerodyn_constants.h"
#include "afi_validateinitinput.hpp"

static constexpr int ErrID_None = 0;
static constexpr int ErrID_Fatal = 4;

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

TestResult run_test(const char* name, afi_initinputtype_t* input, int expected_err) {
    int ErrStat = 0;
    char ErrMsg[ErrMsgLen + 1] = {};
    AFI_ValidateInitInput(input, &ErrStat, ErrMsg);
    if (ErrStat != expected_err) {
        static char detail[256];
        snprintf(detail, sizeof(detail), "expected ErrStat=%d, got %d", expected_err, ErrStat);
        return {name, false, detail};
    }
    return {name, true, ""};
}

#define TEST_ERROR(name, setup) \
TestResult test_##name() { \
    auto input = make_valid_input(); \
    setup; \
    return run_test(#name, &input, ErrID_Fatal); \
}

TestResult test_happy_path() {
    auto input = make_valid_input();
    return run_test("happy_path", &input, ErrID_None);
}

TEST_ERROR(InCol_Alfa_negative, input.InCol_Alfa = -1)
TEST_ERROR(InCol_Cl_negative, input.InCol_Cl = -1)
TEST_ERROR(InCol_Cd_negative, input.InCol_Cd = -1)
TEST_ERROR(InCol_Cm_negative, input.InCol_Cm = -1)
TEST_ERROR(InCol_Cpmin_negative, input.InCol_Cpmin = -1)
TEST_ERROR(AFTabMod_invalid, input.AFTabMod = 99)

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
