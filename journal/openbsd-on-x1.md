% OpenBSD on ThinkPad Carbon X1 3rd gen
% 2015-10-21

Instructions for installing [OpenBSD][] on a
[ThinkPad Carbon X1 3rd gen][x1].

0. Prepare USB stick (example from Linux):

	```sh
	wget http://ftp.eu.openbsd.org/pub/OpenBSD/snapshots/amd64/miniroot58.fs
	dd if=miniroot58.fs of=/dev/sdb bs=1M
	```
1. Enable legacy boot in BIOS.
2. Boot USB stick.
3. Use the `(S)hell` to prepare the disk for full disk encryption:

	```sh
	fdisk -iy sd0
	disklabel -E sd0
	# a b (swap 8GB)
	# a a (RAID remaining space)
	bioctl -c C -l /dev/sd0a softraid0
	```
4. Install OpenBSD. The following were my changes to the defaults:
    - System hostname: *hostname*
    - Setup user: *username*
    - Timezone: *Europe/Oslo*
    - Root disk: *sd2*
    - Parition layout (~470GB):

        ```
        a    1G  /
        d    2G  /tmp
        e  200G  /var
        f   10G  /usr
        g        /home
        ```
    - HTTP Server: ftp.eu.openbsd.org
