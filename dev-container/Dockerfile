FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 必要ツール（bash明示 / TLS / 便利系）
RUN apt update && apt install -y \
    bash \
    build-essential \
    cmake \
    make \
    wget \
    curl \
    git \
    ca-certificates \
    xz-utils \
    dos2unix \
    file \
    procps && \
    rm -rf /var/lib/apt/lists/*

# TriCore toolchain を /opt に展開（ログは静か＋進捗のみ）
WORKDIR /opt
RUN wget -q --show-progress \
      https://github.com/NoMore201/tricore-gcc-toolchain/releases/download/13.4-20250801/tricore-gcc-13.4-20250801-linux.tar.gz \
      -O /opt/tricore-gcc.tar.gz && \
    tar -xf /opt/tricore-gcc.tar.gz && \
    rm /opt/tricore-gcc.tar.gz

# 実体は /opt/bin に入るので PATH を通す
ENV PATH="/opt/bin:${PATH}"

# 作業ディレクトリ
WORKDIR /work

# シェルは /usr/bin/bash で
CMD ["/usr/bin/bash"]
