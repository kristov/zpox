; Find an entry in a table where the next free entry is before the current tid
; (wrapping).
;
; The table size is set to 4, entry 0 has its first byte marked as in-use. Then
; entries 2 and 3 are loaded with the test data.
;
tid_table_len: equ 0x16     ; size of a process table entry (16)
tid_table_base: equ 0x0104  ; location of table
tid_count_max: equ 0x04     ; maximum number entries in tid table

main:
    ld hl, 0xff             ; set entry 0 to in-use
    ld (tid_table_base), hl ; mark zeroth in use
    ld a, 0x02              ; copy 2 blocks, leave 105 free
    ld hl, 0x0106           ; load hl
copy:
    ld bc, tid_table_len    ; amount of data
    ex de, hl               ; copy hl to de
    ld hl, data             ; src test data
    ldir
    ex de, hl               ; copy hl to de
    add hl, bc              ; increment hl by bc
    dec a                   ; count down
    jr z, test              ; begin test once X blocks are loaded
    jr copy                 ; goto copy
test:
    ld b, 0x02              ; current tid == 2
    call tid_next_free      ; should get 5 loaded in c
    halt

include 'tidtable.asm'

data:
    defb 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x02
