% Alpine Linux UEFI installation
% 2014-06-11

1. Boot the Arch Linux install iso and run the following script:

    ```sh
    #!/bin/sh

    # TODO: cryptsetup benchmark
    # TODO: gummiboot

    set -e

    HD=${HD:-/dev/sda}
    BOOTDEV=${HD}1
    ROOTDEV=${HD}2
    CRYPT=cryptroot
    CRYPTDEV=/dev/mapper/$CRYPT

    REL=${REL:-edge}
    MIRROR=${MIRROR:-http://nl.alpinelinux.org/alpine}
    REPO=$MIRROR/$REL/main
    APKV=${APKV:-2.4.4-r0}
    ARCH=$(uname -m)

    sgdisk -Z $HD
    sgdisk -n 1:0:+256M $HD
    sgdisk -n 2:0:0 $HD
    sgdisk -t 1:ef00 $HD
    sgdisk -t 2:8300 $HD
    sgdisk -c 1:bootefi $HD
    sgdisk -c 2:root $HD

    mkfs.vfat -s2 -F32 $BOOTDEV

    modprobe dm-crypt
    cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 \
      --iter-time 5000 --use-random --verify-passphrase luksFormat $ROOTDEV
    cryptsetup open $ROOTDEV $CRYPT
    mkfs.btrfs $CRYPTDEV

    mount $CRYPTDEV /mnt
    mkdir /mnt/boot
    mount $BOOTDEV /mnt/boot

    curl -s $MIRROR/$REL/main/$ARCH/apk-tools-static-${APKV}.apk | tar xz
    ./sbin/apk.static --repository $REPO --update-cache --allow-untrusted \
      --root /mnt --initdb add alpine-base

    cat <<EOF > /mnt/etc/fstab
    $CRYPTDEV / btrfs defaults,noatime,compress=lzo 0 0
    $BOOTDEV /boot vfat defaults,noatime 0 1
    EOF
    echo $REPO > /mnt/etc/apk/repositories

    cp /etc/resolv.conf /mnt/etc

    mount --bind /proc /mnt/proc

    chroot /mnt /bin/sh<<CHROOT
    apk update --quiet 

    setup-hostname -n $HOST
    printf "$INTERFACES" | setup-interfaces -i

    rc-update -q add networking boot
    rc-update -q add urandom boot
    rc-update -q add acpid
    rc-update -q add cron

    apk add --quiet openssh
    rc-update -q add sshd default

    mkdir /etc/mkinitfs
    echo features=\""$FEATURES"\" > /etc/mkinitfs/mkinitfs.conf

    apk add --quiet linux-grsec
    CHROOT

    umount /mnt/proc
    umount /mnt/boot
    umount /mnt
    ```
