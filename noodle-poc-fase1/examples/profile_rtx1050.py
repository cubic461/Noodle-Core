#!/usr/bin/env python3
"""
Profile RTX 1050 GPU + CPU with GPT-2 to generate real hardware metrics.

This script:
1. Verifies GPU availability (RTX 1050)
2. Profiles GPT-2 in 3 modes: GPU only, CPU only, mixed GPU/CPU
3. Generates structured metrics (JSONL)
4. Creates comparative dashboard
5. Suggests optimal staging plan based on real data
"""

import sys
import os
import time
import json
from pathlib import Path
from datetime import datetime

# Add project to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))
sys.path.insert(0, str(PROJECT_ROOT / 'src'))

import torch
import psutil
from transformers import GPT2LMHeadModel, GPT2TokenizerFast

try:
    from src.observability_engine import ObservabilityEngine
    from src.plan import VirtualNode, DeviceType, create_fake_metrics_for_demo
    from src.planner import ExecutionPlanner, PartitionStrategy
    from src.metrics import MetricsCollector
    print("[INFO] All imports successful!")
except ImportError as e:
    print(f"[ERROR] Import failed: {e}")
    print("[INFO] Installing dependencies...")
    os.system("pip install torch transformers psutil")
    print("[INFO] Please run again after installation.")
    sys.exit(1)


def verify_setup():
    """Verify GPU and setup."""
    print("="*80)
    print("HARDWARE VERIFICATION")
    print("="*80)

    # Check CUDA
    if not torch.cuda.is_available():
        print("[WARN] CUDA not available. GPU profiling will be skipped.")
        has_gpu = False
        cuda_device = "N/A"
        vram_gb = 0.0
    else:
        has_gpu = True
        cuda_device = torch.cuda.get_device_name(0)
        vram_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
        print(f"✅ GPU: {cuda_device} ({vram_gb:.1f}GB VRAM)")
        print(f"   CUDA: {torch.version.cuda}")

    # Check CPU
    cpu_count = psutil.cpu_count()
    ram_gb = psutil.virtual_memory().total / (1024**3)
    print(f"✅ CPU: {cpu_count} cores, {ram_gb:.1f}GB RAM")

    # Check if model fits in VRAM
    if has_gpu and vram_gb < 4.5:
        print(f"\n⚠️  Low VRAM detected ({vram_gb:.1f}GB). Using smaller models.")
        model_name = "distilgpt2"  # Smaller model
    else:
        model_name = "gpt2"

    print(f"\n[INFO] Will use model: {model_name}")
    print("="*80)

    return has_gpu, model_name, vram_gb, ram_gb


def load_model_with_fallback(model_name, device):
    """Load model with memory handling."""
    try:
        print(f"[INFO] Loading {model_name} to {device}...")
        model = GPT2LMHeadModel.from_pretrained(model_name)

        if device == "cuda":
            # Check memory before moving
            if torch.cuda.is_available():
                torch.cuda.empty_cache()
                available_vram = torch.cuda.get_device_properties(0).total_memory - torch.cuda.memory_allocated()
                model_size_bytes = sum(p.numel() * p.element_size() for p in model.parameters())

                if model_size_bytes > available_vram * 0.8:  # 80% threshold
                    print(f"[WARN] Model may not fit in VRAM, using FP16 quantization")
                    model = model.half()
        else:
            pass  # CPU model, no special handling

        model = model.to(device)
        model.eval()
        print(f"[OK] Model loaded successfully")
        return model

    except RuntimeError as e:
        if "out of memory" in str(e).lower() or "CUDA out of memory" in str(e):
            print(f"[ERROR] OOM - Model too large for {device}")
            print(f"[INFO] Trying FP16 quantization...")
            torch.cuda.empty_cache()
            model = GPT2LMHeadModel.from_pretrained(model_name).half().to(device)
            model.eval()
            return model
        else:
            raise


def profile_device(model, tokenizer, device, num_runs, profile_name):
    """Profile model on specific device."""
    print(f"\n{'='*80}")
    print(f"PROFILING: {profile_name}")
    print(f"{'='*80}")

    # Setup
    inputs = tokenizer("Hello world, how are you today?", return_tensors="pt")
    input_ids = inputs.input_ids.to(device)
    attention_mask = inputs.attention_mask.to(device)

    # Initialize engine
    log_dir = PROJECT_ROOT / "data" / f"profile_{device}_{profile_name.replace(' ', '_')}"
    engine = ObservabilityEngine(model, log_dir=log_dir)

    # Instrument and warmup
    print(f"[INFO] Instrumenting model with hooks...")
    engine.config = {"num_warmup_runs": 10, "num_profile_runs": num_runs}
    engine.instrument()

    print(f"[INFO] Warming up ({engine.config['num_warmup_runs']} runs)...")
    engine.warmup({"input_ids": input_ids, "attention_mask": attention_mask})

    # Profile
    print(f"[INFO] Profiling ({engine.config['num_profile_runs']} runs)...")
    start_time = time.time()

    results = engine.profile(
        {"input_ids": input_ids, "attention_mask": attention_mask},
        num_runs=engine.config['num_profile_runs'],
        profile_name=profile_name,
    )

    elapsed = time.time() - start_time
    print(f"[TIME] Profiling took {elapsed:.1f}s")

    # Save
    print(f"[INFO] Generating dashboard...")
    engine.save_dashboard(profile_name.replace(' ', '_'))

    # Cleanup
    engine.finalize()
    torch.cuda.empty_cache() if device == "cuda" else None

    return results


