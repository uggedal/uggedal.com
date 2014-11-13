% Void Linux on Hetzner
% 2014-11-13

Instructions for installing a custom [Void Linux][] root fs on
a [Hetzner][] dedicated server.

1. Order a server with the rescure system as OS.
2. SSH into the rescue system and run the following script:

    ```sh
    #!/bin/sh

    set -e

    DEVS='/dev/sda /dev/sdb'
    ROOT=${ROOT:-/mnt}
    ROOT_DEV=${ROOT_DEV:-/dev/md0}

    HOST=${HOST:-void-linux}
    REPO=${REPO:-http://repo.voidlinux.eu/current}

    BASE_PACKAGES='
      base-files ncurses coreutils findutils glibc-locales diffutils
      dash bash grep gzip file sed gawk less util-linux which tar man-pages
      openbsd-man shadow
      procps-ng tzdata iana-etc eudev runit-void openssh dhcpcd
      iproute2 iputils xbps nvi sudo kmod'

    for d in $DEVS; do
      sgdisk -Z $d
      sgdisk -n 1:0:0 $d
      sgdisk -t 1:fd00 $DEV
      sgdisk -c 1:raid $DEV
    done

    mdadm --create --verbose --level=1 --raid-devices=2 $ROOT_DEV $DEVS

    mkfs.ext4 -q -L root $ROOT_DEV
    mount $ROOT_DEV $ROOT

    mkdir $ROOT/dev $ROOT/proc $ROOT/sys
    mount --rbind /dev $ROOT/dev
    mount --rbind /proc $ROOT/proc
    mount --rbind /sys $ROOT/sys

    curl http://repo.voidlinux.eu/static/xbps-static-latest.x86_64-musl.tar.xz | tar xJ

    ./usr/sbin/xbps-install -r $ROOT -R $REPO -Sy $BASE_PACKAGES

    cp /etc/resolv.conf $ROOT/mnt/etc/

    chroot $ROOT /bin/sh <<EOCHROOT
    . /etc/profile

    xbps-install -y linux-lts

    ln -s /usr/bin/runit-init /usr/sbin/init

    mkdir -p /run/runit/runsvdir
    ln -s /etc/runit/runsvdir/default /run/runit/runsvdir/current

    ln -s /etc/sv/dhcpcd /var/service/
    ln -s /etc/sv/sshd /var/service/

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
