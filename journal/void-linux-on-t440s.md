% Void Linux on ThinkPad T440s
% draft

Instructions for installing a [Void Linux][] on a [ThinkPad T440s][t440s].

1. Boot an [Arch Linux image][arch].
2. Setup wifi with `wifi-menu`.
3. Run the following:

    ```sh
    DEV=/dev/sda

    sgdisk -Z $DEV
    sgdisk -n 1:0:+512M $DEV
    sgdisk -n 2:0:0 $DEV
    sgdisk -t 1:ef00 $DEV
    sgdisk -t 2:8300 $DEV
    sgdisk -c 1:bootefi $DEV
    sgdisk -c 2:root $DEV
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[t440s]: http://shop.lenovo.com/us/en/laptops/thinkpad/t-series/t440s/
[arch]: https://www.archlinux.org/download/
