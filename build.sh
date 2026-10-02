#!/bin/sh
set -e
CCOPT=
CXXOPT=

# error if devkitarm is not installed and binutils-arm-none-eabi is not installed
if ! ([ -n "$DEVKITARM" ] && [ -d "$DEVKITARM/bin" ]) && ! (command -v arm-none-eabi-as &> /dev/null && command -v arm-none-eabi-ar &> /dev/null) ; then
	echo "Could not find a binutils installation! Re-read the instructions and make sure you've installed either devkitARM or binutils-arm-none-eabi, depending on your system."
	exit 1
fi

if [ ! -z "$CC" ]; then CCOPT=CC=$CC; fi
if [ ! -z "$CXX" ]; then CXXOPT=CXX=$CXX; fi
make -C gcc clean
make -C gcc old -j1 $CCOPT $CXXOPT
mv gcc/old_agbcc .
make -C gcc clean
make -C gcc -j1 $CCOPT $CXXOPT
mv gcc/agbcc .
# not sure if the ARM compiler is the old one or the new one (-DOLD_COMPILER)
rm -f gcc_arm/config.status gcc_arm/config.cache
cd gcc_arm && ./configure --target=arm-elf --host=i386-linux-gnu && make cc1 && cd ..
mv gcc_arm/cc1 agbcc_arm
# c++ compiler
rm -f g++/config.status g++/config.cache
cd g++ && ./configure --target=thumb-elf --disable-werror --with-cpu=arm7tdmi --with-no-thumb-interwork --disable-multilib --enable-languages="c++" --host=i686-pc-linux --build=i686-pc-linux
make clean && make cc1plus && cd ..
mv g++/cc1plus agbcp
rm -f g++_arm/config.status g++_arm/config.cache
cd g++_arm && ./configure --target=arm-elf --disable-werror --with-cpu=arm7tdmi --with-no-thumb-interwork --disable-multilib --enable-languages="c++" --host=i686-pc-linux --build=i686-pc-linux
make clean && make cc1plus && cd ..
mv g++_arm/cc1plus agbcp_arm
# runtime
make -C libgcc clean
make -C libgcc $CCOPT $CXXOPT
mv libgcc/libgcc.a .
make -C libc clean
make -C libc $CCOPT $CXXOPT
mv libc/libc.a .
