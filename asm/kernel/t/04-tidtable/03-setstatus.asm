include 'variables.asm'

main:
    ld a, 0xf8              ; upper 5 bits of status var set
    ld de, k_tids_tab_base  ; set de to location of table
    ld (de), a              ; save this in tid 0 location
test:
    ld a, 0x00              ; prepare to update tid 0 status
    ld c, k_t_running       ; load c with desired state
    call k_tid_set_status   ; set the status
    ld a, (de)              ; a should now be 11111001 (0xf9)
    halt

include '../../04-tidtable.asm'
