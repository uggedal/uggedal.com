Instructions for installing [FreeBSD][] on [Linode][].

### Pre-install

#### Build Xen kernel and world

Adjust the following if you're not building on an i386 installation.

TODO: strip world

```sh
#!/bin/sh

rootfs=/tmp/xen-rootfs.img
kernel=/tmp/xen-kernel
dest=/mnt
jobs=-j$(sysctl -n hw.ncpu)

truncate -s 512M $rootfs
mdev=$(mdconfig -f $rootfs)
fdisk -BI $mdev
bsdlabel -wB ${mdev}s1
newfs -U ${mdev}s1a
mount /dev/${mdev}s1a $dest

sed -E '/(KDB|DDB|GDB|DEADLKRES|INVARIANT|WITNESS)/d' /usr/src/sys/i386/conf/XEN > /usr/src/sys/i386/conf/XEN-NODEBUG

cd /usr/src
make $jobs buildworld
make $jobs buildkernel KERNCONF=XEN-NODEBUG
export DESTDIR=$dest
make installworld
make installkernel KERNCONF=XEN-NODEBUG
make distribution

cat <<EOF >$dest/etc/fstab
/dev/xbd0 / ufs rw 1 1
EOF

sed -i '' '/^ttyv/d' $dest/etc/ttys
cat <<EOF >>$dest/etc/ttys
xc0     "/usr/libexec/getty Pc"         vt100   on  secure
EOF

cp $dest/boot/kernel/kernel $kernel
gzip $rootfs

umount $dest
mdconfig -d -u $mdev
```

#### Linode configuration

1. Create a two new disk images:
    1. ext3 128MB
    2. raw rest
2. Create a config profile: select pv-grub-x86_32 kernel, disable
   boot helpers and attach the two new disk images.
3. Boot into recovery mode.
4. Attach to the recovery console with Lish and execute the following:
    ```sh
    passwd
    /etc/init.d/ssh start
    ```
5. Upload the rootfs and kernel over ssh.
6. Setup the boot and root partitions:
    ```sh
    mount /dev/xvda /mnt
    mkdir -p /mnt/boot/grub
    mv xen-kernel /mnt/boot/kernel

    cat <<EOF > /mnt/boot/grub/menu.lst
    timeout 0
    root (hd0,0)
    kernel /boot/kernel vfs.root.mountfrom=ufs:xbd0s1
    EOF

    gunzip -c xen-rootfs.img.gz | dd of=/dev/xvdb
    ```
7. Reboot.

### Install

TODO

### Post-install

TODO

### References

* [PrgmrWiki](http://wiki.prgmr.com/mediawiki/index.php/FreeBSD_as_a_DomU)
* [FreeBSD Forums](http://forums.freebsd.org/viewtopic.php?f=39&t=10268)
* [Firstboot resize](http://lists.freebsd.org/pipermail/freebsd-rc/2013-October/003381.html)

[FreeBSD]: https://www.freebsd.org/
[Linode]: https://www.linode.com/
