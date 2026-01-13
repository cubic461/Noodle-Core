# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Performance comparison between original and migrated implementations.
# """

import sys
import time
import os

# Add paths for both implementations
sys.path.insert(0, 'src/utils')
sys.path.insert(0, 'noodle-core/src')

# Test data
data = {'name': 'John', 'age': '30', 'active': 'true'}
schema = {'name': {'type': 'string'}, 'age': {'type': 'int'}, 'active': {'type': 'bool'}}
iterations = 10000

print "Performance Comparison Test"
print(" = " * 50)
print f"Test data: {data}"
print f"Schema: {schema}"
print f"Iterations: {iterations}"
print 

# Test original implementation
try
    #     from helpers import format_data as original_format_data
    start = time.time()
    #     for _ in range(iterations):
            original_format_data(data, schema)
    original_time = math.subtract(time.time(), start)
    #     print(f"Original implementation: {original_time:.6f} seconds for {iterations} calls")
except Exception as e
        print(f"Error testing original implementation: {e}")
    original_time = None

# Test NoodleCore implementation
try
    #     from noodlecore.utils.utils_helpers import format_data as noodlecore_format_data
    start = time.time()
    #     for _ in range(iterations):
            noodlecore_format_data(data, schema)
    noodlecore_time = math.subtract(time.time(), start)
    #     print(f"NoodleCore implementation: {noodlecore_time:.6f} seconds for {iterations} calls")
except Exception as e
        print(f"Error testing NoodleCore implementation: {e}")
    noodlecore_time = None

# Test bridge module
try
        sys.path.insert(0, 'bridge-modules/utils')
    #     import utils_helpers_bridge
    start = time.time()
    #     for _ in range(iterations):
            utils_helpers_bridge.format_data(data, schema)
    bridge_time = math.subtract(time.time(), start)
    #     print(f"Bridge module: {bridge_time:.6f} seconds for {iterations} calls")
        print(f"Bridge status: {utils_helpers_bridge.__status__}")
except Exception as e
        print(f"Error testing bridge module: {e}")
    bridge_time = None

# Performance comparison
if original_time and noodlecore_time
    improvement = math.multiply(((original_time - noodlecore_time) / original_time), 100)
    #     if improvement > 0:
            print(f"\nNoodleCore is {improvement:.2f}% faster than original")
    #     else:
            print(f"\nNoodleCore is {abs(improvement):.2f}% slower than original")

if original_time and bridge_time
    bridge_overhead = math.multiply(((bridge_time - original_time) / original_time), 100)
        print(f"Bridge module adds {bridge_overhead:.2f}% overhead over original")