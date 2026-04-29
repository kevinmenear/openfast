#
# Copyright 2016 National Renewable Energy Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if (GENERATE_TYPES)
  generate_f90_types(src/AeroAcoustics_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/AeroAcoustics_Types.f90 -noextrap)
  generate_f90_types(src/AeroDyn_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/AeroDyn_Types.f90)
  generate_f90_types(src/AeroDyn_Inflow_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/AeroDyn_Inflow_Types.f90 -noextrap)
  generate_f90_types(src/AeroDyn_Inflow_C_Binding_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/AeroDyn_Inflow_C_Binding_Types.f90 -noextrap)
  generate_f90_types(src/AirfoilInfo_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/AirfoilInfo_Types.f90 -noextrap)
  generate_f90_types(src/BEMT_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/BEMT_Types.f90)
  generate_f90_types(src/DBEMT_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/DBEMT_Types.f90)
  generate_f90_types(src/UnsteadyAero_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/UnsteadyAero_Types.f90)
  generate_f90_types(src/AeroDyn_Driver_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/AeroDyn_Driver_Types.f90 -noextrap)
  generate_f90_types(src/FVW_Registry.txt ${CMAKE_CURRENT_LIST_DIR}/src/FVW_Types.f90)
endif()

# BasicAero Library
enable_language(CXX)
add_library(basicaerolib STATIC
  # UnsteadyAero lib
  src/UnsteadyAero.f90
  src/UnsteadyAero_Types.f90

  # AirFoil Info lib
  src/AirfoilInfo.f90
  src/AirfoilInfo_Types.f90
  src/vit_nwtc.cpp
  src/calculate_cn.cpp
  src/vit_afi_table_type_view.f90
  src/vit_afi_parametertype_view.f90
  src/findboundingtables.cpp
  src/compute_iloweriupper.cpp
  src/computeua360_cnoffset.cpp
  src/calculate_c_alpha.cpp
  src/computeuaseparationfunction_zero.cpp
  src/computeua360_updatecnseparated.cpp
  src/computeua360_updateseparationf.cpp
  src/computeuaseparationfunction_oncl.cpp
  src/computeua360_attachedflow.cpp
  src/calculateuacoeffs.cpp
  src/afi_validateinitinput.cpp
  src/afi_computeairfoilcoefs.cpp
  src/afi_computeuacoefs.cpp
  src/readaffile.cpp
  src/afi_init.cpp
  src/afi_wrheader.cpp
  src/afi_wrdata.cpp
  src/afi_wrtables.cpp
)
target_link_libraries(basicaerolib ifwlib nwtclibs stdc++)

# AeroAcoustics library
add_library(aeroacousticslib STATIC
  src/AeroAcoustics_TNO.f90
  src/AeroAcoustics.f90
  src/AeroAcoustics_IO.f90
  src/AeroAcoustics_Types.f90
)
target_link_libraries(aeroacousticslib basicaerolib nwtclibs)

# AeroDyn Library
add_library(aerodynlib STATIC
  src/AeroDyn.f90
  src/AeroDyn_IO_Params.f90
  src/AeroDyn_IO.f90
  src/AeroDyn_AllBldNdOuts_IO.f90
  src/BEMT.f90
  src/DBEMT.f90
  src/BEMTUncoupled.f90
  src/mod_root1dim.f90
  src/AeroDyn_Types.f90
  src/BEMT_Types.f90
  src/DBEMT_Types.f90
  src/vit_dbemt_parametertype_view.f90
  src/vit_dbemt_inputtype_view.f90

  # FVW lib
  src/FVW.f90
  src/FVW_IO.f90
  src/FVW_VortexTools.f90
  src/FVW_Wings.f90
  src/FVW_Subs.f90
  src/FVW_BiotSavart.f90
  src/FVW_Tests.f90
  src/FVW_Types.f90
  src/computetau2.cpp
  src/computetau1.cpp
  src/vit_dbemt_otherstatetype_view.f90
  src/vit_dbemt_continuousstatetype_view.f90
  src/dbemt_initstates.cpp
  src/dbemt_calcoutput.cpp
)
# Prevent vectorization changes when function bodies are replaced by C++ wrappers.
# Replacing a module-internal function with a wrapper call changes the loop body size,
# causing gfortran to make different vectorization decisions (scalar exp vs SIMD
# _ZGVnN2v_exp from libmvec, which differ by 1 ULP). The DBEMT exponential filter
# feedback loop amplifies this into full divergence in UA-coupled test cases.
set_source_files_properties(src/DBEMT.f90 PROPERTIES COMPILE_FLAGS "-fno-tree-loop-vectorize")
target_link_libraries(aerodynlib basicaerolib aeroacousticslib seastlib nwtclibs)

