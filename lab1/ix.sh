#!/usr/bin/env bash

counts=0
for fpath in /var/log/*.log; do
	cur_cnt=(`wc -l "$fpath" 2>/dev/null`)
	((counts += ${cur_cnt:-0}))
done

echo $counts

