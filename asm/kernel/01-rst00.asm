; WARNING! This code must compile to exactly 56 bytes. This is the purpose of
; the padding nop's at the end. This is because the next file appended after is
; the 0x38 interrupt mode 1 handler.
;
k_rst00:
    di                      ; disable interrupts until after bootstrap
    jp k_proc_bootstrap     ; jump to kernel bootstrap
    nop
    nop
    nop
    nop

; Handler for software interrupts (syscalls). The thread state is saved on the
; kernel stack to not pollute the thread stack and surprise anyone.
;
k_rst08:
    di                      ; disable interrupts
    ld (k_sp_tid), sp       ; save the current thread sp
    ld sp, (k_sp_kernel)    ; load the kernel sp
    push af                 ; save all registers on the kernel stack
    push bc
    push de
    push hl
    push ix
    push iy
    call k_proc_syscall     ; process the syscall
    pop iy                  ; restore registers from kernel stack
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ld (k_sp_kernel), sp    ; save the kernel sp
    ld sp, (k_sp_tid)       ; load the current thread sp
    ei                      ; enable interrupts
    reti                    ; return from interrupt

k_rst08_padding:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

