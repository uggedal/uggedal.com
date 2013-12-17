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

```sh
truncate -s 256M rootfs.img
mdconfig -f rootfs.img
fdisk -BI md0
bsdlabel -wB md0s1
newfs -U md0s1a
mount /dev/md0s1a /mnt

sed -E '/(KDB|DDB|GDB|DEADLKRES|INVARIANT|WITNESS)/d' /usr/src/sys/i386/conf/XEN > /usr/src/sys/i386/conf/XEN-NODEBUG

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
mdconfig -d -u md0
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
