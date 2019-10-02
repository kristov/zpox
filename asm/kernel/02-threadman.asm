; k_proc_switch(): Calculate the next thread to run
;
; Purpose:
;   Find the next runnable thread (if applicable) and switch to it.
;
; Usage:
;   1) put the desired tid into a
;   2) call "k_tids_addr_of"
;   3) the address is in de
;
; Explanation:
;   This routine is called from the CTC interrupt (rst38). That interrupt
;   pushes the currently running register values onto the kernel stack. So when
;   this routine is called it is either going to leave the stack unmodified
;   because there is no thread switch possible, or it will copy the contents of
;   the stack into the main thread table for backup and then copy another
;   threads values overwriting the stack. When the routine returns to the
;   interrupt it pops whatever was on the stack back into registers and resumes
;   operation.
;
k_proc_switch:
    call k_tid_next_run     ; find the next runnable tid (in l)
    ld a, 0x00              ; prepare to test if l is zero
    sub l                   ; subtract l from 0
    ret z                   ; TODO: what if l is zero?? (no threads running)
    ld a, (k_tid_curr)      ; load the running tid into a
    sub l                   ; test if its the same tid
    ret z                   ; return if we would be switching to the same tid
    ld a, l                 ; prepare to save the new tid in variable
    ld (k_tid_next), a      ; save the next tid
    ld a, (k_tid_curr)      ; load the running tid into a again
    call k_tid_addr_of      ; populate de with address of tid in table
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
    ld a, (k_tid_next)      ; load the next tid in a
    call k_tid_addr_of      ; populate de with address of new tid in table
    ld bc, 0x0e             ; prepare to copy 14 bytes (7 x 16 bit registers)
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
