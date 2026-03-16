#!/usr/bin/env bash


# Current configuraiton
config_file=
iteration_delay=1


# Statistic information
handled_traps_count=0


# Actions on signals
act_on_SIGHUP() {

	((++handled_traps_count))
}

act_on_SIGUSR1() {

	((++handled_traps_count))
}

act_on_SIGUSR2() {

	((++handled_traps_count))
}

act_on_SIGTERM() {

	((++handled_traps_count))
}


# Register traps
trap act_on_SIGHUP HUP
trap act_on_SIGUSR1 USR1
trap act_on_SIGUSR2 USR2
trap act_on_SIGTERM TERM


# Main program
make_one_step() {

}


# Infinite loop
while true; do
	$(make_one_step)	
	sleep $iteration_delay
done
