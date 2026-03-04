#!/usr/bin/env bash

# troubleshooting located in /home/user/bin
# 7.2 Problem: troubleshooting were trying to open non existing file: ~/requiredDir/requiredFile
# 7.3 Program handle properly SIGUSR1, SIGUSR2 ignored


if [[ $1 = 2 ]]; then
	strace -e trace=network troubleshooting_amd64 &> troubleshooting_network.log
	strace -e trace=file troubleshooting_amd64 &> troubleshooting_file.log
elif [[ $1 = 3 ]]; then
	strace -e trace=none -e signal=SIGUSR1,SIGUSR2 troubleshooting_amd64
	
	# This should be ran in other terminal
	# kill -SIGUSR1 $(pgrep troubleshooting)
fi

