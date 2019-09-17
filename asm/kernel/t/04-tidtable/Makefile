ASM = z80asm-gnu
CC=gcc
CFLAGS=-Wall -Werror -ggdb
CCK_LOC=/home/ceade/src/personal/github/cck
Z80EXT_LOC=/home/ceade/build/z80ex
Z8T_LOC=/home/ceade/src/personal/github/z8t

INCLUDE=-I. -I$(CCK_LOC) -I$(Z80EXT_LOC)/include -I$(Z8T_LOC)

TESTS =
TESTS += 00-emptytable.t
TESTS += 01-wrap.t
TESTS += 02-last.t

all: $(TESTS)

%.t: %.c %.bin
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ $< $(Z8T_LOC)/z8t.o $(CCK_LOC)/cck.o $(Z80EXT_LOC)/z80ex.o

%.bin: %.asm
	$(ASM) -o $@ $<

clean:
	rm -f $(TESTS)
