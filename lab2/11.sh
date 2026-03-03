#!/usr/bin/env bash

echo "RSS PID"

cat /proc/*/stat 2>/dev/null \
	| awk '{ print $24 " " $1 }' \
	| sort -n \
	| tail -n 1
