% Void Linux on ThinkPad T440s
% draft

Instructions for installing a [Void Linux][] on a [ThinkPad T440s][t440s].

1. Boot an [Arch Linux image][arch].
2. Setup wifi with `wifi-menu`.
3. Run the following:

    ```sh
    #!/bin/sh

    set -e

    DEV=/dev/sda
    BOOT_DEV=/dev/sda1
    ROOT_DEV=/dev/sda2
    CRYPT=cryptroot
    CRYPT_DEV=/dev/mapper/$CRYPT
    REPO=http://repo.voidlinux.eu

    sgdisk -Z $DEV
    sgdisk -n 1:0:+512M $DEV
    sgdisk -n 2:0:0 $DEV
    sgdisk -t 1:ef00 $DEV
    sgdisk -t 2:8300 $DEV
    sgdisk -c 1:bootefi $DEV
    sgdisk -c 2:root $DEV

    mkfs.vfat -F32 $BOOT_DEV

    cryptsetup luksFormat $ROOT_DEV
    cryptsetup open $ROOT_DEV $CRYPT

    mkfs.ext4 $CRYPT_DEV

    mount $CRYPT_DEV /mnt
    mkdir /mnt/boot
    mount $BOOT_DEV /mnt/boot

    curl $REPO/static/xbps-static-latest.x86_64-musl.tar.xz | tar xJ
    ./usr/sbin/xbps-install -S -R $REPO/current -r /mnt base-system cryptsetup

    mount --rbind /dev /mnt/dev
    mount --rbind /proc /mnt/proc
    mount --rbind /sys /mnt/sys

    chroot /mnt /bin/bash <<EOF
    passwd
    /usr/sbin/grub-install /dev/sda
    printf 'hostonly=yes\n' > /etc/dracut.conf.d/hostonly.conf
    /usr/sbin/xbps-reconfigure -f linux3.14
    printf '$CRYPT $ROOT_DEV\n' > /etc/crypttab
    EOF

    umount -R /mnt

    # TODO: /etc/hostname /etc/rc.conf
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[t440s]: http://shop.lenovo.com/us/en/laptops/thinkpad/t-series/t440s/
[arch]: https://www.archlinux.org/download/
