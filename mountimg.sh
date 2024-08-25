#!/bin/sh

mkdir mnt
mount boot.img mnt

mount --bind /proc mnt/proc
mount --bind /sys mnt/sys
mount --bind /dev mnt/dev
mount --bind /run mnt/run