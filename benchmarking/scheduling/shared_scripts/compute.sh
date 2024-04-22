#!/bin/bash

# Get the start time in seconds
start_time=$(date +%s)

# Loop for approximately 60 seconds
while true; do
  # Get the current time in seconds
  current_time=$(date +%s)
  
  # Calculate the elapsed time
  elapsed=$((current_time - start_time))
  
  # Exit the loop if the elapsed time is 60 seconds or more
  if [ $elapsed -ge 60 ]; then
    echo "Completed 1 minute of computations."
    break
  fi
  
  # Compute and print the square of the elapsed time
  square=$((elapsed * elapsed))
  echo "Square of elapsed time ($elapsed seconds): $square"
  
  # Sleep for a short period to prevent overwhelming the CPU
  sleep 1
done

