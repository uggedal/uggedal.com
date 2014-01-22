% Systemd migration
% Eivind Uggedal
% 2012-09-08

Arch Linux (which I use on a Macbook Air, Macbook Pro, Raspberry Pi,
and [servers][archserver]) is [moving to systemd][systemdmove].
I started to migrate these systems to systemd a few weeks ago and
today the last system (the server running this site, [mediaqueri.es][], and
a few other sites) was migrated:

    :::text
    magnesium ~ ps_mem
     Private  +   Shared  =  RAM used       Program 

    208.0 KiB +  28.5 KiB = 236.5 KiB       dhcpcd
    428.0 KiB + 173.5 KiB = 601.5 KiB       systemd-logind
    596.0 KiB +  64.5 KiB = 660.5 KiB       crond
    572.0 KiB + 100.0 KiB = 672.0 KiB       systemd-udevd
    652.0 KiB +  74.0 KiB = 726.0 KiB       dbus-daemon
    848.0 KiB + 173.0 KiB =   1.0 MiB       ntpd
    960.0 KiB + 217.5 KiB =   1.1 MiB       login
    612.0 KiB + 681.5 KiB =   1.3 MiB       systemd-journald
      1.9 MiB +  83.0 KiB =   1.9 MiB       bash
      2.1 MiB + 224.0 KiB =   2.4 MiB       systemd
      1.4 MiB +   1.2 MiB =   2.6 MiB       nginx (2)
      6.6 MiB +   2.0 MiB =   8.5 MiB       postgres (5)
     20.8 MiB + 728.5 KiB =  21.5 MiB       salt-minion
     42.2 MiB +  60.0 KiB =  42.3 MiB       redis-server
     68.9 MiB +  10.6 MiB =  79.5 MiB       uwsgi (7)
    ---------------------------------
                            165.0 MiB
    =================================

Apart from installing `systemd-sysvcompat` and enabling the correct units
I had to:

* fix some bugs in [salt's systemd module][salt],
* create and submit a systemd service unit to the
  [redis package][redis],
* build my own PostgreSQL package since a version with
  [systemd support][postgresql] had not been released, and
* add a systemd template service unit to my [uWSGI package][uwsgi]
  instead of using emperor mode.

So far I'm happy with systemd. Faster boot times I couldn't care less about,
but restarting of failed services, socket activation for less used services,
and templated service units are awesome.

[archserver]: https://twitter.com/uggedal/status/199534293662449666
[systemdmove]: https://bbs.archlinux.org/viewtopic.php?pid=1149530#p1149530
[mediaqueri.es]: http://mediaqueri.es
[salt]: https://github.com/saltstack/salt/commits/develop/salt/modules/systemd.py
[redis]: https://projects.archlinux.org/svntogit/community.git/commit/trunk?h=packages/redis&id=c5bb95976c16278f184b25863e65b80f5b9b8e50
[postgresql]: https://projects.archlinux.org/svntogit/packages.git/commit/trunk?h=packages/postgresql&id=4b2cb4108126707fede9ddad17c0100c8e960b24
[uwsgi]: https://github.com/uggedal/pkg/tree/master/uwsgi
