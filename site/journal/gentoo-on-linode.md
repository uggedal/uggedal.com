Instructions for installing a custom [Gentoo][] root fs on
[Linode][].

1. Create a new disk raw disk image using all available space.
2. Create a new configuration profile using the new disk image,
   pv-grub-x86_64 kernel and no Filesystem/Boot helpers.
3. Boot into rescue mode.
4. Set root password.
5. Start sshd:

    ```sh
    /etc/init.d/ssh start
    ```
6. Log in over ssh and start a new screen instance.
7. Execute the following commands:

    ```sh
    mkfs.ext4 /dev/xvda
    mount /dev/xvda /mnt
    curl http://212.110.161.69/gentoo/releases/amd64/autobuilds/current-stage3-amd64-nomultilib/stage3-amd64-nomultilib-20131226.tar.bz2 | tar xjp -C /mnt
    echo 'MAKEOPTS="-j8"' >> /mnt/etc/portage/make.conf
    echo 'GENTOO_MIRRORS="http://mirror.bytemark.co.uk/gentoo/ http://distfiles.gentoo.org http://www.ibiblio.org/pub/Linux/distributions/gentoo"' >> /mnt/etc/portage/make.conf
    echo 'SYNC="rsync://rsync.uk.gentoo.org/gentoo-portage"' >> /mnt/etc/portage/make.conf
    echo 'FEATURES="$FEATURES nodoc noinfo"' >> /mnt/etc/portage/make.conf
    echo 'app-shells/bash -net' >> /mnt/etc/portage/package.use
    vi /mnt/etc/portage/make.conf
    # Add '-nls -cracklib -python -perl -fortran -openmp' to USE
    cp /etc/resolv.conf /mnt/etc/resolv.conf
    mount -t proc proc /mnt/proc
    mount --rbind /sys /mnt/sys
    mount --rbind /dev /mnt/dev
    chroot /mnt /bin/bash
    . /etc/profile
    emerge-webrsync
    echo 'PORTAGE_RSYNC_EXTRA_OPTS="--exclude-from=/etc/portage/rsync_excludes"' >> /etc/portage/make.conf
    cat <<EOF > /etc/portage/rsync_excludes
    app-accessibility/
    app-antivirus/
    app-crd/
    app-emacs/
    app-forensics/
    app-laptop/
    app-leechcraft/
    app-mobilephone/
    app-office*/
    app-pda/
    app-xemacs/
    dev-ada/
    dev-dotnet/
    dev-embedded/
    dev-games/
    dev-haskell/
    dev-java/
    dev-lisp/
    dev-lua/
    dev-ml/
    dev-php/
    dev-qt/
    dev-ruby/
    dev-scheme/
    dev-tcltk/
    dev-tex*/
    games-*/
    gnome-*/
    gnustep-*/
    gpe-*/
    java-virtuals/
    kde-*/
    lxde-base/
    media-radio/
    media-tv/
    net-dialup/
    net-ftp/
    net-im/
    net-news/
    net-nntp/
    net-print/
    net-voip/
    net-zope/
    razorqa-base/
    rox-*/
    sci-*/
    sys-freebsd/
    sys-infiniband/
    www-apache/
    www-plugins/
    xfce-*/
    EOF
    emerge --sync
    echo UTC > /etc/timezone
    emerge --config sys-libs/timezone-data
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
    locale-gen
    eselect locale set 3
    env-update
    . /etc/profile
    emerge gentoo-sources
    cd /usr/src/linux
    make menuconfig
    make -j8 && make modules_install
    cp arch/x86_64/boot/bzImage /boot/
    echo '/dev/xvda / ext4 noatime 0 1' > /etc/fstab
    echo 'hostname="argon"' > /etc/conf.d/hostname
    echo 'dns_domain_lo="uggedal.com"' > /etc/conf.d/net
    echo 'config_eth0="dhcp"' > /etc/conf.d/net
    cd /etc/init.d
    ln -s net.lo net.eth0
    rc-update add net.eth0 default
    vi /etc/hosts
    passwd
    emerge sysklogd
    rc-update add sysklogd default
    rc-update add sshd default
    vi /etc/inittab
    # comment out terminals and add:
    #   hvc0::respawn:/sbin/agetty 38400 hvc0
    emerge dhcpcd
    mkdir -p /boot/grub
    cat << EOF > /boot/grub/menu.lst
    timeout 0
    default 0
    hiddenmenu

    title Gentoo
    root (hd0)
    kernel /boot/bzImage root=/dev/xvda console=hvc0 quiet
    EOF
    ```
8. Reboot.
9. Run the following:

    ```sh
    echo 'PYTHON_TARGETS="python3_3"' >> /etc/portage/make.conf
    echo 'PYTHON_SINGLE_TARGET="python3_3"' >> /etc/portage/make.conf
    emerge --update --deep --newuse @world
    emerge --depclean
    emerge gentoolkit
    revdep-rebuild

    emerge vim
    eselect editor set 3
    emerge --unmerge nano
    ```

[gentoo]: http://gentoo.org/
[Linode]: https://www.linode.com/
