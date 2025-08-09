#!/usr/bin/env bash
set -euo pipefail

ELF="build/test.elf"
EXTRA_OPTS=""
RUN_GDB=0
USE_MONITOR=0
MON_PORT=55555

while [[ $# -gt 0 ]]; do
  case "$1" in
    --elf) ELF="$2"; shift 2;;
    --gdb) RUN_GDB=1; shift;;
    --no-gdb) RUN_GDB=0; shift;;
    --extra) EXTRA_OPTS="$2"; shift 2;;
    --monitor) USE_MONITOR=1; shift;;
    --monitor-port) MON_PORT="$2"; shift 2;;
    *) echo "Unknown option: $1" >&2; exit 2;;
  esac
done

ELF_ABS="/work/${ELF}"
[[ -f "$ELF_ABS" ]] || { echo "ELF not found: $ELF_ABS"; exit 1; }

QEMU_LOG="/tmp/qemu_tricore.log"
MON_OPT=()
if (( USE_MONITOR )); then
  MON_OPT=( -monitor tcp:127.0.0.1:${MON_PORT},server,nowait )
fi

# スクリプトは Ctrl-C を無視（GDB だけが受ける）
trap '' INT

# QEMU を独立セッションで起動（Ctrl-C が届かないように）
set -x
setsid qemu-system-tricore \
  -M tricore_testboard \
  -nographic \
  -s -S \
  -kernel "$ELF_ABS" \
  "${MON_OPT[@]}" \
  $EXTRA_OPTS \
  >"$QEMU_LOG" 2>&1 < /dev/null &
set +x
QEMU_PID=$!

cleanup() {
  if kill -0 "$QEMU_PID" 2>/dev/null; then
    kill "$QEMU_PID" || true
    wait "$QEMU_PID" || true
  fi
}
trap cleanup EXIT

# gdbstub 待ち
echo "Waiting for QEMU gdbstub on 127.0.0.1:1234 ..."
for _ in {1..100}; do
  (echo > /dev/tcp/127.0.0.1/1234) >/dev/null 2>&1 && break
  sleep 0.05
done

if (( RUN_GDB )); then
  /opt/bin/tricore-elf-gdb "$ELF_ABS" \
    -ex "set pagination off" \
    -ex "target remote 127.0.0.1:1234" \
    -ex "b main" \
    -ex c
else
  echo "QEMU started. Logs → $QEMU_LOG"
  echo "Attach with: /opt/bin/tricore-elf-gdb $ELF_ABS -ex 'target remote 127.0.0.1:1234'"
  if (( USE_MONITOR )); then
    echo "Monitor: nc 127.0.0.1 ${MON_PORT}"
  fi
  tail -n 5 "$QEMU_LOG" || true
  wait "$QEMU_PID"
fi
