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

; k_task_switch(): Calculate the next thread to run
;
; Purpose:
;   Find the next runnable thread (if applicable) and switch to it.
;
k_task_switch:
    call k_tid_next_run     ; find the next runnable tid (in c)
    ld a, (k_tid_curr)      ; load the running tid into a
    sub c                   ; test if its the same tid
    ret z                   ; return if we would be switching to the same tid
    ; pop and copy all registers to tid register table
    ; copy and push all registers from new tid
