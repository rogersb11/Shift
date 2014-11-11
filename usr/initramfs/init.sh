#!/bin/bash

RAMDISK="/home/brett/kern/usr/initramfs/ramdisk"
RAMDISK_OUT="/home/brett/kern/usr/initramfs/ramdisk.cpio"


echo "Making ramdisk..."
		cd ${RAMDISK}
		rm ramdisk.cpio
		find . -not -name ".gitignore" | cpio -o -H newc > ${RAMDISK_OUT}

echo "Done!"
