; https://github.com/sbelectronics/rc2014/
; basic_work/scbasic/basdisk.asm

; Some routines ripped from the above site related to talking to the compact
; flash card in the rc2014.

I0 .EQU $E0
I1 .EQU I0+1
I2 .EQU I0+2
I3 .EQU I0+3
I4 .EQU I0+4
I5 .EQU I0+5
I6 .EQU I0+6
I7 .EQU I0+7

SETLBA:
    CALL    GETINT          ; get sector number
    OUT     I3, A           ; lba 0..7
    LD      A, 0
    OUT     I4, A           ; lba 8..15
    LD      A, 0
    OUT     I5, A           ; lba 16..23
    LD      A, $E0
    OUT     I6, A           ; lba 23..27
    LD      A, 1            ; number of sectors
    OUT     I2, A
    RET

WAITRDY:
    PUSH    AF
WAITRDYLP:
    in      A,(I7)
    AND     0C0H    ; 40=Ready, 80=Busy
    cp      040H
    JR      NZ, WAITRDYLP
    POP     AF
    RET

WAITDRQ:
    PUSH    AF
WAITDRQLP:
    in      A,(I7)
    AND     08H
    cp      08H
    JR      NZ, WAITDRQLP
    POP     AF
    RET

DREAD:
    CALL    WAITRDY
    CALL    SETLBA
    LD      A, $20
    OUT     (I7), A        ; read command
    CALL    WAITDRQ

rd4Sec:
    PUSH    HL
    LD      c,4
    LD      HL,DISKBUF
rdSec:
    LD      b,128
rdByte:
    IN      A,(I0)
    LD      (HL),A
    iNC     HL
    dec     b
    JR      NZ, rdByte
    dec     c
    JR      NZ, rdSec
    POP     HL
    RET

DWRITE:
    CALL    WAITRDY
    CALL    SETLBA
    LD      A, $30
    OUT     (I7), A       ; write command
    CALL    WAITDRQ

    PUSH    HL
    LD      c,4
    LD      HL,DISKBUF
wrSec:
    LD      b,128
wrByte:
    LD      A,(HL)
    OUT     (I0),A
    iNC     HL
    dec     b
    JR      NZ, wrByte
    dec     c
    JR      NZ, wrSec
    POP     HL
    RET

DINIT:
    CALL    WAITRDY
    LD      A,1
    OUT     I1, A           ; 8-bit mode
    LD      A, $EF
    OUT     I7, A           ; execute command

    CALL    WAITRDY

    LD      A, $82
    OUT     I1, A           ; turn of write cache
    LD      A, $EF
    OUT     I7, A           ; execute command

    CALL    WAITRDY

    LD      A, $E0          ; master
    OUT     I6, A
    LD      A, $EC          ; get disk id
    OUT     I7, A

    CALL    WAITDRQ

    ; rd4Sec will return to caller
    JP      rd4Sec

