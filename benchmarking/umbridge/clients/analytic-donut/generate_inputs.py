#!/usr/bin/env python3
import argparse
import json
import numpy as np
import umbridge
import pytest

def generate_inputs(num_inputs, dimensions, seed=42):
    np.random.seed(seed)  # Set seed for reproducibility
    return np.random.uniform(-10, 10, size=(num_inputs, dimensions))

def perform_test(model, inputs):
    results = []
    for input_vec in inputs:
        output = model([input_vec.tolist()])[0]
        #print(output)
        # Store each input and output in a structured dictionary format
        result = {
            "input_x": input_vec[0],
            "input_y": input_vec[1],
            "output": output[0]
        }
        results.append(result)
    return results

def save_results(results, filename):
    with open(filename, 'w') as f:
        json.dump(results, f, indent=4)

parser = argparse.ArgumentParser(description='Model output test.')
parser.add_argument('url', metavar='url', type=str,
                    help='the URL on which the model is running, for example http://localhost:4242')
args = parser.parse_args()

print(f"Connecting to host URL {args.url}")
model = umbridge.HTTPModel(args.url, "posterior")

# Generate deterministic pseudo-random inputs
inputs = generate_inputs(100, 2)  # Generate 100 2D inputs

# Perform tests and get results
results = perform_test(model, inputs)

# Save results to JSON
save_results(results, 'model_output_results.json')

