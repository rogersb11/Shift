# install kernel modules
mount -o remount,rw /system
rm /system/lib/modules/*.ko
cp /modules/*.ko /system/lib/modules/
chmod 0644 /system/lib/modules/*.ko
