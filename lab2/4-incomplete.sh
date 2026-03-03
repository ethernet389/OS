#!/usr/bin/env bash


# Create background process
sleep 10000 &
echo "Process started: $!"

# Go to process folder
cd /proc/$!
echo "Directory changed: $PWD"

# Wait for calls
echo -n "Wait for calls"
for ((i=0; i<3;++i)); do
	echo -n "."
	sleep 1
done
echo

# Read last 5 calls
echo -n "Reading last 5 stack trace calls:"
cat stack | tail -n 5
