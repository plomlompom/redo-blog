#!/bin/sh

if [ ! -f "$1" ]; then
  uuidgen
  date -u "+%s_%N"
  echo 00000000000000000000000000000000
  echo 0
fi
