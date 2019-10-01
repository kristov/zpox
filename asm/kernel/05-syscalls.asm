; k_proc_syscall(): Process a syscall
;
; The way to do syscalls from a user thread is:
;   * Push arguments onto the stack right to left
;   * Push syscall id onto the stack
;   * Execute rst08 (pushes return address onto stack)
;
; | Bottom of stack |
; |-----------------|
; | argN            |
; | ...             |
; | arg2            |
; | arg1            |
; | syscall id      |
; | return address  |
; +-----------------+
;
k_proc_syscall:
    ld ix, (k_sp_tid)       ; load the process sp into ix
    ld a, (ix+3)            ; load the syscall id from af push
    add a, a                ; multiply a by 2
    ld h, 0x00              ; clear high byte of hl
    ld l, a                 ; set lower byte to idx * 2
    ld de, k_syscall_tab    ; load base of the jump table
    add hl, de              ; hl is now the location of the sub address in the table
    ld a, (hl)              ; load first byte of address into a
    inc hl                  ; move to second byte of word
    ld h, (hl)              ; load second byte into upper byte of hl
    ld l, a                 ; load first byte into lower byte of hl
    jp (hl)                 ; jump to that address

k_syscall_nop:
    ld a, 0x10
    ret

k_syscall_open:
    ld h, (ix+7)            ; load mode
    ld l, (ix+6)            ; load flags
    ld b, (ix+5)            ; load second byte of filename address
    ld c, (ix+4)            ; load first byte of filename address
    ; convert filename to node id
    ; convert node id to thread id of managing driver thread
    ; create file handle entry in global file table
    ; set file descriptor in thread table to global file table id
    ; send signal to thread id of managing thread that something was opened
    ; put file descriptor in hl
    ret

; When a read is called for an empty buffer the calling thread needs to be
; blocked and a task switch initiated. When something writes to the buffer the
; reading thread needs to be woken up and the code must return to this code to
; resume the read. This means the kernel stack must have the address of the
; "call k_proc_syscall" loaded on the top of the stack so the ret at the end
; can return to the rst08 interrupt handler and restore the process state.
;
k_syscall_read:
    ld h, (ix+7)            ; load second byte of destination buffer
    ld l, (ix+6)            ; load first byte of destination buffer
    ld b, (ix+5)            ; load count
    ld c, (ix+4)            ; load file descriptor
    ; convert file descriptor to global file table id
    ; calculate diff between write and read pointers
    ; if diff is zero put thread in blocked and task switch
    ; copy count bytes into destination buffer
    ; put count into hl
    ret

k_syscall_write:
    ld h, (ix+7)            ; load second byte of source buffer
    ld l, (ix+6)            ; load first byte of source buffer
    ld b, (ix+5)            ; load count
    ld c, (ix+4)            ; load file descriptor
    ; convert file descriptor to global file table id
    ; calculate diff between write and read pointers
    ; if diff is zero put thread in blocked and task switch
    ; copy count bytes into destination buffer
    ; put count into hl
    ret

k_syscall_tab:
    dw k_syscall_nop
    dw k_syscall_open
    dw k_syscall_read
    dw k_syscall_write
