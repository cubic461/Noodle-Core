"""
PyTorch hooks for intercepting layer execution and collecting metrics.
Provides both forward and backward pass monitoring.
"""

import time
import torch
import torch.nn as nn
from typing import Dict, List, Optional, Any
from functools import partial
from .metrics import MetricsCollector, LayerMetrics


class LayerHook:
    """Hooks into a PyTorch module to collect execution metrics."""

    def __init__(
        self,
        module: nn.Module,
        layer_name: str,
        layer_type: str,
        layer_index: int,
        collector: MetricsCollector,
    ):
        self.module = module
        self.layer_name = layer_name
        self.layer_type = layer_type
        self.layer_idx = layer_index
        self.collector = collector
        self.current_metrics: Optional[LayerMetrics] = None

    def pre_forward_hook(self, module: nn.Module, inputs):
        """Hook called before forward pass."""
        try:
            self.current_metrics = self.collector.start_layer_monitoring(
                layer_name=self.layer_name,
                layer_type=self.layer_type,
                layer_idx=self.layer_idx,
            )
            self.start_time = time.time()
        except Exception as e:
            print(f"Error in pre_forward_hook: {e}")

    def post_forward_hook(self, module: nn.Module, inputs, outputs):
        """Hook called after forward pass."""
        try:
            if self.current_metrics is None:
                return

            # Calculate latency
            end_time = time.time()
            latency_ms = (end_time - self.start_time) * 1000

            # Record tensor metadata
            self.collector.record_tensor_metadata(self.current_metrics, inputs, outputs)

            # Record parameter info
            self.collector.record_parameter_info(self.current_metrics, module)

            # Finalize metrics
            self.collector.stop_layer_monitoring(self.current_metrics, latency_ms)
        except Exception as e:
            print(f"Error in post_forward_hook: {e}")


class ModelInstrumentor:
    """Instruments a PyTorch model with hooks to monitor all layers."""

    def __init__(self, collector: MetricsCollector):
        self.collector = collector
        self.hooks: List[torch.utils.hooks.RemovableHandle] = []
        self.layer_mappings: Dict[str, str] = {}

    def instrument_model(
        self, model: nn.Module, prefix: str = ""
    ) -> nn.Module:
        """
        Recursively instrument all named modules in the model.

        Args:
            model: PyTorch model to instrument
            prefix: Prefix for hierarchical layer naming

        Returns:
            Instrumented model (in-place modification)
        """
        layer_idx = 0

        for name, module in model.named_modules():
            # Skip the root module itself
            if name == "":
                continue

            layer_type = module.__class__.__name__
            full_name = f"{prefix}.{name}" if prefix else name

            # Only instrument specific layer types (customize as needed)
            if self._should_instrument(module):
                hook = self._register_hooks(module, full_name, layer_type, layer_idx)
                self.hooks.append(hook)
                self.layer_mappings[full_name] = layer_type
                layer_idx += 1

        return model

    def _should_instrument(self, module: nn.Module) -> bool:
        """Determine if a module should be instrumented."""
        # Instrument common layer types
        target_types = [
            'Linear',
            'Conv2d',
            'LayerNorm',
            'Embedding',
            'MultiheadAttention',
            'TransformerEncoderLayer',
            'TransformerDecoderLayer',
            'GPT2Block',  # Transformer-specific
            'BertLayer',  # BERT-specific
        ]

        return any(module_type in module.__class__.__name__ for module_type in target_types)

    def _register_hooks(
        self, module: nn.Module, layer_name: str, layer_type: str, layer_idx: int
    ) -> torch.utils.hooks.RemovableHandle:
        """Register forward and backward hooks."""
        layer_hook = LayerHook(
            module=module,
            layer_name=layer_name,
            layer_type=layer_type,
            layer_index=layer_idx,
            collector=self.collector,
        )

        # Register hooks
        pre_hook = module.register_forward_pre_hook(layer_hook.pre_forward_hook)
        post_hook = module.register_forward_hook(layer_hook.post_forward_hook)

        # Return only one handle; both will be tracked internally
        return pre_hook

    def remove_hooks(self):
        """Remove all registered hooks."""
        for hook in self.hooks:
            hook.remove()
        self.hooks.clear()
        self.layer_mappings.clear()

    def get_layer_statistics(self) -> Dict[str, Any]:
        """Get basic statistics about instrumented layers."""
        return {
            "total_layers": len(self.layer_mappings),
            "layer_types": list(set(self.layer_mappings.values())),
            "layers": self.layer_mappings,
        }

    def __enter__(self):
        """Context manager entry."""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - cleanup hooks."""
        self.remove_hooks()


class ForwardOnlyHook:
    """
    Simplified hook for inference-only monitoring.
    Optimized for minimal overhead.
    """

    def __init__(self, layer_name: str, collector: MetricsCollector):
        self.layer_name = layer_name
        self.collector = collector
        self.layer_type = layer_name.split(".")[-2] if "." in layer_name else layer_name

    def __call__(self, module: nn.Module, inputs, outputs) -> None:
        """Simple hook implementation optimized for inference."""
        try:
            start_time = time.time()
            # Execute forward pass (this is a post-hook, so forward already happened)

            end_time = time.time()
            latency_ms = (end_time - start_time) * 1000

            if torch.cuda.is_available():
                vram_after = torch.cuda.memory_allocated()
            else:
                vram_after = 0

            # Record simplified metrics
            metrics = LayerMetrics(
                layer_name=self.layer_name,
                layer_type=self.layer_type,
                layer_index=-1,  # Simplified index
                forward_latency_ms=latency_ms,
                peak_vram_after=vram_after,
                device=str(torch.cuda.current_device()) if torch.cuda.is_available() else "cpu",
            )

            self.collector.record_tensor_metadata(metrics, inputs, outputs)

            if module not in self.collector.metrics_history:
                self.collector.metrics_history[module] = []
            self.collector.metrics_history[module].append(metrics)

        except Exception as e:
            # Swallow errors in hooks to avoid crashing inference
            pass


def instrument_transformer_blocks(
    model: nn.Module, collector: MetricsCollector
) -> List[torch.utils.hooks.RemovableHandle]:
    """
    Specialized instrumentor for Transformer models.
    Instruments each transformer block separately.

    Args:
        model: Transformer model (e.g., GPT-2, BERT)
        collector: MetricsCollector instance

    Returns:
        List of hook handles
    """
    handles = []

    if hasattr(model, 'transformer') and hasattr(model.transformer, 'h'):
        # GPT-2 style: model.transformer.h (list of blocks)
        for idx, block in enumerate(model.transformer.h):
            layer_name = f"transformer.h.{idx}"
            hook = ForwardOnlyHook(layer_name, collector)
            handles.append(block.register_forward_hook(hook))

    elif hasattr(model, 'encoder') and hasattr(model.encoder, 'layer'):
        # BERT style: model.encoder.layer
        for idx, block in enumerate(model.encoder.layer):
            layer_name = f"encoder.layer.{idx}"
            hook = ForwardOnlyHook(layer_name, collector)
            handles.append(block.register_forward_hook(hook))

    return handles
