FC_0 ?= gfortran
FC_FLAGS_SET_0 ?= -O2 -ffree-form -ffree-line-length-none -cpp -fdefault-real-8 -fdefault-double-8 -ffp-contract=off
# Makefile for KGEN-generated kernel


ALL_OBJS := vit_afi_table_type_view.o vit_nwtc.o compute_iloweriupper.o AirfoilInfo.o AirfoilInfo_Types.o NWTC_Library.o NWTC_Library_Types.o SingPrec.o kernel_driver.o kgen_utils.o tprof_mod.o

# VIT: C++ compilation support
CXX ?= g++
CXXFLAGS ?= -O2 -fPIC -ffp-contract=off

compute_iloweriupper.o: compute_iloweriupper.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

vit_nwtc.o: vit_nwtc.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# VIT: view populator module
vit_afi_table_type_view.o: vit_afi_table_type_view.f90 AirfoilInfo_Types.o
	$(FC_0) $(FC_FLAGS_SET_0) -c $< -o $@

build: ${ALL_OBJS}
	${FC_0} ${FC_FLAGS_SET_0} -o kernel.exe $^ -lstdc++

run: build
	./kernel.exe

AirfoilInfo.o: AirfoilInfo.f90 AirfoilInfo_Types.o NWTC_Library.o NWTC_Library_Types.o SingPrec.o kgen_utils.o tprof_mod.o vit_afi_table_type_view.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

AirfoilInfo_Types.o: AirfoilInfo_Types.f90 kgen_utils.o tprof_mod.o NWTC_Library.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

NWTC_Library.o: NWTC_Library.f90 kgen_utils.o tprof_mod.o NWTC_Library_Types.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

NWTC_Library_Types.o: NWTC_Library_Types.f90 kgen_utils.o tprof_mod.o SingPrec.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

SingPrec.o: SingPrec.f90 kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kernel_driver.o: kernel_driver.f90 AirfoilInfo.o AirfoilInfo_Types.o NWTC_Library.o NWTC_Library_Types.o SingPrec.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kgen_utils.o: kgen_utils.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

tprof_mod.o: tprof_mod.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

clean:
	rm -f kernel.exe *.mod ${ALL_OBJS}
