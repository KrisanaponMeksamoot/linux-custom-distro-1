#!/bin/sh

dd if=/dev/zero of=boot.img bs=1M count=512
mkfs boot.img

mkdir mnt
mount boot.img mnt

echo copying files
cp -a target/. mnt/

mkdir -p mnt/boot/syslinux
cp syslinux.cfg mnt/boot/syslinux

sudo chown -R root:root mnt

extlinux -i mnt

umount mnt
rm -r mnt

echo done
