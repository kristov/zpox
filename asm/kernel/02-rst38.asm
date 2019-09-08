k_proc_hardint:
    di                      ; disable interrupts
    ld (k_sp_tid), sp       ; save the current thread sp
    ld sp, (k_sp_kernel)    ; load the kernel sp
    push af                 ; save all registers on the kernel stack
    push bc
    push de
    push hl
    push ix
    push iy
    call k_task_switch      ; do a task switch
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

k_task_switch:
    nop
