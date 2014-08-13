#!/bin/bash

TOOLCHAIN="/home/brett/Desktop/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.7.4-2014.01/bin/arm-cortex_a9-linux-gnueabihf-"
STRIP="/home/brett/Desktop/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.7.4-2014.01/bin/arm-gnueabi-strip"
OUTDIR="out2"
CONFIG="note2_defconfig"
MODULES=("/home/brett/kern/arch/arm/mvp/commkm/commkm.ko" "/home/brett/kern/arch/arm/mvp/mvpkm/mvpkm.ko" "/home/brett/kern/arch/arm/mvp/pvtcpkm/pvtcpkm.ko" "drivers/interceptor/vpnclient.ko" "drivers/net/wireless/bcmdhd/dhd.ko" "drivers/new/wireless/btlock/btlock.ko" "drivers/scsi/scsi_wait_scan.ko" "/home/brett/kern/fs/cifs/cifs.ko")
KERNEL_DIR="/home/brett/kern"
MODULES_DIR="/home/brett/kern/out2/lib/modules"
CURRENTDATE=$(date +"%m-%d")


#echo "Cleaning..."
#		cd ${KERNEL_DIR}
#		make clean && make mrproper

	read -p "Clean working directory..(y/n)? : " achoice
	case "$achoice" in
		y|Y )
			rm -rf arch/arm/boot/zImage
			make clean && make mrproper
			echo "Working directory cleaned...";;
		n|N )
	esac

#echo "Making ramdisk..."
#		cd ${RAMDISK}
#		rm *.cpio
#		find . -not -name ".gitignore" | cpio -o -H newc > ${RAMDISK_OUT}

echo "Initial Build..."
		cd ${KERNEL_DIR}
		make ${CONFIG}
		make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN}

echo "Building Modules..."
		make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} modules

	for module in "${MODULES[@]}" ; do
			cp "${module}" ${MODULES_DIR}
			${STRIP} --strip-unneeded ${MODULES_DIR}/*
	done

echo "Building CWM Kernel..."
		cd ${KERNEL_DIR}
		make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN}
		cp arch/arm/boot/zImage ${OUTDIR}
		cd ${OUTDIR}
		echo "Creating Shift CWM kernel zip..."
		zip -r Shift-4.8-CM.zip ./ -x *.zip *.gitignore

echo "Done!"
