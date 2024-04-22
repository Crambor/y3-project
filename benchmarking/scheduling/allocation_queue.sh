#! /bin/bash


./hq alloc add slurm --time-limit 180m \
                   --idle-timeout 3m \
                   --backlog 10 \
                   --workers-per-alloc 1 \
                   --max-worker-count 10 \
                   --cpus=1
