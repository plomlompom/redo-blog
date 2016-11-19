#!/bin/sh

if [ ! -f "$1" ]; then
  uuidgen > "$1"
fi
