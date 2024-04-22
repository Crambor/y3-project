#!/bin/bash

# Default number of replicas
replicas=${1:-10}

while [[ $replicas -ge 1 ]]
do
    # Update the number of replicas in the Kubernetes manifest and apply it
    sed -i "s/replicas: [0-9]*/replicas: $replicas/" model.yaml
    kubectl apply -f model.yaml

    # Output the current number of replicas
    echo "Applied configuration with $replicas replicas"

    # Change directory and execute the Python script
    cd client
    python3 ./parallel_output.py http://10.10.10.129:31379

    # Decrement the number of replicas
    ((replicas--))

    # Go back to the previous directory to be ready for the next loop iteration
    cd ..
done

