"""
Noodle Vector Database::Memory - memory.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Full Memory Manager for Vector Database.

Integrates with storage for tiering.
"""

import time
from collections import OrderedDict
from typing import Dict, List, Optional

import psutil  # For real RAM monitoring

from .storage import VectorIndex


class MemoryManager:
    """
    Full implementation with LRU eviction and tiering.
    """

    def __init__(
        self, index: VectorIndex, max_hot_size: int = 1000, threshold_pct: float = 70.0
    ):
        self.index = index
        self.hot: OrderedDict[str, Dict] = (
            OrderedDict()
        )  # id -> {matrix, timestamp, metadata}
        self.max_hot_size = max_hot_size
        self.threshold_pct = threshold_pct
        self.total_ram_mb = psutil.virtual_memory().total // (1024**2)
        self.threshold_mb = self.total_ram_mb * threshold_pct / 100

    def add_embedding(self, id_: str, matrix: "Matrix", metadata: Dict):
        """Add to hot cache, evict if needed."""
        timestamp = time.time()
        self.hot[id_] = {"matrix": matrix, "timestamp": timestamp, "metadata": metadata}
        self.hot.move_to_end(id_)
        self._evict_if_needed()

    def _get_current_usage_mb(self) -> float:
        """Estimate RAM usage of hot cache."""
        # Approximate: each matrix ~ dim * 4 bytes + overhead
        total = 0
        for item in self.hot.values():
            # Assume matrix dim 384, float32
            total += 384 * 4 + len(str(item["metadata"]))  # Rough
        return total / (1024**2)

    def _evict_if_needed(self) -> List[str]:
        """Evict LRU if over size or RAM threshold."""
        evicted = []
        usage = self._get_current_usage_mb()
        while (
            len(self.hot) > self.max_hot_size or usage > self.threshold_mb
        ) and self.hot:
            id_to_evict = next(iter(self.hot))
            evicted.append(id_to_evict)
            item = self.hot.pop(id_to_evict)
            # Persist to cold
            self.index._persist_single(id_to_evict, item["matrix"], item["metadata"])
            usage = self._get_current_usage_mb()
        return evicted

    def get_embedding(self, id_: str) -> Optional["Matrix"]:
        """Get from hot, promote if miss."""
        if id_ in self.hot:
            item = self.hot[id_]
            item["timestamp"] = time.time()
            self.hot.move_to_end(id_)
            return item["matrix"]
        # Load from cold
        matrix = self.index.get(id_)
        if matrix:
            metadata = self.index.metadata.get(id_, {})
            self.add_embedding(id_, matrix, metadata)  # Promote
            return matrix
        return None

    def prefetch(self, ids: List[str]):
        """Prefetch to hot."""
        for id_ in ids:
            matrix = self.index.get(id_)
            if matrix:
                metadata = self.index.metadata.get(id_, {})
                self.add_embedding(id_, matrix, metadata)

    def get_status(self) -> Dict:
        """Status for UI."""
        usage = self._get_current_usage_mb()
        return {
            "hot_count": len(self.hot),
            "ram_usage_mb": usage,
            "threshold_mb": self.threshold_mb,
            "pct_used": (
                (usage / self.threshold_mb * 100) if self.threshold_mb > 0 else 0
            ),
            "evicted_recent": len(self._evict_if_needed()),  # Trigger check
        }

    def set_config(
        self, max_hot_size: Optional[int] = None, threshold_pct: Optional[float] = None
    ):
        """Update config."""
        if max_hot_size is not None:
            self.max_hot_size = max_hot_size
        if threshold_pct is not None:
            self.threshold_pct = threshold_pct
            self.threshold_mb = self.total_ram_mb * threshold_pct / 100


