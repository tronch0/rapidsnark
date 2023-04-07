
# Benchmark Tests for rapidsnark

This folder contains a series of benchmark tests and utilities designed to evaluate and optimize the performance of the rapidsnark prover with various circuits implementations.

## Overview

The benchmark tests cover the most common circuit implementations, aiming to provide insight into the performance and cost of widely-used circuits. By offering a comprehensive set of benchmarking tests, we aim to foster a better understanding of the current performance levels of rapidsnark.

## Getting Started

Before running the benchmark tests, ensure that you have followed the instructions in the main `README.md` file to set up the rapidsnark environment, and you have the prover executable in the `build`/`build_prover` folder.

A valid environment to run the benchmark tests contains the following:
 - prover executable in the `build`/`build_prover` folder
 - Clone circomlib by running the script [benchmark/common/setup_circomlib.sh](benchmark/common/setup_circomlib.sh)


## Running the Benchmark Tests

1. [Poseidon](./poseidon) - Assess Poseidon hash function performance.
2. [SHA256](./sha256) - Evaluate SHA256 hashing efficiency.
3. [Merkle tree inclusion](./mt_inclusion) - Test Merkle tree proof validation.

To run a specific benchmark test, run the `benchmark_mac.sh` with the following arguments:

 - <strong>Input file number</strong> - the number after the `input_` in the input file to the circuit (check input folder for the specific benchmark test)
 - <strong>The power of tau file number</strong> - for the setup phase (it'll be downloaded if not exist in the designated folder)

[//]: # (## Utils)

[//]: # ()
[//]: # (This folder also contains utilities that can be used to assist with the benchmarking process or to analyze the results. Here's a brief overview of each utility:)

[//]: # ()
[//]: # (1. [Utility 1 Description]&#40;./utils/utility1&#41; - Briefly describe the purpose and function of Utility 1.)

[//]: # (2. [Utility 2 Description]&#40;./utils/utility2&#41; - Briefly describe the purpose and function of Utility 2.)

[//]: # ()
[//]: # (For more information on how to use each utility, please refer to the documentation provided in the corresponding utility folder.)

## Contributing

We encourage community members to contribute to the benchmark tests by improving existing benchmark tests, proposing new tests, or suggesting performance enhancements. Please feel free to open issues or submit pull requests to share your ideas and improvements.
