#!/usr/bin/env bash

get_young_pids() {
	ps -eo pid=,etimes= \
		| awk -v n=$1 -v own_pid=$$ \
		'{ if ($2 < n && $1 != own_pid) print $1 }'
}


for young_pid in $(get_young_pids $1); do
	kill -s KILL $young_pid && echo $young_pid >> killed.log
done

echo "Henocide is done :)"
