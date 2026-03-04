#!/usr/bin/env bash

# Process killed because of high MEM usage

# Not good at all
top_troubleshooting_amd64 &
top -p $!
