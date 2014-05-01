#!/system/bin/sh

ROOT_RW()
{
mount -o remount,rw /;
}
ROOT_RW;

# fix owners on critical folders
chown -R root:root /tmp;
chown -R root:root /res;
chown -R root:root /sbin;
chown -R root:root /lib;

# oom and mem perm fix
chmod 666 /sys/module/lowmemorykiller/parameters/cost;
chmod 666 /sys/module/lowmemorykiller/parameters/adj;

# allow user and admin to use all free mem.
echo 0 > /proc/sys/vm/user_reserve_kbytes;
echo 8192 > /proc/sys/vm/admin_reserve_kbytes;

mkdir /data/.shift
chmod 0777 /data/.shift

. /res/customconfig/customconfig-helper

ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.shift/.ccxmlsum`" ];
then
  rm -f /data/.shift/*.profile
  echo ${ccxmlsum} > /data/.shift/.ccxmlsum
fi
[ ! -f /data/.shift/default.profile ] && cp /res/customconfig/default.profile /data/.shift

read_defaults
read_config

# Apps and ROOT Install
sh /sbin/ext/install.sh;

# disable debugging on some modules
if [ "$logger" == "off" ];then
  rm -rf /dev/log
  echo 0 > /sys/module/ump/parameters/ump_debug_level
  echo 0 > /sys/module/mali/parameters/mali_debug_level
  echo 0 > /sys/module/kernel/parameters/initcall_debug
  echo 0 > /sys//module/lowmemorykiller/parameters/debug_level
  echo 0 > /sys/module/earlysuspend/parameters/debug_mask
  echo 0 > /sys/module/alarm/parameters/debug_mask
  echo 0 > /sys/module/alarm_dev/parameters/debug_mask
  echo 0 > /sys/module/binder/parameters/debug_mask
  echo 0 > /sys/module/xt_qtaguid/parameters/debug_mask
fi

#apply last soundgasm level on boot
/res/uci.sh soundgasm_hp $soundgasm_hp

# apply STweaks defaults
/res/uci.sh apply

#usb mode
/res/customconfig/actions/usb-mode ${usb_mode}

# install kernel modules
mount -o remount,rw /system
rm /system/lib/modules/*.ko
# install wifi module
cp /modules/dhd.ko /system/lib/modules/
# install fm radio module
cp /modules/Si4709_driver.ko /system/lib/modules/
# check if optional modules should be installed
if [ "$cifs" == "on" ];then
cp /modules/auth_rpcgss.ko /system/lib/modules/
cp /modules/cifs.ko /system/lib/modules/
cp /modules/lockd.ko /system/lib/modules/
cp /modules/nfs.ko /system/lib/modules/
cp /modules/rpcsec_gss_krb5.ko /system/lib/modules/
cp /modules/sunrpc.ko /system/lib/modules/
fi
if [ "$scsi" == "on" ];then
cp /modules/scsi_wait_scan.ko /system/lib/modules/
fi

chmod 0644 /system/lib/modules/*.ko

# Cortex parent should be ROOT/INIT and not STweaks
nohup /sbin/ext/cortexbrain-tune.sh;
CORTEX=$(pgrep -f "/sbin/ext/cortexbrain-tune.sh");
echo "-900" > /proc/"$CORTEX"/oom_score_adj;

# busybox addons
if [ -e /system/xbin/busybox ] && [ ! -e /sbin/ifconfig ]; then
	$BB ln -s /system/xbin/busybox /sbin/ifconfig;
fi;

### Disables Built In Error Reporting
setprop profiler.force_disable_err_rpt 1
setprop profiler.force_disable_ulog 1

# system status
cp /res/systemstatus /system/bin/systemstatus
chown root.system /system/bin/systemstatus
chmod 0755 /system/bin/systemstatus

cp /res/systemcat /system/bin/systemcat
chown root.system /system/bin/systemcat
chmod 0755 /system/bin/systemcat

# check if vpll is enabled
if [ "$vpll" == "on" ];then
echo "1" > /sys/module/mali/parameters/mali_use_vpll
fi

# install lights lib needed by BLN
rm /system/lib/hw/lights.exynos4.so
cp /res/lights.exynos4.so /system/lib/hw/lights.exynos4.so
chown root.root /system/lib/hw/lights.exynos4.so
chmod 0664 /system/lib/hw/lights.exynos4.so
mount -o remount,ro /system

# google dns
setprop net.dns1 8.8.8.8
setprop net.dns2 8.8.4.4

# set recommended KSM settings by google
echo "100" > /sys/kernel/mm/ksm/pages_to_scan
echo "500" > /sys/kernel/mm/ksm/sleep_millisecs

sysctl -w vm.dirty_background_ratio=5;
sysctl -w vm.dirty_ratio=10;
# low swapiness to use swap only when the system 
# is under extreme memory pressure
sysctl -w vm.swappiness=25;

##### init scripts #####
/system/bin/sh sh /sbin/ext/run-init-scripts.sh
