include '../../00-variables.asm'

main:
    ld a, 0x00              ; prepare to load 0 at location
    ld (k_tid_curr), a      ; current tid == 0
    call k_tid_next_free    ; should get 1 loaded in c
    halt

include '../../04-tidtable.asm'
