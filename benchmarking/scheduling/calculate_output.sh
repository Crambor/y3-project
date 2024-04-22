#!/bin/bash

scheduler=${1:-slurm}
cd timings/$scheduler

for num_jobs_dir in */; do
    echo -e "\n"
    for job_duration_dir in "$num_jobs_dir"*/; do
        cd "$job_duration_dir" || continue

        sum=0
        count=0

        for cn_file in cn*; do
            if [ -f "$cn_file" ]; then
                value=$(cat "$cn_file")
                sum=$(echo "$sum + $value" | bc)
                ((count++))
            fi
        done

        if [ "$count" -ne 0 ]; then
            average=$(echo "scale=3; $sum / $count" | bc)
        else
            average=0
        fi

	if [ ! -e ./elapsed_time ]; then
            cd - > /dev/null
	    break
	fi
        elapsed_time=$(cat elapsed_time)
        num_jobs_clean="${num_jobs_dir%/}" 
        job_duration_clean="${job_duration_dir%/}"  
        job_duration_clean="${job_duration_clean##*/}"  
	printf "%-12s %-18s %-25s %-20s\n" "num_jobs: $num_jobs_clean" "job_duration: ${job_duration_clean#*/}" "Average Time: $average" "Elapsed Time: $elapsed_time"

        cd - > /dev/null
    done
done

