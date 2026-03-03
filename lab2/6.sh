#!/usr/bin/env bash

ps -eo pid,size --sort=size \
	| awk '
		BEGIN { acc = 0 } 
		{ acc += $2; print } 
		END { printf "SUMMARY SIZE\n%d\n", acc }
	'
