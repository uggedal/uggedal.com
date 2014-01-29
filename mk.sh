#!/bin/sh

header() {
  sed $2'q;d' $1 | sed 's/^% //'
}

tmpl() {
  awk '
  {
    print substitute($0)
  }

  function substitute(raw) {
    if (match(raw, /\{\{([^}]*)\}\}/)) {
      tag = substr(raw, RSTART, RLENGTH)
      key = substr(raw, RSTART+2, RLENGTH-4)
      gsub(tag, ENVIRON[key], raw)
      return substitute(raw)
    } else {
      return raw
    }
  }
  ' $1
}

inject() {
  local line
  line=$(sed -n '/@@BODY@@/=' $2)

  sed "${line}r $1" | sed "${line}d"
}

htmlext() {
  printf '%s.html' ${1%*.md}
}

site_title='Eivind Uggedal'
export site_title

article() {
  local layout tmp

  layout=$(dirname $1)/article.tmpl

  title=$(header $1 1)
  date=$(header $1 2)
  export title date

  tmp=$(mktemp)
  trap "rm $tmp" EXIT TERM INT

  sed '1,2d' $1 | markdown > $tmp

  tmpl $layout | inject $tmp $layout > $(htmlext $1)
}

reverse_chronological() {
  local limit=9999
  local date

  [ "$1" = '--limit' ] && {
    limit=$2
    shift 2
  }

  for f; do
    date=$(header $f 2)
    [ "$date" = draft ] || printf '%s %s\n' $date $f
  done | sort -r | head -n$limit | cut -d' ' -f2
}

index() {
  local target layout tmpl f f_date f_title

  target=$1
  shift
  layout=$(dirname $target)/index.tmpl

  tmp=$(mktemp)
  trap "rm $tmp" EXIT TERM INT

  for f in $(reverse_chronological "$@"); do
    f_title=$(header $f 1)
    f_date=$(header $f 2)

    markdown <<EOF >> $tmp
1. $f_date  
   [$f_title](/$(htmlext $f))
EOF
  done

  tmpl $layout | inject $tmp $layout > $target
}

feed() {
  local target

  target=$1
  shift

cat <<EOF > $target
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title type="text">Journal of Eivind Uggedal</title>
  <id>http://uggedal.com/journal/index.atom</id>
  <updated>$(date -u +"%Y-%m-%dT%H:%M:%SZ")</updated>
  <link href="http://uggedal.com/journal" />
  <link href="http://uggedal.com/journal/index.atom" rel="self" />
  <author>
    <name>Eivind Uggedal</name>
  </author>
  <generator>POSIX shell</generator>
EOF

  for f in $(reverse_chronological "$@"); do
    f_title=$(header $f 1)
    f_date=$(header $f 2)
    f_url=http://uggedal.com/$(htmlext $f)

    cat <<EOF >> $target
  <entry xml:base="http://uggedal.com/journal/index.atom">
    <title type="text">$f_title</title>
    <id>$f_url</id>
    <updated>${f_date}T00:00:00Z</updated>
    <link href="$f_url" />
  </entry>
EOF
  done

  printf '</feed>\n' >> $target
}

action=$1
shift
$action "$@"
