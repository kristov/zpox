# Kernel

## Interrupts

An interrupt source periodically invokes the main OS interrupt handler. This switches the OS context back in and executes any task context switching.

### Task switching on interrupt

The process table stores the register states for each process. When an interrupt occurs we need to save the current process state, choose a new process and restore the new process state into registers. Looking up values in the process table requires using registers to calculate offsets. Because of this we can not use the shadow register copy functions because we can not access those values without polluting register values. Instead we block copy the current process registers into a static location not requiring computation, and then copy from there into the process table. We then copy the new process register values into the same static location and from there copy into CPU registers. This way we do not need to perform a computation while register values are being copied in and out of the CPU.

### RST interrupt handler

* Disable interrupts
* Pop off the return address as we are not going to return
* Copy current process register values to static location
* Calculate process table location
* Copy static location values to process table
* Calculate new process id
* Copy new process table values into static location
* Copy static location values into registers
* Enable interrupts
* Jump to process PC to resume operation

### Syscalls

For some syscalls we know that we are not going to do a context switch while the syscall is being processed, so we disable interrupts and can use the shadow registers to save the current process state.

* Disable interrupts
* Shadow register swap
* Process the syscall
* Shadow register swap
* Enable interrupts
* Return

A special type of syscall is one where the process will be put into the bloked state. For example a syscall writing a large mount of data to a socket, and the reader of the socket needs to get some CPU time to process it.

### Semaphores

Semaphores are implemented using an in-kernal array of bytes. Each of the below steps is assumed to occur within the "Process the syscall" section above.

#### Down

* Test if semaphore is zero
* If zero
  * Block the process pending an up
  * Store the process id somewhere of blocked ids
  * Initiate a task switch
* Else decrement semaphore

#### Up

* If there are pending blocked processes choose one and unblock it
* Else increment the semaphore

Some syscalls require services from other processes. For example the 

## Open questions

### How to stop a process stack overflow writing down into OS RAM?

Could have some memory addresses that are "blacked out" in between the OS RAM area and the user RAM area and if writes are attempted it triggers a physical interrupt to indicate a process has attempted to write into OS RAM. Alternatively a mode that when a user process is running the 16K of OS RAM is made read-only via an IO request. When a syscall is made this is disabled so the OS can write into that RAM area. Alternatively processes could be given the whole 64K of RAM and any syscall first pages in the OS RAM to execute the syscall.

### Syscall context switching

Context switching is pretty expensive and for some syscalls we will need to context switch in some other process. For example the disk service would need to be switched in to process a disk write. However a lock would not need a context switch as there is no service providing locks. We could go with a mono kernel where all the services are compiled into the kernel but that reduces flexibility.

### Two interrupt locations: 0x28 for syscalls and 0x38 for CTC

Threads wishing to make a syscall place the syscall id into the [?] register and do a "RST 28h" instruction.

#### Logical function map of an interrupt

    void hardware_interrupt() {
        DI();
        POP(); // remove return address
        task_switch();
        EI();
        goto CURRENT_THREAD_PC;
    }

    void task_switch() {
        save_current_thread_registers();
        task_switch();
    }

    void save_current_thread_registers() {
        // Copy registers to scratchpad
        // Calculate thread table start address
        // Copy scratchpad to thread table
    }

    void load_next_process() {
        find_next_process();
        // Copy new thread table values into scratchpad
        // Copy scratchpad values into registers
    }

    void find_next_process() {
        // Cycle through thread table from prev thread
        // If in running state pick it
        // If blocked on socket read and socket has data wake it up and pick it
    }

#### Logical function map of a syscall

    void software_interrupt() {
        DI();
        EX_AF();
        EXX();
        // Get the syscall id from the I register
        // Lookup the address in the syscall vector table using [?]
        process_syscall();
        EXX();
        EX_AF();
        EI();
        RETI();
    }

