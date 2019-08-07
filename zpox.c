#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
//#include <signal.h>
//#include <locale.h>
#include "z80ex.h"
#include "z80ex_dasm.h"
#include "console.h"

// An instance of an emulator UI
struct zpox {
    uint8_t* memory;
    Z80EX_CONTEXT *cpu;
    uint16_t pc_before;
    uint16_t pc_after;
};

// Z80EX-Callback for a CPU memory read
Z80EX_BYTE mem_read(Z80EX_CONTEXT* cpu, Z80EX_WORD addr, int m1_state, void* user_data) {
    struct zpox* z;
    z = user_data;
    return z->memory[(uint16_t)addr];
}

// Z80EX-Callback for a CPU memory write
void mem_write(Z80EX_CONTEXT *cpu, Z80EX_WORD addr, Z80EX_BYTE value, void *user_data) {
    //printf("memory write: address[%04x] data[%02x]\n", addr, value);
    struct zpox* z = user_data;
    z->memory[(uint16_t)addr] = value;
    return;
}

// Z80EX-Callback for a CPU port read
Z80EX_BYTE port_read(Z80EX_CONTEXT *cpu, Z80EX_WORD port, void *z80emu) {
    return console_port_read((uint16_t)port);
}

// Z80EX-Callback for a CPU port write
void port_write(Z80EX_CONTEXT *cpu, Z80EX_WORD port, Z80EX_BYTE value, void *z80emu) {
    console_port_write((uint16_t)port, (uint8_t)value);
}

// Z80EX-Callback for an interrupt read
Z80EX_BYTE int_read(Z80EX_CONTEXT *cpu, void *z80emu) {
    fprintf(stderr, "interrupt vector!\n");
    return 0;
}

// Z80EX-Callback for DASM memory read
Z80EX_BYTE mem_read_dasm(Z80EX_WORD addr, void *user_data) {
    struct zpox* z = user_data;
    return z->memory[(uint16_t)addr];
}

// Load a ROM file from disk into 16k memory
void load_binary_rom(struct zpox* z, char* rom_file) {
    unsigned long len;
    FILE* rom_fh;

    rom_fh = fopen(rom_file, "rb");
    if (rom_fh == NULL) {
        fprintf(stderr, "Could not open rom file\n");
        exit(1);
    }

    fseek(rom_fh, 0, SEEK_END);
    len = ftell(rom_fh);
    rewind(rom_fh);

    if (len > 0x10000) {
        fprintf(stderr, "ROM image larger than 64k (%ld)", len);
        len = 0x10000;
    }
    fread(z->memory, len, 1, rom_fh);

    fclose(rom_fh);
}

// initialize an instance of a z80 emulator
void init_zpox(struct zpox* z) {
    memset(z, 0, sizeof(struct zpox));
    z->memory = malloc(sizeof(uint8_t) * 0x10000);
    if (z->memory == NULL) {
        fprintf(stderr, "unable to malloc memory");
        return;
    }
    memset(z->memory, 0, sizeof(uint8_t) * 0x10000);
}

void print_asm(struct zpox* z, uint16_t pc) {
    char asm_char[255];
    int t, t2;
    z80ex_dasm(asm_char, 255, 0, &t, &t2, mem_read_dasm, pc, z);
    fprintf(stderr, "[%04x] %s\n", pc, asm_char);
}

void main_program(struct zpox* z) {
    uint16_t pc;
    z->cpu = z80ex_create(mem_read, z, mem_write, z, port_read, z, port_write, z, int_read, z);
    while (1) {
        pc = z80ex_get_reg(z->cpu, regPC);
        print_asm(z, pc);
        z80ex_step(z->cpu);
    }
}

// Parse command args and set up the instance
int main(int argc, char *argv[]) {
    int8_t c;
	int option_index = 0;
    struct zpox z;

	static struct option long_options[] = {
        {"rom", optional_argument, 0, 'r'},
        {0, 0, 0, 0}
    };

    init_zpox(&z);
    console_init();

    while (1) {
		c = getopt_long(argc, argv, "r:", long_options, &option_index);
		if (c == -1) {
			break;
		}
        switch (c) {
            case 'r':
                load_binary_rom(&z, optarg);
                break;
            default:
                //print_help();
                exit(1);
        }
    }
    main_program(&z);
    return 0;
}