# ADI lib
add_library(adilib STATIC
  src/AeroDyn_Inflow.f90
  src/AeroDyn_Inflow_Types.f90
)
target_link_libraries(adilib aerodynlib ifwlib)

# AeroDyn Driver Subs Library
add_library(aerodyn_driver_subs STATIC
  src/AeroDyn_Driver_Subs.f90
  src/AeroDyn_Driver_Types.f90
)
target_link_libraries(aerodyn_driver_subs adilib aerodynlib versioninfolib)

# AeroDyn Driver
add_executable(aerodyn_driver 
  src/AeroDyn_Driver.f90
)
target_link_libraries(aerodyn_driver aerodyn_driver_subs)

# AeroAcoustics driver
add_executable(aeroacoustics_driver
   src/AeroAcoustics_Driver_Subs.f90
   src/AeroAcoustics_Driver.f90
)
target_link_libraries(aeroacoustics_driver aeroacousticslib versioninfolib)

# UnsteadyAero Driver
add_executable(unsteadyaero_driver 
  src/UnsteadyAero_Driver.f90
  src/UA_Dvr_Subs.f90
)
target_link_libraries(unsteadyaero_driver basicaerolib lindynlib versioninfolib)


# AeroDyn-InflowWind c-bindings interface library
#   create object instead of directly linking into shared and static -- causes issues in parallel builds
#   This is only required because we are static linking the library for wavetank
#   NOTE: target linking at the object, static, and shared libraries.  Different CMake versions handle this
#         slightly differently with unpredictable results if I don't.
add_library(aerodyn_inflow_c_binding_object OBJECT
  src/AeroDyn_Inflow_C_Binding_Types.f90
  src/AeroDyn_Inflow_C_Binding.f90
)
target_link_libraries(aerodyn_inflow_c_binding_object adilib aerodyn_driver_subs nwtclibs versioninfolib)
set_property(TARGET aerodyn_inflow_c_binding_object PROPERTY POSITION_INDEPENDENT_CODE 1) # required for shared libs
if(APPLE OR UNIX)
   target_compile_definitions(aerodyn_inflow_c_binding_object PRIVATE IMPLICIT_DLLEXPORT)
endif()

#   shared
add_library(aerodyn_inflow_c_binding SHARED $<TARGET_OBJECTS:aerodyn_inflow_c_binding_object>)
target_link_libraries(aerodyn_inflow_c_binding adilib aerodyn_driver_subs nwtclibs versioninfolib)


# C-bindings non-shared interface
# This is a workaround for building wavetank into a single DLL (also allows setting CU globaly for sending screen to file for labview integration)
add_library(aerodyn_inflow_c_bind_static STATIC $<TARGET_OBJECTS:aerodyn_inflow_c_binding_object>)
target_link_libraries(aerodyn_inflow_c_bind_static adilib aerodyn_driver_subs nwtclibs versioninfolib)
if(APPLE OR UNIX)
   target_compile_definitions(aerodyn_inflow_c_bind_static PRIVATE IMPLICIT_DLLEXPORT)
endif()


install(TARGETS aerodynlib aeroacousticslib basicaerolib aerodyn_driver_subs aerodyn_driver aeroacoustics_driver unsteadyaero_driver aerodyn_inflow_c_binding adilib aerodyn_inflow_c_bind_static
  EXPORT "${CMAKE_PROJECT_NAME}Libraries"
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
