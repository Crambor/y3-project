#!/bin/bash

# this script captures the time taken for a simple maths script
# outputting directly to memory to be processed later

INPUT_NUMBER=$2

if [[ -z "$JOB_DURATION" ]]; then
	JOB_DURATION=${1:-1}
fi

if [[ -z "$INPUT_NUMBER" ]]; then
	INPUT_NUMBER=$HQ_TASK_ID
fi

if [[ -z "$INPUT_NUMBER" ]]; then
	INPUT_NUMBER=$SLURM_ARRAY_TASK_ID
fi

if [[ -z "$INPUT_NUMBER" ]]; then
    echo "Usage: $0 <job_id> <job_duration>"
    exit 1
fi

OUTPUT_FILE="/dev/shm/temp/${INPUT_NUMBER}"
mkdir -p "$(dirname "$OUTPUT_FILE")"


{ time shared_scripts/run_maths_for.sh $JOB_DURATION ; } 2> $OUTPUT_FILE 
