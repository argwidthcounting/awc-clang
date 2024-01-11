cd build
ninja clang
cd ../build-libc
ninja clean && ninja
cd ..