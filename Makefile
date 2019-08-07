CC := gcc
CFLAGS := -Wall -Werror -ggdb

LDFLAGS = -lpthread

INCLUDE=-Iexternal/z80ex/include/
zpox: zpox.c external/z80ex/z80ex.o external/z80ex/z80ex_dasm.o console.o
	$(CC) $(CFLAGS) $(INCLUDE) $(LDFLAGS) -o $@ external/z80ex/z80ex.o external/z80ex/z80ex_dasm.o console.o $<

external/z80ex/z80ex.o:
	cd external/z80ex/ && make

console.o: console.c console.h
	$(CC) $(CFLAGS) $(DEFS) $(INCD) -c -o $@ $<

clone-emulator:
	mkdir -p external/
	cd external/ && git clone https://github.com/lipro/z80ex.git
	mkdir -p external/z80ex/lib

clean:
	rm -f zpox
	cd external/z80ex/ && make clean
