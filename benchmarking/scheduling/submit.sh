#!/bin/bash


num_jobs=${1:-10}
job_duration=${2:-1}
scheduler=${3:-slurm}

echo "scheduler is $scheduler"
top_dir=./timings/${scheduler}/${num_jobs}/${job_duration}
mkdir -p $top_dir


submit_jobs() {
    if [ "$scheduler" = "slurm" ]; then
		sbatch --job-name="job_$num_jobs" --output=/dev/null --array=1-$num_jobs --wrap="bash shared_scripts/capture.sh $job_duration" > /dev/null
    elif [ "$scheduler" = "hq" ]; then
		./hq job submit --stdout=none --stderr=none --array 1-$num_jobs --env JOB_DURATION=$job_duration ./shared_scripts/capture.sh > /dev/null
    fi
}

wait_for_scheduler() {
    if [ "$scheduler" = "slurm" ]; then
        while [ -n "$(squeue -u $USER -h)" ]; do
            sleep 0.01
        done

    elif [ "$scheduler" = "hq" ]; then
	while true; do
        	job_count=$(./hq job list --filter running,waiting | wc -l)
		if [ "$job_count" -le 4 ]; then
			break
		fi
		sleep 0.01
	done
    fi
}

start_time=$(date +%s.%N)
echo "Running $num_jobs jobs - task duration ${job_duration}s"

submit_jobs
mid_time=$(date +%s.%N)
mid_elapsed=$(echo "$mid_time - $start_time" | bc)
echo "Submitted $num_jobs jobs in $mid_elapsed seconds."
wait_for_scheduler
end_time=$(date +%s.%N)
elapsed_time=$(echo "$end_time - $mid_time" | bc)

echo -e "Total elapsed time: $elapsed_time seconds.\n"
echo "$elapsed_time" > $top_dir/elapsed_time

[[ "$scheduler" = "slurm" ]] && sbatch ./sum_timings.slurm > /dev/null
[[ "$scheduler" = "hq" ]] && ./hq job submit --stdout=none --stderr=none --array 1-10 ./shared_scripts/sum_timings.sh > /dev/null
wait_for_scheduler

mv ./timings/cn* $top_dir/

