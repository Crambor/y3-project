#!/bin/bash

while :
do
  # Submit a job and wait for it to complete
  ./hq submit --wait hq_scripts/compute.sh

  # Read the output of the job
  output=$(./hq job cat last stdout)

  # Decide if we should end or continue
  if [ "${output}" -eq 0 ]; then
      break
  fi
done

