// VIT Translation
// Function: AFI_WrHeader
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE AFI_WrHeader(delim, FileName, unOutFile, ErrStat, ErrMsg)
// Verification: file-output

#include "vit_types.h"
#include "vit_nwtc.h"

#include <cstdio>
#include <cstring>
#include <ctime>
#include <string>

static constexpr int NumChans = 46;

static const char* ChanName[NumChans] = {
    "AirfoilNumber", "TableNumber",
    "alpha0", "alpha1", "alpha2", "eta_e", "C_nalpha", "C_lalpha",
    "T_f0", "T_V0", "T_p", "T_VL", "b1", "b2", "b5",
    "A1", "A2", "A5", "S1", "S2", "S3", "S4",
    "Cn1", "Cn2", "St_sh", "Cd0", "Cm0",
    "k0", "k1", "k2", "k3", "k1_hat", "x_cp_bar",
    "UACutout", "UACutout_delta", "UACutout_blend", "filtCutOff",
    "alphaLower", "alphaUpper", "c_alphaLower", "c_alphaUpper",
    "alpha0ReverseFlow", "alphaBreakUpper", "CnBreakUpper",
    "alphaBreakLower", "CnBreakLower",
};

static const char* ChanUnit[NumChans] = {
    "(-)", "(-)",
    "(deg)", "(deg)", "(deg)", "(-)", "(-/rad)", "(-/rad)",
    "(-)", "(-)", "(-)", "(-)", "(-)", "(-)", "(-)",
    "(-)", "(-)", "(-)", "(-)", "(-)", "(-)", "(-)",
    "(-)", "(-)", "(-)", "(-)", "(-)",
    "(-)", "(-)", "(-)", "(-)", "(-)", "(-)",
    "(deg)", "(deg)", "(deg)", "(-)",
    "(deg)", "(deg)", "(-)", "(-)",
    "(deg)", "(deg)", "(-)",
    "(deg)", "(-)",
};

extern "C" {

void afi_wrheader_c(const char* delim, const char* filename,
                    int* errStat, char* errMsg) {
    *errStat = ErrID_None;
    std::memset(errMsg, ' ', ErrMsgLen);

    FILE* f = fopen(filename, "w");
    if (!f) {
        *errStat = ErrID_Fatal;
        setErrMsg(errMsg, std::string("AFI_WrHeader: Cannot open file: ") + filename);
        return;
    }

    // Timestamp header (matches Fortran: blank line, date/time, program name, 3 blank lines)
    time_t now = time(nullptr);
    struct tm* t = localtime(&now);
    static const char* months[] = {"Jan","Feb","Mar","Apr","May","Jun",
                                    "Jul","Aug","Sep","Oct","Nov","Dec"};
    char datebuf[32], timebuf[16];
    snprintf(datebuf, sizeof(datebuf), "%02d-%s-%04d", t->tm_mday, months[t->tm_mon], t->tm_year + 1900);
    snprintf(timebuf, sizeof(timebuf), "%02d:%02d:%02d", t->tm_hour, t->tm_min, t->tm_sec);

    fprintf(f, "\nPredictions were generated on %s at %s\n", datebuf, timebuf);
    fprintf(f, " AeroDyn\n");
    fprintf(f, "\n");
    fprintf(f, "\n");
    fprintf(f, "\n");

    // Channel names (WrFileNR pattern: first name, then delim+name for rest)
    // Fortran uses CHARACTER(17) which left-pads shorter strings with spaces
    static constexpr int MaxLen = 17;
    auto writePadded = [&](const char* str) {
        int len = (int)std::strlen(str);
        int pad = MaxLen - len;
        fputs(str, f);
        for (int j = 0; j < pad; j++) fputc(' ', f);
    };

    writePadded(ChanName[0]);
    for (int i = 1; i < NumChans; i++) {
        fputs(delim, f);
        writePadded(ChanName[i]);
    }
    fprintf(f, "\n");

    writePadded(ChanUnit[0]);
    for (int i = 1; i < NumChans; i++) {
        fputs(delim, f);
        writePadded(ChanUnit[i]);
    }
    fprintf(f, "\n");

    fclose(f);
}

} // extern "C"
