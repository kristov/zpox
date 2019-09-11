ASM = z80asm-gnu

SRCS =
SRCS += 00-variables.asm
SRCS += 01-rst00.asm
SRCS += 02-rst38.asm
SRCS += 03-bootstrap.asm
SRCS += 04-tidtable.asm

all: rom.bin

kernel.bin: kernel.asm $(SRCS)
	$(ASM) -o $@ $<

rom.bin: kernel.bin
	cp kernel.bin rom.bin
	./padd.sh rom.bin 4096

clean:
	rm -f kernel.bin rom.bin
