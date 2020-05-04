#!/usr/bin/env bash

docker build -t reitermarkus/cross-xtensa:llvm -f llvm.Dockerfile .

docker run --rm -it reitermarkus/cross-xtensa:llvm /llvm-xtensa/bin/clang -v
