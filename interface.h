#ifndef INTERFACE_H
#define INTERFACE_H

#include <stdint.h>

struct interface {
    void* user_data;
    void (*init)();
    uint8_t (*interrupt_ready)(void* user_data);
    uint8_t (*interrupt_addr)(void* user_data);
    uint8_t (*port_read)(void* user_data, uint16_t address);
    void (*port_write)(void* user_data, uint16_t address, uint8_t data);
};

#endif
