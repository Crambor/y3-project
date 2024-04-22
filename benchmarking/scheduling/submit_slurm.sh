#!/bin/bash


num_jobs=${1:-10}
job_duration=${2:-1}
scheduler=${3:-slurm}

top_dir=./timings/${scheduler}/${num_jobs}/${job_duration}
mkdir -p $top_dir

submit_jobs() {
    if [ "$scheduler" = "slurm" ]; then
		for i in $(seq 1 $num_jobs); do
			sbatch --job-name="job_$i" --output=/dev/null --wrap="bash shared_scripts/capture.sh $i $job_duration" > /dev/null
		done
	elif [ "$sched" = "hq" ]; then
		echo "hq placeholder"
    fi
}

wait_for_scheduler() {
    if [ "$scheduler" = "slurm" ]; then
        while [ -n "$(squeue -u $USER -h)" ]; do
            sleep 0.01
        done

	elif [ "$sched" = "hq" ]; then
		echo "hq placeholder"
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
elapsed_time=$(echo "$end_time - $start_time" | bc)

echo -e "Total elapsed time: $elapsed_time seconds.\n"
echo "$elapsed_time" > $top_dir/elapsed_time

sbatch ./sum_timings.slurm > /dev/null
wait_for_scheduler

mv ./timings/cn* $top_dir/
