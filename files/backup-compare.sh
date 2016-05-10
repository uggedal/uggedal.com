#!/bin/sh

ROOT=$HOME/backup-compare

RAW=$ROOT/raw
SRC=$ROOT/src
DEST=$ROOT/dest

TIME=$(which time)

sudo apt-get -yqq install time exiftool bup bup-doc borgbackup obnam

t() {
	printf '%s\n' "$*"
	$TIME -f 'real\t%e\nuser\t%U\nsys\t%S\nmem\t%MKB\n' "$@"
}

flushcache() {
	echo '> flush disk cache'
	sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
}

prepare() {
	echo '> preparing src'
	rm -rf $SRC
	cp -r $RAW $SRC
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

bup_1() {
	export BUP_DIR=$DEST
	t bup init
	t bup index $SRC
	t bup save -n test $SRC
}

bup_2() {
	t bup index $SRC
	t bup save -n test $SRC
}

borg_1() {
	t borg init -e none $DEST
	t borg create $DEST::test1 $SRC
}

borg_2() {
	t borg create $DEST::test2 $SRC
	stats dest 2
}

obnam_1() {
	t obnam backup -r $DEST $SRC
}

obnam_2() {
	t obnam backup -r $DEST $SRC
}

TOOL=$1

prepare
stats src 1

rm -rf $DEST
flushcache
${TOOL}_1
stats dest 1

modify
stats src 2

${TOOL}_2
stats dest 2
