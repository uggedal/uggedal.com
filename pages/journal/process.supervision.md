date: 2012-03-09
title: Process Supervision
draft: true

Not all processes are equally stable. A *process supervisor* is essential when
dealing with long-running processes which have a high possibility of dying or
getting [killed by the OS][oom-killer]. There are loads of alternatives in
this space, ranging from single responsibility implementations to large
projects trying to handle everything but the kitchen sink.


### Overview

I've used the following aspects to distinguish the different processes
supervision solutions:

#### Process 1

Does the processes supervisor need to be started from the
kernel as process number one?

#### Process runners

Process runners will be the parent process for the process you would like
to keep running. To stay the parent process they can only handle
non-daemonizing programs or programs which can be configured to not daemonize.
According to Dustin Sallings process runners is [the right way][right-way]
to supervise your programs.

#### Process monitors

Process monitors supervises daemonized programs through different types
of polling for their state.

#### LOC

A high degree of complexity is not something you would like to have
in a critial piece of your stack like a process supervisor.
To gauge the complexity of each solution I've measured
actual lines of code determined by [`cloc`][cloc]. I ignored
documentation, tests, bundled external dependencies,
translation files, and build scripts.

#### Responsiveness

A test daemon was created to measure how much overhead the supervisors
added and how instant they reacted to failure. The test daemon and
configurations for running it under different supervision suites
are available in a [git repository][code].

TODO: describe test daemon.

#### VmPeak

Peak virtual memory size of supervision process as determined by
`grep VmPeak /proc/$PID/status`.

<table>
  <thead>
    <tr>
      <th>&nbsp;
      <th>Version
      <th>Process 1
      <th><abbr title="Process runner">Runner</abbr>
      <th><abbr title="Process monitor">Monitor</abbr>
      <th><abbr title="Lines of code">LOC</abbr>
      <th>Responsiveness
      <th><abbr title="Peak virtual memory size">VmPeak</abbr>

  <tbody>
    <tr>
      <td><a href="#sysvinit">sysvinit inittab</a>
      <td>2.88
      <td>&#10003;
      <td>&#10003;
      <td>&nbsp;
      <td>6562
      <td>N
      <td>N
    <tr>
      <td><a href="#Upstart">upstart</a>
      <td>1.4
      <td>&#10003;
      <td>&#10003;
      <td>&#10003;
      <td>11054
      <td>N
      <td>N
    <tr>
      <td><a href="#systemd">systemd</a>
      <td>43
      <td>&#10003;
      <td>&#10003;
      <td>&#10003;
      <td>87419
      <td>N
      <td>N
    <tr>
      <td><a href="#daemontools">daemontools</a>
      <td>0.76
      <td>&nbsp;
      <td>&#10003;
      <td>&nbsp;
      <td>3750
      <td>N
      <td>N
    <tr>
      <td><a href="#runit">runit</a>
      <td>2.1.1
      <td>&nbsp;
      <td>&#10003;
      <td>&nbsp;
      <td>5685
      <td>N
      <td>N
    <tr>
      <td><a href="#s6">s6</a>
      <td>0.14
      <td>&nbsp;
      <td>&#10003;
      <td>&nbsp;
      <td>3851
      <td>N
      <td>N
    <tr>
      <td><a href="#perp">perp</a>
      <td>2.05
      <td>&nbsp;
      <td>&#10003;
      <td>&nbsp;
      <td>6823
      <td>N
      <td>N

  <tbody>
    <tr>
      <td><a href="#supervisord">supervisord</a>
      <td>3.0a12
      <td>&nbsp;
      <td>&#10003;
      <td>&nbsp;
      <td>7211
      <td>N
      <td>N
    <tr>
      <td><a href="#restartd">restartd</a>
      <td>0.2.2
      <td>&nbsp;
      <td>&nbsp;
      <td>&#10003;
      <td>373
      <td>N
      <td>N
    <tr>
      <td><a href="#monit">monit</a>
      <td>5.3.2
      <td>&nbsp;
      <td>&nbsp;
      <td>&#10003;
      <td>33891
      <td>N
      <td>N
    <tr>
      <td><a href="#god">god</a>
      <td>0.12.1
      <td>&nbsp;
      <td>&nbsp;
      <td>&#10003;
      <td>3978
      <td>N
      <td>N
</table>


As I'm only concerned with solutions running on Linux I've left out
BSD init's [ttys][], Solaris' [smf][], and OS X's [launchd][].

All alternatives were compared on Arch Linux apart from Upstart which
were tested on Ubuntu Server 12.04 Beta 1.


