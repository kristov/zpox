#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
//#include <signal.h>
//#include <locale.h>
#include <stdint.h>
#include "z80.h"
#include "z80ex_dasm.h"

struct open_files {
    FILE* control;
};

struct zpox {
    uint8_t* memory;
    Z80Context *cpu;
    uint16_t pc_before;
    uint16_t pc_after;
    struct open_files* files;
};

struct zpox z;

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
    z->files->control = fopen(file, "r");
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
    fprintf(stderr, "  read %d from file\n", num);
    return (uint8_t)num;
}

byte mem_read(int param, ushort addr) {
    return z.memory[(uint16_t)addr];
}

void mem_write(int param, ushort address, byte data) {
    fprintf(stderr, "  memory write: address[%04x] data[%02x]\n", address, data);
    z.memory[(uint16_t)address] = data;
    return;
}

byte port_read(int param, ushort port) {
    if (port == 0x80) {
        return read_control_file(&z);
    }
    if (port == 0x82) {
        return read_control_file(&z);
    }
    return 0;
}

void port_write(int param, ushort port, byte data) {
    if (port == 0x81) {
        fprintf(stderr, "  serial write A [%02x] \"%c\"\n", data, data);
        return;
    }
    if (port == 0x83) {
        fprintf(stderr, "  serial write B [%02x] \"%c\"\n", data, data);
        return;
    }
}

Z80EX_BYTE mem_read_dasm(Z80EX_WORD addr, void *user_data) {
    struct zpox* z = user_data;
    return z->memory[(uint16_t)addr];
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
    while (1) {
        pc = z->cpu->PC;
        print_asm(z, pc);
        Z80Execute(z->cpu);
        nr_ins++;
        if (nr_ins > 500) {
            break;
        }
    }
}

// Parse command args and set up the instance
int main(int argc, char *argv[]) {
    int8_t c;
    int option_index = 0;
    struct open_files f;
    Z80Context cpu;

    static struct option long_options[] = {
        {"rom", optional_argument, 0, 'r'},
        {"ctrl", optional_argument, 0, 'c'},
        {0, 0, 0, 0}
    };

    init_zpox(&z);
    z.files = &f;

    cpu.memRead = mem_read;
    cpu.memWrite = mem_write;
    cpu.ioRead = port_read;
    cpu.ioWrite = port_write;
    z.cpu = &cpu;
    Z80RESET(&cpu);

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
