# Processes

A process is defined as:

* The start address of the code
* Some working RAM (a page id)

A thread is defined as:

* An id
* Saved set of registers
* A stack
* A pointer to the start address of the code
* A pointer to working RAM (a page id)

Task switching is done at the thread level. A normal user process is one or more threads pointing to the same chunk of code and the same RAM page. A kernel thread is slightly different: it points to a different code start address from other kernel threads, but the same working RAM page id (page 0 - the second 16Kb of RAM). In this sense a process does not really exist as a real entity because it's defined instead by the two fields stored at the thread level. There are no "pids" but rather "tids".

The kernel itself is not a process or a thread. It consists of code performing three main functions: 1) CTC interrupt handling for process switching 2) Sending data between processes using sockets and 3) A syscall interface (software interrupts). Everything else is a thread.

## Sockets

Sockets are in-kernel structures that connect two threads for communication. For example a serial console driver thread with a shell thread. There are two buffers one for each direction, some thread ids to indicate what threads to wake up and suspend and some flags to indicate status.

## Drivers

Drivers are bits of code which deal with interfacing with I/O devices. They are separate threads with their own code, stack and working RAM areas. There are four core drivers that run independently of a physical disk. Their code must live somewhere, so they are located in the kernel ROM. If the IDE driver detects there is a physical disk attached it can load additional drivers from disk. There is 16K of RAM available for the kernel and all drivers. The core drivers are:

### Virtual file system

This provides a virtual file system for the other three drivers to interact with. The file system is stored in memory. It's primary function is to provide an interface to sockets so that other drivers can create and open sockets with each other.

### Serial driver

This handles reading a writing to an attached serial device. It creates a socket for a shell which is then available via the virtual file system.

### IDE driver

This detects and initialises any physical disks attached to the system.

### Minimal shell

The minimal shell depends a serial device (ie: a physical serial device, or a virtual device created by an optional video and keyboard driver) and provides a basic shell environment for browsing the virtual file system, mounting physical disks if present etc.

## Core driver loading

The drivers are loaded in a particular order ensuring that minimal functionality is made good use of. The virtual file system is loaded first so that the remaining drivers can interact with sockets. The minimal shell is started last so that it can see the virtual file system and any sockets created by the serial driver.

## System reset

What steps need to be executed in order to bring the system up?

* Disable interrupts
* Set up SP for OS RAM area
* Start kernel threads (drivers)
  * Start virtual file system
  * Start serial driver
  * Start IDE driver
  * Start minimal shell
* Enable interrupts

If a serial console is connected the shell process will be able to provide an interactive environment for bringing the rest of the system up.

## Starting a process

* Find a free process table entry
* Set register values to reset CPU defaults
* Set PC value in the process table
* Set program state to running

