#!/bin/sh

umount mnt/proc
umount mnt/sys
umount mnt/dev
umount mnt/run

umount mnt

rmdir mnt