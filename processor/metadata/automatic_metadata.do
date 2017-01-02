#!/bin/sh

if [ ! -f "$1" ]; then
  uuidgen
  date -u "+%s"
fi
