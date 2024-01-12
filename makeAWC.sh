#!/bin/bash
# Check that all of the programs we need are installed

if ! [ -x "$(command -v make)" ]; then
  echo 'Error: make is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v cmake)" ]; then
  echo 'Error: cmake is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v wget)" ]; then
  echo 'Error: wget is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v unzip)" ]; then
  echo 'Error: unzip is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v gcc)" ]; then
  echo 'Error: gcc is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v g++)" ]; then
  echo 'Error: g++ is not installed.' >&2
  exit 1
fi

ROOT=$(pwd)

#Check if we are currently in the awc-clang repository
string=$(git remote show origin 2>/dev/null)
if [[ $string == *"argwidthcounting/awc-clang.git"* ]]; then
  echo "Build script currently in awc-clang directory."
  echo "Build script will download testing suite and others to parent directory."
  cd ..
  ROOT=$(pwd)
fi

# First, build AClang
if ! [ -d "awc-clang" ]; then
  git clone https://github.com/argwidthcounting/awc-clang.git || exit
fi

cd awc-clang || exit
if ! [ -d "build" ]; then
  mkdir build
fi
cd build || exit

# Running cmake twice with the same options is fine
cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm \
  -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_OPTIMIZED_TABLEGEN=ON || exit

make clang || exit

# Second, build alibc and alibc++
cd .. || exit
if ! [ -d "build-libc" ]; then
  mkdir build-libc
fi
cd build-libc || exit

cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86" \
  -DCMAKE_C_COMPILER="$ROOT/awc-clang/build/bin/clang" \
  -DCMAKE_CXX_COMPILER="$ROOT/awc-clang/build/bin/clang++" \
  -DLIBCXX_ENABLE_THREADS=ON -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind" \
  -S ../runtimes || exit

make || exit

cd "$ROOT"

# Third, build Clang
if ! [ -d "reg-clang" ]; then
  wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-17.0.5.zip -O reg-clang.zip || exit
  unzip reg-clang.zip || exit
  mv llvm-project-llvmorg-17.0.5 reg-clang || exit
fi

cd reg-clang || exit
if ! [ -d "build" ]; then
  mkdir build
fi
cd build || exit

cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm \
  -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_OPTIMIZED_TABLEGEN=ON || exit

make clang || exit

# Fourth, build libc and libc++
cd .. || exit
if ! [ -d "build-libc" ]; then
  mkdir build-libc
fi
cd build-libc || exit

cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86" \
  -DCMAKE_C_COMPILER="$ROOT/reg-clang/build/bin/clang" \
  -DCMAKE_CXX_COMPILER="$ROOT/reg-clang/build/bin/clang++" \
  -DLIBCXX_ENABLE_THREADS=ON -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind" \
  -S ../runtimes || exit

make || exit

cd "$ROOT"

# Finally, download the test suite
if ! [ -d "awc-test-suite" ]; then
  git clone https://github.com/argwidthcounting/awc-test-suite.git || exit
fi

echo "aclang () {
    $ROOT/awc-clang/build/bin/clang++ -nostdinc++ -nostdlib++ -isystem $ROOT/awc-clang/build-libc/include/c++/v1 \
     -L $ROOT/awc-clang/build-libc/lib -Wl,-rpath,$ROOT/awc-clang/build-libc/lib -lc++ \
     -L $ROOT/awc-clang/build-libc/libc/lib \"\$@\" -lllvmlibc
}
rclang () {
    $ROOT/reg-clang/build/bin/clang++ -nostdinc++ -nostdlib++ -isystem $ROOT/reg-clang/build-libc/include/c++/v1 \
     -L $ROOT/reg-clang/build-libc/lib -Wl,-rpath,$ROOT/reg-clang/build-libc/lib -lc++ \
     -L $ROOT/reg-clang/build-libc/libc/lib \"\$@\" -lllvmlibc
}" >$ROOT/load_awc_run_commands.sh

echo "The file $ROOT/load_awc_run_commands.sh contains aclang and rclang functions, which run the \
AWC-enabled clang and regular clang commands. Run '. $ROOT/load_awc_run_commands.sh' to source\
these functions and be able to execute them."

read -p "Would you like to build ChibiCC as well? [(Y)/N]: " input

i=$(echo $input | tr '[:lower:]' '[:upper:]')

if ! [ "$i" = "N" ]; then
  if ! [ -d "chibicc-awc" ]; then
    git clone https://github.com/argwidthcounting/chibicc-awc.git
  fi
  if ! [ -d "chibicc-reg" ]; then
    git clone https://github.com/rui314/chibicc.git chibicc-reg
  fi
  cd chibicc-awc || exit
  make || exit
  cd .. || exit
  cd chibicc-reg || exit
  make || exit
  cd .. || exit

  echo "achibicc () {
    $ROOT/chibicc-awc/chibicc \"\$@\"
}
rchibicc () {
    $ROOT/chibicc-reg/chibicc \"\$@\"
}" >> $ROOT/load_awc_run_commands.sh

  echo "The file $ROOT/load_awc_run_commands.sh now also contains achibicc and rchibicc. Run '. $ROOT/load_awc_run_commands.sh' to source\
  these functions and be able to execute them."
fi
