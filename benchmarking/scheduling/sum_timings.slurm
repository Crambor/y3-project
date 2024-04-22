#!/bin/bash
#SBATCH --job-name=sum-timings
#SBATCH --output=/dev/null
#SBATCH --nodes=10         

srun --ntasks=$SLURM_NNODES --ntasks-per-node=1 shared_scripts/sum_timings.sh

