from pathlib import Path
import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer
import argparse
import sys
import os

# Import from noodle_poc package
project_root = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(project_root, '..', 'src'))

from noodle_poc.observability_engine import ObservabilityEngine
import noodle_poc.logger

print('[PROFILE] Starting GPT-2 profiler...')

def load_gpt2_model(
    model_name: str = "gpt2",
    device: str = "cpu",
    dtype: str = "fp32",
):
    """Load GPT-2 model and tokenizer."""
    print(f"[LOADING] Loading model: {model_name}")
    print(f"   Device: {device}")
    print(f"   Precision: {dtype}")

    tokenizer = GPT2Tokenizer.from_pretrained(model_name)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    model = GPT2LMHeadModel.from_pretrained(model_name)
    model.eval()

    if dtype == "fp16":
        model = model.half()
    elif dtype == "bf16":
        model = model.bfloat16()

    device_torch = torch.device(device)
    model = model.to(device_torch)

    print(f"[SUCCESS] Model loaded successfully")
    print(f"   Parameters: {sum(p.numel() for p in model.parameters()):,}")
    print(f"   Size: {sum(p.numel() * p.element_size() for p in model.parameters()) / 1024**3:.2f} GB")

    return model, tokenizer

def create_sample_inputs(tokenizer, prompts: list, max_length: int = 128, device: str = "cpu"):
    """Create tokenized inputs from text prompts."""
    encoded = tokenizer(
        prompts,
        padding="max_length",
        truncation=True,
        max_length=max_length,
        return_tensors="pt",
    )
    device_torch = torch.device(device)
    inputs = {k: v.to(device_torch) for k, v in encoded.items()}
    return inputs

def profile_gpt2(config_path: str = "config/gpt2_config.yaml", model_name: str = "gpt2", num_samples: int = 100, output_dir: str = "data"):
    """Complete GPT-2 profiling workflow."""
    try:
        engine = ObservabilityEngine.from_config(Path(config_path))
    except Exception as e:
        print(f"[ERROR] Error loading config: {e}")
        sys.exit(1)

    engine.config['model_name'] = model_name
    engine.config['num_profile_runs'] = num_samples

    if output_dir:
        engine.log_dir = Path(output_dir) / "metrics"
        engine.log_dir.mkdir(parents=True, exist_ok=True)

    device = "cpu"
    dtype = engine.config.get("dtype", "fp32")

    try:
        model, tokenizer = load_gpt2_model(model_name, device, dtype)
        engine.set_model(model)
    except Exception as e:
        print(f"[ERROR] Error loading model: {e}")
        sys.exit(1)

    sample_prompts = engine.config.get("sample_prompts", ["The quick brown fox"])
    sequence_length = engine.config.get("sequence_length", 128)

    inputs = create_sample_inputs(tokenizer, sample_prompts, max_length=sequence_length, device=device)

    try:
        print("\n" + "="*60)
        print("[START] Starting Profiling Workflow")
        print("="*60 + "\n")

        engine.instrument()
        num_warmup = engine.config.get("num_warmup_runs", 3)
        num_profile = engine.config.get("num_profile_runs", num_samples)

        print(f"[WARMUP] Warming up ({num_warmup} runs)")
        engine.warmup(inputs)

        print(f"[PROFILE] Profiling ({num_profile} runs)")
        results = engine.profile(inputs, profile_name=model_name)

        print(f"[SAVE] Saving results")
        engine.save_dashboard(model_name)

        print("\n" + "="*60)
        print("[RESULTS] Profiling Results Summary")
        print("="*60)
        print(f"Model: {model_name}")
        print(f"Layers profiled: {results['total_layers']}")
        print(f"Total profiling runs: {num_profile}")

        if 'end_to_end_latency' in results:
            e2e = results['end_to_end_latency']
            print(f"End-to-end latency: {e2e['mean_ms']:.2f} ms (avg over {e2e['num_runs']} runs)")

        summary = results['layer_summary']
        if summary:
            print(f"\nTop 5 slowest layers:")
            sorted_layers = sorted(summary.items(), key=lambda x: x[1]['avg_latency_ms'], reverse=True)[:5]
            for i, (layer_name, stats) in enumerate(sorted_layers, 1):
                print(f"  {i}. {layer_name}: {stats['avg_latency_ms']:.3f} ms (p95: {stats['p95_latency_ms']:.3f} ms)")

        print("\n" + "="*60)
        print("[SUCCESS] Profiling complete!")
        print(f"[DASHBOARD] {engine.log_dir}/{model_name}_dashboard.html")
        print(f"[METRICS] {engine.log_dir}/{model_name}_metrics.jsonl")
        print("="*60 + "\n")

    except Exception as e:
        print(f"\n[ERROR] Error during profiling: {e}")
        import traceback
        traceback.print_exc()
    finally:
        if engine.is_instrumented:
            engine.finalize()

    return results

def main():
    """Main entry point for CLI."""
    parser = argparse.ArgumentParser(description="Profile GPT-2 with NoodleCore Observability Engine")
    parser.add_argument('--config', type=str, default='config/gpt2_config.yaml', help='Path to configuration file')
    parser.add_argument('--model', type=str, default='gpt2', help='Hugging Face model name')
    parser.add_argument('--num-samples', type=int, default=100, help='Number of profiling samples')
    parser.add_argument('--output-dir', type=str, default='data', help='Output directory for results')
    parser.add_argument('--device', type=str, help='Device to use (overrides config)')

    args = parser.parse_args()

    profile_gpt2(
        config_path=args.config,
        model_name=args.model,
        num_samples=args.num_samples,
        output_dir=args.output_dir,
    )

if __name__ == '__main__':
    main()
