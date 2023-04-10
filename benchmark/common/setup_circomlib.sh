#!/bin/bash

CIRCOMLIB_REPO_URL="https://github.com/iden3/circomlib"

script_dir=$(realpath "$0")
target_dir="$script_dir/circomlib"

git clone "$CIRCOMLIB_REPO_URL" $target_dir