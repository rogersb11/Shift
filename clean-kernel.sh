#!/bin/bash

cp -pv .config .config.bkp;
make ARCH=arm CROSS_COMPILE=/home/brett/Desktop/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.7.4-2014.01/bin/arm-cortex_a9-linux-gnueabihf- mrproper;
cp -pv .config.bkp .config;
make clean;

# clean ccache
read -t 5 -p "clean ccache, 5sec timeout (y/n)?";
if [ "$REPLY" == "y" ]; then
	ccache -C;
fi;
