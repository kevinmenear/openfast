// VIT Translation
// Function: AFI_WrData
// Source: AirfoilInfo.f90
// Module: AirfoilInfo
// Fortran: SUBROUTINE AFI_WrData(k, unOutFile, delim, AFInfo)
// Verification: file-output

#include "vit_types.h"
#include "vit_nwtc.h"

#include <cstdio>
#include <cstring>
#include <string>

extern "C" {

void afi_wrdata_c(int k, const char* filename, const char* delim,
                  afi_parametertype_view_t* p) {
    FILE* f = fopen(filename, "a");
    if (!f) return;

    for (int i = 0; i < p->n_Table; i++) {
        const afi_table_type_view_t* tab = &p->Table[i];

        fprintf(f, "%17d%s%17d", k, delim, i + 1);

        if (tab->InclUAdata) {
            const afi_ua_bl_type_t* bl = &tab->UA_BL;
            double vals[44] = {
                bl->alpha0 * R2D,
                bl->alpha1 * R2D,
                bl->alpha2 * R2D,
                bl->eta_e,
                bl->C_nalpha,
                bl->C_lalpha,
                bl->T_f0,
                bl->T_V0,
                bl->T_p,
                bl->T_VL,
                bl->b1,
                bl->b2,
                bl->b5,
                bl->A1,
                bl->A2,
                bl->A5,
                bl->S1,
                bl->S2,
                bl->S3,
                bl->S4,
                bl->Cn1,
                bl->Cn2,
                bl->St_sh,
                bl->Cd0,
                bl->Cm0,
                bl->k0,
                bl->k1,
                bl->k2,
                bl->k3,
                bl->k1_hat,
                bl->x_cp_bar,
                bl->UACutout * R2D,
                bl->UACutout_delta * R2D,
                bl->UACutout_blend * R2D,
                bl->filtCutOff,
                bl->alphaLower * R2D,
                bl->alphaUpper * R2D,
                bl->c_alphaLower,
                bl->c_alphaUpper,
                bl->alpha0ReverseFlow * R2D,
                bl->alphaBreakUpper * R2D,
                bl->CnBreakUpper,
                bl->alphaBreakLower * R2D,
                bl->CnBreakLower,
            };
            for (int j = 0; j < 44; j++) {
                fprintf(f, "%s%17.5f", delim, vals[j]);
            }
        } else {
            for (int j = 0; j < 44; j++) {
                fprintf(f, "%s%17.5f", delim, 0.0);
            }
        }
        fprintf(f, "\n");
    }

    fclose(f);
}

} // extern "C"
