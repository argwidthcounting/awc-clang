# Argument Width Counting


***SEE [https://github.com/Ktrio3/awc-clang](https://github.com/Ktrio3/awc-clang) FOR ANY POTENTIAL UPDATES*** This is an old anonymized repo used for double-blind review.


Argument Width Counting (AWC) is a new memory access-control policy that, when enforced, prevents all observed variadic-function attacks, including format-string attacks. AWC tracks the initial width or size of variadic arguments allocated on the stack and requires that variadic functions cannot request more bytes than initially allocated. When enforced, this policy limits variadic functions to the segments of memory allocated to the variadic arguments.

AWC requires that the variadic functions only access X bytes off the stack, where X is the number of bytes pushed to the stack as variadic arguments during the function call. This differentiates it from argument counting, which counts the number of arguments, rather than their width. That is, AWC tracks the total size of all variadic arguments rather than the number of arguments. For example, if a variadic function call pushes 3 integers, than the width is 3 ints * 4 bytes each = 12 bytes total. Calls to va_arg may only access a total of 12 bytes; if the program attempts to access more than 12 bytes  accessed, the program is terminated. For a more detailed description with more complex examples, please refer to the original paper. TODO: Add link to paper once released

This repository contains a prototype mechanism for AWC developed for [Clang/LLVM](https://clang.llvm.org) ([GitHub](https://github.com/llvm/llvm-project)). By slightly modifying the Clang compiler and LLVM backend, AWC can be enforced.

There are many different techniques that can be employed to enforce the AWC policy, each with their own trade-offs. For this prototype, we enforce AWC by:

1. adding a "remaining" member to the va_struct that tracks the number of bytes accessed using by that va_struct.  
2. during a variadic function call, an extra variadic argument containg the variadic width is pushed to the stack before the other variadic arguments.
3. in the variadic function, during va_start, the width is retrieved off the stack and stored into the new remaining struct member.
4. during va_arg, decrementing the size of the requested type from remaining; if the remaining value becomes negative, then the va_arg call is out of bounds and the program is terminated.

In order to be able to fully test out the C compiler on some real programs for benchmarking, we also compiled LLVM's libc using the AWC-enabled Clang compiler, bringing AWC protection to libc functions like printf. Note that libc is not fully implemented, so there are some limitations. Another library could always be compiled with the AWC-enabled Clang to get the full implementation.  

For brevity, from here on out we refer to the AWC-enabled Clang compiler as AClang or aclang, and
unless otherwise noted, Clang will always refers to the non-AWC-enabled Clang compiler. Similarly, alibc will refer to libc compiled with AClang.

A [simple testing suite](https://github.com/argwidthcounting/awc-test-suite) is available, which contains several scripts for quickly testing AClang. This includes all of the benchmarking scripts used to populate the tables in the paper.

This project was based on the most recent stable release of Clang/LLVM at the time of development. This was [17.0.5](https://github.com/llvm/llvm-project/releases/tag/llvmorg-17.0.5) . While we had originally planned to fork the main branch, we instead downloaded the source for the last stable release as the current build at the time was marked as failing the build tests.

Finally, please note that we only developed the LLVM backend for X86-64 Linux/Unix systems. The variadic functions are part of the LLVM backend, and thus must be modified slightly to accomadate other processors.  If you are using an Apple computer with an ARM processor (released in/after 2020), this will almost certainly not work out of the gate and will need to be emulated. I do not own one myself, and thus have not tested it. If you're a tech-savvy Mac user and are familiar with this, I would greatly appreciate any insight or even a pull request with instructions to help others.

All modifications to Clang and LLVM can be found by referring to the git commits, or by searching for "// AWC CHANGE".

# Build Instructions

The following sections describe all of the steps to build AClang/Clang and alibc/libc. 

If you cloned this repo in your home directory, you should be able to just copy and paste every instruction. If not in your home directory, replace the `$HOME` with the path to the cloned repository.

Alternatively, a [build script](makeAWC.sh) is also available which will perform all of this for you. The script will download this repository, the Clang 17.0.5 source code, and the testing suite, then build AClang, alibc, Clang, libc. It will also output bash functions for easily running these. To use it, just download the bash script and run it.

## Building AClang (and Clang)

The instructions below are very similar to those on the [Clang website](https://clang.llvm.org/get_started.html#build), but they are included here below for completeness. To build Clang instead of AClang, replace cloning the repository with downloading the [Clang/LLVM 17.0.5 source code](https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-17.0.5.zip). A full list of [modified commands for Clang](#building-clang-and-libc) are available.

Clone the repository and enter the new directory.

```bash
git clone https://github.com/argwidthcounting/awc-clang.git && cd awc-clang
```

Make a new build directory 

```bash
mkdir build && cd build
```

Use cmake to generate the makefiles for the project. Note that cmake can be used to generate the build instructions for many different systems; I personally tested out "Unix Makefiles" and Ninja, and I had no issues using either. To use Ninja, (or something else), swap the `-G "Unix..."` to `-G Ninja`.

```bash
cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_OPTIMIZED_TABLEGEN=ON
```

Still in the build directory, build the project (note this will take some time; if you are using WSL with debug instead of prod, I needed to increase my allocated cache/swap memory).

```bash
make clang
```

Once the build has finished, the AClang compiler can be found under `$HOME/awc-clang/build/bin/clang++`.  If you do not want to test AWC with libc, you can compile programs normally using this executable.

## Building alibc/alibc++ (and libc/libc++)

The documentation for compiling libc was not as well documented as Clang (likely because libc is not fully implemented, see future work). The following instructions are what worked for me.

Navigate to the awc-clang directory you cloned when building AClang, and create a new directory to contain the build files for alibc. Alternatively, if building libc, navigate to the unmodified Clang source code you downloaded.

```bash
cd awc-clang && mkdir build-libc && cd build-libc
```

Use cmake again to generate build files. Previously, cmake automatically found the best compiler to use when building AClang; this time, specify that the newly compiled AClang compiler should be used (once for C, and once for C++). Note you must give an absolute path to the compiler. You can change the build to Ninja again if you prefer. 

If you are building libc and not alibc, provide a path to Clang, not AClang.

```bash
cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86" -DCMAKE_C_COMPILER="$HOME/awc-clang/build/bin/clang" -DCMAKE_CXX_COMPILER="$HOME/awc-clang/build/bin/clang++" -DLIBCXX_ENABLE_THREADS=ON -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind" -S ../runtimes
```

Build the library.

```bash
make 
```

The newly compiled library files can be found under "build-libc/libc/lib" (alibc) and "build-libc/lib" (alibc++).

## Using AClang with alibc

To compile a program, use AClang and specify the location of the alibc library. For example, to compile test.c, use:

```bash
$HOME/awc-clang/build/bin/clang++ -L $HOME/awc-clang/build-libc/libc/lib test.c -o test {Any other options for clang} -lllvmlibc
```

Note that for some reason I needed the -lllvmlibc to appear at the very end or clang would begin linking with the system's libc again.

If you want to use both alibc and alibc++, there are several more options to specify:

```bash
$HOME/awc-clang/build/bin/clang++ -nostdinc++ -nostdlib++ -isystem $HOME/awc-clang/build-libc/include/c++/v1 -L $HOME/awc-clang/build-libc/lib -Wl,-rpath,$HOME/awc-clang/build-libc/lib -lc++ -L $HOME/awc-clang/build-libc/libc/lib test.c -o test {Any other options for clang} -lllvmlibc
```

Optional: Add the following to your bashrc/zshrc/etc. to easily run the compiler.

```bash
aclang () {
    $HOME/awc-clang/build/bin/clang++ -nostdinc++ -nostdlib++ -isystem $HOME/awc-clang/build-libc/include/c++/v1 -L $HOME/awc-clang/build-libc/lib -Wl,-rpath,$HOME/awc-clang/build-libc/lib -lc++ -L $HOME/awc-clang/build-libc/libc/lib "$@" -lllvmlibc
}
```

Source your bashrc file by either logging out or using `. ~/.bashrc`. Now you can compile your programs like normal using the command aclang:

```bash
aclang test.c -o test
```

### Building Clang and libc

The following is a repeat of all of the commands from the previous section, but slightly modified to build Clang instead of AClang. As before, the commands are assumed to be run in the home directory. To differentiate from your regularly installed Clang (if present), the name reg-clang or rclang is used. If you want to run the performance benchmarks, you should build clang like this rather than using the version installed with apt or a similar package manager to ensure the comparison is not skewed by external factors (e.g., using a different lib).

```bash 
wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-17.0.5.zip -O reg-clang.zip

unzip reg-clang.zip

cd reg-clang

mkdir build && cd build

cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_OPTIMIZED_TABLEGEN=ON

make clang

cd ../

mkdir build-libc && cd build-libc

cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86" 
  -DCMAKE_C_COMPILER="$HOME/reg-clang/build/bin/clang" -DCMAKE_CXX_COMPILER="$HOME/reg-clang/build/bin/clang++" -DLIBCXX_ENABLE_THREADS=ON -DLLVM_ENABLE_RUNTIMES="libc;libcxx;libcxxabi;libunwind" -S ../runtimes

make
```

Similar to aclang, you can modify your bashrc to add a rclang command:

```bash
rclang () {
    $HOME/reg-clang/build/bin/clang++ -nostdinc++ -nostdlib++ -isystem $HOME/reg-clang/build-libc/include/c++/v1 -L $HOME/reg-clang/build-libc/lib -Wl,-rpath,$HOME/reg-clang/build-libc/lib -lc++ -L $HOME/reg-clang/build-libc/libc/lib \"\$@\" -lllvmlibc
}
```

Now you can compile programs with a Clang executable built in a similar fashion AClang by running

```bash
rclang test.c -o test
```

At this point, you might have three different clang commands:
```
aclang - the modified 17.0.5 Clang with AWC
rclang - Clang 17.0.5 using the statically compiled LLVM libc
clang - the most recent version of Clang installed by your package manager
```

# Future Improvements

As this is just a prototype implementation, it does not have some of the features that
would be expected before being merged into production. Namely, the following would be
necessary:

1. Implement other backends
2. Options to enable/disable AWC support, including an option to disable at compilation time
   1. It might make sense to implement as a sanitizer?
3. Develop unit tests, possibly based on the current prototype testing/benchmark suite 

