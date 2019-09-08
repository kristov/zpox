; This code prepares the kernel to run threads - namely the kernel driver
; threads.
;
k_proc_bootstrap:
    ld sp, 0x7fff           ; set the kernel stack top
    ld (k_sp_kernel), sp    ; store the kernel stack top variable
    ;
    ; INIT file system thread
    ; INIT serial thread
    ; INIT shell thread
    ;
    ei

