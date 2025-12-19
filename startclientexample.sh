#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"
LOG="$DIR/startclientexample-$(date +%Y%m%d-%H%M%S).log"

bash "$DIR/startclientexample.real.sh" "$@" 2>&1 | tee "$LOG"
