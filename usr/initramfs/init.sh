#!/bin/bash

RAMDISK="/home/brett/kern/usr/initramfs/ramdisk"
RAMDISK_OUT="/home/brett/kern/usr/initramfs/newramdisk.cpio"


echo "Making ramdisk..."
		cd ${RAMDISK}
		rm *.cpio
		find . -not -name ".gitignore" | cpio -o -H newc > ${RAMDISK_OUT}

echo "Done!"
