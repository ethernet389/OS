#!/usr/bin/env bash

ps -eo pid=PID,etime=ELAPSED --sort=-etimes | head -n 2
