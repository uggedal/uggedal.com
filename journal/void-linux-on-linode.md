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

    BASE_PACKAGES='
      base-files ncurses coreutils findutils
      dash bash grep gzip file sed gawk util-linux which tar
      shadow
      procps-ng iana-etc eudev runit-void openssh dhcpcd openssh openssh-server
      iproute2 iputils xbps nvi sudo kmod'

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

    xbps-install -y linux
    
    ln -s /usr/bin/runit-init /usr/sbin/init

    mkdir -p /run/runit/runsvdir
    ln -s /etc/runit/runsvdir/default /run/runit/runsvdir/current

    ln -s /etc/sv/dhcpcd /var/service/
    ln -s /etc/sv/sshd /var/service/

    rm /var/service/agetty-tty*
    mkdir /etc/sv/agetty-hvc0
    for f in finish run supervise; do
      ln -s /etc/sv/agetty-generic/$f /etc/sv/agetty-hvc0/
    done
    ln -s /etc/sv/agetty-hvc0 /var/service/

    passwd
    EOCHROOT

    printf $HOSTNAME > $ROOT/etc/hostname

    mkdir -p $ROOT/boot/grub
    cat << EOF > $ROOT/boot/grub/menu.lst
    timeout 0
    default 0
    hiddenmenu

    title Void Linux
    root (hd0)
    kernel /boot/vmlinuz-3.14.16_1 root=$ROOT_DEV console=hvc0 quiet
    initrd /boot/initramfs-3.14.16_1.img
    EOF

    umount $ROOT/sys
    umount $ROOT/proc
    umount $ROOT/dev
    umount $ROOT
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[Linode]: https://www.linode.com/
