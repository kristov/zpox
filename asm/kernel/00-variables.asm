; Layout of kernel variables in memory, starting from the first writable
; address (ROM occupies first 1K of address space).
;
;   +--------+--------------------------------------+
;   | 0x0000 | Start of ROM                         |
;   | ...    |                                      |
;   | 0x03ff | End of ROM                           |
;   |--------+--------------------------------------|
;   | 0x0400 | Kernel stack pointer                 |
;   | 0x0401 |                                      |
;   |--------+--------------------------------------|
;   | 0x0402 | Current thread stack pointer         |
;   | 0x0403 |                                      |
;   |--------+--------------------------------------|
;   | 0x0404 | Running thread id                    |
;   |--------+--------------------------------------|
;   | 0x0405 | Thread 0 status (status table start) |
;   | 0x0406 | Thread 1 status                      |
;   | ...    | Thread [X] status                    |
;   | 0x0414 | Thread 15 status (status table end)  |
;   |--------+--------------------------------------|
;   | 0x0415 |                                      |


; Kernel variables and constants
;
k_sp_kernel: equ 0x0400     ; stores stack pointer of the kernel
k_sp_tid: equ 0x0402        ; stores stack pointer of the current thread
k_tid_curr: equ 0x0404      ; the running thread id
k_tid_max: equ 0x10         ; maximum number of threads

; Variables for the thread status table. This is an array of k_tid_max bytes
; where each byte encodes the thread status and any pending signals.
;
k_tids_tab_base: equ 0x0405 ; location of thread status table
k_t_unused: equ 0x00        ; the thread entry is free
k_t_running: equ 0x01       ; the thread is running
k_t_blocked: equ 0x02       ; the thread is blocked
k_t_ready: equ 0x03         ; the thread can be run next
k_sighup: equ 0x01          ; terminate
k_sigint: equ 0x02          ; terminate
k_sigpipe: equ 0x03         ; terminate
k_sigchld: equ 0x04         ; ignore
k_sigstop: equ 0x05         ; block
k_sigcont: equ 0x06         ; run
k_sigtstp: equ 0x07         ; block
k_sigttin: equ 0x08         ; block
k_sigttou: equ 0x09         ; block

; Variables for the thread table. This is an array of structs, where each
; stores the process state (registers, stack pointer).
;
k_tid_tab_base: equ 0x415   ; location of thread table
k_tid_tab_len: equ 0x10     ; size of a process table entry (16)

