    .section .text
    .global _start
    .type   _start, @function

    .extern __DATA_LOAD_START__
    .extern __DATA_START__
    .extern __DATA_END__
    .extern __DATA_SIZE__        /* ★追加 */
    .extern __BSS_START__
    .extern __BSS_END__
    .extern __BSS_SIZE__         /* ★追加 */
    .extern __SDA_WINDOW_BASE__ 
    .extern __STACK_TOP__
    .extern _start_c
    .extern main

_start:
    /* ---- SDA base（任意） ---- */
    movh.a %a0, hi:__SDATA_START__
    lea    %a0, [%a0] lo:__SDATA_START__

    /* ---- A2=src(ROM), A3=dst(RAM) ---- */
    movh.a %a2, hi:__DATA_LOAD_START__
    lea    %a2, [%a2] lo:__DATA_LOAD_START__

    movh.a %a3, hi:__DATA_START__
    lea    %a3, [%a3] lo:__DATA_START__

    /* ---- D5 = DATA SIZE ---- */
    movh   %d5, hi:__DATA_SIZE__
    addi   %d5, %d5, lo:__DATA_SIZE__

.Lcopy_data:
    jz     %d5, .Lclear_bss
    ld.bu  %d0, [%a2+]
    st.b   [%a3+], %d0
    addi   %d5, %d5, -1
    j      .Lcopy_data

    /* ---- zero .bss ---- */
.Lclear_bss:
    movh.a %a3, hi:__BSS_START__
    lea    %a3, [%a3] lo:__BSS_START__

    movh   %d6, hi:__BSS_SIZE__
    addi   %d6, %d6, lo:__BSS_SIZE__
    mov    %d0, 0

.Lzero_bss:
    jz     %d6, .Lcall_c
    st.b   [%a3+], %d0
    addi   %d6, %d6, -1
    j      .Lzero_bss

.Lcall_c:
    /* ---- set SP (a10) before calling C ---- */
    movh.a %a10, hi:__STACK_TOP__
    lea    %a10, [%a10] lo:__STACK_TOP__

    /* reset frame pointer */
    mov.a  %a11, 0

    /* j      _start_c */
    j      main

    .size _start, . - _start
