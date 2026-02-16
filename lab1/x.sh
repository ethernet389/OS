#!/usr/bin/env bash

man --pager=cat bash \
	| grep -owE '[a-zA-Z]{4,}' \
	| awk '{ cnt[$1]++ } END { for (word in cnt) print cnt[word], word }' \
	| sort -n \
	| tail -n 3

