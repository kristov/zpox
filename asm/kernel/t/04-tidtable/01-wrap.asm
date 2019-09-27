; Find an entry in a table where the next free entry is before the current tid
; (wrapping).
;
include 'variables.asm'

main:
    ld a, k_t_running       ; set a to running state value
    ld de, k_tids_tab_base  ; set de to location of table
    ld (de), a              ; set status byte to in-use
    inc de                  ; go to next entry
    inc de                  ; skip over entry 1 (leave it zero)
    ld (de), a              ; set status byte to in-use
    inc de                  ; go to next entry
    ld (de), a              ; set status byte to in-use
test:
    ld a, 0x02              ; prepare to load 2 at location
    ld (k_tid_curr), a      ; current tid == 2
    call k_tid_next_free    ; should skip over tid 3 and 0 and return 1
    halt

include '../../04-tidtable.asm'
