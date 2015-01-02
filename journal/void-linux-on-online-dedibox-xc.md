% Void Linux on Online.net Dedibox XC
% 2014-11-14

Instructions for installing a custom [Void Linux][] root fs on
a [Online.net][] [Dedibox XC][] dedicated server.

1. Order a server and install any distro.
2. Enable the rescue system (a distro needs to be installed before
   the rescue system can be started).
2. SSH into the rescue system and run the following script:

    ```sh
    #!/bin/sh

    set -e

    ROOT=/mnt
    DEV=/dev/sda
    ROOT_DEV=${DEV}2

    HOST=${HOST:-void-linux}
    REPO=${REPO:-http://repo.voidlinux.eu/current}

    sgdisk -Z $DEV
    sgdisk -n 1:0:+8M $DEV
    sgdisk -n 2:0:0 $DEV
    sgdisk -t 1:ef02 $DEV
    sgdisk -t 2:8300 $DEV
    sgdisk -c 1:grub $DEV
    sgdisk -c 2:root $DEV

    mkfs.ext4 -q -m1 -E lazy_itable_init=0 -L root $ROOT_DEV
    mount $ROOT_DEV $ROOT

    mkdir $ROOT/dev $ROOT/proc $ROOT/sys
    mount --rbind /dev $ROOT/dev
    mount --rbind /proc $ROOT/proc
    mount --rbind /sys $ROOT/sys

    curl http://repo.voidlinux.eu/static/xbps-static-latest.x86_64-musl.tar.xz | tar xJ

    ./usr/sbin/xbps-install -r $ROOT -R $REPO -Sy base-voidstrap grub

    cp /etc/resolv.conf $ROOT/etc/

    chroot $ROOT /bin/sh <<EOCHROOT
    . /etc/profile

    xbps-install -y linux-lts

    ln -s /usr/bin/runit-init /usr/sbin/init

    mkdir -p /run/runit/runsvdir
    ln -s /etc/runit/runsvdir/default /run/runit/runsvdir/current

    ln -s /etc/sv/dhcpcd /var/service/
    ln -s /etc/sv/sshd /var/service/

    grub-install $DEV

    xbps-reconfigure -f linux3.14

    passwd
    EOCHROOT

    printf $HOSTNAME > $ROOT/etc/hostname


    umount $ROOT/sys
    umount $ROOT/proc
    umount $ROOT/dev
    umount $ROOT
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[Online.net]: http://www.online.net/en
[Dedibox XC]: http://www.online.net/en/dedicated-server/dedibox-xc