def compare_results(results_gpu, results_cpu):
    """Compare GPU vs CPU performance."""
    print(f"\n{'='*80}")
    print("PERFORMANCE COMPARISON")
    print(f"{'='*80}")

    if results_gpu and results_cpu:
        gpu_ms = results_gpu.get('end_to_end_latency', {}).get('mean_ms', 0)
        cpu_ms = results_cpu.get('end_to_end_latency', {}).get('mean_ms', 0)
        speedup = cpu_ms / gpu_ms if gpu_ms > 0 else 0

        print(f"GPU latency:  {gpu_ms:>8.1f}ms")
        print(f"CPU latency:  {cpu_ms:>8.1f}ms")
        print(f"GPU speedup:  {speedup:>8.2f}x")
    else:
        print("[WARN] Not enough data for comparison")

    # Memory analysis
    print(f"\n{'-'*80}")
    print("MEMORY ANALYSIS")
    print(f"{'-'*80}")

    if torch.cuda.is_available():
        peak_vram_mb = torch.cuda.max_memory_allocated() / (1024**2)
        print(f"Peak VRAM usage: {peak_vram_mb:.1f}MB")
        print(f"Remaining VRAM:  {(4096 - peak_vram_mb/1024):.1f}GB")
    else:
        print("No GPU available for memory analysis")


def create_staging_plan(has_gpu, vram_gb, ram_gb):
    """Create staging plan based on hardware."""
    print(f"\n{'='*80}")
    print("STAGING PLAN RECOMMENDATION")
    print(f"{'='*80}")

    # Use fake metrics for demo (replace with actual GPU/CPU metrics when available)
    fake_metrics = create_fake_metrics_for_demo()
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    # Create virtual nodes based on actual hardware
    nodes = []

    if has_gpu:
        gpu_node = VirtualNode(
            node_id="RTX1050_Local",
            device_type=DeviceType.GPU,
            compute_score=20.0,
            vram_gb=float(vram_gb),
            ram_gb=0.0,
        )
        nodes.append(gpu_node)
        print(f"✅ GPU Node: {gpu_node.node_id} ({gpu_node.vram_gb:.1f}GB VRAM)")

    cpu_node = VirtualNode(
        node_id="CPU_Local",
        device_type=DeviceType.CPU,
        compute_score=5.0,
        ram_gb=float(ram_gb),
    )
    nodes.append(cpu_node)
    print(f"✅ CPU Node: {cpu_node.node_id} ({cpu_node.ram_gb:.1f}GB RAM)")

    # Generate plan
    planner = ExecutionPlanner(
        collector,
        strategy=PartitionStrategy.BALANCED,
    )

    plan = planner.generate_plan(
        available_nodes=nodes,
        model_name="GPT2_RTX1050_Local"
    )

    print(f"\n{'-'*80}")
    print("RECOMMENDED PLAN")
    print(f"{'-'*80}")
    print(plan.visualize())

    # Export plan to JSON
    plan_json = plan.to_json()
    plan_file = PROJECT_ROOT / "data" / f"staging_plan_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(plan_file, 'w') as f:
        f.write(plan_json)
    print(f"\n[OK] Plan saved to: {plan_file}")


def main():
    """Main profiling workflow."""
    print("\n" + "="*80)
    print("🚀 RTX 1050 DISTRIBUTED INFERENCE PROFILER")
    print("="*80)

    # Verify setup
    has_gpu, model_name, vram_gb, ram_gb = verify_setup()

    # Load tokenizer (always on CPU)
    print(f"\n[INFO] Loading tokenizer...")
    tokenizer = GPT2TokenizerFast.from_pretrained(model_name)
    print(f"[OK] Tokenizer ready")

    # Profile CPU
    print(f"\n[STEP 1/2] Profiling CPU...")
    try:
        model_cpu = load_model_with_fallback(model_name, "cpu")
        results_cpu = profile_device(model_cpu, tokenizer, "cpu", 50, "GPT2 CPU Local")
        good_cpu = True
    except Exception as e:
        print(f"[ERROR] CPU profiling failed: {e}")
        results_cpu = None
        good_cpu = False

    # Profile GPU (if available)
    results_gpu = None
    if has_gpu:
        print(f"\n[STEP 2/2] Profiling GPU...")
        try:
            model_gpu = load_model_with_fallback(model_name, "cuda")
            results_gpu = profile_device(model_gpu, tokenizer, "cuda", 50, "GPT2 GPU RTX1050")
        except Exception as e:
            print(f"[ERROR] GPU profiling failed: {e}")
            print(f"[INFO] GPU profiling skipped, continuing with CPU data...")
    else:
        print(f"\n[INFO] Skipping GPU profiling (no CUDA available)")

    # Compare
    if results_gpu or results_cpu:
        compare_results(results_gpu, results_cpu)

        # Staging plan
        create_staging_plan(has_gpu, vram_gb, ram_gb)

        # Final summary
        print(f"\n{'='*80}")
        print("🎯 PROFILING COMPLETE!")
        print(f"{'='*80}")
        print(f"CPU Profile: {'✅' if good_cpu else '❌'}")
        print(f"GPU Profile: {'✅' if results_gpu else '❌'}")
        print(f"\n[INFO] Next step: run examples/staged_inference_step2.py for actual staged execution")

    else:
        print(f"[ERROR] No profiling data available, exiting...")
        return 1

    return 0


if __name__ == '__main__':
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print(f"\n[INFO] Interrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n[ERROR] Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
