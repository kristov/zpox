ASM = z80asm-gnu

SRCS =
SRCS += 00-variables.asm
SRCS += 01-interrupt.asm
SRCS += 02-tidtable.asm

all: kernel.bin

kernel.bin: kernel.asm
	$(ASM) -o $@ $<

kernel.asm: $(SRCS)
	cat $(SRCS) > $@

clean:
	rm -f kernel.bin kernel.asm
