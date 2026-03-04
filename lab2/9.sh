#!/usr/bin/env bash

tmp_file='.tmp_file'

for proc_fpath in /proc/*; do
	if ! [[ $proc_fpath =~ /proc/[0-9]+ ]]; then
		continue
	fi

	proc_stat=(`cat $proc_fpath/stat`)	
	
	proc_pid="${proc_stat[0]}"
	proc_ppid="${proc_stat[3]}"

	proc_art=$(cat $proc_fpath/sched \
		| grep -E '(nr_switches)|(se.sum_exec_runtime)' \
		| awk -F ':' '
			NR == 1 { nr_switches = $2 }
			NR == 2 { sum_exec_runtime = $2 }
			END { print nr_switches / sum_exec_runtime }
		')

	printf "%s %s %s\n" $proc_ppid $proc_pid $proc_art >> $tmp_file
done

sort -n $tmp_file \
	| awk '{ printf "ProcessID=%s : ParentProcessID=%s : Average_Running_Time=%s\n", $2, $1, $2 }' \
	| tee process_info.log
