# Y3-Project


Most of the code used or written during my Y3 final project. Majority of my testing was performed on 2x Dell Optiplex 3080 nodes, consisting of near-identical hardware. Both had i5-10500T CPUs (6 cores @ 2.3GHz) and were connected together into a dedicated gigabit switch whose only other connection was to my router directly, to avoid any network congestion.

## Terraform
The terraform directory is an attempt at automating various test environments so I can easily experiment across a variety of systems - e.g. different schedulers, whilst maintaining the same underlying machine configurations for the most accurate results comparison.

This does not include any kubernetes infrastructure - that was done manually with the Talos Linux ISO, which greatly speeds up the deployment of kubernetes. This project can be seen here: https://github.com/siderolabs/talos
I created two kubernetes worker nodes as VMs 

## Ansible
This directory is another form of automation, tidbits of which were taken from projects I have worked on in the past. Please note that this will not include all server configurations, since many manual changes were made for the sake of time.

## Benchmarking
This is the primary directory of all benchmarking done for this project. Further details inside this directory.

