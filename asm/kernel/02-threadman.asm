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
