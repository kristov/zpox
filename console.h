#ifndef CONSOLE_H
#define CONSOLE_H

#include <stdint.h>

uint8_t console_port_read(uint16_t port);

void console_port_write(uint16_t port, uint8_t value);

void console_init();

#endif
