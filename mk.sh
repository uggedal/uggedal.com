#!/bin/sh

site_title='Eivind Uggedal'

tmpl_head() {
  local title="$1"

  cat <<EOF
<!doctype html>
<html>
  <head>
    <title>$title</title>

    <link rel=alternate
          type=application/atom+xml
          href=/journal/index.atom
          title="Feed of the latest journal entries">
    <link href=/static/style.css rel="stylesheet">
  </head>
  <body>

    <h1>
      <a href=/>$site_title</a>
    </h1>
EOF
}

tmpl_foot() {
  cat <<EOF
    <footer>
      Read <a href=https://github.com/uggedal/uggedal.com>the source</a>.
    </footer>

  </body>
</html>
EOF
}

tmpl_article() {
  local title="$1"
  local date="$2"
  local body="$3"

}

header() {
  sed $2'q;d' $1 | sed 's/^% //'
}

htmlext() {
  printf '%s.html' ${1%*.md}
}

article() {
  local target title date

  target=$(htmlext $1)
  title=$(header $1 1)
  date=$(header $1 2)

  tmpl_head "$title" > $target
  cat <<EOF >>$target
    <article>
      <header>
        <h1>$title</h1>

        <p class="byline">
          An entry from <strong>$date</strong> in
          the <a href=/journal>Journal</a>.
        </p>
      </header>

      $(sed '1,2d' $1 | markdown)
    </article>
EOF
  tmpl_foot >> $target
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
  local target article ar_title ar_date ar_href

  target=$1
  title="$2"
  shift 2

  tmpl_head "$title" > $target

  [ "$1" = '--limit' ] && {
    cat <<EOF >> $target
    <section class=about>
      I'm a programmer at <a href=http://bekk.no>BEKK</a>.
      I share <a href=https://github.com/uggedal>open source code</a>
      written in my pastime.
      I created <a href=http://mediaqueri.es>mediaqueri.es</a>, <em>the</em>
      collection of responsively designed web sites.
      Previously I ran <a href=http://wasitup.com>wasitup.com</a>,
      a free HTTP monitor doing 4.5 million outgoing requests each
      day.
      You can contact me at
      <a href=mailto:eivind@uggedal.com>eivind@uggedal.com</a>.
    </section>
EOF
  }
  cat <<EOF >> $target
    <section class=entries>
      <header>
        <h1>$title</h1>
      </header>
      <ol>
EOF

  for ar in $(reverse_chronological "$@"); do
    ar_title=$(header $ar 1)
    ar_date=$(header $ar 2)
    ar_href=/$(htmlext $ar)

    cat <<EOF >> $target
        <li>
          $ar_date<br>
          <a href=$ar_href>$ar_title</a>
        </li>
EOF
  done

  printf '      </ol>\n' >> $target

  [ "$1" = '--limit' ] && {
    cat <<EOF >> $target
      <p>
        <a href=/journal>
          <em>All journal entries</em>
        </a>
      <p>
EOF
  }

  printf '    </section>\n' >> $target


  tmpl_foot >> $target
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
    <content type="html">
      <![CDATA[$(sed '1,2d' $f | markdown)]]>
    </content>
  </entry>
EOF
  done

  printf '</feed>\n' >> $target
}

action=$1
shift
$action "$@"