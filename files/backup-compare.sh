#!/bin/sh -e

ROOT=$HOME/backup-compare

RAW=$ROOT/raw
SRC=$ROOT/src
DEST=$ROOT/dest
WRK=$ROOT/wrk
REST=$ROOT/rest

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
	local n=$1
	local t="$2"

	echo "> modifying src ($n files)"

	for f in $(find $SRC -name \*.jpg | head -n$n); do
		cp $f $f.copy
		exiftool -q -comment="$t" $f.copy
	done
}

stats() {
	printf '> %s stats (%s):\n' $1 $2
	printf '  size: '
	BLOCKSIZE= du -s $ROOT/$1 | awk '{ print $1 }'
	printf '  files: '
	find $ROOT/$1 -type f | wc -l
}

bup_init() {
	export BUP_DIR=$DEST
	t bup init
}

bup_snapshot() {
	t sh -ec "bup index $SRC && bup save -n test $SRC"
}

bup_restore() {
	t bup restore -C $REST test/latest
}

borg_init() {
	t borg init -e none $DEST
}

borg_snapshot() {
	t borg create $DEST::test$1 $SRC
}

borg_restore() {
	(
		mkdir -p $REST
		cd $REST
		t borg extract $DEST::testm_100
	)
}

obnam_init() {
	:
}

obnam_snapshot() {
	t obnam backup -r $DEST $SRC
}

obnam_restore() {
	t obnam restore -r $DEST --to $REST
}

zbackup_init() {
	t zbackup init --non-encrypted $DEST
}

zbackup_snapshot() {
	t sh -ec "tar -c $SRC | zbackup backup --non-encrypted $DEST/backups/test$1"
}

zbackup_restore() {
	mkdir -p $REST
	t sh -ec "zbackup restore --non-encrypted $DEST/backups/testm_100 | tar -C $REST -x"
}

restic_setup() {
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

restic_init() {
	export RESTIC_PASSWORD=foo
	t $WRK/restic/restic -r $DEST init
}

restic_snapshot() {
	t $WRK/restic/restic -r $DEST backup $SRC
}

restic_restore() {
	local last=$($WRK/restic/restic -r $DEST snapshots | awk 'END { print $1 }')
	t $WRK/restic/restic -r $DEST restore $last --target $REST
}

duplicity_init() {
	:
}

duplicity_snapshot() {
	t duplicity --no-encryption $SRC file://$DEST
}

duplicity_restore() {
	t duplicity --no-encryption file://$DEST $REST
}

sudo apt-get -yqq install time exiftool \
	golang-go \
	bup bup-doc borgbackup obnam zbackup duplicity

if [ $# -eq 0 ]; then
	set -- bup borg obnam zbackup restic duplicity
fi

for tool; do

	if type ${tool}_setup >/dev/null 2>&1; then
		${tool}_setup
	fi

	prepare

	{
		stats src 1

		rm -rf $DEST
		flushcache
		${tool}_init
		${tool}_snapshot 1
		stats dest 1

		modify 100 'this is a copy'
		stats src 2

		${tool}_snapshot 2
		stats dest 2

		${tool}_snapshot 3
		stats dest 3

		echo "> modifying src (1 file) and taking snapshot (100 times)"
		for i in $(seq 100); do
			modify 1 $i >/dev/null
			${tool}_snapshot m_$i >/dev/null 2>&1
		done

		stats dest 4

		rm -rf $REST
		${tool}_restore
	} 2>&1 | tee $ROOT/$tool.txt
done
