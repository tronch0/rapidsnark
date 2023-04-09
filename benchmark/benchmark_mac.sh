#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Error: This script requires 3 arguments."
  echo "Usage: $0 <benchmark_name> <input_file> <tau_rank>"
  echo ""
  echo "1. benchmark_name: The folder name of the benchmark to test."
  echo "2. input_file: The input file to use in the benchmark (only the postfix after input_)."
  echo "3. tau_rank: the power of tau file rank to use. (will be downloaded if not exist)"
  exit 1
fi

BENCHMARK_NAME=$1
INPUT_SIZE=$2
TAU_RANK=$3

echo "Benchmark to test - $BENCHMARK_NAME"
echo "Input size to use -  $INPUT_SIZE"
echo "Power of tau rank to use - $TAU_RANK"

set -e
SCRIPT=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")

BENCHMARK_DIR="${SCRIPT_DIR}/${BENCHMARK_NAME}"
CIRCUIT_DIR="${BENCHMARK_DIR}/circuit"
COMPILED_DIR="${CIRCUIT_DIR}/compiled"

RAPID_SNARK_PROVER=${SCRIPT_DIR}"/../build_prover/src/prover"
TIME=(gtime -f "mem %M\ntime %e\ncpu %P")


export NODE_OPTIONS=--max_old_space_size=327680
# sysctl -w vm.max_map_count=655300

function renderCircom() {
  pushd "$CIRCUIT_DIR"
  echo sed -i '' "s/Main([0-9]*)/Main($INPUT_SIZE)/" circuit.circom
  sed -i '' "s/Main([0-9]*)/Main($INPUT_SIZE)/" circuit.circom
  popd
}

function compile() {
  pushd "$CIRCUIT_DIR"
  echo circom circuit.circom --r1cs --sym --wasm -o "$COMPILED_DIR"
  circom circuit.circom --r1cs --sym --wasm -o "$COMPILED_DIR"
  popd
}

function setup() {
  echo "${TIME[@]}" ./trusted_setup.sh "$TAU_RANK"
  "${TIME[@]}" ./trusted_setup.sh "$TAU_RANK" "$COMPILED_DIR"

  prove_key_size=$(ls -lh "$COMPILED_DIR"/circuit_0001.zkey | awk '{print $5}')
  verify_key_size=$(ls -lh "$COMPILED_DIR"/verification_key.json | awk '{print $5}')

  echo "Prove key size: $prove_key_size"
  echo "Verify key size: $verify_key_size"
}

#  witness generation by c++ is not supported on M1 arm64
function generateWtns() {
  pushd "$CIRCUIT_DIR"
  echo node "$COMPILED_DIR/circuit_js/generate_witness.js" "$COMPILED_DIR/circuit_js/circuit.wasm" "$BENCHMARK_DIR/input/input_${INPUT_SIZE}.json" "$COMPILED_DIR/witness.wtns"
  "${TIME[@]}" node "$COMPILED_DIR/circuit_js/generate_witness.js" "$COMPILED_DIR/circuit_js/circuit.wasm" "$BENCHMARK_DIR/input/input_${INPUT_SIZE}.json" "$COMPILED_DIR/witness.wtns"
  popd
}

avg_time() {
    #
    # usage: avg_time n command ...
    #
    n=$1; shift
    (($# > 0)) || return
    echo "$@"
    for ((i = 0; i < n; i++)); do
        "${TIME[@]}" "$@" 2>&1
    done | awk '
        /mem/ { mem = mem + $2; nm++ }
        /time/ { time = time + $2; nt++ }
        /cpu/  { cpu  = cpu  + substr($2,1,length($2)-1); nc++}
        END    {
                 if (nm>0) printf("mem %f\n", mem/nm);
                 if (nt>0) printf("time %f\n", time/nt);
                 if (nc>0) printf("cpu %f\n",  cpu/nc)
               }'
}


#function normalProve() {
#  pushd "$CIRCUIT_DIR"
#  avg_time 10 snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json
#  proof_size=$(ls -lh proof.json | awk '{print $5}')
#  echo "Proof size: $proof_size"
#  popd
#}


function rapidProve() {
  pushd "$CIRCUIT_DIR"
  avg_time 10 "$RAPID_SNARK_PROVER" "$COMPILED_DIR/circuit_0001.zkey" "$COMPILED_DIR/witness.wtns" "$COMPILED_DIR/proof.json" "$COMPILED_DIR/public.json"
  proof_size=$(ls -lh "$COMPILED_DIR/proof.json" | awk '{print $5}')
  echo "Proof size: $proof_size"
  popd
}

function verify() {
  pushd "$CIRCUIT_DIR"
  avg_time 10 snarkjs groth16 verify "$COMPILED_DIR/verification_key.json" "$COMPILED_DIR/public.json" "$COMPILED_DIR/proof.json"
  popd
}


echo "========== Step0: render circom  =========="
renderCircom

echo "========== Step1: compile circom  =========="
compile

echo "========== Step2: setup =========="
setup

echo "========== Step3: generate witness  =========="
generateWtns

echo "========== Step4: prove  =========="
rapidProve

echo "========== Step5: verify  =========="
verify
