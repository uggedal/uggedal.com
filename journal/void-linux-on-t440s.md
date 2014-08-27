% Void Linux on ThinkPad T440s
% draft

Instructions for installing a [Void Linux][] on a [ThinkPad T440s][t440s].

1. Boot an [Arch Linux image][arch].
2. Setup wifi with `wifi-menu`.
3. Run the following:

    ```sh
    DEV=/dev/sda

    sgdisk -Z $DEV
    sgdisk -n 1:0:+512M $HD
    sgdisk -n 2:0:0 $HD
    sgdisk -t 1:ef00 $HD
    sgdisk -t 2:8300 $HD
    sgdisk -c 1:bootefi $HD
    sgdisk -c 2:root $HD
    ```
5. Reboot.

[Void Linux]: http://voidlinux.eu/
[t440s]: http://shop.lenovo.com/us/en/laptops/thinkpad/t-series/t440s/
[arch]: https://www.archlinux.org/download/
