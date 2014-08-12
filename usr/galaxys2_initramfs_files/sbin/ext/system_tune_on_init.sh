#!/system/bin/sh

# stop ROM VM from booting!
stop;

# check if gps or battery failed to init on reboot
GPS_ERR_CHECK=$(dmesg | grep -w "k3g_probe : Device indentification failed" | wc -l);
BATTERY_CHECK=$(dmesg | grep -w "max8997_muic_charger_cb: fail to get battery ps" | wc -l);
if [ "$GPS_ERR_CHECK" -eq "1" ] || [ "$BATTERY_CHECK" -eq "1" ]; then
	sync;
	reboot;
fi;

mount -o remount,rw,nosuid,nodev /cache;
mount -o remount,rw,nosuid,nodev /data;
mount -o remount,rw /;
mount -o remount,rw /lib/modules;

# cleaning
rm -rf /cache/lost+found/* 2> /dev/null;
rm -rf /data/lost+found/* 2> /dev/null;
rm -rf /data/tombstones/* 2> /dev/null;
rm -rf /data/anr/* 2> /dev/null;

# critical Permissions fix
chown -R root:system /sys/devices/system/cpu/;
chown -R system:system /data/anr;
chown -R root:radio /data/property/;
chmod -R 777 /tmp/;
chmod -R 6755 /sbin/ext/;
chmod -R 0777 /dev/cpuctl/;
chmod -R 0777 /data/system/inputmethod/;
chmod -R 0777 /sys/devices/system/cpu/;
chmod -R 0777 /data/anr/;
chmod 0744 /proc/cmdline;
chmod -R 0770 /data/property/;
chmod -R 0400 /data/tombstones;


BOOT_ROM()
{

	# perm fixes
	chown -R root:root /data/property;
	chmod -R 0700 /data/property;

	# Start ROM VM boot!
	start;
}

if [ -e /tmp/wrong_kernel ]; then
	if [ -e /system/bin/wrong_kernel.png ]; then
		$BB cp /system/bin/wrong_kernel.png /res/images/icon_clockwork.png;
		/sbin/choose_rom 0;
	fi;
	sleep 15;
	sync;
	reboot;
else
		BOOT_ROM;
fi;
