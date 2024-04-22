#! /bin/bash


./hq worker start &
#./hq alloc add slurm --time-limit 90m \
#                   --idle-timeout 3m \
#                   --backlog 5 \
#                   --workers-per-alloc 1 \
#                   --max-worker-count 10 \
#                   --cpus=1
