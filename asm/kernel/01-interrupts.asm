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

; k_proc_hardint(): Respond to a hardware interrupt
;
; Purpose:
;   This function is to be called on the CTC interrupt and prepare for a thread
;   switch. It is to be located at 0x038 (the jump point for IM1). It needs to
;   somehow save the running thread context and restore it afterwards.
;
; Explanation:
;   My first thought was to use the shadow registers to save the thread context
;   while the interrupt was being handled. However I encountered two problems
;   with this: 1) It is likely that a thread switch will happen every time this
;   is called meaning that the registers will need to be swapped back in so
;   they can be saved somewhere before switching to another thread, and 2) The
;   ix and iy registers are not shadowed meaning threads could not use them
;   reliably. Therefore I decided to push everything onto the stack. I use the
;   kernel stack instead of the thread stack so that thread code doesn't run
;   out of stack space unpredictably.
;
k_proc_hardint:
    di                      ; disable interrupts
    ld (k_sp_tid), sp       ; save the current thread sp
    ld sp, (k_sp_kernel)    ; load the kernel sp
    push iy                 ; save all registers on the kernel stack
    push ix
    push hl
    push de
    push bc
    push af
    call k_task_switch      ; do a task switch
    pop af                  ; restore registers from kernel stack
    pop bc
    pop de
    pop hl
    pop ix
    pop iy
    ld (k_sp_kernel), sp    ; save the kernel sp
    ld sp, (k_sp_tid)       ; load the current thread sp
    ei                      ; enable interrupts
    reti                    ; return from interrupt
