% Void Linux on Linode
% 2014-08-13

Instructions for installing a custom [Void Linux][] root fs on
[Linode][].

1. Create a new raw disk image using all space.
2. Create a new configuration profile using the new disk image,
   pv-grub-x86_64 kernel and no Filesystem/Boot helpers.
3. Boot into rescue mode and run the following script:

    ```sh
    #!/bin/sh

    set -e

    ROOT=${ROOT:-/mnt}
    ROOT_DEV=${ROOT_DEV:-/dev/xvda}

    HOST=${HOST:-void-linux}
    REPO=${REPO:-http://repo.voidlinux.eu/current}

    mkfs.ext4 -q -L root $ROOT_DEV
    mount $ROOT_DEV $ROOT

    mkdir $ROOT/dev $ROOT/proc $ROOT/sys
    mount --rbind /dev $ROOT/dev
    mount --rbind /proc $ROOT/proc
    mount --rbind /sys $ROOT/sys

    curl http://repo.voidlinux.eu/static/xbps-static-latest.x86_64-musl.tar.xz | tar xJ

    ./usr/sbin/xbps-install -r $ROOT -R $REPO -Sy base-voidstrap

    cp /etc/resolv.conf $ROOT/etc/

    chroot $ROOT /bin/sh <<EOCHROOT
    . /etc/profile

    xbps-install -y linux-lts
    
    mkdir -p /run/runit/runsvdir
    ln -s /etc/runit/runsvdir/default /run/runit/runsvdir/current

    ln -s /etc/sv/dhcpcd /var/service/
    ln -s /etc/sv/sshd /var/service/

    mkdir /etc/sv/agetty-hvc0
    for f in finish run supervise; do
      ln -s /etc/sv/agetty-generic/$f /etc/sv/agetty-hvc0/
    done
    ln -s /etc/sv/agetty-hvc0 /var/service/

    for d in /etc/sv/agetty-tty[1-9]; do
      touch $d/down
    done

    cat <<"_EOF_" >$ROOT/etc/kernel.d/post-install/20-xen-grub
    #!/bin/sh

    PKGNAME="$1"
    VERSION="$2"

    mkdir -p /boot/grub
    cat <<EOF > /boot/grub/menu.lst
    timeout 0
    default 0
    hiddenmenu

    title Void Linux
    root (hd0)
    kernel /boot/vmlinuz-$VERSION root=/dev/xvda console=hvc0 ipv6.disable=1 quiet
    initrd /boot/initramfs-$VERSION.img
    EOF
    _EOF_

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
