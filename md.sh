#!/bin/sh

URI=https://api.github.com/markdown/raw
MD_CT='Content-Type: text/x-markdown'

exec curl -sf --data-binary @- $URI -H "$MD_CT"
