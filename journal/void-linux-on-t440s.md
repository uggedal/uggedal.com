% Void Linux on ThinkPad T440s
% 2014-08-29

Instructions for installing a [Void Linux][] on a [ThinkPad T440s][t440s].

1. Boot an [Arch Linux image][arch].
2. Setup wifi with `wifi-menu`.
3. Run the following:

    ```sh
    #!/bin/sh

    set -e

    DEV=/dev/sda
    BOOT_DEV=${DEV}1
    ROOT_DEV=${DEV}2
    CRYPT=cryptroot
    CRYPT_DEV=/dev/mapper/$CRYPT
    REPO=http://repo.voidlinux.eu

    BASE_PACKAGES='
      base-files ncurses coreutils findutils glibc-locales diffutils
      dash bash grep gzip file sed gawk less util-linux which tar man-pages
      man-db shadow
      procps-ng tzdata iana-etc eudev runit-void dhcpcd
      iproute2 iputils xbps nvi sudo kmod
      cryptsetup openssh openssh-server'

    sgdisk -Z $DEV
    sgdisk -n 1:0:+256M $DEV
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
    mkdir -p /mnt/boot
    mount $BOOT_DEV /mnt/boot

    curl $REPO/static/xbps-static-latest.x86_64-musl.tar.xz | tar xJ
    ./usr/sbin/xbps-install -Sy -R $REPO/current -r /mnt $BASE_PACKAGES

    mount --rbind /dev /mnt/dev
    mount --rbind /proc /mnt/proc
    mount --rbind /sys /mnt/sys

    gummiboot install --path /mnt/boot

    eval $(blkid -o export $ROOT_DEV)

    cat <<EOF > /mnt/boot/loader/entries/void.conf
    title void (efi_stub)
    linux /vmlinuz-3.14.17_1
    initrd /initramfs-3.14.17_1.img
    options cryptdevice=$ROOT_DEV:$CRYPT root=/dev/mapper/luks-$UUID init=/usr/bin/runit-init ro quiet elevator=noop
    EOF

    printf 'default void\n' > /mnt/boot/loader/loader.conf

    cp /etc/resolv.conf /mnt/etc

    chroot /mnt /bin/bash <<EOF
    . /etc/profile
    mkdir -p /etc/dracut.conf.d
    printf 'hostonly=yes\n' > /etc/dracut.conf.d/hostonly.conf
    xbps-install -y linux
    EOF
    ```
4. Set root password and clean up:

    ```sh
    chroot /mnt passwd
    umount -R /mnt
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[t440s]: http://shop.lenovo.com/us/en/laptops/thinkpad/t-series/t440s/
[arch]: https://www.archlinux.org/download/
