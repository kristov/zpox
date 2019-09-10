; Variables for key kernel routines.
;
k_proc_syscall: equ 0x38    ; syscall handler

; Stack pointer storage locations.
;
k_sp_kernel: equ 0x0100     ; stores sp of the kernel
k_sp_tid: equ 0x0102        ; stores sp of the current thread

; Kernel variables
;
k_tid_curr: equ 0x0104      ; the running thread id

; Variables for the thread table - the length of each entry, the location in
; memory and the maximum number of entries.
;
k_tid_tab_len: equ 0x10     ; size of a process table entry (16)
k_tid_tab_base: equ 0x0105  ; location of table
k_tid_max: equ 0x04         ; maximum number entries in tid table

; There is space for 8 kernel threads in the lower 32Kb of memory. Each is
; given 4Kb of space for code, heap and stack. This gives 8 possible drivers.
;
k_proc0_sp: equ 0x1000      ; stack pointer for proc 0
k_proc1_sp: equ 0x2000      ; stack pointer for proc 1
k_proc2_sp: equ 0x3000      ; stack pointer for proc 2
k_proc3_sp: equ 0x4000      ; stack pointer for proc 3
k_proc4_sp: equ 0x5000      ; stack pointer for proc 4
k_proc5_sp: equ 0x6000      ; stack pointer for proc 5
k_proc6_sp: equ 0x7000      ; stack pointer for proc 6
k_proc7_sp: equ 0x8000      ; stack pointer for proc 7
