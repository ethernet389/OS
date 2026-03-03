#!/usr/bin/env bash


# Create background process
sleep 10000 &
echo "START PROCESS: $!"

# Go to process folder
cd /proc/$!
echo "CHANGE DIR: $PWD"
echo

# Wait for calls
echo -n "WAIT FOR CALLS"
for ((i=0; i<3;++i)); do
	echo -n "."
	sleep 1
done
echo

# Read last 5 calls
echo "LAST 5 STACK CALLS:"
echo "============================="

cat stack | tail -n 5

echo "============================="
echo

# Read process info
echo "PROCESS INFO:"
grep -wE "(Name)|(Kthread)|(PPid)|(Tgid)|(Pid)" status

