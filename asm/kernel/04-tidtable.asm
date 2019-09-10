; k_tid_addr_of(): Find the address of a tid in the thread table
;
; Purpose:
;   The tid specifies an index into the thread table. The purpose of this
;   function is to take a tid and turn it into an address.
;
; Usage:
;   1) call "k_tid_addr_of"
;   2) the address is in ix
;
; Explanation:
;   Only bc and de can be added to ix. However neither of them can be added to
;   each other (bit shifted left). So first hl is used to calculate the byte
;   offset from k_tid_tab_base for this tid. Then hl is copied to de, ix is
;   loaded with the base address of the table and then de is added to ix to
;   give the final result.
;
; Registers used:
;
;   a:  the current tid
;   hl: multiplication of tid
;   de: transfer hl to ix
;   ix: address of tid entry in memory
;
k_tid_addr_of:
    ld ix, k_tid_tab_base   ; put base address in ix
    ld h, 0x00              ; zero h ("xor h" didnt seem to work)
    ld a, (k_tid_curr)      ; load current tid into a
    ld l, a                 ; move it to l
    add hl, hl              ; x2
    add hl, hl              ; x4
    add hl, hl              ; x8
    add hl, hl              ; x16
    ex de, hl               ; de does not have "add de, de"
    add ix, de              ; add de to ix
    ex de, hl               ; swap back as de might have useful things
    ret

; k_tid_find_status(): Find the next tid entry after tid with a given status
;
; Purpose:
;   The thread table can be fragmented, with empty spaces between valid threads
;   (paused or running). This function is to find the next entry after the
;   current tid that has a certain status. If the current tid is greater than
;   zero and no free threads are found after that tid, the code wraps back
;   around and searches from the start of the thread table back up to tid. If
;   we always search from the beginning early threads would hog the CPU.
;
; Usage:
;   1) put the desired status into c
;   2) call "k_tid_find_status"
;   3) if l != 0 then ix == address of tid and l == the new tid
;   4) if l == 0 then no thread of that status was found (tid 0 is reserved)
;
; Explanation:
;   First k_tid_addr_of() is called to set ix to the address of the thread table
;   entry. Then de is reset to the entry size. Then a loop of k_tid_max is
;   started to scan all possible table entries. Each loop adds de to ix to move
;   to the next entry. Unless tid is zero this loop would extend beyond the
;   table. So the tid is subtracted from k_tid_max to give the point where
;   we reset ix to the beginning of the table and reset l to 0. This means we
;   will scan up from the current tid looking for the next free entry, and when
;   we get to the top it will cycle back to the beginning of the table. Because
;   b is controlling the loop we will stop before getting back to the current
;   tid.
;
; Registers used:
;
;   a:  misc
;   b:  loop variable for the thread table
;   l:  The return tid
;   h:  number of entries from current tid until end of table
;   de: size of a block
;   ix: address of tid entry in memory
;
k_tid_find_status:
    call k_tid_addr_of      ; calculate the address of the current tid in the table
    ld a, (k_tid_curr)      ; load current tid into a
    ld l, a                 ; move it to l
    ld a, k_tid_max         ; calculate the diff betwen tid and the max table entry
    sub l                   ; a now contains k_tid_max - tid (nr of loops before resetting k_tid_tab_base)
    ld h, a                 ; free up a, h becomes loops until a reset of ix needed
    ld b, k_tid_max         ; prepare to loop around k_tid_max times
    ld de, k_tid_tab_len    ; set de to size of block
k_tid_next_block:
    add ix, de              ; shift ix to next block (de is k_tid_tab_len)
    inc l                   ; increment the new tid stored in l
    dec h                   ; decrement h
    jp nz, k_tid_no_reset   ; if h is not zero skip resetting ix
    ld ix, k_tid_tab_base   ; cycle ix back to beginning of table
    ld l, 0x00              ; cycle new tid back around
k_tid_no_reset:
    ld a, (ix+0)            ; load status byte into a
    sub c                   ; subtract the wanted status
    jp z, k_tid_found       ; if zero we found an entry
    djnz k_tid_next_block
    ld l, 0x00              ; not found
k_tid_found:
    ret

; k_tid_next_free(): Find the next empty thread table entry
;
; Purpose:
;   Finds the tid and address of the next empty thread.
;
; Usage:
;   1) call "k_tid_next_free"
;   2) if c != 0 then ix == address of tid and c == next runnable tid
;   3) if c == 0 then no runnable threads were found (tid 0 is reserved)
;
k_tid_next_free:
    ld c, 0x00              ; looking for status zero meaning free
    call k_tid_find_status  ; use status search routine
    ret

; k_tid_next_run(): Find the next runnable thread
;
; Purpose:
;   Finds the tid and address of the next runnable thread.
;
; Usage:
;   1) call "k_tid_next_run"
;   2) if c != 0 then ix == address of tid and c == next runnable tid
;   3) if c == 0 then no runnable threads were found (tid 0 is reserved)
;
k_tid_next_run:
    ld c, 0x01              ; look for running status
    call k_tid_find_status  ; use status search routine
    ret

