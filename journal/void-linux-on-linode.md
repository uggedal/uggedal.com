% Void Linux on Linode
% 2014-08-13

Instructions for installing a custom [Void Linux][] musl root fs on
a KVM [Linode][].

1. Create a new raw disk image using all space.
2. Create a new configuration profile using the new disk image,
   *Direct Disk* kernel and no Filesystem/Boot helpers.
3. Boot into rescue mode and run the following script:

    ```sh
    #!/bin/sh

    set -e

    ROOT=${ROOT:-/mnt}
    HOST=${HOST:-/dev/sda}
    ROOT_DEV=${DEV}1

    HOST=${HOST:-void-linux}
    REPO=${REPO:-http://muslrepo.voidlinux.eu}

    fdisk $DEV <<EOF
    n
     
     
     
     
    w
    q
    EOF

    mkfs.ext4 -q -L root $ROOT_DEV
    mount $ROOT_DEV $ROOT

    mkdir $ROOT/dev $ROOT/proc $ROOT/sys
    mount --rbind /dev $ROOT/dev
    mount --rbind /proc $ROOT/proc
    mount --rbind /sys $ROOT/sys

    curl $REPO/static/xbps-static-latest.x86_64-musl.tar.xz | tar xJ

    XBPS_ARCH=x86_64-musl ./usr/bin/xbps-install \
      -r $ROOT -R $REPO/current -Sy base-voidstrap grub

    cp /etc/resolv.conf $ROOT/etc/

    chroot $ROOT /bin/sh <<EOCHROOT
    . /etc/profile

    grub-install $DEV
    xbps-install -y linux
    
    mkdir -p /run/runit/runsvdir
    ln -s /etc/runit/runsvdir/default /run/runit/runsvdir/current

    ln -s /etc/sv/dhcpcd /var/service/
    ln -s /etc/sv/sshd /var/service/

    ln -s /etc/sv/agetty-ttyS0 /var/service/

    for d in /etc/sv/agetty-tty[1-9]; do
      touch $d/down
    done

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
