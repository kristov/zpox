CC := gcc
CFLAGS := -Wall -Werror -ggdb

LDFLAGS = -lpthread

zpox: zpox.c external/z80ex/z80ex.o external/z80ex/z80ex_dasm.o console.o
	$(CC) $(CFLAGS) -Iexternal/z80ex/include $(LDFLAGS) -o $@ external/z80ex/z80ex.o external/z80ex/z80ex_dasm.o console.o $<

zpox_libz80: zpox_libz80.c z80.o external/z80ex/z80ex_dasm.o
	$(CC) $(CFLAGS) -Iexternal/libz80 -Iexternal/z80ex/include -o $@ z80.o external/z80ex/z80ex_dasm.o $<

z80.o: external/libz80/z80.c external/libz80/z80.h external/z80ex/z80ex_dasm.o
	$(CC) $(CFLAGS) -Iexternal/libz80 -c -o $@ $<

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
