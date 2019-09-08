# File system

The file system is virtual and a physical disk is not required for basic operation. Physical disks are mounted and overlayed on top of the virtual file system. This means that the root directory is not located on a physical disk, and child directories of root are overlayed on top of the virtual root. Any file in the file system that is not mounted from a physical disk is a socket created by a driver. When you open such a file you are reading from a socket stream. The file system driver is minimalistic as it does not need to store file contents.

## Implementation


