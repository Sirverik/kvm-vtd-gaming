
#!/bin/bash

VM_IMG=/dev/w7/windows
INSTALL_IMG=/home/instinct/Samba/win7.iso
DRIVER_CD=/home/instinct/Samba/virtio-win-0.1.141.iso

DEVICE1="01:00.0"
DEVICE2="01:00.1"

QEMU_PA_SAMPLES=4096 QEMU_AUDIO_DRV=pa \
qemu-system-x86_64 \
-enable-kvm \
-m 2048 \
-cpu host,kvm=off \
-smp 4,sockets=1,cores=2,threads=2 \
-machine q35,accel=kvm \
-rtc base=localtime,driftfix=slew \
-bios /usr/share/ovmf/OVMF.fd \
-drive file=$VM_IMG,if=none,id=drive-virtio-disk0,format=raw,cache=none \
-device virtio-blk-pci,scsi=on,addr=0x7,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=2 \
-drive file=$INSTALL_IMG,if=none,id=drive-ide0-0-0,readonly=on,format=raw \
-device ide-cd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0,bootindex=1 \
-drive file=$DRIVER_CD,if=none,id=drive-ide1-0-0,readonly=on,format=raw \
-device ide-cd,bus=ide.1,unit=0,drive=drive-ide1-0-0,id=ide1-0-0,bootindex=3 \
-device virtio-net-pci,netdev=user.0,mac=52:54:00:1a:21:32 \
-netdev user,id=user.0 \
-vga qxl \
-soundhw hda \
-usb \
-device usb-mouse \
-device usb-kbd \
-smb /home/instinct/Samba/
#-device vfio-pci,host=$DEVICE1,addr=0x8.0x0,multifunction=on,x-vga=off \
#-device vfio-pci,host=$DEVICE2,addr=0x8.0x1 \
