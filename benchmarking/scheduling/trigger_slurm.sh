#!/bin/bash

num_jobs_list=(2000 4000)
job_duration_list=(0.1 0.2 0.5 1 2 5)

for num_jobs in "${num_jobs_list[@]}"; do
    for job_duration in "${job_duration_list[@]}"; do
        echo "Submitting job: num_jobs=$num_jobs, job_duration=${job_duration}s"
        ./submit.sh "$num_jobs" "$job_duration" "slurm"
        echo "Job submitted."
    done
done

