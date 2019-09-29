ASM = z80asm-gnu
Z8T=/home/ceade/src/personal/github/z8t/z8t

TESTS =
TESTS += 00-taskswitch.bin

all: $(TESTS)

%.bin: %.asm
	$(ASM) -o $@ $<

tests: $(TESTS)
	$(Z8T) -r 00-taskswitch.bin -t 00-taskswitch.tspec

clean:
	rm -f $(TESTS)
