# VIT test-validate Makefile for AirfoilInfo functions
# Build against production libraries — no project rebuild needed.

FC = gfortran
CXX = g++
FC_FLAGS = -fPIC -ffree-line-length-none -cpp -fdefault-real-8 -fdefault-double-8 -ffp-contract=off -DOPENFAST_DOUBLE_PRECISION -DHAS_FORTRAN2008_FEATURES \
           -I. -I/workspace/openfast/build/ftnmods -J.
CXX_FLAGS = -O2 -fPIC -ffp-contract=off -I. -I/workspace/openfast/modules/aerodyn/src

# Libraries derived from CMake target (link order preserved)
LIBS = /workspace/openfast/build/modules/aerodyn/libaerodyn_driver_subs.a \
       /workspace/openfast/build/modules/aerodyn/libadilib.a \
       /workspace/openfast/build/modules/aerodyn/libaerodynlib.a \
       /workspace/openfast/build/modules/aerodyn/libaeroacousticslib.a \
       /workspace/openfast/build/modules/aerodyn/libbasicaerolib.a \
       -lstdc++ \
       /workspace/openfast/build/modules/seastate/libseastlib.a \
       /workspace/openfast/build/modules/inflowwind/libifwlib.a \
       /workspace/openfast/build/modules/version/libversioninfolib.a \
       /workspace/openfast/build/modules/nwtc-library/libnwtclibs.a \
       /usr/lib/aarch64-linux-gnu/libopenblas.so \
       -lm \
       -ldl \
       -ldl \
       -lgfortran

checkvaluesareuniquemonotonicincreasing.hpp: /workspace/openfast/translations/AirfoilInfo/checkvaluesareuniquemonotonicincreasing.cpp
	cp $< $@

# Patched source: function made PUBLIC for bridge access
AirfoilInfo.o: AirfoilInfo.f90
	$(FC) $(FC_FLAGS) -c $< -o $@

checkvaluesareuniquemonotonicincreasing_bridge.o: checkvaluesareuniquemonotonicincreasing_bridge.f90 AirfoilInfo.o
	$(FC) $(FC_FLAGS) -c checkvaluesareuniquemonotonicincreasing_bridge.f90 -o $@

test: checkvaluesareuniquemonotonicincreasing_test.o checkvaluesareuniquemonotonicincreasing_bridge.o AirfoilInfo.o
	$(CXX) -o $@ $^ $(LIBS)

checkvaluesareuniquemonotonicincreasing_test.o: checkvaluesareuniquemonotonicincreasing_test.cpp checkvaluesareuniquemonotonicincreasing.hpp
	$(CXX) $(CXX_FLAGS) -c checkvaluesareuniquemonotonicincreasing_test.cpp -o $@

run: test
	./test

# --- AFI_Init validation test ---

afi_init_validation_bridge.o: afi_init_validation_bridge.f90 AirfoilInfo.o
	$(FC) $(FC_FLAGS) -c afi_init_validation_bridge.f90 -o $@

afi_init_validation_test.o: afi_init_validation_test.cpp
	$(CXX) $(CXX_FLAGS) -c afi_init_validation_test.cpp -o $@

test_afi_init_validation: afi_init_validation_test.o afi_init_validation_bridge.o AirfoilInfo.o
	$(CXX) -o $@ $^ $(LIBS)

run_afi_init_validation: test_afi_init_validation
	./test_afi_init_validation

# --- AFI_WrHeader+WrData file-output test ---

afi_wrheaderdata_filetest_bridge.o: afi_wrheaderdata_filetest_bridge.f90 AirfoilInfo.o
	$(FC) $(FC_FLAGS) -c afi_wrheaderdata_filetest_bridge.f90 -o $@

afi_wrheaderdata_filetest.o: afi_wrheaderdata_filetest.cpp
	$(CXX) $(CXX_FLAGS) -c afi_wrheaderdata_filetest.cpp -o $@

test_afi_wrheaderdata_filetest: afi_wrheaderdata_filetest.o afi_wrheaderdata_filetest_bridge.o AirfoilInfo.o
	$(CXX) -o $@ $^ $(LIBS)

run_afi_wrheaderdata_filetest: test_afi_wrheaderdata_filetest
	./test_afi_wrheaderdata_filetest

clean:
	rm -f *.o test test_afi_init_validation test_afi_wrheaderdata_filetest *.hpp *.mod
