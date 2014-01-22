% My ideal Linux distro
% Eivind Uggedal
% 2013-11-12

### Design

* Less code.
* Small components.
* Do one thing well.
* One way to do it.
* Vanilla packages.
* Simple package creation
* No helpers.
* Base system should only contain components for booting and a
  package manager.
* Stable core with ability to update or build more recent versions of
  non-core packages.

### Alternatives

Each distro is rated from 1 to 5 in various categories.

|              | Stability | Minimalism | Vanilla | Packaging | Total  |
|--------------|----------:|-----------:|--------:|----------:|-------:|
| Arch Linux   |         1 |          2 |       4 |         4 |     11 |
| CRUX         |         2 |          4 |       5 |         2 |     13 |
| Alpine Linux |         3 |          5 |       2 |         5 |     15 |
| Slackware    |         5 |          3 |       5 |         3 |     16 |

#### Arch Linux

##### +

* Mostly vanilla packages
* Somewhat minimal base
* Good package manager (but awful cli interface)
* `PKGBUILD` and `makepkg` makes it really easy to create packages

##### -

* Far from stable.
* Packages carry too many dependencies
* Systemd is not as pleasant and fexible as initialy thought

#### CRUX

##### +

* Vanilla packages.
* Somewhat minimal base
* As easy as Arch Linux to create packages
* Stable core releases (but limited testing)
* Minimal set of dependencies for packages
* Sysvinit

##### -

* Recompiling ports could lead to unstable core
* Fragmented set of package management tools
* `prt-tools` is written in perl
* Self-compiled kernel
* Lacking good documentation

#### Alpine Linux

##### +

* Very minimal base
* Good package manager
* As easy as Arch Linux to create packages
* Stable core releases (but limited testing)
* uClibc (libmusl in the future)
* Busybox
* mdev for servers, udev for desktops

##### -

* Heavily patched packages due to non glibc
* No chromium package
* Patched kernels (but provides a vanilla alternative)
* OpenRC (better than systemd, but too complex compared to sysvinit)
* Custom configuration helpers

#### Slackware

##### +

* Vanilla packages
* Extremely stable
* Flexible package management
* Generally well documented
* `slackpkg+` handles third party repositories well
* Sysvinit

##### -

* Full install is Recommended to satisfy all dependencies
* More work to make a minimal system due to manual dependency handling
* SlackBuilds are not DRY
* Installer is inflexible (should just be a receipe)
* Some unneeded distro specific helpers
