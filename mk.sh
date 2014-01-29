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
  local layout=page.tmpl
  local tmp

  title=$(header $1 1)
  date=$(header $1 2)
  export title date

  tmp=$(mktemp)
  trap "rm $tmp" EXIT TERM INT

  sed '1,2d' $1 | markdown > $tmp

  tmpl $layout | inject $tmp $layout > $(htmlext $1)
}

reverse_chronological() {
  for article; do
    printf '%s %s\n' $(header $article 2) $article
  done | sort -r | cut -d' ' -f2
}

index() {
  local layout=index.tmpl
  local date
  local path
  local tmp

  title=Journal
  export title

  local target=$1
  shift

  tmp=$(mktemp)
  trap "rm $tmp" EXIT TERM INT

  for article in $(reverse_chronological "$@"); do
    title=$(header $article 1)
    date=$(header $article 2)

    [ "$date" = draft ] || markdown <<EOF >>$tmp
1. $date  
   [$title]($(htmlext $article))
EOF
  done


  tmpl $layout | inject $tmp $layout > $target
}

action=$1
shift
$action "$@"
