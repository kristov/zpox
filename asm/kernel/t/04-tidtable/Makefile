ASM = z80asm-gnu

TESTS =
TESTS += 00-emptytable.bin
TESTS += 01-wrap.bin
TESTS += 02-last.bin

all: $(TESTS)

%.bin: %.asm
	$(ASM) -o $@ $<

clean:
	rm -f $(TESTS)
