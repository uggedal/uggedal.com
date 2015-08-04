% Void Linux on Linode
% 2014-08-13

Instructions for installing a custom [Void Linux][] root fs on
a KVM [Linode][].

1. Create a new raw disk image using all space.
2. Create a new configuration profile using the new disk image,
   *Direct Disk* kernel and no Filesystem/Boot helpers.
3. Boot into rescue mode and run the following script:

    ```sh
    #!/bin/sh

    set -e

    ROOT=${ROOT:-/mnt}
    ROOT_DEV=${ROOT_DEV:-/dev/sda}

    HOST=${HOST:-void-linux}
    REPO=${REPO:-http://repo.voidlinux.eu/current}

    mkfs.ext4 -q -L root $ROOT_DEV
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
    
    mkdir -p /run/runit/runsvdir
    ln -s /etc/runit/runsvdir/default /run/runit/runsvdir/current

    ln -s /etc/sv/dhcpcd /var/service/
    ln -s /etc/sv/sshd /var/service/

    ln -s /etc/sv/agetty-ttyS0 /var/service/

    for d in /etc/sv/agetty-tty[1-9]; do
      touch $d/down
    done

    xbps-reconfigure -f linux3.14

    passwd
    EOCHROOT

    printf $HOST > $ROOT/etc/hostname

    umount $ROOT/sys
    umount $ROOT/proc
    umount $ROOT/dev
    umount $ROOT
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[Linode]: https://www.linode.com/
