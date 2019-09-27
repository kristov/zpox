include 'variables.asm'

main:
    ld a, k_t_running       ; set a to running state value
    ld de, k_tids_tab_base  ; set de to location of table
    ld (de), a              ; set status byte to in-use
    inc de                  ; go to next entry
    ld (de), a              ; set status byte to in-use
    inc de                  ; skip over entry 1 (leave it zero)
    ld (de), a              ; set status byte to in-use
test:
    ld a, 0x01              ; prepare to load 0 at location
    ld (k_tid_curr), a      ; current tid == 0
    call k_tid_next_free    ; should get 4 loaded in l
    halt

include '../../04-tidtable.asm'
