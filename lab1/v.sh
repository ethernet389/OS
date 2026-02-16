#!/usr/bin/env bash

fname="info.log"

cat /var/log/anaconda/syslog 2>/dev/null > "$fname" || \
	awk '{if ($2 == "INFO") print }' /var/log/installer/syslog 2>/dev/null 1>"$fname" || \
	rm "$fname"
