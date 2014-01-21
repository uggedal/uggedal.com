Instructions for installing a custom [Gentoo][] root fs on
[Linode][].

1. Create a new disk raw disk image using all available space.
2. Create a new configuration profile using the new disk image,
   pv-grub-x86_64 kernel and no Filesystem/Boot helpers.
3. Boot into rescue mode.
4. Extract and chroot to a stage3:

    ```sh
    mkfs.ext4 /dev/xvda
    mount /dev/xvda /mnt

    curl http://212.110.161.69/gentoo/releases/amd64/autobuilds/current-stage3-amd64-nomultilib/stage3-amd64-nomultilib-20140116.tar.bz2 | tar xjp -C /mnt

    cp /etc/resolv.conf /mnt/etc/resolv.conf

    mount -t proc proc /mnt/proc
    mount --rbind /sys /mnt/sys
    mount --rbind /dev /mnt/dev

    chroot /mnt /bin/bash
    ```

5. Execute the following inside the chroot:

    ```sh
    . /etc/profile

    wget -O- https://github.com/uggedal/conf/archive/master.tar.gz | tar xz
    (
      cd conf-master
      cat <<EOF > env.sh
    host=localhost
    roles='portage dhcp'
    _portage_makeopts=-j8
    _portage_use='bindist vim-syntax bash-completion'
    _portage_install_mask='/usr/lib/systemd'
    _portage_mirrors='http://mirror.bytemark.co.uk/gentoo http://distfiles.gentoo.org http://www.ibiblio.org/pub/Linux/distributions/gentoo'
    _portage_sync='rsync://rsync.uk.gentoo.org/gentoo-portage'
    _dhcp_if=eth0
    EOF
      ./push env.sh
    )
    rm -r conf-master

    mkdir /usr/local/portage
    (
      cd /usr/local/portage
      wget -O- https://github.com/uggedal/overlay/archive/master.tar.gz | tar xz --strip-components=1
    )

    eselect profile set x-portage:uggedal/default/linux/amd64/development

    emerge --sync
    emerge dev-vcs/git

    emerge sys-devel/bc
    git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git -b linux-3.10.y --depth 1 /usr/src/linux
    (
      cd /usr/src/linux
      curl -L https://github.com/uggedal/kernels/raw/master/xen.config > .config
      make oldconfig
      make -j8 && make modules_install
      cp arch/x86_64/boot/bzImage /boot/
    )

    rm -rf /usr/local/portage
    git clone git://github.com/uggedal/overlay.git /usr/local/portage

    echo '/dev/xvda / ext4 noatime 0 1' > /etc/fstab

    emerge dhcpcd

    emerge --depclean
    rc-update del udev sysinit

    passwd

    sed -i '/^c[0-9]/d' /etc/inittab
    echo 'hvc0::respawn:/sbin/agetty 38400 hvc0' >> /etc/inittab

    mkdir -p /boot/grub
    cat << EOF > /boot/grub/menu.lst
    timeout 0
    default 0
    hiddenmenu

    title Gentoo
    root (hd0)
    kernel /boot/bzImage root=/dev/xvda console=hvc0 quiet
    EOF

    rc-update add sshd default
    ```

6. Reboot.
7. Execute the following:

    ```sh
    emerge --ask --verbose --tree --update --deep --with-bdeps=y --newuse @world
    ```

TODO
----

```sh

# provision fully with conf.sh

curl https://raw.github.com/uggedal/dotfiles/master/.inputrc > /etc/inputrc

emerge --unmerge nano

eselect bashcomp enable --global base
eselect bashcomp enable --global coreutils
eselect bashcomp enable --global gentoo
eselect bashcomp enable --global eselect
eselect bashcomp enable --global ssh
eselect bashcomp enable --global tmux
eselect bashcomp enable --global git
```

[gentoo]: http://gentoo.org/
[Linode]: https://www.linode.com/
