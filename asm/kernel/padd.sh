#!/bin/bash
FILE=$1;
SIZE=$2;
FILESIZE=`stat -L -c %s ${FILE}`;
PADD=$(( ${SIZE} - ${FILESIZE} ));
dd if=/dev/zero bs=1 count=${PADD} >> ${FILE}
