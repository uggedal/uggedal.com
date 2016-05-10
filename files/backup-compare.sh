#!/bin/sh

ROOT=$HOME/backup-compare

RAW=$ROOT/raw
SRC=$ROOT/src
DEST=$ROOT/dest

TIME=$(which time)

sudo apt-get -yqq install time exiftool bup bup-doc borgbackup

t() {
	printf '%s\n' "$*"
	$TIME "$@"
}

flushcache() {
	echo '> flush disk cache'
	sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
}

prepare() {
	echo '> preparing src'
	rm -rf $SRC
	$TIME cp -r $RAW $SRC
}

modify() {
	echo '> modifying src'
	for f in $(find $SRC -name \*.jpg | head -n100); do
		cp $f $f.copy
		exiftool -q -comment='this is a copy' $f.copy
	done
}

stats() {
	printf '> %s stats (%s):\n' $1 $2
	printf '  size: '
	BLOCKSIZE= du -s $ROOT/$1 | awk '{ print $1 }'
	printf '  files: '
	find $ROOT/$1 -type f | wc -l
}

bup() {
	export BUP_DIR=$DEST

	prepare
	stats src 1

	rm -rf $DEST
	flushcache
	t bup init
	t bup index $SRC
	t bup save -n test $SRC
	stats dest 1

	modify
	stats src 2

	t bup index $SRC
	t bup save -n test $SRC
	stats dest 2
}

borg() {
	prepare
	stats src 1

	rm -rf $DEST
	flushcache
	t borg init -e none $DEST
	t borg create $DEST::test1 $SRC
	stats dest 1

	modify
	stats src 2

	t borg create $DEST::test1 $SRC
	stats dest 2
}

$1
