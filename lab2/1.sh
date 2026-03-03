#!/usr/bin/env bash

ps aux | awk '
NR>1 {
	if ($8 ~ /[RSDZT]/) {
		print $2
	}
}
'
