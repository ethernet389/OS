#!/usr/bin/env bash

acc=''

while read line; do
	if [[ $line = q ]]; then
		echo "$acc"
		exit 0
	fi

	acc+="$line"
done

