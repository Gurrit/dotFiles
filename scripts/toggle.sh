#!/bin/bash
# Toggle a program, either start if not running or kill if running, 
# should probably only be used in scripts. Currently doesn't support passing arguments...

COMMAND=$1

toggle() {
	if pgrep $1 > /dev/null 
	then 
		pkill $COMMAND
	else 
		setsid $COMMAND & > /dev/null
	fi
}

toggle "$@"
