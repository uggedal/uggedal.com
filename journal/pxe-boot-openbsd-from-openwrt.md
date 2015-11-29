% PXE boot OpenBSD from OpenWRT
% 2015-11-29

I had problems with getting an old amd64 system boot from USB using
`miniroot58.fs` as [`biosboot(8)`][biosboot] aborted with `ERR M`.
My only remaining option was to get [PXE][] working.

As my current wifi access point and router is running OpenWRT the
easiest option was to temporarily configure it to serve
OpenBSD installs.

First we need to download the `pxeboot` and `bsd.rd` programs.
My device had enough space in the `/tmp` tmpfs mount:

```sh
mkdir /tmp/tftp
cd /tmp/tftp
wget ftp://ftp.eu.openbsd.org/pub/OpenBSD/5.8/amd64/pxeboot
wget ftp://ftp.eu.openbsd.org/pub/OpenBSD/5.8/amd64/bsd.rd
```

Then we'll have to edit the dhcp configuration in
`/etc/config/dhcp`:

```sh
config dnsmasq
	option enable_tftp '1'
	option tftp_root '/tmp/tftp'
	[existing values...]

config boot openbsd
	option filename 'pxeboot'
	option serveraddress '192.168.1.1'
	option servername 'OpenWRT PXE'
```

A restart of dnsmasq and we should be ready:

```sh
/etc/init.d/dnsmasq restart
```

I then booted the system with PXE and used `bsd.rd` at the
`boot>` prompt.

Note that you must disable the `tftp_root` setting when done
as `/tmp` is volatile. When the OpenWRT system reboots
`/tmp/tftp` will be gone and `dnsmasq` will fail to start
which leads to no DHCP nor DNS for your network.

[biosboot]:http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/amd64/biosboot.8
[PXE]: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
