// VIT Translation Scaffold
// Function: Calculate_C_alpha
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE Calculate_C_alpha(alpha, Cn, Cl, Default_Cn_alpha, Default_Cl_alpha, Default_alpha0, ErrStat, ErrMsg)
// Source MD5: a4b4ad883b48
// VIT: 0.1.0
// Status: unverified
// Generated: 2026-04-25T15:36:21Z

#include <cstdio>
#include <cstring>
#include <vector>
#include "vit_nwtc.h"

// LAPACK dgels_ external (Fortran calling convention)
extern "C" {
    void dgels_(const char* trans, const int* m, const int* n, const int* nrhs,
                double* a, const int* lda, double* b, const int* ldb,
                double* work, const int* lwork, int* info);
}

void Calculate_C_alpha(double* alpha, int n_alpha, double* Cn, int n_Cn,
                       double* Cl, int n_Cl,
                       double* Default_Cn_alpha, double* Default_Cl_alpha,
                       double* Default_alpha0, int* ErrStat, char* ErrMsg) {
    constexpr int ErrID_None = 0;
    constexpr int ErrID_Fatal = 4;

    // Early return if not enough data
    if (n_Cn < 2 || n_Cl < 2) {
        const char* msg = "Calculate_C_alpha: Not enough data points to compute Cn and Cl slopes.";
        std::memset(ErrMsg, ' ', 1024);
        std::memcpy(ErrMsg, msg, std::strlen(msg));
        *ErrStat = ErrID_Fatal;
        *Default_Cn_alpha = std::numeric_limits<double>::epsilon();
        *Default_Cl_alpha = std::numeric_limits<double>::epsilon();
        *Default_alpha0 = 0.0;
        return;
    }

    int M = n_alpha;
    int N = 2;
    int NRHS = 2;
    int LDA = M;
    int LDB = std::max(2, M);

    // A is M x 2, column-major: col 0 = alpha, col 1 = 1.0
    std::vector<double> A(LDA * N);
    for (int i = 0; i < M; i++) {
        A[i]       = alpha[i];   // Column 0
        A[i + LDA] = 1.0;       // Column 1
    }

    // B is max(2,M) x 2, column-major: col 0 = Cn, col 1 = Cl
    std::vector<double> B(LDB * NRHS, 0.0);
    if (n_Cn == 1) {
        for (int i = 0; i < LDB; i++) {
            B[i]       = Cn[0];
            B[i + LDB] = Cl[0];
        }
    } else {
        for (int i = 0; i < M; i++) {
            B[i]       = Cn[i];
            B[i + LDB] = Cl[i];
        }
    }

    // Workspace query
    double work_size;
    int lwork = -1;
    int info = 0;
    dgels_("N", &M, &N, &NRHS, A.data(), &LDA, B.data(), &LDB, &work_size, &lwork, &info);

    lwork = static_cast<int>(work_size);
    std::vector<double> work(lwork);

    // Solve
    dgels_("N", &M, &N, &NRHS, A.data(), &LDA, B.data(), &LDB, work.data(), &lwork, &info);

    if (info != 0) {
        char buf[256];
        if (info < 0) {
            std::snprintf(buf, sizeof(buf),
                "LAPACK_DGELS: Illegal value in argument %d.", -info);
        } else {
            std::snprintf(buf, sizeof(buf),
                "LAPACK_DGELS: Diagonal element %d of triangular factor is zero.", info);
        }
        std::memset(ErrMsg, ' ', 1024);
        std::memcpy(ErrMsg, buf, std::strlen(buf));
        *ErrStat = ErrID_Fatal;
        *Default_Cn_alpha = 0.0;
        *Default_Cl_alpha = 0.0;
        *Default_alpha0 = 0.0;
        return;
    }

    // Success
    *ErrStat = ErrID_None;
    // Fortran blank-fills CHARACTER buffers on assignment; match that behavior
    std::memset(ErrMsg, ' ', 1024);

    // B(1,1) = Cn_alpha, B(1,2) = Cl_alpha (0-indexed: B[0], B[LDB])
    *Default_Cn_alpha = B[0];
    *Default_Cl_alpha = B[LDB];

    // alpha0 = -B(2,1)/B(1,1) if B(1,1) != 0
    if (!EqualRealNos(B[0], 0.0)) {
        *Default_alpha0 = -B[1] / B[0];
    } else {
        *Default_alpha0 = 0.0;
    }
}
