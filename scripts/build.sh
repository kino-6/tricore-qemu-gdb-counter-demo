#!/usr/bin/env bash
set -euo pipefail

cd /work

# build/ は volumes のマウント先なのでフォルダ自体は消さない
mkdir -p build
# 中身だけ安全に掃除（隠しファイルも含む）
if [ -d build ]; then
  find build -mindepth 1 -maxdepth 1 -exec rm -rf {} +
fi

# CRLF 対応（Windows で触った場合の保険）
if command -v dos2unix >/dev/null 2>&1; then
  find /work/scripts -type f -name '*.sh' -exec dos2unix {} + || true
  find /work/src -type f \( -name '*.c' -o -name '*.ld' -o -name 'CMakeLists.txt' \) -exec dos2unix {} + || true
fi

# ツールチェーンの PATH（明示しておくと安心）
export PATH=/opt/bin:$PATH

# 構成とビルド（src→build の分離を徹底）
cmake -S /work/src -B /work/build \
  -G "Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=/work/scripts/toolchains/tricore.cmake \
  -DCMAKE_BUILD_TYPE=Debug

cmake --build /work/build -j
