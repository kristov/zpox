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

; k_task_switch(): Calculate the next thread to run
;
; Purpose:
;   Find the next runnable thread (if applicable) and switch to it.
;
k_task_switch:
    call k_tid_next_run     ; find the next runnable tid (in c)
    ld a, c                 ; prepare to test if c is zero
    ret z                   ; TODO: what if c is zero?? (no threads running)
    ld a, (k_tid_curr)      ; load the running tid into a
    sub c                   ; test if its the same tid
    ret z                   ; return if we would be switching to the same tid
    ; TODO: call function to calculate de based on index in a
    ld de, k_tid_tab_base   ; REPLACE
    ld a, c                 ; save the new tid into a
    ld bc, 0x0e             ; prepare to copy 14 bytes (7 x 16 bit registers)
    ld hl, 0x00             ; prepare to load hl with sp
    add hl, sp              ; set hl to the stack pointer
    inc hl                  ; the top of the stack is the return address, skip
    inc hl                  ; the second byte of the return address
    ldi                     ; a
    ldi                     ; f
    ldi                     ; b
    ldi                     ; c
    ldi                     ; d
    ldi                     ; e
    ldi                     ; h
    ldi                     ; l
    ldi                     ; i
    ldi                     ; x
    ldi                     ; i
    ldi                     ; y
    ld hl, k_sp_tid         ; load hl with the location of the tid sp
    ldi                     ; s
    ldi                     ; p
    ; TODO: call function to calculate de based on index in a
    ld de, k_tid_tab_base   ; REPLACE
    ld bc, 0x0c             ; prepare to copy 12 bytes (6 x 16 bit registers)
    ld hl, 0x00             ; prepare to load hl with sp
    add hl, sp              ; set hl to the stack pointer
    inc hl                  ; the top of the stack is the return address, skip
    inc hl                  ; the second byte of the return address
    ex de, hl               ; swap source and destination (copying back to stack)
    ldi                     ; a
    ldi                     ; f
    ldi                     ; b
    ldi                     ; c
    ldi                     ; d
    ldi                     ; e
    ldi                     ; h
    ldi                     ; l
    ldi                     ; i
    ldi                     ; x
    ldi                     ; i
    ldi                     ; y
    ld de, k_sp_tid         ; load de with the location of the tid sp
    ldi                     ; s
    ldi                     ; p
    ret
