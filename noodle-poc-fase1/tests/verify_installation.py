#!/usr/bin/env python3
"""
📦 Package Installation Test

Run this script to verify that the NoodleCore POC package is correctly installed.

Usage:
    python tests/verify_installation.py

Expected output:
    ✅ All dependencies installed
    ✅ Core modules can be imported
    ✅ Configuration file found
    ✅ Example scripts ready
    ✅ Ready to profile GPT-2!
"""

import sys
from pathlib import Path


def test_imports():
    """Test that all core modules can be imported."""
    print("🔍 Testing module imports...")

    try:
        import torch
        print(f"  ✅ PyTorch {torch.__version__}")
    except ImportError as e:
        print(f"  ❌ PyTorch: {e}")
        return False

    try:
        import transformers
        print(f"  ✅ Transformers {transformers.__version__}")
    except ImportError as e:
        print(f"  ❌ Transformers: {e}")
        return False

    try:
        import pandas
        print(f"  ✅ Pandas {pandas.__version__}")
    except ImportError as e:
        print(f"  ❌ Pandas: {e}")
        return False

    try:
        import plotly
        print(f"  ✅ Plotly {plotly.__version__}")
    except ImportError as e:
        print(f"  ❌ Plotly: {e}")
        return False

    # Test project modules
    try:
        from src.metrics import MetricsCollector, LayerMetrics
        print("  ✅ Core metrics module")
    except ImportError as e:
        print(f"  ❌ Metrics module: {e}")
        return False

    try:
        from src.hooks import ModelInstrumentor
        print("  ✅ Hooks module")
    except ImportError as e:
        print(f"  ❌ Hooks module: {e}")
        return False

    try:
        from src.observability_engine import ObservabilityEngine
        print("  ✅ Observability engine")
    except ImportError as e:
        print(f"  ❌ Observability engine: {e}")
        return False

    print("✅ All module imports successful!\n")
    return True


def test_config_exists():
    """Test that configuration files exist."""
    print("🔍 Checking configuration files...")

    config_dir = Path("config")
    if not config_dir.exists():
        print(f"  ❌ Config directory not found: {config_dir}")
        return False

    gpt2_config = config_dir / "gpt2_config.yaml"
    if not gpt2_config.exists():
        print(f"  ❌ GPT-2 config not found: {gpt2_config}")
        return False

    print("  ✅ Configuration files found")
    print("✅ Configuration files OK!\n")
    return True


def test_example_scripts():
    """Test that example scripts exist."""
    print("🔍 Checking example scripts...")

    examples_dir = Path("examples")
    if not examples_dir.exists():
        print(f"  ❌ Examples directory not found: {examples_dir}")
        return False

    profile_script = examples_dir / "profile_gpt2.py"
    if not profile_script.exists():
        print(f"  ❌ Profile script not found: {profile_script}")
        return False

    print("  ✅ Example scripts found")
    print("✅ Example scripts OK!\n")
    return True


def test_data_directories():
    """Test that data directories exist or can be created."""
    print("🔍 Checking data directories...")

    data_dir = Path("data")
    if not data_dir.exists():
        print("  ⚠️  Data directory not found, creating...")
        data_dir.mkdir(parents=True, exist_ok=True)
        (data_dir / "metrics").mkdir(exist_ok=True)
        (data_dir / "logs").mkdir(exist_ok=True)
        print("  ✅ Data directories created")

    print("✅ Data directories OK!\n")
    return True


def test_cuda_availability():
    """Test CUDA availability."""
    print("🔍 Checking CUDA availability...")

    import torch

    if torch.cuda.is_available():
        print(f"  ✅ CUDA is available ({torch.cuda.device_count()} GPU(s))")
        for i in range(torch.cuda.device_count()):
            props = torch.cuda.get_device_properties(i)
            print(f"    - GPU {i}: {props.name} ({props.total_memory / 1024**3:.1f} GB)")
    else:
        print("  ⚠️  CUDA not available (will use CPU)")

    print("✅ CUDA check complete!\n")
    return True


def main():
    """Run all installation tests."""
    print("="*60)
    print("🔧 NoodleCore - Installation Verification")
    print("="*60 + "\n")

    all_passed = True

    all_passed &= test_imports()
    all_passed &= test_config_exists()
    all_passed &= test_example_scripts()
    all_passed &= test_data_directories()
    all_passed &= test_cuda_availability()

    print("="*60)
    if all_passed:
        print("✅ ALL TESTS PASSED!")
        print("🎉 Installation successful - ready to profile models!")
        print("\nNext steps:")
        print("  1. python examples/profile_gpt2.py --model gpt2 --num-samples 10")
        print("  2. Open data/metrics/gpt2_dashboard.html to view results")
    else:
        print("❌ SOME TESTS FAILED")
        print("⚠️  Please check error messages above")
        sys.exit(1)

    print("="*60)


if __name__ == '__main__':
    main()
