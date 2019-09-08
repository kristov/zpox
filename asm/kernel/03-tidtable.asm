; tid_addr_of(): Find the address of a tid in the thread table
;
; Usage:
;   1) put the tid into b
;   2) call "tid_addr_of"
;   3) the address is in ix
;
; Explanation:
;   Only bc and de can be added to ix. However neither of them can be added to
;   each other (bit shifted left). So first hl is used to calculate the byte
;   offset from tid_table_base for this tid. Then hl is copied to de, ix is
;   loaded with the base address of the table and then de is added to ix to
;   give the final result.
;
tid_addr_of:
    ld ix, tid_table_base   ; put base address in ix
    ld h, 0x00              ; zero h ("xor h" didnt seem to work)
    ld l, b                 ; put tid into lower byte
    add hl, hl              ; x2
    add hl, hl              ; x4
    add hl, hl              ; x8
    add hl, hl              ; x16
    ex de, hl               ; de does not have "add de, de"
    add ix, de              ; add de to ix
    ret

; tid_next_free(): Find the next free tid entry after tid
;
; Purpose:
;   The thread table can be fragmented, with empty spaces between valid threads
;   (paused or running). This function is to find the next entry after the
;   current tid that is free. If the current tid is greater than zero and no
;   free threads are found after that tid, the code wraps back around and
;   searches from the start of the thread table back up to tid. If we always
;   search from the beginning early threads would hog the CPU.
;
; Usage:
;   1) put the tid into b
;   2) call "tid_next_free"
;   3) if d == 0xff then ix == address of tid and c == next available tid
;   4) if d == 0x00 then no free space was found
;
; Explanation:
;   First tid_addr_of() is called to set ix to the address of the thread table
;   entry. Then de is reset to the entry size. Then a loop of tid_count_max is
;   started to scan all possible table entries. Each loop adds de to ix to move
;   to the next entry. Unless tid is zero this loop would extend beyond the
;   table. So the tid is subtracted from tid_count_max to give the point where
;   we reset ix to the beginning of the table and reset c to 0. This means we
;   will scan up from the current tid looking for the next free entry, and when
;   we get to the top it will cycle back to the beginning of the table. Because
;   b is controlling the loop we will stop before getting back to the current
;   tid.
;
tid_next_free:
    ld c, b                 ; save the current tid into c
    call tid_addr_of        ; calculate the address of the current tid in the table
    ld de, tid_table_len    ; set de to size of block
    ld b, tid_count_max     ; prepare to loop around tid_count_max times
    ld a, tid_count_max     ; calculate the diff betwen tid and the max table entry
    sub c                   ; a now contains tid_count_max - tid (nr of loops before resetting tid_table_base)
    ld h, a                 ; free up a, h becomes loops until a reset of ix needed
tid_next_block:
    add ix, de              ; shift ix to next block (de is tid_table_len)
    inc c                   ; increment the new tid stored in c
    dec h                   ; decrement h
    jp nz, tid_no_reset     ; if h is not zero skip resetting ix
    ld ix, tid_table_base   ; cycle ix back to beginning of table
    ld c, 0x00              ; cycle new tid back around
tid_no_reset:
    ld a, (ix+0)            ; load status byte into a
    and a                   ; trigger zero flag if zero
    jp z, tid_found         ; found free tid
    djnz tid_next_block
tid_not_found:
    ld de, 0x00             ; prepare return not found
    ret
tid_found:
    ld de, 0xff             ; prepare return found
    ret
