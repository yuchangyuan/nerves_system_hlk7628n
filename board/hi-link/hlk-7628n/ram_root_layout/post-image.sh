#!/bin/sh

set -e

TARGETDIR=$1

cat ${BINARIES_DIR}/vmlinux.bin ${BINARIES_DIR}/mt7628an_hilink_hlk-7628n.dtb > ${BINARIES_DIR}/.img0

${HOST_DIR}/bin/lzma-old -z -c ${BINARIES_DIR}/.img0 > ${BINARIES_DIR}/.img1

${HOST_DIR}/bin/mkimage -A mips -O linux -C lzma -a 0x80000000 -e 0x80000000 -d ${BINARIES_DIR}/.img1 ${BINARIES_DIR}/uImage

cat ${BINARIES_DIR}/uImage ${BINARIES_DIR}/rootfs.squashfs > ${TARGETDIR}/ram_root_layout.bin
