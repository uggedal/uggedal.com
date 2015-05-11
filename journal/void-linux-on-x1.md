% Void Linux on ThinkPad Carbon X1 3rd gen
% 2015-05-11

Instructions for installing a [Void Linux][] on a
[ThinkPad Carbon X1 3rd gen][x1].

1. Boot a Void Linux live image.
2. Setup wifi:

    ```sh
    cd /etc/wpa_supplicant
    cp wpa_supplicant.conf wpa_supplicant-wlp4s0.conf
    chmod o-r *
    sv restart dhcpcd
    ```
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
    PKGS="
      base-files ncurses coreutils findutils glibc-locales diffutils
      dash bash grep gzip file sed gawk less util-linux which tar
      mdocml shadow e2fsprogs kbd psmisc procps-ng tzdata iana-etc
      eudev dhcpcd iproute2 iputils traceroute iw wpa_supplicant
      openssh runit-void xbps nvi sudo kmod cryptsetup gummiboot
    "

    fdisk $DEV <<EOF
    g
    n


    +512
    t
    1
    n



    w
    EOF

    mkfs.vfat -F32 $BOOT_DEV

    cryptsetup luksFormat $ROOT_DEV
    cryptsetup open $ROOT_DEV $CRYPT

    mkfs.ext4 $CRYPT_DEV

    mount $CRYPT_DEV /mnt
    mkdir -p /mnt/boot
    mount $BOOT_DEV /mnt/boot

    xbps-install -Sy -R $REPO/current -r /mnt $PKGS

    mount --rbind /dev /mnt/dev
    mount --rbind /proc /mnt/proc
    mount --rbind /sys /mnt/sys

    eval $(blkid -o export $ROOT_DEV)

    mkdir -p /mnt/boot/loader
    {
      printf 'root=/dev/mapper/luks-%s ' $UUID
      printf 'rootflags=noatime,discard '
      printf 'ro rd.luks.uuid=%s rd.luks.allow-discards ' $UUID
      printf 'init=/usr/bin/runit-init elevator=noop i915.enable_ips=0 quiet\n'
    } > /mnt/boot/loader/void-options.conf

    printf '/dev/sda1 /boot vfat defaults,noatime 0 0\n' >> /mnt/etc/fstab

    cp /etc/resolv.conf /mnt/etc

    chroot /mnt /bin/bash <<EOF
    . /etc/profile
    mkdir -p /etc/dracut.conf.d
    printf 'hostonly=yes\n' > /etc/dracut.conf.d/hostonly.conf
    xbps-install -y linux
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars
    gummiboot install
    EOF
    ```
4. Set root password and clean up:

    ```sh
    chroot /mnt passwd
    umount -R /mnt
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[x1]: http://shop.lenovo.com/us/en/laptops/thinkpad/x-series/x1-carbon/
