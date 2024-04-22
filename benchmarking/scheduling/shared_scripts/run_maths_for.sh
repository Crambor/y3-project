#!/bin/bash


# default to 1s
DURATION=${1:-1}

# date with nanosecond precision
START_TIME=$(date +%s.%N)

# cpu intensive random maths
while true; do
    echo $(( RANDOM % 200 ))                     > /dev/null
    echo $(( RANDOM % 200 * RANDOM % 200 ))      > /dev/null
    echo $(( RANDOM % 200 / (RANDOM % 5 + 1) ))  > /dev/null
    echo $(( RANDOM % 200 - RANDOM % 100 ))      > /dev/null

    CURRENT_TIME=$(date +%s.%N)
    if (( $(echo "$CURRENT_TIME - $START_TIME >= $DURATION" | bc) )); then
        break
    fi
done

