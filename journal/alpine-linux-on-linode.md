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
    FS=${FS:-ext3}
    INITFS="ata base ide scsi usb virtio $FS"
    MODULES="sd-mod,usb-storage,$FS"

    REL=${REL:-2.7}
    MIRROR=${MIRROR:-http://nl.alpinelinux.org/alpine}
    REPO=$MIRROR/v$REL/main
    APKV=${APKV:-2.4.0-r4}
    DEV=${DEV:-/dev/xvda}
    ROOT=${ROOT:-/mnt}
    ARCH=$(uname -m)


    mkfs.$FS -q $DEV
    mount $DEV $ROOT

    curl -s $MIRROR/v$REL/main/$ARCH/apk-tools-static-${APKV}.apk | tar xz
    ./sbin/apk.static --repository $REPO --update-cache --allow-untrusted \
      --root $ROOT --initdb add alpine-base

    echo "$DEV / $FS defaults,noatime 0 1" > $ROOT/etc/fstab
    echo $REPO > $ROOT/etc/apk/repositories

    mkdir -p $ROOT/boot/grub
    cat << EOF > $ROOT/boot/grub/menu.lst
    timeout 0
    default 0
    hiddenmenu

    title Alpine Linux
    root (hd0)
    kernel /boot/grsec root=$DEV modules=$MODULES console=hvc0 pax_nouderef quiet
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
    echo features=\""$INITFS"\" > /etc/mkinitfs/mkinitfs.conf

    apk add --quiet linux-virt-grsec
    CHROOT

    umount $ROOT/proc
    umount $ROOT
    ```
5. Reboot.

[Alpine Linux]: http://alpinelinux.org/
[Linode]: https://www.linode.com/
