# Syscalls

## read()

Reads some data from a file descriptor.

* The kernel looks up the global file descriptor index from the thread `fd_tab` table in the thread
* Locate the `global_descriptor` entry from this id.
* If the read blocked flag is set change the thread state to Blocked and initiate a context switch.
* If the wtid variable is zero, reset the pointers and send an EOF to the reader.
* If the readp variable equals the writep variable set the read blocked flag change the thread state to Blocked and initiate a context switch.
* Copy a byte from the buffer to the destination address and advance the readp variable.
* Loop to readp == writep check.
* If we fall out of the loop ok then return to the process.

                    ; get address of bytes to read into X
                    ; get the dest address
                    ; if *X > 256 subtract 256 from *X and set a = 256
                    ; else set a = *X
        ld b, a     ; a == nr of bytes to read in this chunk
    loop:
                    ; copy byte from buffer to dest address and advance dest address
                    ; check if (readp + 1) == write p
                    ; if so add b back to *X, set the read blocked flag then jump to context_switch
                    ; increment readp
        djnz loop
                    ; unset write blocked flag
        ret         ; return to kernel syscall interrupt

## write

