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
    echo 'FEATURES="$FEATURES nodoc noinfo clean-logs compressdebug"' >> /mnt/etc/portage/make.conf
    echo 'app-shells/bash -net' >> /mnt/etc/portage/package.use
    vi /mnt/etc/portage/make.conf
    # Add 'vim-syntax bash-completion -nls -cracklib -python -perl -fortran -openmp -zeroconf -tcpd' to USE
    cp /etc/resolv.conf /mnt/etc/resolv.conf
    mount -t proc proc /mnt/proc
    mount --rbind /sys /mnt/sys
    mount --rbind /dev /mnt/dev
    chroot /mnt /bin/bash
    . /etc/profile
    emerge-webrsync
    echo 'INSTALL_MASK="/usr/lib/systemd"' >> /etc/portage/make.con
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
    metadata/md5-cache/app-accessibility/
    metadata/md5-cache/app-antivirus/
    metadata/md5-cache/app-crd/
    metadata/md5-cache/app-emacs/
    metadata/md5-cache/app-forensics/
    metadata/md5-cache/app-laptop/
    metadata/md5-cache/app-leechcraft/
    metadata/md5-cache/app-mobilephone/
    metadata/md5-cache/app-office*/
    metadata/md5-cache/app-pda/
    metadata/md5-cache/app-xemacs/
    metadata/md5-cache/dev-ada/
    metadata/md5-cache/dev-dotnet/
    metadata/md5-cache/dev-embedded/
    metadata/md5-cache/dev-games/
    metadata/md5-cache/dev-haskell/
    metadata/md5-cache/dev-java/
    metadata/md5-cache/dev-lisp/
    metadata/md5-cache/dev-lua/
    metadata/md5-cache/dev-ml/
    metadata/md5-cache/dev-php/
    metadata/md5-cache/dev-qt/
    metadata/md5-cache/dev-ruby/
    metadata/md5-cache/dev-scheme/
    metadata/md5-cache/dev-tcltk/
    metadata/md5-cache/dev-tex*/
    metadata/md5-cache/games-*/
    metadata/md5-cache/gnome-*/
    metadata/md5-cache/gnustep-*/
    metadata/md5-cache/gpe-*/
    metadata/md5-cache/java-virtuals/
    metadata/md5-cache/kde-*/
    metadata/md5-cache/lxde-base/
    metadata/md5-cache/media-radio/
    metadata/md5-cache/media-tv/
    metadata/md5-cache/net-dialup/
    metadata/md5-cache/net-ftp/
    metadata/md5-cache/net-im/
    metadata/md5-cache/net-news/
    metadata/md5-cache/net-nntp/
    metadata/md5-cache/net-print/
    metadata/md5-cache/net-voip/
    metadata/md5-cache/net-zope/
    metadata/md5-cache/razorqa-base/
    metadata/md5-cache/rox-*/
    metadata/md5-cache/sci-*/
    metadata/md5-cache/sys-freebsd/
    metadata/md5-cache/sys-infiniband/
    metadata/md5-cache/www-apache/
    metadata/md5-cache/www-plugins/
    metadata/md5-cache/xfce-*/
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

    curl https://raw.github.com/uggedal/dotfiles/master/.inputrc > /etc/inputrc

    emerge vim
    eselect editor set 3
    emerge --unmerge nano

    emerge tmux

    emerge base-completion
    eselect bashcomp enable --global base
    eselect bashcomp enable --global coreutils
    eselect bashcomp enable --global gentoo
    eselect bashcomp enable --global eselect
    eselect bashcomp enable --global ssh
    eselect bashcomp enable --global tmux
    eselect bashcomp enable --global git

    echo 'sys-block/thin-provisioning-tools ~amd64' >> /etc/portage/package.accept_keywords
    echo 'dev-lang/go ~amd64' >> /etc/portage/package.accept_keywords
    echo 'app-emulation/lxc ~amd64' >> /etc/portage/package.accept_keywords
    echo 'app-emulation/docker ~amd64' >> /etc/portage/package.accept_keywords

    echo 'sys-fs/lvm2 -lvm1' >> /etc/portage/package.use

    emerge app-emulation/docker
    echo net.ipv4.ip_forward = 1 > /etc/sysctl.d/docker.conf
    sysctl -p /etc/sysctl.d/docker.conf
    rc-update add docker default
    /etc/init.d/docker start
    eselect bashcomp enable --global docker

    echo 'CLEAN_DELAY=0' >> /etc/portage/make.conf
    ```

[gentoo]: http://gentoo.org/
[Linode]: https://www.linode.com/
