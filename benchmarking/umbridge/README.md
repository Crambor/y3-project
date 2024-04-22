README.md

# benchmarking - umbridge

Installing the load balancer requires golang on your system. The compiling is as simple as running `go build ./load-balancer.go` which will generate a binary.

`hq` and `caddy` binaries are also necessary for this execution, and no error checking has been implemented yet to check for these. Please run the helper bash scripts `./get_hq.sh` and `./get_caddy.sh` to download these.


The load balancer can be interacted with by running `./load-balancer -s [path_to_server] -n [num_replicas]`
	path_to_server is a filepath to a UM-Bridge model server you wish to spawn. Please look at `./run-server.sh` and `./server.py` for further details.
	num_replicas is the number of hyperqueue tasks to spawn.


KNOWN IMPLEMENTATION ISSUES:
- there is no hyperqueue task reallocation yet for the workers. once they die, they die and do not re-spawn. this is why their time limit is high
- there is no error handling inside of the load-balancer code yet

