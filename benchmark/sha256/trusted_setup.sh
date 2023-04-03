#!/bin/bash

if [ $# -ne 1 ]; then
  echo "tau_rank required"
  exit 1
fi

SCRIPT=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
CIRCUIT_DIR=${SCRIPT_DIR}"/circuit/compiled"
TAU_RANK=$1
TAU_DIR=${SCRIPT_DIR}"/../common/ptau"
TAU_FILE="${TAU_DIR}/powersOfTau28_hez_final_${TAU_RANK}.ptau"

if [ ! -f "$TAU_FILE" ]; then
  wget -P "$TAU_DIR" https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_${TAU_RANK}.ptau
fi

pushd "$CIRCUIT_DIR" || exit
snarkjs groth16 setup sha256.r1cs ${TAU_FILE} sha256_0000.zkey
echo 1 | snarkjs zkey contribute sha256_0000.zkey sha256_0001.zkey --name='cont' -v
snarkjs zkey export verificationkey sha256_0001.zkey verification_key.json
popd || exit
