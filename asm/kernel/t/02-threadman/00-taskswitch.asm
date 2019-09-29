include 'variables.asm'

; The test goes as follows:
;
;   * the current running thread is tid 1
;   * tid 2 is not runnable, tid 3 is the next thread that should run
;   * tid 1 table entry is filled with ff's (they should get overwritten)
;   * tid 3 table entry is filled with 0xb[1-6] and fake sp (0x3030)
;   * tid 1 sp variable is set to 0x2020
;   * fake 0xa[1-6] values are pushed onto the stack, simulating interrupt
;   * call task switch routine
;
; The result should be:
;
;   * the ff's in tid 1 table are overridden with 0xa[1-6] and 0x2020
;   * tid 3 is selected as the next runnable thread
;   * tid 3 table values replace 0xa[1-6] on the stack
;   * the k_sp_tid variable is set to 0x3030
;
main:
    ld sp, 0x01a4           ; set the stack top
    ld (k_sp_kernel), sp    ; set the kernel stack variable

    ; Set thread status table entry 1 and 3 to runnable
    ld a, k_t_running       ; set a to running state value
    ld de, k_tids_tab_base  ; set de to location of table
    inc de                  ; go to next entry
    ld (de), a              ; set status byte to in-use
    inc de                  ; go to next entry
    inc de                  ; skip over entry 2 (leave it zero)
    ld (de), a              ; set status byte to in-use

    ; Tell the kernel thread 0 is currently running
    ld a, 0x01              ; current thread 1
    ld (k_tid_curr), a      ; set kernel variable for current tid

    ; Copy proc_a_regs to thread table
    ld bc, 0x0010           ; prepare to copy 16 bytes
    ld hl, k_tid_tab_base   ; copy to tid table
    ld de, 0x10             ; prepare to add 16 to hl (thread 1)
    add hl, de              ; add to hl
    ex de, hl               ; swap so de is destination address
    ld hl, proc_a_regs      ; source data is proc_a_regs defb
    ldir                    ; block copy to tid table

    ; Copy proc_b_regs to thread table
    ld bc, 0x0010           ; prepare to copy 16 bytes
    ld hl, k_tid_tab_base   ; copy to tid table
    ld de, 0x30             ; prepare to add 48 to hl (thread 3)
    add hl, de              ; add to hl
    ex de, hl               ; swap so de is destination address
    ld hl, proc_b_regs      ; source data is proc_a_regs defb
    ldir                    ; block copy to tid table

    ld bc, 0x2020           ; fake sp value
    ld (k_sp_tid), bc
    ld bc, 0xa6a6           ; iy
    push bc
    ld bc, 0xa5a5           ; ix
    push bc
    ld bc, 0xa4a4           ; hl
    push bc
    ld bc, 0xa3a3           ; de
    push bc
    ld bc, 0xa2a2           ; bc
    push bc
    ld bc, 0xa1a1           ; af
    push bc
    call k_task_switch      ; do a task switch
    halt

include '../../02-threadman.asm'
include '../../04-tidtable.asm'

proc_a_regs:
    defb 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
    ; defb 0xa1,0xa1,0xa2,0xa2,0xa3,0xa3,0xa4,0xa4,0xa5,0xa5,0xa6,0xa6,0xa7,0xa7,0xff,0xff

proc_b_regs:
    defb 0xb1,0xb1,0xb2,0xb2,0xb3,0xb3,0xb4,0xb4,0xb5,0xb5,0xb6,0xb6,0x30,0x30,0xff,0xff
