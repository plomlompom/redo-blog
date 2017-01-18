#!/bin/sh

if [ ! -f "$1" ]; then
  printf "\n%s" "<li><a href=\"%URL%\">%URL%</a></li>"
fi
