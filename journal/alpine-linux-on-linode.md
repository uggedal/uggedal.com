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
    ROOT_FS=${ROOT_FS:-ext4}
    FEATURES="ata base ide scsi usb virtio $ROOT_FS"
    MODULES="sd-mod,usb-storage,$ROOT_FS"

    REL=${REL:-3.2}
    MIRROR=${MIRROR:-http://nl.alpinelinux.org/alpine}
    REPO=$MIRROR/v$REL/main
    APKV=${APKV:-2.6.3-r0}
    DEV=${DEV:-/dev/sda}
    ROOT_DEV=${DEV}1
    ROOT=${ROOT:-/mnt}
    ARCH=$(uname -m)

    fdisk $DEV <<EOF
    n
     
     
     
     
    a
    w
    EOF

    mkfs.$ROOT_FS -L root $ROOT_DEV >/dev/null
    mount $ROOT_DEV $ROOT

    curl -s $MIRROR/v$REL/main/$ARCH/apk-tools-static-${APKV}.apk | tar xz
    ./sbin/apk.static --repository $REPO --update-cache --allow-untrusted \
      --root $ROOT --initdb add alpine-base

    cat <<EOF > $ROOT/etc/fstab
    $ROOT_DEV / $ROOT_FS defaults,noatime 0 0
    EOF
    echo $REPO > $ROOT/etc/apk/repositories

    sed -i '/^tty[1-9]:/d' $ROOT/etc/inittab

    cp /etc/resolv.conf $ROOT/etc

    mount --rbind /dev $ROOT/dev
    mount --rbind /proc $ROOT/proc
    mount --rbind /sys $ROOT/sys

    chroot $ROOT /bin/sh<<CHROOT
    apk update --quiet 

    setup-hostname -n $HOST
    printf "$INTERFACES" | setup-interfaces -i

    rc-update --quiet add networking boot
    rc-update --quiet add urandom boot

    apk add --quiet openssh
    rc-update --quiet add sshd default

    apk add --quiet linux-grsec syslinux e2fsprogs

    mkdir -p /etc/mkinitfs
    echo features=\""$FEATURES"\" > /etc/mkinitfs/mkinitfs.conf

    dd bs=440 count=1 if=/usr/share/syslinux/mbr.bin of=/dev/sda

    sed -e "s:^root=.*:root=$ROOT_DEV:" \
      -e "s:^default_kernel_opts=.*:default_kernel_opts=\"$kernel_opts\":" \
      -e "s:^modules=.*:modules=$MODULES:" \
      -i /etc/update-extlinux.conf
    extlinux --install /boot
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
