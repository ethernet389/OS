#!/usr/bin/env bash

# Configuration
config_file=/etc/fifo-spamer.config
spam_msg=SPAM
spam_dest=/dev/null
spam_delay=1

load_cfg() {
	source "$config_file"
}

load_cfg


# Set signal traps
act_on_SIGHUP() {
	load_cfg
	echo "Update config"
}

trap act_on_SIGHUP HUP


# Main program
make_one_step() {
	echo "$spam_msg" >> "$spam_dest"
}


# Infinite loop
while true; do
	make_one_step
	sleep $spam_delay
done
