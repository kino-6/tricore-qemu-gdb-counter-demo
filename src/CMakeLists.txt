cmake_minimum_required(VERSION 3.13)
project(test_tricore C ASM)

# add asm
add_executable(test.elf
  crt0.S
  start.c
  main.c
)

# debug build
target_compile_options(test.elf PRIVATE
  -g -O0 -ffreestanding -fno-builtin -fno-stack-protector
  -gdwarf-2 -gstrict-dwarf  # recommend
)

target_compile_options(test.elf PRIVATE
  $<$<COMPILE_LANGUAGE:C>:-msmall-data=0>
)

# debug
set(CMAKE_VERBOSE_MAKEFILE ON)

# linker
target_link_options(test.elf PRIVATE
  -T${CMAKE_SOURCE_DIR}/link.ld
  -nostdlib
  -Wl,-Map=${CMAKE_BINARY_DIR}/test.map
)
