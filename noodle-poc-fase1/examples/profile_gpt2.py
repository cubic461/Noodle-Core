#!/usr/bin/env python3
"""
GPT-2 Profiling Example

This script demonstrates how to use the NoodleCore Observability Engine
to profile a GPT-2 model and generate detailed metrics and visualizations.

Usage:
    python profile_gpt2.py --model gpt2 --num-samples 100
    python profile_gpt2.py --model gpt2-medium --num-samples 50 --device cpu
"""

import argparse
import sys
import time
from pathlib import Path
import yaml

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.observability_engine import ObservabilityEngine
from src.logger import StructuredLogger


def load_model(model_name: str, device: str):
    """Load model and tokenizer."""
    print(f"🔄 Loading model: {model_name}")
    
    # Load tokenizer
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    # Load model
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.float32,  # Use FP32 for compatibility
        low_cpu_mem_usage=True,
    )
    
    # Move to device
    device = torch.device(device)
    model = model.to(device)
    model.eval()
    
    print(f"✅ Model loaded successfully ({device})")
    print(f"   Parameters: {sum(p.numel() for p in model.parameters()):,}")
    
    return model, tokenizer


def create_sample_inputs(tokenizer, sequence_length: int = 128):
    """Create sample inputs for profiling."""
    # Use a typical prompt for LLM profiling
    prompt = (
        "In a shocking finding, scientists discovered a herd of unicorns living in "
        "a remote, previously unexplored valley in the Andes Mountains. Even more "
        "surprising to the researchers was the fact that the unicorns spoke perfect "
        "English."
    )
    
    # Tokenize
    inputs = tokenizer(
        prompt,
        return_tensors="pt",
        max_length=sequence_length,
        padding="max_length",
        truncation=True
    )
    
    print(f"📝 Sample input created: {inputs['input_ids'].shape}")
    
    return inputs


def main(args):
    """Main profiling workflow."""
    
    # Load configuration
    config_path = Path(args.config)
    if config_path.exists():
        print(f"📋 Loading config from: {config_path}")
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
    else:
        print(f"⚠️  Config not found: {config_path}, using defaults")
        config = {}
    
    # Override config with CLI args
    if args.model:
        config['model_name'] = args.model
    if args.num_samples:
        config['num_profile_runs'] = args.num_samples
    if args.device:
        config['device'] = args.device
    
    model_name = config.get('model_name', 'gpt2')
    device = config.get('device', 'cuda:0' if torch.cuda.is_available() else 'cpu')
    num_warmup = config.get('num_warmup_runs', 10)
    num_profile = config.get('num_profile_runs', 100)
    
    print("=" * 70)
    print("🚀 NoodleCore Observability Engine - GPT-2 Profiling")
    print("=" * 70)
    print(f"Model: {model_name}")
    print(f"Device: {device}")
    print(f"Warmup runs: {num_warmup}")
    print(f"Profile runs: {num_profile}")
    print(f"Output: {config.get('log_dir', 'data/metrics')}")
    print("=" * 70)
    
    # Create output directory
    output_dir = Path(config.get('log_dir', 'data/metrics'))
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Load model and tokenizer
    model, tokenizer = load_model(model_name, device)
    
    # Create sample inputs
    inputs = create_sample_inputs(
        tokenizer,
        sequence_length=config.get('sequence_length', 128)
    )
    
    # Move inputs to device
    inputs = {k: v.to(device) if isinstance(v, torch.Tensor) else v 
              for k, v in inputs.items()}
    
    # Initialize Observability Engine
    print("\n🔧 Initializing Observability Engine...")
    engine = ObservabilityEngine(
        model=model,
        log_dir=output_dir,
        config=config
    )
    
    # Profile the model
    try:
        print("\n" + "=" * 70)
        print("📊 PROFILING WORKFLOW")
        print("=" * 70)
        
        # Step 1: Instrument model
        print("\n[1/4] ⚙️  Instrumenting model with hooks...")
        engine.instrument()
        
        # Step 2: Warmup
        print(f"\n[2/4] 🔥 Running {num_warmup} warmup iterations...")
        engine.warmup(inputs, num_warmup_runs=num_warmup)
        
        # Step 3: Profile
        print(f"\n[3/4] 🔍 Profiling with {num_profile} iterations...")
        start_time = time.time()
        report = engine.profile(inputs, num_runs=num_profile)
        
        profile_duration = time.time() - start_time
        print(f"✅ Profiling complete in {profile_duration:.2f}s")
        
        # Display summary
        print("\n" + "=" * 70)
        print("📊 PROFILING SUMMARY")
        print("=" * 70)
        print(f"Model: {model_name}")
        print(f"Total layers profiled: {report.get('total_layers', 'N/A')}")
        print(f"Total profiling runs: {report.get('num_runs', 'N/A')}")
        
        if 'end_to_end_latency' in report:
            e2e = report['end_to_end_latency']
            print(f"End-to-end latency: {e2e['mean_ms']:.2f}ms (avg)")
        
        # Step 4: Generate Dashboard
        print(f"\n[4/4] 📊 Generating dashboard and visualizations...")
        dashboard_name = f"{model_name.replace('/', '_')}_profile"
        engine.save_dashboard(output_name=dashboard_name)
        
        print(f"✅ Dashboard saved: {output_dir / f'{dashboard_name}_dashboard.html'}")
        
        # Export summary report as JSON
        import json
        summary_path = output_dir / f"{dashboard_name}_summary.json"
        with open(summary_path, 'w') as f:
            json.dump(report, f, indent=2)
        print(f"✅ Summary saved: {summary_path}")
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Profiling interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Error during profiling: {e}")
        import traceback
        traceback.print_exc()
        return 1
    finally:
        # Cleanup
        print("\n🧹 Cleaning up...")
        engine.finalize()
        print("✅ Cleanup complete")
    
    print("\n" + "=" * 70)
    print("🎉 PROFILING COMPLETE!")
    print("=" * 70)
    print(f"\nNext steps:")
    print(f"1. Open dashboard: {output_dir / f'{dashboard_name}_dashboard.html'}")
    print(f"2. Review metrics: {output_dir / f'{dashboard_name}_metrics.jsonl'}")
    print(f"3. Check summary: {output_dir / f'{dashboard_name}_summary.json'}")
    print(f"\n🚀 Ready for Fase 2: Execution Planning with collected metrics!")
    
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Profile GPT-2 with NoodleCore Observability Engine',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python profile_gpt2.py --model gpt2 --num-samples 100
  python profile_gpt2.py --model gpt2-medium --device cpu --num-samples 50
  python profile_gpt2.py --config custom_config.yaml
        """
    )
    
    parser.add_argument(
        '--model',
        type=str,
        default='gpt2',
        help='Model name to profile (default: gpt2)'
    )
    parser.add_argument(
        '--device',
        type=str,
        help='Device to run on (default: cuda:0 if available, else cpu)'
    )
    parser.add_argument(
        '--num-samples',
        type=int,
        help='Number of profiling samples (default: 100)'
    )
    parser.add_argument(
        '--config',
        type=str,
        default='config/gpt2_config.yaml',
        help='Path to configuration file (default: config/gpt2_config.yaml)'
    )
    
    args = parser.parse_args()
    
    # Set default device if not specified
    if not args.device:
        args.device = 'cuda:0' if torch.cuda.is_available() else 'cpu'
    
    sys.exit(main(args))
