; Find an entry in a table where the next free entry is before the current tid
; (wrapping).
;
include '../../00-variables.asm'

main:
    ld hl, 0xff             ; set entry 0 to in-use
    ld (k_tid_tab_base), hl ; mark zeroth in use
    ld a, 0x02              ; copy 2 blocks, leave 106 free
    ld hl, 0x0125           ; load hl
copy:
    ld bc, k_tid_tab_len    ; amount of data
    ex de, hl               ; copy hl to de
    ld hl, data             ; src test data
    ldir
    ex de, hl               ; copy hl to de
    add hl, bc              ; increment hl by bc
    dec a                   ; count down
    jr z, test              ; begin test once X blocks are loaded
    jr copy                 ; goto copy
test:
    ld a, 0x02              ; prepare to load 0 at location
    ld (k_tid_curr), a      ; current tid == 0
    call k_tid_next_free    ; should get 1 loaded in l
    halt

include '../../04-tidtable.asm'

data:
    defb 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x02
