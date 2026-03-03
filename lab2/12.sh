#!/usr/bin/env bash

lim=$1
new_nice=$2

for pid in `ps -eo pid=,etimes= | awk -v lim=$lim '$2 > lim { print $1 }'`; do
	renice $new_nice -p $pid	
done
