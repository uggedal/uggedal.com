% Deduplicated Backup Comparison
% draft

I've been on lookup for a fully open source alternative since Tarsnap
popularized deduplicateted backups. I've compared the efficiency
(storage and bandwidth), performance, security and utility of
the main offerings. I'm ignoring what should be every backup system's
most important quality: stability and correctness.

### Test data

Initally the input data consists of ten thousand of JPEG images and small
H.264 encoded video files totaling 28GB.

```sh
$ du -s ~/media
29201852        ~/media
$ find ~/media -type f | wc -l
10349
```
After an initial backup a few of the files were duplicated and
modified slightly:

```sh
for f in $(find ~/media -type f -name \*.jpg | sort | head -n100); do
	mkdir -p ~/media/copy/$(dirname $f)
	cp $f ~/media/copy/$f
	exiftool -comment='this is a copy' ~/media/copy/$f
done
```

```sh
$ du -s ~/media/copy
256552  ~/media/copy
```

### Bup

```sh
$ bup --version
debian/0.27-2

$ bup init
$ echo 3 > /proc/sys/vm/drop_caches
$ time bup init
$ time bup index ~/media
$ time bup save -n local-media ~/media
$ du -s ~/.bup/
# new files
$ echo 3 > /proc/sys/vm/drop_caches
$ time bup index ~/media
$ time bup save -n local-media ~/media
$ du -s ~/.bup/
# no new files
$ echo 3 > /proc/sys/vm/drop_caches
$ time bup index ~/media
$ time bup save -n local-media ~/media

```

TODO: peak memory usage (maybe GNU time)
TODO: measure restore also
TODO: measure network where applicable
TODO: clear caches before each run
TODO: compare stable and master versions
TODO: compare obnam experimental format
