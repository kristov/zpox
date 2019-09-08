; Variables for the thread table - the length of each entry, the location in
; memory and the maximum number of entries.
;
tid_table_len: equ 0x10     ; size of a process table entry (16)
tid_table_base: equ 0x0104  ; location of table
tid_count_max: equ 0x04     ; maximum number entries in tid table
