// AeroDyn-specific constants from AirfoilInfo_Types.f90 (Registry-generated).
// Used by translated AeroDyn functions that branch on UA model or table mode.
//
// Source: modules/aerodyn/src/AirfoilInfo_Types.f90, lines 36-47

#ifndef VIT_AERODYN_CONSTANTS_H
#define VIT_AERODYN_CONSTANTS_H

// Airfoil table interpolation modes (AFTabMod)
static constexpr int AFITable_1     = 1;  // 1D interpolation on AoA
static constexpr int AFITable_2Re   = 2;  // 2D on AoA and Re
static constexpr int AFITable_2User = 3;  // 2D on AoA and UserProp

// UA (Unsteady Aerodynamics) model selector (UAMod)
static constexpr int UA_None          = 0;
static constexpr int UA_Baseline      = 1;
static constexpr int UA_Gonzalez      = 2;
static constexpr int UA_MinnemaPierce = 3;
static constexpr int UA_HGM           = 4;
static constexpr int UA_HGMV          = 5;
static constexpr int UA_Oye           = 6;
static constexpr int UA_BV            = 7;
static constexpr int UA_HGMV360       = 8;

#endif // VIT_AERODYN_CONSTANTS_H
