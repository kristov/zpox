# Kernel Structures

* Register scratch pad
* Thread table
* Current thread id
* Sockets

## Register scratch pad

When context switching kernel interrupt code needs to copy thread register values without using the registers for computation. To do this there is a hard-coded location in memory to act as a scratch pad (eg: `ld (**),hl` where `(**)` is a constant). After that is done the CPU registers can be used to compute the thread table entry offset and copy from the scratch pad to the thread table. The scratch pad looks like this:

    struct ks_registers {
        uint16_t AF;
        uint16_t BC;
        uint16_t DE;
        uint16_t HL;
        uint16_t IX;
        uint16_t IY;
        uint16_t SP;
        uint16_t PC;
    };

## Thread table

The kernel thread table has 256 entries for all threads running on the machine. Entry 0 is reserved for the kernel itself (even though it does not use various values. Each entry is structured like so:

    struct ks_thread_table {
        uint8_t state;
        uint8_t ptid;
        uint8_t bank_id;
        uint16_t name;
        uint16_t main;
        struct ks_registers registers;
        uint8_t fd_tab[128];
    };

The index into the table is the TID.

### state

Thread states occupy the lower two bits of the state variable:

| Val | State       |
|-----|-------------|
| 0   | Empty entry |
| 1   | Running     |
| 2   | Blocked     |
| 3   | Ready       |

The next 4 bits represent a signal pending to the process:

| Signal  | Default action |
|---------|----------------|
| SIGHUP  | Terminate      |
| SIGINT  | Terminate      |
| SIGPIPE | Terminate      |
| SIGCHLD | Ignore         |
| SIGSTOP | Blocked        |
| SIGCONT | Running        |
| SIGTSTP | Blocked        |
| SIGTTIN | Blocked        |
| SIGTTOU | Blocked        |

### ptid

Parent thread id.

### bank\_id

Memory bank number owned by the process.

### name

Pointer to null terminated string of the name of the process.

### main

The location of the `main()` entry point in memory.

### registers

The saved registers.

### fd\_tab[128]

A table of 128 file descriptors. The value is an index into the global descriptor table in the kernel.

## File descriptors and pipes

When a thread is started it will be given two file descriptors by default, STDIN and STDOUT, which are connected to the same global descriptor entry as the parent. The file descriptor table in the thread table is an array of bytes. The position in the array is the file descriptor number and the value is the global descriptor index (zero reserved for not used). The indicies 0, 1 and 2 in the thread file descriptor table correspond to STDIN, STDOUT and STDERR respectively. The global descriptor index table has the following structure:

    struct global_descriptor {
        uint8_t state;
        uint8_t readp;
        uint8_t writep;
        uint8_t rtid;
        uint8_t wtid;
        uint8_t buf[255];
    };

### state

When the readers or writers should be blocked two flag bits are set in the state variable so the kernel can check these and change the state of the threads.

### readp

The index of the reading pointer. The pointer is advanced when the reader reads some data. If the reading pointer becomes the same value as the writing pointer the reader is blocked until the writing pointer is advanced.

### writep

The index of the writing pointer. If the writing pointer becomes one less than the reading pointer the writer is blocked until more is read.

### rtid

The id of the reading thread. If it's zero the reading thread has been stopped. A writing thread will receive a SIGPIPE if there is no reading thread and the global descriptor entry will be removed.

### wtid

The id of the writing thread. If it's zero the writing thread has been stopped. 

### buf

A 256 byte buffer for data. This allows the readp and writep variables to loop around on increment.

The zero index in the global descriptor table is reserved. Opening a device, file or pipe from a thread first creates the global descriptor entry and then adds the index of that entry into the file descriptor table.

[](http://web.cse.ohio-state.edu/~mamrak.1/CIS762/pipes_lab_notes.html)

## Socket table

Each socket connection between one thread and another gets it's own entry in the socket table. A driver created the dev node that user programs can open. Dev nodes can be exclusive or not. If exclusive the open will fail if there is already an open socket connection. A parent writes to the OUT buffer and reads from IN. A child writes to the IN buffer and reads from OUT. A blocking read on an empty buffer will cause the reading thread to go into a blocked state. A write on a full buffer will also cause the thread to go into a blocked state.

For a parent driver trying to write data out to a child, the child is either blocked on read or in a ready state doing something unrelated when it is woken up again. If the child is blocked on read then the next time it gets the CPU it will empty part or all of the buffer. If the child fails to read the driver will remain blocked waiting for the OUT buffer to be flushed.

For the case of the serial driver this could result in a blocked driver unable to get data to the child. For this reason the serial driver will not echo back characters it receives immediately, but wait for the child to echo back in the IN buffer what it has just read. When the child is able to read it will empty the OUT buffer which will trigger the kernel to unblock the driver (which might not run again yet). Then the child writes what was read back to the IN buffer and the kernel blocks the child until the driver can read again. When the driver gets CPU time and can read again it will empty the IN buffer (unblocking the child) and send the echoed characters back to the serial device.

If the size of the write is larger than the buffer the writer thread will block until the reader has read some.

This means if the child is not able to read above the maximum baud rate for the serial device, a large paste of characters 


| Name  | Size | Notes                 |
|-------|------|-----------------------|
| TID-P | 1    | Parent TID            |
| TID-C | 1    | Child TID             |
| IN    | 126  | Input buffer (parent) |
| OUT   | 126  | Output buffer (child) |
| State | 1    |                       |
| TOTAL | 255  |                       |

