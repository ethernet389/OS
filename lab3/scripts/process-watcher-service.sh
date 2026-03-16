#!/usr/bin/env bash

# Current configuraiton
config_file=/etc/process-watcher.config
log_file=/var/log/process-watcher.log
iteration_delay=1

load_cfg() {
	source "$config_file"
}

load_cfg


# Statistic information
handled_traps_count=0


# Actions on signals
# Reload configuration
act_on_SIGHUP() {
	load_cfg
	((++handled_traps_count))
}

# Output status snapshot in journal
act_on_SIGUSR1() {

	((++handled_traps_count))
}

# Rotate logs or change mode
act_on_SIGUSR2() {

	((++handled_traps_count))
}

# Graceful shutdown
act_on_SIGTERM() {
	echo "IT WORKED!!!" >> /home/user/labworks/lab3/test_log
	exit
	((++handled_traps_count))
}


# Register traps
trap act_on_SIGHUP HUP
trap act_on_SIGUSR1 USR1
trap act_on_SIGUSR2 USR2
trap act_on_SIGTERM TERM


# Main program
make_one_step() {
	echo
}


# Infinite loop
while true; do
	make_one_step
	sleep $iteration_delay
done
