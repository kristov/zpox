ASM = z80asm-gnu
Z8T_LOC=/home/ceade/src/personal/github/z8t

TESTS =
TESTS += 00-emptytable.bin
TESTS += 01-wrap.bin
TESTS += 02-last.bin

all: $(TESTS)

%.bin: %.asm
	$(ASM) -o $@ $<

clean:
	rm -f $(TESTS)
