ASM = z80asm-gnu

SRCS =
SRCS += 00-variables.asm
SRCS += 01-interrupts.asm
SRCS += 02-threadman.asm
SRCS += 04-tidtable.asm

all: rom.bin

kernel.bin: kernel.asm $(SRCS)
	$(ASM) -o $@ $<

rom.bin: kernel.bin
	cp kernel.bin rom.bin
	./padd.sh rom.bin 4096

clean:
	rm -f kernel.bin rom.bin
