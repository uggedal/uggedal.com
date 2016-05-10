#!/bin/sh -e

ROOT=$HOME/backup-compare

RAW=$ROOT/raw
SRC=$ROOT/src
DEST=$ROOT/dest
WRK=$ROOT/wrk

TIME=$(which time)

RESTIC_V=6bc7a7

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

zbackup_1() {
	t zbackup init --non-encrypted $DEST
	t sh -c "tar c $SRC | zbackup backup --non-encrypted $DEST/backups/test1"
}

zbackup_2() {
	t sh -c "tar c $SRC | zbackup backup --non-encrypted $DEST/backups/test2"
}

restic_0() {
	if [ -x $WRK/restic/restic ]; then
		return 0
	fi

	mkdir -p $WRK/restic
	(
		cd $WRK/restic
		curl -L https://github.com/restic/restic/archive/$RESTIC_V.tar.gz |
			tar --strip-components=1 -xz
		go run build.go
	)
}

restic_1() {
	export RESTIC_PASSWORD=foo
	t $WRK/restic/restic -r $DEST init
	t $WRK/restic/restic -r $DEST backup $SRC
}

restic_2() {
	t $WRK/restic/restic -r $DEST backup $SRC
}

sudo apt-get -yqq install time exiftool \
	golang-go \
	bup bup-doc borgbackup obnam zbackup

for tool; do

	if type ${tool}_0 >/dev/null 2>&1; then
		${tool}_0
	fi

	prepare

	{
		stats src 1

		rm -rf $DEST
		flushcache
		${tool}_1
		stats dest 1

		modify
		stats src 2

		${tool}_2
		stats dest 2
	} 2>&1 | tee $ROOT/$tool.txt
done
