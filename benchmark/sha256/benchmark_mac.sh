#!/bin/bash

if [ $# -ne 2 ]; then
  echo "input_size and tau_rank required"
  exit 1
fi

set -e
SCRIPT=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
CIRCUIT_DIR=${SCRIPT_DIR}"/circuit"
TIME=(gtime -f "mem %M\ntime %e\ncpu %P")
RAPID_SNARK_PROVER=${SCRIPT_DIR}"/../../build_prover/src/prover"
INPUT_SIZE=$1
TAU_RANK=$2
echo "input size $INPUT_SIZE"
echo "tau rank $TAU_RANK"
TAU_DIR=${SCRIPT_DIR}"/../common/ptau"
TAU_FILE="${TAU_DIR}/powersOfTau28_hez_final_${TAU_RANK}.ptau"

export NODE_OPTIONS=--max_old_space_size=327680
# sysctl -w vm.max_map_count=655300

function renderCircom() {
  pushd "$CIRCUIT_DIR"
  echo sed -i '' "s/Main([0-9]*)/Main($INPUT_SIZE)/" sha256.circom
  sed -i '' "s/Main([0-9]*)/Main($INPUT_SIZE)/" sha256.circom
  popd
}

function compile() {
  pushd "$CIRCUIT_DIR"
  echo circom sha256.circom --r1cs --sym --wasm -o compiled
  circom sha256.circom --r1cs --sym --wasm -o compiled
  popd
}

function setup() {
  if [ ! -f "$TAU_FILE" ]; then
    echo "download $TAU_FILE" with wget, make sure wget installed
    wget -P "$TAU_DIR" https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_${TAU_RANK}.ptau
  fi
  echo "${TIME[@]}" "$SCRIPT_DIR"/trusted_setup.sh "$TAU_RANK"
  "${TIME[@]}" "$SCRIPT_DIR"/trusted_setup.sh "$TAU_RANK"
  prove_key_size=$(ls -lh "$CIRCUIT_DIR"/compiled/sha256_0001.zkey | awk '{print $5}')
  verify_key_size=$(ls -lh "$CIRCUIT_DIR"/compiled/verification_key.json | awk '{print $5}')
  echo "Prove key size: $prove_key_size"
  echo "Verify key size: $verify_key_size"
}

#  witness generation by c++ is not supported on M1 arm64
function generateWtns() {
  pushd "$CIRCUIT_DIR"
  echo node compiled/sha256_js/generate_witness.js compiled/sha256_js/sha256.wasm ../input/input_${INPUT_SIZE}.json compiled/witness.wtns
  "${TIME[@]}" node compiled/sha256_js/generate_witness.js compiled/sha256_js/sha256.wasm ../input/input_${INPUT_SIZE}.json compiled/witness.wtns
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
#  avg_time 10 snarkjs groth16 prove sha256_0001.zkey witness.wtns proof.json public.json
#  proof_size=$(ls -lh proof.json | awk '{print $5}')
#  echo "Proof size: $proof_size"
#  popd
#}


function rapidProve() {
  pushd "$CIRCUIT_DIR"
  avg_time 10 "$RAPID_SNARK_PROVER" compiled/sha256_0001.zkey compiled/witness.wtns proof.json public.json
  proof_size=$(ls -lh proof.json | awk '{print $5}')
  echo "Proof size: $proof_size"
  popd
}

function verify() {
  pushd "$CIRCUIT_DIR"
  avg_time 10 snarkjs groth16 verify compiled/verification_key.json compiled/public.json proof.json
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
