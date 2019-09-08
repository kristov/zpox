; Variables for key kernel routines.
;
k_proc_syscall: equ 0x38    ; syscall handler

; Stack pointer storage locations.
;
k_sp_kernel: equ 0x0100     ; stores sp of the kernel
k_sp_tid: equ 0x0102        ; stores sp of the current thread

; Variables for the thread table - the length of each entry, the location in
; memory and the maximum number of entries.
;
tid_table_len: equ 0x10     ; size of a process table entry (16)
tid_table_base: equ 0x0104  ; location of table
tid_count_max: equ 0x04     ; maximum number entries in tid table

