#!/usr/bin/env bash

process_file=$1

cat $process_file \
	| awk -F '[[:blank:]=]' '
		{ 
			++ppid_child_count[$5] 
			ppid_art_sum[$5] += $8
			ppid_lines[$5] = ppid_lines[$5] $0 "\n"
		} 
		END { 
			for (ppid in ppid_child_count) 
				printf "%s\tAverage_Running_Children_of_ParentID=%s is %s\n\n",
				ppid_lines[ppid], 
				ppid, 
				ppid_art_sum[ppid] / ppid_child_count[ppid] 
		}
	' > $process_file
