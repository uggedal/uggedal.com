% OpenBSD on Linode
% 2015-10-13

Instructions for installing a [OpenBSD][] on a KVM [Linode][].

1. Create a new raw disk image using all space.
2. Create a new configuration profile using the first disk image
   as boot device, *Full-virtualization*, *Direct Disk* kernel
   and no *Filesystem/Boot helpers*.
3. Boot into rescue mode.
4. Write `miniroot*.fs` to the disk:

    ```sh
    wget http://ftp.eu.openbsd.org/pub/OpenBSD/snapshots/amd64/miniroot58.fs
    dd if=miniroot58.fs of=/dev/sda bs=1M
    ```
6. Reboot into the standard configuration.
7. Interrupt the `boot>` prompt and execute `set tty com0`.
8. Install OpenBSD. The following were my changes to the defaults:
    - System hostname: *hostname*
    - Run X: *no*
    - Setup user: *username*
    - Timezone: *UCT*
    - Root disk: *wd1*
    - Parition layout (for 4096M RAM):
        ```
        a   1024M  /
        b   4352M  swap
        d   2048M  /tmp
        e   8192M  /var
        f  10240M  /usr
        g          /home
        ```
    - HTTP Server: ftp.eu.openbsd.org
9. Set the second disk as boot device.

[OpenBSD]: http://www.openbsd.org/
[Linode]: https://www.linode.com/
