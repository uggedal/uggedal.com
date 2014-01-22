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

layout=page.tmpl

site_title='Eivind Uggedal'
title=$(header $1 1)
date=$(header $1 2)
export site_title title date


tmp=$(mktemp)
trap "rm $tmp" EXIT TERM INT

sed '1,2d' $1 | markdown > $tmp

tmpl $layout | inject $tmp $layout > ${1%*.md}.html
