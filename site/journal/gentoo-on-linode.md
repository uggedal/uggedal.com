Instructions for installing a custom [Gentoo][] root fs on
[Linode][].

1. Create a new disk raw disk image using all available space.
2. Create a new configuration profile using the new disk image,
   pv-grub-x86_64 kernel and no Filesystem/Boot helpers.

References
----------

* Stripped docker base:
    - [1](https://blog.flameeyes.eu/2012/03/how-down-can-you-strip-a-gentoo-system)
* Use no-multilib profile.
* [Partial portage tree](http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=3&chap=5)

[gentoo]: http://gentoo.org/
[Linode]: https://www.linode.com/
