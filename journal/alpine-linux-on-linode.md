% Alpine Linux on Linode
% 2013-12-05

Instructions for installing a custom [Alpine Linux][] root fs on
[Linode][].

1. Create a new raw disk image 128MB in size.
2. Create a new raw disk image using all remaining space.
3. Create a new configuration profile using the new disk images,
   pv-grub-x86_64 kernel and no Filesystem/Boot helpers.
4. Boot into rescue mode.

    ```sh
    #!/bin/sh

    set -e

    KEYMAP="${KEYMAP:-'us us'}"
    HOST=${HOST:-alpine-linux}
    INTERFACES="auto lo
    iface lo inet loopback

    auto eth0
    iface eth0 inet dhcp
      hostname $HOST
    "
    BOOT_FS=${ROOT_FS:-ext2}
    ROOT_FS=${ROOT_FS:-btrfs}
    FEATURES="ata base ide scsi usb virtio $ROOT_FS"
    MODULES="sd-mod,usb-storage,$ROOT_FS"

    REL=${REL:-2.7}
    MIRROR=${MIRROR:-http://nl.alpinelinux.org/alpine}
    REPO=$MIRROR/v$REL/main
    APKV=${APKV:-2.4.0-r6}
    BOOT_DEV=${ROOT_DEV:-/dev/xvda}
    ROOT_DEV=${ROOT_DEV:-/dev/xvdb}
    ROOT=${ROOT:-/mnt}
    ARCH=$(uname -m)


    mkfs.$BOOT_FS -q -L boot $BOOT_DEV
    mkfs.$ROOT_FS -f -L root -l 16k $ROOT_DEV >/dev/null
    mount $ROOT_DEV $ROOT
    mkdir $ROOT/boot
    mount $BOOT_DEV $ROOT/boot

    curl -s $MIRROR/v$REL/main/$ARCH/apk-tools-static-${APKV}.apk | tar xz
    ./sbin/apk.static --repository $REPO --update-cache --allow-untrusted \
      --root $ROOT --initdb add alpine-base

    cat <<EOF > $ROOT/etc/fstab
    $ROOT_DEV / $ROOT_FS defaults,noatime,compress=lzo 0 0
    $ROOT_DEV / $ROOT_FS defaults,noatime 0 1
    EOF
    echo $REPO > $ROOT/etc/apk/repositories

    sed -i '/^tty[0-9]:/d' $ROOT/etc/inittab
    echo 'hvc0::respawn:/sbin/getty 38400 hvc0' >> $ROOT/etc/inittab

    mkdir -p $ROOT/boot/grub
    cat << EOF > $ROOT/boot/grub/menu.lst
    timeout 0
    default 0
    hiddenmenu

    title Alpine Linux
    root (hd0)
    kernel /boot/grsec root=$ROOT_DEV modules=$MODULES console=hvc0 pax_nouderef quiet
    initrd /boot/grsec.gz
    EOF

    cp /etc/resolv.conf $ROOT/etc

    mount --bind /proc $ROOT/proc

    chroot $ROOT /bin/sh<<CHROOT
    apk update --quiet 

    setup-keymap $KEYMAP
    setup-hostname -n $HOST
    printf "$INTERFACES" | setup-interfaces -i

    rc-update -q add networking boot
    rc-update -q add urandom boot
    rc-update -q add acpid
    rc-update -q add cron

    apk add --quiet openssh
    rc-update -q add sshd default

    apk add --quiet openntpd
    rc-update -q add ntpd default

    mkdir /etc/mkinitfs
    echo features=\""$FEATURES"\" > /etc/mkinitfs/mkinitfs.conf

    apk add --quiet linux-grsec
    CHROOT

    umount $ROOT/proc
    umount $ROOT/boot
    umount $ROOT
    ```
5. Reboot.

[Alpine Linux]: http://alpinelinux.org/
[Linode]: https://www.linode.com/
