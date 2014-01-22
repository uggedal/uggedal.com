#!/bin/sh

page_template=page.tmpl

header() {
  sed $2'q;d' $1 | sed 's/^% //'
}

site_title='Eivind Uggedal'
title=$(header $1 1)
date=$(header $1 3)
export site_title title date


tmp=$(mktemp)
trap "rm $tmp" EXIT TERM INT

markdown $1 > $tmp

body_line=$(sed -n '/@@BODY@@/=' $page_template)

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
' $page_template | sed "${body_line}r $tmp" | sed "${body_line}d" > ${1%*.md}.html
