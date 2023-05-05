# rapidsnark - Apple's chip edition (M1, M2...)

<b>Important note:</b> All information & instructions assumes host machine are arm64 Apple chip with MacOS.

## dependencies

You should have installed gcc and cmake

````
brew install gcc
brew install cmake
````

To verify support for optimized execution through parallel processing, ensure that your installed version of GCC is compatible with OpenMP. You can do this by executing the following command:
````sh
g++ -fopenmp --version
````
If you see the version information without any error messages, your GCC installation supports OpenMP.

## Compile Prover (Apple chips)

````sh
git submodule init

git submodule update

./build_gmp.sh host_noasm

mkdir build_prover && cd build_prover

cmake .. -DCMAKE_C_COMPILER=$(brew --prefix gcc)/bin/gcc-12 -DCMAKE_CXX_COMPILER=$(brew --prefix gcc)/bin/g++-12 -DTARGET_PLATFORM=arm64_host -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../package -DIS_APPLE_CHIP=ON

make -j4 && make install
````
*<b>in the cmake command:</b> please change the g++ version to what you installed (in the example we are using version 12)

## Building proof

You have a full prover compiled in the build directory.

So you can replace snarkjs command:

````sh
snarkjs groth16 prove <circuit.zkey> <witness.wtns> <proof.json> <public.json>
````

by this one
````sh
./package/bin/prover <circuit.zkey> <witness.wtns> <proof.json> <public.json>
````

## Benchmark

This section aims to provide insight into the performance and cost of widely-used proofs with rapidsnark. We are testing the most commonly used circuits with different inputs and scenarios to better understand their behavior under various conditions and explore opportunities for optimization.

Please navigate to the [/benchmark](./benchmark) folder to explore the benchmarking tests.

## License

rapidsnark is part of the iden3 project copyright 2021 0KIMS association and published with GPL-3 license. Please check the COPYING file for more details.
