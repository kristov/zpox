#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include <pthread.h>
#include "interface.h"

#define CMD_NULL 0
#define CMD_ABORT 1
#define CMD_RESINT 2
#define CMD_RESCH 3
#define CMD_INTEN 4
#define CMD_RESTR 5
#define CMD_RESERR 6
#define CMD_INTRET 7

#define RRG_AVAIL 0
#define RRG_INTPEN 1
#define RRG_BUFEMP 2
#define RRG_DCD 3
#define RRG_SYNC 4
#define RRG_CTS 5
#define RRG_TRSUNRN 6
#define RRG_BRK 7

struct channel {
    uint8_t wr[8];
    uint8_t rr[3];
    uint8_t fifo[2];
    uint8_t idx;
    pthread_mutex_t lock;
};

struct console {
    pthread_t thread;
    struct channel porta;
    struct channel portb;
};

struct console CONSOLE;

static void console_init();
static uint8_t console_interrupt_ready(void* user_data);
static uint8_t console_interrupt_addr(void* user_data);
static uint8_t console_port_read(void* user_data, uint16_t address);
static void console_port_write(void* user_data, uint16_t address, uint8_t data);

struct interface console_interface = {
    &CONSOLE,
    console_init,
    console_interrupt_ready,
    console_interrupt_addr,
    console_port_read,
    console_port_write
};

void get_porta(uint8_t* c) {
    if (!pthread_mutex_trylock(&CONSOLE.porta.lock)) {
        if (CONSOLE.porta.idx > 0) {
            *c = CONSOLE.porta.fifo[0];
            for (uint8_t idx = 1; idx < CONSOLE.porta.idx; idx++) {
                CONSOLE.porta.fifo[idx-1] = CONSOLE.porta.fifo[idx];
            }
            CONSOLE.porta.idx--;
            CONSOLE.porta.rr[0] = 0x00;
        }
        pthread_mutex_unlock(&CONSOLE.porta.lock);
    }
}

void get_porta_status(uint8_t* s) {
    if (!pthread_mutex_trylock(&CONSOLE.porta.lock)) {
        *s = CONSOLE.porta.rr[0];
        pthread_mutex_unlock(&CONSOLE.porta.lock);
    }
}

void put_porta(uint8_t c) {
    pthread_mutex_lock(&CONSOLE.porta.lock);
    CONSOLE.porta.fifo[CONSOLE.porta.idx] = c;
    CONSOLE.porta.idx++;
    CONSOLE.porta.rr[0] = 0x01;
    pthread_mutex_unlock(&CONSOLE.porta.lock);
}

void init_term() {
    struct termios info;
    tcgetattr(0, &info);          // get current terminal attirbutes; 0 is the file descriptor for stdin
    info.c_lflag &= ~ICANON;      // disable canonical mode
    info.c_cc[VMIN] = 1;          // wait until at least one keystroke available
    info.c_cc[VTIME] = 0;         // no timeout
    tcsetattr(0, TCSANOW, &info); // set immediately
}

void* start_thread() {
    while (1) {
        char c = getchar();
        put_porta((uint8_t)c);

    }
    return NULL;
}

void init_thread() {
    int32_t thread_ret = pthread_create(&CONSOLE.thread, NULL, start_thread, NULL);
    if (thread_ret != 0) {
        return;
    }
}

static void console_init() {
    init_term();
    init_thread();
}

static uint8_t console_interrupt_ready(void* user_data) {
    return CONSOLE.porta.rr[0];
}

static uint8_t console_interrupt_addr(void* user_data) {
    fprintf(stderr, "INT!\n");
    pthread_mutex_lock(&CONSOLE.porta.lock);
    pthread_mutex_unlock(&CONSOLE.porta.lock);
    return 0;
}

static uint8_t console_port_read(void* user_data, uint16_t address) {
    uint8_t c = 0;
    if (address == 0x80) {
        get_porta_status(&c);
        fprintf(stderr, "PORTA control read: address[%04x] data[%02x]\n", address, c);
        return c;
    }
    if (address == 0x81) {
        get_porta(&c);
        fprintf(stderr, "PORTA data read: address[%04x] data[%02x]\n", address, c);
        return c;
    }
    if (address == 0x82) {
        //fprintf(stderr, "PORTB control read: address[%04x]\n", address);
        return c;
    }
    if (address == 0x83) {
        //fprintf(stderr, "PORTB data read: address[%04x]\n", address);
        return c;
    }
    return c;
}

static void console_port_write(void* user_data, uint16_t address, uint8_t data) {
    if (address == 0x80) {
        fprintf(stderr, "PORTA control write: address[%04x] data[%02x]\n", address, data);
        return;
    }
    if (address == 0x81) {
        fprintf(stderr, "PORTA data write: address[%04x] data[%02x]\n", address, data);
        put_porta(data);
        return;
    }
    if (address == 0x82) {
        //fprintf(stderr, "PORTB control write: address[%04x] data[%02x]\n", address, data);
        return;
    }
    if (address == 0x83) {
        //fprintf(stderr, "PORTB data write: address[%04x] data[%02x]\n", address, data);
        return;
    }
}

struct interface* get_interface() {
    return &console_interface;
}
