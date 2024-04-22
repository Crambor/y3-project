import numpy as np
import time

def test_operation(operation, dimension):
    """Function to time how long a given operation takes with a specified matrix size."""
    A = np.random.rand(dimension, dimension)
    B = np.random.rand(dimension, dimension)

    start_time = time.perf_counter()
    operation(A, B)
    elapsed_time = time.perf_counter() - start_time
    return elapsed_time

def main():
    # List of operations to test
    operations = [
#        np.dot,  # Matrix multiplication
#        lambda A, B: np.linalg.matrix_power(A, 3),  # Matrix raised to the power of 3
        lambda A, B: np.linalg.eig(A)  # Eigenvalues calculation
    ]

    cumulative_time = 0
    dimension = 100
    operation_details = []

    # Loop until the sum of operations' times is close to 1 second
    while cumulative_time < 1.05:
        for op in operations:
            elapsed_time = test_operation(op, dimension)
            cumulative_time += elapsed_time
            operation_details.append((op.__name__, dimension, elapsed_time))
            print(f"Operation {op.__name__} with dimension {dimension}x{dimension} took {elapsed_time:.3f} seconds. Cumulative time: {cumulative_time:.3f}")

        dimension += 50  # Increase dimension to increase computation time
        
        if cumulative_time > 1.00:
            break

        cumulative_time = 0

    print("Final operation details to reach around 1 second:")
    for detail in operation_details:
        print(f"Operation {detail[0]} with dimension {detail[1]}x{detail[1]} took {detail[2]:.3f} seconds.")

    return operation_details

if __name__ == "__main__":
    main()

