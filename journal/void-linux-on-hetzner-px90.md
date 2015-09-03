% Void Linux on Hetzner PX90
% 2014-11-13

Instructions for installing a custom [Void Linux][] root fs on
a [Hetzner][] [PX90][] dedicated server.

1. Order a server with the rescure system as OS.
2. SSH into the rescue system and run the following script:

    ```sh
    #!/bin/sh

    set -e

    DEVS='/dev/sda /dev/sdb'
    RAID_PARTS='/dev/sda2 /dev/sdb2'
    ROOT=${ROOT:-/mnt}
    ROOT_DEV=${ROOT_DEV:-/dev/md0}

    HOST=${HOST:-void-linux}
    REPO=${REPO:-http://repo.voidlinux.eu/current}

    for d in $DEVS; do
      sgdisk -Z $d
      sgdisk -n 1:0:+8M $d
      sgdisk -n 2:0:0 $d
      sgdisk -t 1:ef02 $d
      sgdisk -t 2:fd00 $d
      sgdisk -c 1:grub $d
      sgdisk -c 2:raid $d
    done

    for r in $RAID_PARTS; do
      mdadm --zero-superbloc $r
    done

    mdadm --create --verbose --level=1 --raid-devices=2 $ROOT_DEV $RAID_PARTS

    mkfs.ext4 -q -m1 -E lazy_itable_init=0 -L root $ROOT_DEV
    mount $ROOT_DEV $ROOT

    mkdir $ROOT/dev $ROOT/proc $ROOT/sys
    mount --rbind /dev $ROOT/dev
    mount --rbind /proc $ROOT/proc
    mount --rbind /sys $ROOT/sys

    curl http://repo.voidlinux.eu/static/xbps-static-latest.x86_64-musl.tar.xz | tar xJ

    ./usr/sbin/xbps-install -r $ROOT -R $REPO -Sy base-voidstrap mdadm grub

    cp /etc/resolv.conf $ROOT/etc/

    chroot $ROOT /bin/sh <<EOCHROOT
    . /etc/profile

    xbps-install -y linux-lts

    ln -s /usr/bin/runit-init /usr/sbin/init

    mkdir -p /run/runit/runsvdir
    ln -s /etc/runit/runsvdir/default /run/runit/runsvdir/current

    ln -s /etc/sv/dhcpcd /var/service/
    ln -s /etc/sv/sshd /var/service/
    ln -s /etc/sv/mdadm /var/service/

    for d in $DEVS; do
      grub-install $d
    done

    mdadm --detail --scan > /etc/mdadm.conf

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
[Hetzner]: http://www.hetzner.de/en
[PX90]: http://www.hetzner.de/en/hosting/produkte_rootserver/px90