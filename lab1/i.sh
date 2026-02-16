#!/usr/bin/env bash

mx=$1

a=$2
b=$3

if [[ $a -gt $mx ]]; then
	mx=$a
fi

if [[ $b -gt $mx ]]; then
	mx=$b
fi

echo $mx
