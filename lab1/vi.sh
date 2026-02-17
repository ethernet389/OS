#!/usr/bin/env bash

first_fpath="/var/log/anaconda/X.log"
second_fpath="/var/log/anaconda/X.0.log"

if [ -f "$first_fpath" ]; then
	log_fpath="$first_fpath"
elif [ -f "$second_fpath" ]; then
	log_fpath="$second_fpath"
else
	echo "Files doesn't exist."
	exit 1
fi

echo "$log_fpath"
grep '(WW)' "$log_fpath" | sed 's/(WW)/Warning:/' > full.log
grep '(II)' "$log_fpath" | sed 's/(II)/Information:/' >> full.log

cat full.log
