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

struct open_files {
    FILE* control;
};

struct zpox {
    uint8_t* memory;
    Z80EX_CONTEXT *cpu;
    uint16_t pc_before;
    uint16_t pc_after;
    struct interface* console;
    struct open_files* files;
};

// Z80EX-Callback for a CPU memory read
Z80EX_BYTE mem_read(Z80EX_CONTEXT* cpu, Z80EX_WORD addr, int m1_state, void* user_data) {
    struct zpox* z;
    z = user_data;
    return z->memory[(uint16_t)addr];
}

// Z80EX-Callback for a CPU memory write
void mem_write(Z80EX_CONTEXT* cpu, Z80EX_WORD address, Z80EX_BYTE data, void* user_data) {
    printf("memory write: address[%04x] data[%02x]\n", address, data);
    struct zpox* z = user_data;
    z->memory[(uint16_t)address] = data;
    return;
}

// Z80EX-Callback for a CPU port read
Z80EX_BYTE port_read(Z80EX_CONTEXT* cpu, Z80EX_WORD port, void* user_data) {
    struct zpox* z = user_data;
    return z->console->port_read(z->console->user_data, (uint16_t)port);
}

// Z80EX-Callback for a CPU port write
void port_write(Z80EX_CONTEXT *cpu, Z80EX_WORD port, Z80EX_BYTE value, void* user_data) {
    struct zpox* z = user_data;
    z->console->port_write(z->console->user_data, (uint16_t)port, (uint8_t)value);
}

// Z80EX-Callback for an interrupt read
Z80EX_BYTE int_read(Z80EX_CONTEXT* cpu, void* user_data) {
    struct zpox* z = user_data;
    fprintf(stderr, "interrupt vector!\n");
    return z->console->interrupt_addr(z->console->user_data);
}

// Z80EX-Callback for DASM memory read
Z80EX_BYTE mem_read_dasm(Z80EX_WORD addr, void *user_data) {
    struct zpox* z = user_data;
    return z->memory[(uint16_t)addr];
}

void load_binary_rom(struct zpox* z, char* file) {
    unsigned long len;
    FILE* rom_fh;

    rom_fh = fopen(file, "rb");
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

void open_control_file(struct zpox* z, char* file) {
    z->files->control = fopen("file", "r");
    if (z->files->control == NULL) {
        return;
    }
}

uint8_t read_control_file(struct zpox* z) {
    if (z->files->control == NULL) {
        return 0;
    }
    char* line;
    size_t len = 0;
    ssize_t read = getline(&line, &len, z->files->control);
    if (read <= 0) {
        return 0;
    }
    int32_t num = 0;
    sscanf(line, "%x", &num);
    return num;
}

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
    uint32_t nr_ins = 0;
    z->cpu = z80ex_create(mem_read, z, mem_write, z, port_read, z, port_write, z, int_read, z);
    while (1) {
        pc = z80ex_get_reg(z->cpu, regPC);
        print_asm(z, pc);
        z80ex_step(z->cpu);
        if (z->console->interrupt_ready(z->console->user_data)) {
            z80ex_int(z->cpu);
        }
        nr_ins++;
        if (nr_ins > 100) {
            break;
        }
    }
}

// Parse command args and set up the instance
int main(int argc, char *argv[]) {
    int8_t c;
    int option_index = 0;
    struct zpox z;
    struct open_files f;

    static struct option long_options[] = {
        {"rom", optional_argument, 0, 'r'},
        {"ctrl", optional_argument, 0, 'c'},
        {0, 0, 0, 0}
    };

    init_zpox(&z);
    z.files = &f;
    z.console = get_interface();
    z.console->init();

    while (1) {
        c = getopt_long(argc, argv, "r:c:", long_options, &option_index);
        if (c == -1) {
            break;
        }
        switch (c) {
            case 'r':
                load_binary_rom(&z, optarg);
                break;
            case 'c':
                open_control_file(&z, optarg);
                break;
            default:
                //print_help();
                exit(1);
        }
    }
    main_program(&z);
    return 0;
}
