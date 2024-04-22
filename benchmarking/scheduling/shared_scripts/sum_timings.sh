#!/bin/bash

input_dir="/dev/shm/temp/"
output_dir="./timings/"
mkdir -p "$output_dir"

if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory does not exist."
    exit 1
fi

total_time=0
for file in "$input_dir"*; do
    if [[ -s "$file" ]]; then
        real_time=$(grep 'real' "$file" | awk '{print $2}' | sed 's/m/*60+/; s/s//')
        if [[ -n "$real_time" ]]; then
            total_seconds=$(echo "$real_time" | bc -l)
            total_time=$(echo "$total_time + $total_seconds" | bc -l)
        else
            echo "No real time found in $file"
        fi
    else
        echo "Skipping $file: empty or invalid data"
    fi
done

rm -r /dev/shm/temp/
echo "$total_time" > "${output_dir}$(hostname)"

