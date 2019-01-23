#!/bin/bash

VM_IMG=/dev/mapper/w7-windows
#VM_IMG2=/home/instinct/.vms/Fraps.raw
DRIVER_CD=/home/instinct/Samba/virtio-win-0.1.106.iso

DEVICE1="01:00.0"
DEVICE2="01:00.1"
DEVICE3="66:00.0"
#DEVICE4="02:00.0"

modprobe vfio-pci

for dev in "0000:$DEVICE1" "0000:$DEVICE2"; do
        vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
        device=$(cat /sys/bus/pci/devices/$dev/device)
        if [ -e /sys/bus/pci/devices/$dev/driver ]; then
                echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
        fi
        echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/new_id
done

QEMU_PA_SAMPLES=4096 QEMU_AUDIO_DRV=pa \
qemu-system-x86_64 \
-enable-kvm \
-machine q35,accel=kvm \
-bios /usr/share/ovmf/OVMF.fd \
-cpu host,kvm=off \
-smp 6,sockets=1,cores=3,threads=2 \
-m 4096 \
-rtc base=localtime,driftfix=slew \
-soundhw hda \
-drive file=$VM_IMG,if=none,id=drive-virtio-disk0,format=raw,cache=none \
-drive file=$DRIVER_CD,if=none,id=drive-ide1-0-0,readonly=on,format=raw \
-device ide-cd,bus=ide.1,unit=0,drive=drive-ide1-0-0,id=ide1-0-0,bootindex=3 \
-device virtio-blk-pci,scsi=off,addr=0x7,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 \
-device virtio-net-pci,netdev=user.0,mac=52:54:00:a0:62:27 \
-netdev user,id=user.0 \
-device vfio-pci,host=$DEVICE1,addr=0x8.0x0,multifunction=on,x-vga=on \
-device vfio-pci,host=$DEVICE2,addr=0x8.0x1 \
-vga qxl \
-usbdevice host:0909:001a \
-usbdevice host:1532:0017 \
-smb /home/instinct/Samba/ \
#-usbdevice host:04b4:0101 \
#-usbdevice host:04b4:0101 \
#-usbdevice host:045e:028e \
#-usbdevice host:1532:010e \
