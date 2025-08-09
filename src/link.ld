/* link.ld */
ENTRY(_start)

MEMORY {
  rom (rx)  : ORIGIN = 0x80000000, LENGTH = 512K   /* FLASH / ROM */
  ram (rwx) : ORIGIN = 0xA1000000, LENGTH = 256K   /* SRAM        */
}

__STACK_SIZE = 8K;

/* 64KiB SDAウィンドウの中心。a0 に入れる値 */
PROVIDE(__SDA_WINDOW_BASE__ = ORIGIN(ram) + 0x8000);
PROVIDE(__SDATA_START__    = __SDA_WINDOW_BASE__);

SECTIONS
{
  .text : ALIGN(4) {
    KEEP(*(.start))
    *(.text .text.*)
    *(.rodata .rodata.*)
  } > rom

  .data : ALIGN(4) {
    __DATA_START__ = .;
    *(.data .data.*)
    __DATA_END__ = .;
  } > ram AT > rom
  __DATA_LOAD_START__ = LOADADDR(.data);
  __DATA_SIZE__       = SIZEOF(.data);

  .bss (NOLOAD) : ALIGN(4) {
    __BSS_START__ = .;
    *(.bss .bss.*)
    *(COMMON)
    __BSS_END__ = .;
  } > ram
  __BSS_SIZE__ = SIZEOF(.bss);

  . = ORIGIN(ram) + LENGTH(ram);
  . = . - __STACK_SIZE;
  . = ALIGN(8);
  __STACK_TOP__ = .;

  /DISCARD/ : { *(.comment*) *(.eh_frame*) }
}
