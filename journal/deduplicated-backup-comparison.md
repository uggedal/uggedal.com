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
for f in $(find ~/media -type -f -name \*.jpg | sort | head -n1000); do
	mkdir -p copy/$(dirname $f)
	cp $f copy/$f
	exiftool -comment='this is a copy' $f
done
```

### Bup

```sh
$ bup --version
debian/0.27-2

$ bup init
$ echo 3 > /proc/sys/vm/drop_caches
$ time bup init
Initialized empty Git repository in /home/eu/.bup/

real    0m0.220s
user    0m0.108s
sys     0m0.020s
$ time bup index ~/media
Indexing: 10356, done (11563 paths/s).

real    0m1.001s
user    0m0.668s
sys     0m0.108s
~ time bup save -n local-media ~/media
Reading index: 10356, done.
bloom: creating from 1 file (134195 objects).
bloom: adding 1 file (133957 objects).
bloom: adding 1 file (134692 objects).
bloom: creating from 4 files (536592 objects).
bloom: adding 1 file (132938 objects).
bloom: adding 1 file (134108 objects).
bloom: adding 1 file (133047 objects).
bloom: adding 1 file (132023 objects).
bloom: adding 1 file (131701 objects).
bloom: adding 1 file (131802 objects).
bloom: adding 1 file (132305 objects).
bloom: adding 1 file (130971 objects).
bloom: creating from 13 files (1727682 objects).
bloom: adding 1 file (131996 objects).
bloom: adding 1 file (131915 objects).
bloom: adding 1 file (133186 objects).
bloom: adding 1 file (133566 objects).
bloom: adding 1 file (132656 objects).
bloom: adding 1 file (133539 objects).
bloom: adding 1 file (131996 objects).
bloom: adding 1 file (133119 objects).
bloom: adding 1 file (133478 objects).
bloom: adding 1 file (133411 objects).
bloom: adding 1 file (133360 objects).
bloom: adding 1 file (133390 objects).
bloom: creating from 26 files (3456830 objects).
bloom: adding 1 file (133706 objects).
bloom: adding 1 file (133864 objects).
bloom: adding 1 file (133666 objects).
Saving: 100.00% (29181325/29181325k, 10356/10356 files), done.
bloom: adding 1 file (121721 objects).

real    17m10.586s
user    13m13.624s
sys     0m35.008s

```

TODO: clear caches before each run
TODO: compare stable and master versions
TODO: compare obnam experimental format
