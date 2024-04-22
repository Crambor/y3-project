#! /bin/bash

#HQ --cpus=1
#HQ --time-request=10m
#HQ --time-limit=60m
#HQ --stdout none
#HQ --stderr none

# Launch model server, send back server URL
# and wait to ensure that HQ won't schedule any more jobs to this allocation.

function get_available_port {
    # Define the range of ports to select from
    MIN_PORT=1024
    MAX_PORT=65535

    # Generate a random port number
    port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)

    # Check if the port is in use
    while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; do
        # If the port is in use, generate a new random port number
        port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)
    done

    echo $port
}

port=$(get_available_port)
export PORT=$port

# Assume that server sets the port according to the environment variable 'PORT'.
/mnt/home/crambor/y3-project/benchmarking/umbridge/run-server.sh &

host=$(hostname -I | awk '{print $1}')

echo "Waiting for model server to respond at $host:$port..."
while ! curl -s "http://$host:$port/Info" > /dev/null; do
    sleep 1
done
echo "Model server responded"

IP=$(hostname -I | cut -d' ' -f1)
curl -X POST http://10.10.10.12:8080/register -d "ip=$IP&port=$PORT"

sleep infinity # keep the job occupied
