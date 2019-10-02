k_rst00:
    di
    jp k_int_bootstrap
    nop
    nop
    nop
    nop

k_rst08:
    di
    jp k_int_syscall
    nop
    nop
    nop
    nop

k_rst10:
    di
    jp k_int_reti
    nop
    nop
    nop
    nop

k_rst18:
    di
    jp k_int_reti
    nop
    nop
    nop
    nop

k_rst20:
    di
    jp k_int_reti
    nop
    nop
    nop
    nop

k_rst28:
    di
    jp k_int_reti
    nop
    nop
    nop
    nop

k_rst30:
    di
    jp k_int_reti
    nop
    nop
    nop
    nop

k_rst38:
    di
    jp k_int_switch
    nop
    nop
    nop
    nop

k_int_reti:
    ei                      ; enable interrupts
    reti                    ; return from interrupt

k_int_bootstrap:
    ld sp, 0x7fff           ; set the kernel stack top
    ld (k_sp_kernel), sp    ; store the kernel stack top variable
    ;
    ; Fill in thread table entry 0
    ; INIT file system thread
    ; INIT serial thread
    ; INIT shell thread
    ; Configure the CTC
    ;
    ei                      ; after this the CTC will fire to run a thread
k_int_mainloop:
    nop                     ; this is what the kernel will do until interrupt
    jp k_int_mainloop       ; enter an infinite loop

k_int_syscall:
    ld (k_sp_tid), sp       ; save the current thread sp
    ld sp, (k_sp_kernel)    ; load the kernel sp
    push iy                 ; save all registers on the kernel stack
    push ix
    push hl
    push de
    push bc
    push af
    call k_proc_syscall     ; process the syscall
    pop af                  ; restore registers from kernel stack
    pop bc
    pop de
    pop hl
    pop ix
    pop iy
    ld (k_sp_kernel), sp    ; save the kernel sp
    ld sp, (k_sp_tid)       ; load the current thread sp
    jp k_int_reti          ; jump to return

k_int_switch:
    ld (k_sp_tid), sp       ; save the current thread sp
    ld sp, (k_sp_kernel)    ; load the kernel sp
    push iy                 ; save all registers on the kernel stack
    push ix
    push hl
    push de
    push bc
    push af
    call k_proc_switch      ; do a task switch
    pop af                  ; restore registers from kernel stack
    pop bc
    pop de
    pop hl
    pop ix
    pop iy
    ld (k_sp_kernel), sp    ; save the kernel sp
    ld sp, (k_sp_tid)       ; load the current thread sp
    jp k_int_reti          ; jump to return

