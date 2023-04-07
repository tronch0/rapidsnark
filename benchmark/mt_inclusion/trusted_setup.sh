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
TAU_FILE=p"owersOfTau28_hez_final_${TAU_RANK}.ptau"
TAU_FILE_WITH_DIR="${TAU_DIR}/${TAU_FILE}"

# call scripit with tau_file as an input
../common/download_ptau.sh "$TAU_FILE"
# deprecated
#if [ ! -f "$TAU_FILE" ]; then
#  wget -P "$TAU_DIR" https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_${TAU_RANK}.ptau
#fi

pushd "$CIRCUIT_DIR" || exit
snarkjs groth16 setup inclusion.r1cs ${TAU_FILE_WITH_DIR} inclusion_0000.zkey
echo 1 | snarkjs zkey contribute inclusion_0000.zkey inclusion_0001.zkey --name='cont' -v
snarkjs zkey export verificationkey inclusion_0001.zkey verification_key.json
popd || exit
