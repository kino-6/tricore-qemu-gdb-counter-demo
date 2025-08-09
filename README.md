# TriCore QEMU + GDB Counter Demo

A minimal setup to run **TriCore (QEMU)**, load an ELF, and monitor `counter++` with a **hardware watchpoint** in GDB.

## Requirements

- test on wsl2
- Docker / Docker Compose
- (Bundled) tricore-elf-gcc, qemu-system-tricore

---

## 1) Build the Docker image

```bash
docker compose build
```

## 2) Build the ELF inside the container

```bash
docker compose run --rm tricore-dev bash /work/scripts/build.sh
```

Artifacts will be generated under:  
`./build/test.elf`, `./build/test.map`

## 3) Launch QEMU + GDB (self-contained in the same container)

```bash
docker compose run --rm tricore-dev bash /work/scripts/launch.sh --elf build/test.elf --gdb
```

> QEMU gdbstub will start and automatically break at `main`.  
> To monitor `counter`:
> gdb
> (gdb) watch counter if counter == 100
> (gdb) c

---

## Example success log

**`main.c`**

```c
volatile int counter = 0;

int main(void) {
    for (;;) {
        counter++;
    }
    return 0;
}
```

**`GDB session`**

```bash
Breakpoint 1, main () at /work/src/main.c:3
3       int main(void) {
(gdb) p counter
$1 = 0
(gdb) watch counter
Hardware watchpoint 2: counter
(gdb) c
Continuing.

Hardware watchpoint 2: counter

Old value = 0
New value = 1
main () at /work/src/main.c:5
5               counter++;
(gdb) info reg pc
pc             0x8000006a          0x8000006a <main+2>
```

---

## Key points

- **Memory map**:  
  - `rom (rx)  : ORIGIN = 0x80000000`  
  - `ram (rwx) : ORIGIN = 0xA1000000`
- **Small data area (a0) init**: `a0 = RAM_ORIGIN + 0x8000`  
  → `ld/st [%a0]-32768` accesses `counter (0xA1000000)` correctly.
- **Startup (crt0.S)**:
  - Copy `.data` from ROM to RAM (`__DATA_LOAD_START__` → `__DATA_START__..__DATA_END__`)
  - Zero `.bss` (`__BSS_START__..__BSS_END__`)
  - Initialize `SP (a10)` / `FP (a11)`
  - Use `j main` instead of `call` to avoid CSA setup

---

## Common pitfalls

- `p counter` shows “Cannot access memory”  
  → `link.ld` RAM ORIGIN does not match QEMU's actual RAM (should be `0xA1000000` here).
- `counter` never changes / PC jumps to invalid address  
  → `a0` not set correctly.
- Crash after `call main`  
  → CSA not initialized. Use `j main` in minimal setups.

---

## Optional

### QEMU monitor (HMP)

Enable monitor TCP (default: 55555) with:

```bash
docker compose run --rm tricore-dev bash /work/scripts/launch.sh --elf build/test.elf --gdb --monitor
# In another shell:
nc 127.0.0.1 55555
(qemu) help
```

### GDB helper command

```gdb
define w100
  delete
  display counter
  watch counter if counter == 100
  continue
end
```

---

## Folder structure

```bash
src/
  crt0.S        # Startup: .data/.bss init + a0/SP setup + j main
  link.ld       # ROM/RAM map + SDA window symbols
  main.c        # counter++ loop
scripts/
  build.sh      # CMake build
  launch.sh     # QEMU + gdbstub
build/          # Output files (elf/map) - add to .gitignore
```

---

## License

MIT

## JP Memo

日本語のメモ

## 1) イメージをビルド

docker compose build

## 2) ビルド（コンテナ内で）

docker compose run --rm tricore-dev bash /work/scripts/build.sh
生成物: ./build/test.elf, ./build/test.map

## 3) QEMU起動 + GDB接続

docker compose run --rm tricore-dev bash /work/scripts/launch.sh --elf build/test.elf --gdb

## success log

```c
volatile int counter = 0;

int main(void) {
    for (;;) {
        counter++;
    }
    return 0;
}
```

```bash
Breakpoint 1, main () at /work/src/main.c:3
3       int main(void) {
(gdb) p counter
$1 = 0
(gdb) watch counter
Hardware watchpoint 2: counter
(gdb) c
Continuing.

Hardware watchpoint 2: counter

Old value = 0
New value = 1
main () at /work/src/main.c:5
5               counter++;
(gdb) info reg pc
pc             0x8000006a          0x8000006a <main+2>
```
