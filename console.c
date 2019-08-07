#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include <pthread.h>

struct queue {
    uint8_t queue[256];
    uint8_t idx;
    pthread_mutex_t lock;
    uint8_t status;
};

struct console {
    pthread_t thread;
    struct queue porta_q;
    struct queue portb_q;
};

struct console CONSOLE;

void get_porta_q(uint8_t* c) {
    if (!pthread_mutex_trylock(&CONSOLE.porta_q.lock)) {
        if (CONSOLE.porta_q.idx > 0) {
            CONSOLE.porta_q.idx--;
            *c = CONSOLE.porta_q.queue[CONSOLE.porta_q.idx];
            CONSOLE.porta_q.status = 0x00;
        }
        pthread_mutex_unlock(&CONSOLE.porta_q.lock);
    }
}

void get_porta_status(uint8_t* s) {
    if (!pthread_mutex_trylock(&CONSOLE.porta_q.lock)) {
        *s = CONSOLE.porta_q.status;
        pthread_mutex_unlock(&CONSOLE.porta_q.lock);
    }
}

void put_porta_q(uint8_t c) {
    pthread_mutex_lock(&CONSOLE.porta_q.lock);
    CONSOLE.porta_q.queue[CONSOLE.porta_q.idx] = c;
    CONSOLE.porta_q.idx++;
    CONSOLE.porta_q.status = 0xff;
    pthread_mutex_unlock(&CONSOLE.porta_q.lock);
}

void* start_thread() {
    while (1) {
        char c = getchar();
        put_porta_q((uint8_t)c);
    }
    return NULL;
}

void init_thread() {
    int32_t thread_ret = pthread_create(&CONSOLE.thread, NULL, start_thread, NULL);
    if (thread_ret != 0) {
        return;
    }
}

// init terminal settings
void init_term() {
    struct termios info;
    tcgetattr(0, &info);          // get current terminal attirbutes; 0 is the file descriptor for stdin
    info.c_lflag &= ~ICANON;      // disable canonical mode
    info.c_cc[VMIN] = 1;          // wait until at least one keystroke available
    info.c_cc[VTIME] = 0;         // no timeout
    tcsetattr(0, TCSANOW, &info); // set immediately
}

uint8_t console_port_read(uint16_t port) {
    uint8_t c = 0;
    if (port == 0x80) {
        get_porta_status(&c);
        //fprintf(stderr, "PORTA control read: address[%04x] data[%02x]\n", port, c);
        return c;
    }
    if (port == 0x81) {
        get_porta_q(&c);
        fprintf(stderr, "PORTA data read: address[%04x] data[%02x]\n", port, c);
        return c;
    }
    if (port == 0x82) {
        //fprintf(stderr, "PORTB control read: address[%04x]\n", port);
        return c;
    }
    if (port == 0x83) {
        //fprintf(stderr, "PORTB data read: address[%04x]\n", port);
        return c;
    }
    return c;
}

void console_port_write(uint16_t port, uint8_t value) {
    if (port == 0x80) {
        //fprintf(stderr, "PORTA control write: address[%04x] data[%02x]\n", port, value);
        return;
    }
    if (port == 0x81) {
        fprintf(stderr, "PORTA data write: address[%04x] data[%02x]\n", port, value);
        put_porta_q(value);
        return;
    }
    if (port == 0x82) {
        //fprintf(stderr, "PORTB control write: address[%04x] data[%02x]\n", port, value);
        return;
    }
    if (port == 0x83) {
        //fprintf(stderr, "PORTB data write: address[%04x] data[%02x]\n", port, value);
        return;
    }
}

void console_init() {
    init_term();
    init_thread();
}
