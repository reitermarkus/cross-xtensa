FROM ubuntu:18.04


# LLVM

ARG LLVM_XTENSA_BRANCH=xtensa_release_9.0.1
ARG LLVM_XTENSA_REPO=https://github.com/espressif/llvm-project.git
ENV LLVM_XTENSA_PREFIX=/opt/xtensa/llvm

RUN apt-get update \
 && dependencies='\
      ca-certificates \
      cmake \
      g++ \
      git \
      ninja-build \
      python \
    ' \
 && apt-get install --assume-yes --no-install-recommends ${dependencies} \
 && export LLVM_XTENSA_SRC=/tmp/llvm \
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
 && rm -r "${LLVM_XTENSA_SRC}" \
 && apt-get purge --assume-yes --auto-remove ${dependencies} \
 && rm -rf /var/lib/apt/lists/*

ENV PATH="${LLVM_XTENSA_PREFIX}/bin:${PATH}"


# Xargo

RUN apt-get update \
 && dependencies='\
      ca-certificates \
      curl \
    ' \
 && apt-get install --assume-yes --no-install-recommends ${dependencies} \
 && curl -sSfL https://raw.githubusercontent.com/rust-embedded/cross/master/docker/xargo.sh -o xargo.sh \
 && bash xargo.sh \
 && apt-get purge --assume-yes --auto-remove ${dependencies} \
 && rm -rf /var/lib/apt/lists/*


# Rust

ARG RUST_XTENSA_BRANCH=xtensa-support-master
ARG RUST_XTENSA_REPO=https://github.com/reitermarkus/rust
ENV RUST_XTENSA_SRC=/opt/xtensa/rust-src
ENV RUST_XTENSA_PREFIX=/opt/xtensa/rust

RUN apt-get update \
 && dependencies='\
      ca-certificates \
      cmake \
      curl \
      gcc \
      git \
      libc6-dev \
      libssl-dev \
      make \
      pkg-config \
      python\
    ' \
 && apt-get install --assume-yes --no-install-recommends ${dependencies} \
 && git clone --depth 1 -b "${RUST_XTENSA_BRANCH}" "${RUST_XTENSA_REPO}" "${RUST_XTENSA_SRC}" \
 && cd "${RUST_XTENSA_SRC}" \
 && mkdir -p "${RUST_XTENSA_PREFIX}" \
 && ./configure \
      --enable-lld \
      --disable-docs \
      --disable-compiler-docs \
      --llvm-root="${LLVM_XTENSA_PREFIX}" \
      --prefix="${RUST_XTENSA_PREFIX}" \
      --release-channel=nightly \
 && ./x.py build \
 && ./x.py install \
 && ./x.py clean \
 && rm -r build \
 && apt-get purge --assume-yes --auto-remove ${dependencies} \
 && rm -rf /var/lib/apt/lists/*

ENV PATH="${RUST_XTENSA_PREFIX}/bin:${PATH}"

ENV XARGO_RUST_SRC="${RUST_XTENSA_SRC}"


# IDF

ARG IDF_VERSION='release/v4.1'
ENV IDF_PATH=/opt/esp/idf
ENV IDF_TOOLS_PATH=/opt/esp/idf-tools

RUN apt-get update \
 && dependencies='\
      bison \
      ca-certificates \
      ccache \
      cmake \
      flex \
      git \
      gperf \
      jq \
      libffi-dev \
      libncurses-dev \
      libssl-dev \
      make \
      ninja-build \
      python3 \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      wget \
    ' \
 && apt-get install --assume-yes --no-install-recommends ${dependencies} \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
 && git clone -b "${IDF_VERSION}" --depth 1 --recursive https://github.com/espressif/esp-idf "${IDF_PATH}" \
 && cd "${IDF_PATH}" \
 && pip3 install -r requirements.txt \
 && ./install.sh \
 && cd - \
 && chmod -R 0777 "${IDF_PATH}" \
 && chmod -R 0777 "${IDF_TOOLS_PATH}" \
 && apt-get purge --assume-yes --auto-remove ${dependencies} \
 && rm -rf /var/lib/apt/lists/*


COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