### Process runners

<h4 id="sysvinit">sysvinit inittab</h4>

By placing calls to binaries in System V init's [`/etc/inittab`][inittab] it's
able to spawn processes and make sure they are running if you use the
`respawn` action. Processes started from `/etc/inittab` should not detach from
its parent (i.e. run in foreground, not daemon mode).

TODO: usage example, including reload of watched services

While not a very flexible solution for supervising processes,
`/etc/inittab` is very useful for continously running other supervision suites
unable to be process 1.

<h4 id="upstart">Upstart</h4>

[Upstart] has been the default init in Ubuntu since 6.10 (Edgy Eft). Fedora
used Upstart for 6 releases before migrating to `systemd`.

TODO: usage example

TODO: both runner and monitor.

If tracking a daemon it uses [ptrace(2)][ptrace] to keep track of its
process id.

<h4 id="systemd">systemd</h4>

[`systemd`][systemd] debuted in Fedora 15.

TODO: usage example

TODO: both runner and monitor.

If tracking a forking daemon systemd uses a reference to a pid file in the
service's unit file for tracking its process id.

http://monolight.cc/2011/05/the-systemd-fallacy/
http://news.ycombinator.com/item?id="3663035

<h4 id="daemontools">daemontools</h4>

[`daemontools`][daemontools] was created by D. J. Bernstein of [qmail][] fame.
It has not seen any updates for a decade, but has prooven to be extremely
stable. A combinations of infrequent releases and a formerly more restrictive
license spawned many clones and extensions.

TODO: usage example

Although one can run daemontools as process 1,
it was [not designed for it][svscan1].

http://cr.yp.to/daemontools/faq/create.html#why
http://thedjbway.b0llix.net/daemontools.html

<h4 id="runit">runit</h4>

[`runit`][runit] ...

TODO: usage example

Despite the fact that runit was designed so that it can [replace init][runit1]
running as process 1, I've never seen it used as a replacement for init.

<h4 id="s6">s6</h4>

[`s6`][s6] ...

TODO: usage example

Like runit, s6 was designed so that it can run as [process 1][s61] if one
wants to.

<h4 id="perp">perp</h4>

[`perp`][perp] ...

Single process.
FHS.
No symlnks, uses sticky bit of config directory.

TODO: usage example

<h4 id="supervisord">supervisord</h4>

[`supervisord`][supervisord] ...

TODO: usage example


### Process monitors

<h4 id="restartd">restartd</h4>

Weighting in at a few hundred lines of C code [`restartd`][restartd] is the
simplest solution of those comprared here.

TODO: usage example

<h4 id="monit">monit</h4>

[`monit`][monit] ...

TODO: usage example

Monit no support for daemonizing foreground processes. If you are
dealing with programs which does not self-daemonize you can use [daemonize][].

<h4 id="god">god</h4>

[`god`][god] ...

TODO: usage example

Has support for daemonizing foreground processes.

Alternative: https://github.com/arya/bluepill


### Conclusion

TODO: write me.


### Resources:

http://blog.gmane.org/gmane.comp.sysutils.supervision.general
http://www.skarnet.org/software/s6/why.html
http://recycle.lbl.gov/~ldoolitt/foundations.html


[oom-killer]: http://lwn.net/Articles/317814/
[right-way]: http://dustin.github.com/2010/02/28/running-processes.html
[code]: https://github.com/uggedal/supervision
[cloc]: http://cloc.sourceforge.net/
[inittab]: http://man.cx/inittab(4)
[ptrace]: http://man.cx/PTRACE(2)
[ttys]: http://www.freebsd.org/cgi/man.cgi?query=ttys
[restartd]: http://packages.debian.org/unstable/restartd
[daemontools]: http://cr.yp.to/daemontools.html
[qmail]: http://cr.yp.to/qmail.html
[svscan1]: http://code.dogmap.org/svscan-1/
[runit]: http://smarden.org/runit/
[runit1]: http://smarden.org/runit/replaceinit.html
[s6]: http://www.skarnet.org/software/s6/index.html
[s61]: http://www.skarnet.org/software/s6/s6-svscan-1.html
[perp]: http://b0llix.net/perp/
[smf]: http://opensolaris.org/os/community/smf
[launchd]: http://launchd.macosforge.org/
[Upstart]: http://upstart.ubuntu.com/
[systemd]: http://www.freedesktop.org/wiki/Software/systemd/
[monit]: http://mmonit.com/monit/
[daemonize]: http://software.clapper.org/daemonize/
[supervisord]: http://supervisord.org/
[god]: http://godrb.com/