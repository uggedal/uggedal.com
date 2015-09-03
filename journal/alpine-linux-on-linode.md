% Alpine Linux on Linode
% 2013-12-05

Instructions for installing a custom [Alpine Linux][] root fs on
a KVM [Linode][].

1. Create a new raw disk image using all space.
2. Create a new configuration profile using the new disk image,
   *Direct Disk* kernel and no Filesystem/Boot helpers.
3. Boot into rescue mode and run the following script:

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

    BOOT_FS=${BOOT_FS:-ext4}
    ROOT_FS=${ROOT_FS:-ext4}
    DEV=${DEV:-/dev/sda}
    BOOT_DEV=${DEV}1
    SWAP_DEV=${DEV}2
    ROOT_DEV=${DEV}3
    ROOT=${ROOT:-/mnt}

    FEATURES="ata base ide scsi usb virtio $ROOT_FS"
    MODULES="sd-mod,usb-storage,$ROOT_FS"
    CMDLINE='console=ttyS0 quiet'

    REL=${REL:-3.2}
    MIRROR=${MIRROR:-http://nl.alpinelinux.org/alpine}
    REPO=$MIRROR/v$REL/main
    APKV=${APKV:-2.6.3-r0}
    ARCH=$(uname -m)

    fdisk $DEV <<EOF
    n
    p
    1
     
    +100M
    n
    p
    2
     
    +2G
    t
    2
    82
    n
    p
    3
     
     
    a
    3
    w
    EOF

    mkfs.$BOOT_FS -L boot $BOOT_DEV >/dev/null
    mkfs.$ROOT_FS -L root $ROOT_DEV >/dev/null
    mkswap $SWAP_DEV

    mount $ROOT_DEV $ROOT
    mkdir -p $ROOT/boot
    mount $BOOT_DEV $ROOT/boot

    curl -s $MIRROR/v$REL/main/$ARCH/apk-tools-static-${APKV}.apk | tar xz
    ./sbin/apk.static --repository $REPO --update-cache --allow-untrusted \
      --root $ROOT --initdb add alpine-base

    cat <<EOF > $ROOT/etc/fstab
    $ROOT_DEV / $ROOT_FS defaults,noatime 0 0
    $BOOT_DEV /boot $BOOT_FS defaults,noatime 0 0
    $SWAP_DEV swap swap defaults 0 0
    EOF
    echo $REPO > $ROOT/etc/apk/repositories

    sed -e '/^tty[1-9]:/d' \
      -e 's/^#\(ttyS0\)/\1/' \
      -i $ROOT/etc/inittab

    cp /etc/resolv.conf $ROOT/etc

    mount --rbind /dev $ROOT/dev
    mount --rbind /proc $ROOT/proc
    mount --rbind /sys $ROOT/sys

    chroot $ROOT /bin/sh<<CHROOT
    apk update --quiet 

    setup-hostname -n $HOST
    printf "$INTERFACES" | setup-interfaces -i

    echo virtio_net >> /etc/modules
    rc-update -q add modules sysinit
    rc-update -q add mdev sysinit

    rc-update --quiet add swap boot
    rc-update --quiet add networking boot
    rc-update --quiet add urandom boot

    apk add --quiet openssh
    rc-update --quiet add sshd default

    apk add --quiet syslinux linux-grsec e2fsprogs

    mkdir -p /etc/mkinitfs
    echo features=\""$FEATURES"\" > /etc/mkinitfs/mkinitfs.conf

    cat /usr/share/syslinux/mbr.bin > $DEV

    sed -e "s:^root=.*:root=$ROOT_DEV:" \
      -e "s:^default_kernel_opts=.*:default_kernel_opts=\"$CMDLINE\":" \
      -e "s:^modules=.*:modules=$MODULES:" \
      -i /etc/update-extlinux.conf
    extlinux --install /boot
    apk fix linux-grsec
    CHROOT

    umount $ROOT/dev/pts
    umount $ROOT/dev
    umount $ROOT/sys
    umount $ROOT/proc
    umount $ROOT
    ```
5. Reboot.

[Alpine Linux]: http://alpinelinux.org/
[Linode]: https://www.linode.com/
