FROM ubuntu:18.04 as llvm

ARG LLVM_XTENSA_BRANCH=xtensa_release_9.0.1
ARG LLVM_XTENSA_REPO=https://github.com/espressif/llvm-project.git
ENV LLVM_XTENSA_PREFIX="/llvm-xtensa"

RUN apt-get update \
 && dependencies="cmake g++ ca-certificates git ninja-build python" \
 && apt-get install --assume-yes --no-install-recommends ${dependencies} \
 && export LLVM_XTENSA_SRC=/tmp/llvm-xtensa \
 && git clone --depth 1 -b "${LLVM_XTENSA_BRANCH}" "${LLVM_XTENSA_REPO}" "${LLVM_XTENSA_SRC}" \
 && cd "${LLVM_XTENSA_SRC}" \
 && mkdir build \
 && cd build \
 && cmake ../llvm \
      -G Ninja \
      -DLLVM_TARGETS_TO_BUILD=X86 \
      -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=Xtensa \
      -DLLVM_ENABLE_PROJECTS='clang;lld' \
      -DLLVM_INSTALL_UTILS=ON \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DLLVM_INCLUDE_BENCHMARKS=OFF \
      -DCMAKE_BUILD_TYPE=Release \
 && cmake --build . \
 && cmake -DCMAKE_INSTALL_PREFIX="${LLVM_XTENSA_PREFIX}" -P cmake_install.cmake \
 && apt-get purge --assume-yes --auto-remove ${dependencies} \
 && rm -r "${LLVM_XTENSA_SRC}" \
 && rm -rf /var/lib/apt/lists/*
