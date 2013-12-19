Instructions for installing [FreeBSD][] on [Linode][].

Pre-install
-----------

### Linode configuration

1. Delete all disk images and create a two new disk images:
    1. ext2 128MB
    2. raw rest
2. Rename config profile, select pv-grub-x86_32 kernel, disable
   boot helpers and attach the two new disk images.
3. Boot into recovery mode.
4. Attach to the recovery console with Lish.

### Build Xen kernel and world

Adjust the following if you're not building on an i386 installation.

```sh
truncate -s 256M rootfs.img
mdev=$(mdconfig -f rootfs.img)
fdisk -BI $mdev
bsdlabel -wB $mdevs1
newfs -U $mdevs1a
mount /dev/$mdevs1a /mnt

sed -E '/(KDB|DDB|GDB|DEADLKRES|INVARIANT|WITNESS)/d' /usr/src/sys/i386/conf/XEN > /usr/src/sys/i386/conf/XEN-NODEBUG

cd /usr/src
make buildworld
make buildkernel KERNCONF=XEN-NODEBUG
export DESTDIR=/mnt
make installworld
make installkernel KERNCONF=XEN-NODEBUG
make distribution

cat <<EOF >/mnt/etc/fstab
/dev/xbd0 / ufs rw 1 1
EOF

sed -i '' '/^ttyv/d' /mnt/etc/ttys
cat <<EOF >>/mnt/etc/ttys
xc0     "/usr/libexec/getty Pc"         vt100   on  secure
EOF

cp /mnt/boot/kernel/kernel xen-kernel

umount /mnt
mdconfig -d -u $mdev
```

Install
-------

TODO

Post-install
------------

TODO

References
----------

* [PrgmrWiki](http://wiki.prgmr.com/mediawiki/index.php/FreeBSD_as_a_DomU)
* [FreeBSD Forums](http://forums.freebsd.org/viewtopic.php?f=39&t=10268)
* [Firstboot resize](http://lists.freebsd.org/pipermail/freebsd-rc/2013-October/003381.html)

[FreeBSD]: https://www.freebsd.org/
[Linode]: https://www.linode.com/
