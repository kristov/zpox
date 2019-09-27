ASM = z80asm-gnu
Z8T=/home/ceade/src/personal/github/z8t/z8t

TESTS =
TESTS += 00-emptytable.bin
TESTS += 01-wrap.bin
TESTS += 02-last.bin
TESTS += 03-setstatus.bin

all: $(TESTS)

%.bin: %.asm
	$(ASM) -o $@ $<

tests: $(TESTS)
	$(Z8T) -r 00-emptytable.bin -t 00-emptytable.tspec
	$(Z8T) -r 01-wrap.bin -t 01-wrap.tspec
	$(Z8T) -r 02-last.bin -t 02-last.tspec
	$(Z8T) -r 03-setstatus.bin -t 03-setstatus.tspec

clean:
	rm -f $(TESTS)
