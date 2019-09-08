; Find an entry in an empty table. The table is 4 entries long, each
; entry is 16 bytes.

tid_table_len: equ 0x10     ; size of a process table entry (16)
tid_table_base: equ 0x0104  ; location of table
tid_count_max: equ 0x04     ; maximum number entries in tid table

main:
    ld b, 0x00              ; current tid == 0
    call tid_next_free      ; should get 1 loaded in c
    halt

include 'tidtable.asm'

data:
    defb 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x02
