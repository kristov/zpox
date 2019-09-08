scratch: equ 0x40

; Software interrupts (rst 0x08) will hopefully not require a context
; switch (ie: they are non-blocking syscalls) so we use the register
; swapping opcodes to not require pushing register values onto the thread
; stack. If however this syscall turns out to be blocking we need to
; initiate a task switch by swapping the thread registers back in and
; jumping to the regular hardware interrupt routine (skipping the di that
; was already made).
;
org 0x08
software_interrupt:
    di
    ex af
    exx
    call process_syscall
    exx
    ex af
    ei
    reti

; Because hardware interrupts are usually going to initiate a thread
; context switch the code here does not use the alternate register set.
; Instead it saves registers on the thread stack and then performs the
; context switch.
;
org 0x38
hardware_interrupt:
    di                          ; disable interrupts
saveregscratch:
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    ld (scratch), sp            ; save sp
    ld sp, (spkernel)           ; restore kernel sp
    call task_switch            ; process the task switch
restscratchreg:
    ld (spkernel), sp           ; save kernel sp
    ld sp, (scratch)            ; restore sp
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ei                          ; enable interrupts
    reti                        ; jump to pc

task_switch:
    ld iy, (thread_table_end)   ; one byte past the last byte of thread table entry 255
    ld b, 256                   ; start from current thread id and descend
    ld a, (current_tid)         ; the current thread id
task_switch_loop:
    ; increment a
    ; ???
    djnz first_loop
    ret

process_syscall:
    ; process syscall
    ; if task switch:
    ;   exx                     ; switch thread back in
    ;   ex af                   ; switch thread af back in
    ;   pop bc                  ; discard return address from kernel stack
    ;   jp saveregscratch       ; jump to task switch code
    ret
