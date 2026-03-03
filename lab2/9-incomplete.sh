#!/usr/bin/env bash

echo_proc_fmt() {
	echo "ProcessID=$1 : ParentProcessID=$2 : Average_Running_Time=$3"
}

for proc_stat_fpath in /proc/*/stat; do
	if ! [[ $proc_stat_fpath =~ /proc/[0-9]+/stat ]]; then
		continue
	fi

	proc_stat=(`cat $proc_stat_fpath`)	
	
	proc_pid="${proc_stat[0]}"
	proc_ppid="${proc_stat[3]}"

	echo_proc_fmt $proc_pid $proc_ppid NaN
done
