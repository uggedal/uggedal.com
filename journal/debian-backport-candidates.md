% Finding Potential Debian Backport Upgrades
% 2022-01-19

As an avid user of Debian Stable there are occasions where I want to move to
newer upstream versions for some packages. If you're lucky Debian Developers
have provided a fresh backport from Debian Testing in the [Debian
Backports][bpo] repositories.

Finding the packages that you currently have installed which have upgrades in
Debian Backports can be gotten with attempting a global upgrade and then
canceling it:

```sh
sudo apt -t bullseye-backports upgrade
```

I wanted something a bit neater and created the following script:

```python
#!/usr/bin/env python3

import apt


def getbpv(p):
    if p.versions is None:
        return None
    for version in p.versions:
        for origin in version.origins:
            if origin.archive.endswith("backports"):
                return version.version
            return None


s = set()

with apt.Cache() as cache:
    for p in cache:
        bpv = getbpv(p)
        if bpv is None or not p.is_installed:
            continue
        if bpv == p.installed:
            s.add(
                "[x] {:20} {:10}".format(
                    p.versions[0].source_name, p.installed.version
                )
            )
        else:
            s.add(
                "[ ] {:20} {:10} -> {:10}".format(
                    p.versions[0].source_name, p.installed.version, bpv
                )
            )

for l in sorted(s):
    print(l)
```

Download [apt-backports](/apt-backports)
and save it to somewhere on your `$PATH` and make it executable.
It does not require superuser privileges, so `~/.local/bin/` can be a good
place.

It requires that you have the `python3-apt` package installed. It's likely that
you already have it since it's a dependency of `unattended-upgrades`,
`apt-listchanges`. `command-not-found` and more.

Example output where packages which are already upgraded to Debian Backports are
marked with `[x]`:

```
[ ] at-spi2-core         2.38.0-4   -> 2.42.0-2~bpo11+1
[ ] curl                 7.74.0-1.3+deb11u1 -> 7.81.0-1~bpo11+1
[ ] devscripts           2.21.3+deb11u1 -> 2.21.7~bpo11+1
[ ] e2fsprogs            1.46.2-2   -> 1.46.5-2~bpo11+2
[ ] git                  1:2.30.2-1 -> 1:2.34.1-1~bpo11+1
[ ] iproute2             5.10.0-4   -> 5.15.0-1~bpo11+1
[ ] libbpf               1:0.3-2    -> 1:0.5.0-1~bpo11+1
[ ] libdrm               2.4.104-1  -> 2.4.109-2~bpo11+1
[ ] libepoxy             1.5.5-1    -> 1.5.8-1~bpo11+1
[ ] lintian              2.104.0    -> 2.111.0~bpo11+1
[ ] linux                5.10.84-1  -> 5.15.5-2~bpo11+1
[ ] linux-signed-amd64   5.10.84-1  -> 5.15.5-2~bpo11+1
[ ] npm                  7.5.2+ds-2 -> 8.3.0~ds-2~bpo11+1
[ ] openldap             2.4.57+dfsg-3 -> 2.4.59+dfsg-1~bpo11+1
[ ] sway                 1.5-7      -> 1.6.1-2~bpo11+1
[ ] tmux                 3.1c-1+deb11u1 -> 3.2a-4~bpo11+1
[ ] vulkan-loader        1.2.162.0-1 -> 1.2.182.0-2~bpo11+1
[ ] wayland              1.18.0-2~exp1.1 -> 1.19.0-2~bpo11+1
[x] neovim               0.6.1-3~bpo11+1
[x] python-pipx          0.16.5-1~bpo11+1
[x] tree-sitter          0.20.1-1~bpo11+1
```

[bpo]: https://backports.debian.org
