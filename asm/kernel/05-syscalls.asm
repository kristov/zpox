k_proc_syscall:
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
    ld a, 0x11
    ret

k_syscall_read:
    ld a, 0x12
    ret

k_syscall_write:
    ld a, 0x13
    ret

k_syscall_tab:
    dw k_syscall_nop
    dw k_syscall_open
    dw k_syscall_read
    dw k_syscall_write
