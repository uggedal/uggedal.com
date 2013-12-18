#!/bin/sh

URI=https://api.github.com/markdown/raw
MD_CT='Content-Type: text/x-markdown'

AUTH=

[ -z "$GITHUB_TOKEN" ] || AUTH="-u $GITHUB_TOKEN:x-oauth-basic"

exec curl -sf $AUTH --data-binary @- $URI -H "$MD_CT"
