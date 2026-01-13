# Fix path issues in Windows
import sys
import os

# Add project root and src to path
project_root = os.path.dirname(os.path.abspath(__file__))
src_path = os.path.join(project_root, 'src')
sys.path.insert(0, project_root)
sys.path.insert(0, src_path)

# Now import
from src.observability_engine import ObservabilityEngine
from src.metrics import MetricsCollector
import src.logger

print('[IMPORTS] All modules imported successfully!')

# Simple test
collector = MetricsCollector()
print('[TEST] MetricsCollector created')

# Test basic functionality
layer_metrics = collector.start_layer_monitoring("test_layer", "Linear", 0)
collector.stop_layer_monitoring(layer_metrics, 5.5)
print(f'[TEST] Recorded latency: {layer_metrics.forward_latency_ms} ms')

print('\n[SUCCESS] Basic functionality verified!')
print('\nReady to profile GPT-2. Run:')
print('  python examples/profile_gpt2.py --model gpt2 --num-samples 3 --device cpu')
