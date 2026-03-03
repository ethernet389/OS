#!/usr/bin/env bash

ps -eo pid= --sort=+etimes | head -n 1
