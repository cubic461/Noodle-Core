# Converted from Python to NoodleCore
# Original file: src

# """
# Symbol Index for Noodle
# -----------------------
# This module implements the symbol index for Noodle, providing fast lookups
# of variables, functions, and modules using a combination of hashmap and trie structures.
# """

import hashlib
import time
from dataclasses import dataclass
import enum.Enum
import typing.Any

import ..compiler.parser.ASTNode
import ..compiler.semantic_analyzer.FunctionSymbol


class SymbolType(Enum)
    #     """Types of symbols that can be indexed"""

    VARIABLE = "variable"
    FUNCTION = "function"
    CLASS = "class"
    MODULE = "module"
    PARAMETER = "parameter"
    CONSTANT = "constant"
    TYPE_ALIAS = "type_alias"


dataclass
class SymbolEntry
    #     """Represents an entry in the symbol index"""

    #     name: str
    #     symbol_type: SymbolType
    data_type: Optional[Type] = None
    namespace: str = "global"
    definition_position: Optional[Tuple[int, int]] = None
    declaration_node: Optional[ASTNode] = None
    is_exported: bool = False
    dependencies: Set[str] = field(default_factory=set)
    attributes: Dict[str, Any] = field(default_factory=dict)
    last_accessed: Optional[float] = None
    access_count: int = 0
    hash_id: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


class SymbolIndex
    #     """
    #     Symbol Index for Noodle with O(1) lookups and namespace support.
    #     Combines hashmap for direct access with trie for namespace resolution.
    #     """

    #     def __init__(self):
    #         # Primary hashmap for O(1) symbol lookup
    self.symbols: Dict[str, SymbolEntry] = {}

    #         # Namespace trie for hierarchical symbol resolution
    self.namespace_trie = NamespaceTrie()

    #         # Reverse index for type-based lookups
    self.type_index: Dict[Type, Set[str]] = {}

    #         # Dependency graph
    self.dependency_graph: Dict[str, Set[str]] = {}

    #         # Access statistics
    self.access_stats: Dict[str, int] = {}

    #         # Cache for frequent lookups
    self.lookup_cache: Dict[str, SymbolEntry] = {}
    self.cache_size_limit = 1000

    #         # Index metadata
    self.created_at = time.time()
    self.last_updated = time.time()
    self.symbol_count = 0

    #     def add_symbol(
    #         self,
    #         name: str,
    #         symbol_type: SymbolType,
    data_type: Optional[Type] = None,
    namespace: str = "global",
    definition_position: Optional[Tuple[int, int]] = None,
    declaration_node: Optional[ASTNode] = None,
    is_exported: bool = False,
    dependencies: Optional[Set[str]] = None,
    attributes: Optional[Dict[str, Any]] = None,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -SymbolEntry):
    #         """
    #         Add a symbol to the index

    #         Args:
    #             name: Symbol name
    #             symbol_type: Type of symbol
    #             data_type: Associated data type
    #             namespace: Namespace where symbol is defined
    #             definition_position: Source code position of definition
    #             declaration_node: AST node of declaration
    #             is_exported: Whether symbol is exported from namespace
    #             dependencies: Set of symbol names this symbol depends on
    #             attributes: Additional attributes
    #             metadata: Additional metadata

    #         Returns:
    #             The created symbol entry
    #         """
    #         # Generate unique hash ID for this symbol
    hash_content = f"{name}{symbol_type.value}{namespace}{time.time()}"
    hash_id = hashlib.sha256(hash_content.encode()).hexdigest()[:16]

    #         # Create symbol entry
    entry = SymbolEntry(
    name = name,
    symbol_type = symbol_type,
    data_type = data_type,
    namespace = namespace,
    definition_position = definition_position,
    declaration_node = declaration_node,
    is_exported = is_exported,
    dependencies = dependencies or set(),
    attributes = attributes or {},
    metadata = metadata or {},
    hash_id = hash_id,
    #         )

    #         # Add to primary index
    self.symbols[name] = entry
    self.symbol_count + = 1

    #         # Add to namespace trie
            self.namespace_trie.insert(name, namespace, entry)

    #         # Update type index
    #         if data_type:
    #             if data_type not in self.type_index:
    self.type_index[data_type] = set()
                self.type_index[data_type].add(name)

    #         # Update dependency graph
    #         if dependencies:
    self.dependency_graph[name] = dependencies
    #             for dep in dependencies:
    #                 if dep not in self.dependency_graph:
    self.dependency_graph[dep] = set()
                    self.dependency_graph[dep].add(name)

    #         # Update access stats
    self.access_stats[name] = 0

    #         # Update metadata
    self.last_updated = time.time()

    #         # Invalidate cache
            self.lookup_cache.clear()

    #         return entry

    #     def get_symbol(
    self, name: str, namespace: Optional[str] = None
    #     ) -Optional[SymbolEntry]):
    #         """
    #         Get a symbol by name with optional namespace restriction

    #         Args:
    #             name: Symbol name to lookup
    #             namespace: Optional namespace to restrict search

    #         Returns:
    #             Symbol entry if found, None otherwise
    #         """
    #         # Check cache first
    #         cache_key = f"{name}:{namespace}" if namespace else name
    #         if cache_key in self.lookup_cache:
    entry = self.lookup_cache[cache_key]
                self._record_access(entry)
    #             return entry

    #         # Try direct lookup
    #         if name in self.symbols:
    entry = self.symbols[name]

    #             # If namespace specified, verify it matches
    #             if namespace and entry.namespace != namespace:
    #                 # Try namespace trie lookup
    entry = self.namespace_trie.lookup(name, namespace)
    #                 if not entry:
    #                     return None
    #             else:
    #                 # Record access for direct hit
                    self._record_access(entry)

    #                 # Update cache
                    self._update_cache(cache_key, entry)

    #                 return entry

    #         # Try namespace trie lookup
    #         if namespace:
    entry = self.namespace_trie.lookup(name, namespace)
    #             if entry:
                    self._record_access(entry)
                    self._update_cache(cache_key, entry)
    #                 return entry

    #         return None

    #     def get_symbols_by_type(self, symbol_type: SymbolType) -List[SymbolEntry]):
    #         """
    #         Get all symbols of a specific type

    #         Args:
    #             symbol_type: Type of symbols to retrieve

    #         Returns:
    #             List of symbol entries
    #         """
    #         return [
    #             entry for entry in self.symbols.values() if entry.symbol_type == symbol_type
    #         ]

    #     def get_symbols_by_data_type(self, data_type: Type) -List[SymbolEntry]):
    #         """
    #         Get all symbols with a specific data type

    #         Args:
    #             data_type: Data type to filter by

    #         Returns:
    #             List of symbol entries
    #         """
    #         if data_type not in self.type_index:
    #             return []

    #         return [self.symbols[name] for name in self.type_index[data_type]]

    #     def get_symbols_in_namespace(self, namespace: str) -List[SymbolEntry]):
    #         """
    #         Get all symbols in a specific namespace

    #         Args:
    #             namespace: Namespace name

    #         Returns:
    #             List of symbol entries
    #         """
            return self.namespace_trie.get_namespace(namespace)

    #     def update_symbol(
    self, name: str, updates: Dict[str, Any], namespace: Optional[str] = None
    #     ) -bool):
    #         """
    #         Update an existing symbol entry

    #         Args:
    #             name: Symbol name to update
    #             updates: Dictionary of fields to update
    #             namespace: Optional namespace to restrict search

    #         Returns:
    #             True if update successful, False if symbol not found
    #         """
    entry = self.get_symbol(name, namespace)
    #         if not entry:
    #             return False

    #         # Update fields
    #         for key, value in updates.items():
    #             if hasattr(entry, key):
                    setattr(entry, key, value)

    #         # Special handling for dependencies
    #         if "dependencies" in updates:
    #             # Update dependency graph
    old_deps = self.dependency_graph.get(name, set())
    new_deps = updates["dependencies"]

    #             # Remove from old dependencies' reverse dependencies
    #             for dep in old_deps - new_deps:
    #                 if dep in self.dependency_graph and name in self.dependency_graph[dep]:
                        self.dependency_graph[dep].remove(name)

    #             # Add to new dependencies' reverse dependencies
    #             for dep in new_deps - old_deps:
    #                 if dep not in self.dependency_graph:
    self.dependency_graph[dep] = set()
                    self.dependency_graph[dep].add(name)

    #             # Update dependency graph entry
    self.dependency_graph[name] = new_deps

    #         # Update metadata
    self.last_updated = time.time()

    #         # Invalidate cache
            self.lookup_cache.clear()

    #         return True

    #     def remove_symbol(self, name: str, namespace: Optional[str] = None) -bool):
    #         """
    #         Remove a symbol from the index

    #         Args:
    #             name: Symbol name to remove
    #             namespace: Optional namespace to restrict search

    #         Returns:
    #             True if removal successful, False if symbol not found
    #         """
    entry = self.get_symbol(name, namespace)
    #         if not entry:
    #             return False

    #         # Remove from primary index
    #         del self.symbols[name]
    self.symbol_count - = 1

    #         # Remove from namespace trie
            self.namespace_trie.remove(name, entry.namespace)

    #         # Remove from type index
    #         if entry.data_type and entry.data_type in self.type_index:
                self.type_index[entry.data_type].discard(name)
    #             if not self.type_index[entry.data_type]:
    #                 del self.type_index[entry.data_type]

    #         # Remove from dependency graph
    #         if name in self.dependency_graph:
    #             # Remove from reverse dependencies
    #             for dep in self.dependency_graph[name]:
    #                 if dep in self.dependency_graph and name in self.dependency_graph[dep]:
                        self.dependency_graph[dep].remove(name)
    #             del self.dependency_graph[name]

    #         # Remove this symbol's reverse dependencies
    #         for sym_name, deps in self.dependency_graph.items():
    #             if name in deps:
                    deps.remove(name)

    #         # Remove access stats
            self.access_stats.pop(name, None)

    #         # Invalidate cache
            self.lookup_cache.clear()

    #         # Update metadata
    self.last_updated = time.time()

    #         return True

    #     def find_symbols_by_pattern(
    self, pattern: str, namespace: Optional[str] = None
    #     ) -List[SymbolEntry]):
    #         """
            Find symbols matching a pattern (supports wildcards)

    #         Args:
                pattern: Pattern to match (supports * wildcard)
    #             namespace: Optional namespace to restrict search

    #         Returns:
    #             List of matching symbol entries
    #         """
    #         if "*" in pattern:
    #             # Convert wildcard pattern to regex
    #             import re

    regex_pattern = pattern.replace("*", ".*")
    regex = re.compile(regex_pattern)

    matches = []
    #             for name, entry in self.symbols.items():
    #                 if regex.match(name):
    #                     if not namespace or entry.namespace == namespace:
                            matches.append(entry)
    #             return matches
    #         else:
    #             # Exact match
    entry = self.get_symbol(pattern, namespace)
    #             return [entry] if entry else []

    #     def get_dependent_symbols(self, name: str) -Set[str]):
    #         """
    #         Get all symbols that depend on the given symbol

    #         Args:
    #             name: Symbol name

    #         Returns:
    #             Set of dependent symbol names
    #         """
            return self.dependency_graph.get(name, set())

    #     def get_symbol_dependencies(self, name: str) -Set[str]):
    #         """
    #         Get all dependencies of a symbol

    #         Args:
    #             name: Symbol name

    #         Returns:
    #             Set of dependency names
    #         """
            return self.dependency_graph.get(name, set())

    #     def get_access_statistics(self) -Dict[str, int]):
    #         """
    #         Get access statistics for all symbols

    #         Returns:
    #             Dictionary mapping symbol names to access counts
    #         """
            return self.access_stats.copy()

    #     def get_most_accessed_symbols(self, limit: int = 10) -List[Tuple[str, int]]):
    #         """
    #         Get the most frequently accessed symbols

    #         Args:
    #             limit: Maximum number of symbols to return

    #         Returns:
                List of (symbol_name, access_count) tuples
    #         """
    sorted_symbols = sorted(
    self.access_stats.items(), key = lambda x: x[1], reverse=True
    #         )
    #         return sorted_symbols[:limit]

    #     def get_namespace_hierarchy(self) -Dict[str, List[str]]):
    #         """
    #         Get the namespace hierarchy

    #         Returns:
    #             Dictionary mapping namespace names to lists of contained symbols
    #         """
            return self.namespace_trie.get_all_namespaces()

    #     def export_namespace(self, namespace: str) -Dict[str, Any]):
    #         """
    #         Export a namespace as a serializable dictionary

    #         Args:
    #             namespace: Namespace to export

    #         Returns:
    #             Dictionary representation of the namespace
    #         """
    symbols = self.get_symbols_in_namespace(namespace)
    #         return {
    #             "namespace": namespace,
    #             "symbols": [
    #                 {
    #                     "name": sym.name,
    #                     "type": sym.symbol_type.value,
    #                     "data_type": str(sym.data_type) if sym.data_type else None,
    #                     "is_exported": sym.is_exported,
                        "dependencies": list(sym.dependencies),
    #                     "attributes": sym.attributes,
    #                     "metadata": sym.metadata,
    #                 }
    #                 for sym in symbols
    #             ],
                "exported_at": time.time(),
    #         }

    #     def import_namespace(self, namespace_data: Dict[str, Any]) -bool):
    #         """
    #         Import a namespace from a dictionary

    #         Args:
    #             namespace_data: Dictionary representation of namespace

    #         Returns:
    #             True if import successful
    #         """
    namespace = namespace_data["namespace"]
    symbols_data = namespace_data["symbols"]

    #         for symbol_data in symbols_data:
                self.add_symbol(
    name = symbol_data["name"],
    symbol_type = SymbolType(symbol_data["type"]),
    data_type = (
    #                     Type(symbol_data["data_type"]) if symbol_data["data_type"] else None
    #                 ),
    namespace = namespace,
    is_exported = symbol_data["is_exported"],
    dependencies = set(symbol_data["dependencies"]),
    attributes = symbol_data["attributes"],
    metadata = symbol_data["metadata"],
    #             )

    #         return True

    #     def validate_integrity(self) -List[str]):
    #         """
    #         Validate the integrity of the symbol index

    #         Returns:
    #             List of validation errors, empty if valid
    #         """
    errors = []

    #         # Check all symbols in primary index exist in namespace trie
    #         for name, entry in self.symbols.items():
    #             if not self.namespace_trie.lookup(name, entry.namespace):
                    errors.append(f"Symbol '{name}' missing from namespace trie")

    #         # Check dependency graph consistency
    #         for name, deps in self.dependency_graph.items():
    #             for dep in deps:
    #                 if dep not in self.symbols:
                        errors.append(
    #                         f"Symbol '{name}' depends on non-existent symbol '{dep}'"
    #                     )

    #         # Check type index consistency
    #         for data_type, names in self.type_index.items():
    #             for name in names:
    #                 if name not in self.symbols:
                        errors.append(f"Type index references non-existent symbol '{name}'")
    #                 elif self.symbols[name].data_type != data_type:
    #                     errors.append(f"Type index mismatch for symbol '{name}'")

    #         return errors

    #     def get_index_statistics(self) -Dict[str, Any]):
    #         """
    #         Get statistics about the symbol index

    #         Returns:
    #             Dictionary of index statistics
    #         """
    #         return {
    #             "total_symbols": self.symbol_count,
                "namespaces": len(self.namespace_trie.get_all_namespaces()),
                "types_indexed": len(self.type_index),
                "dependency_count": len(self.dependency_graph),
                "cache_size": len(self.lookup_cache),
                "cache_hit_rate": self._calculate_cache_hit_rate(),
    #             "created_at": self.created_at,
    #             "last_updated": self.last_updated,
                "most_accessed": self.get_most_accessed_symbols(5),
    #             "symbols_by_type": {
    #                 st.value: len(self.get_symbols_by_type(st)) for st in SymbolType
    #             },
    #         }

    #     def _record_access(self, entry: SymbolEntry):
    #         """Record an access to a symbol"""
    entry.last_accessed = time.time()
    entry.access_count + = 1
    self.access_stats[entry.name] = entry.access_count

    #     def _update_cache(self, key: str, entry: SymbolEntry):
    #         """Update the lookup cache"""
    #         if len(self.lookup_cache) >= self.cache_size_limit:
    #             # Remove oldest entry
    oldest_key = min(
                    self.lookup_cache.keys(),
    key = lambda k: self.lookup_cache[k].last_accessed or 0,
    #             )
    #             del self.lookup_cache[oldest_key]

    self.lookup_cache[key] = entry

    #     def _calculate_cache_hit_rate(self) -float):
    #         """Calculate the cache hit rate"""
    #         if not self.access_stats:
    #             return 0.0

    total_accesses = sum(self.access_stats.values())
    #         cache_accesses = sum(entry.access_count for entry in self.lookup_cache.values())

    #         return cache_accesses / total_accesses if total_accesses 0 else 0.0


class NamespaceTrie
    #     """
    #     Trie-based namespace management for hierarchical symbol resolution.
    #     Supports efficient namespace lookups and symbol organization.
    #     """

    #     def __init__(self)):
    self.root = TrieNode()

    #     def insert(self, name: str, namespace: str, entry: SymbolEntry):
    #         """
    #         Insert a symbol into a namespace

    #         Args:
    #             name: Symbol name
                namespace: Namespace path (e.g., "math.linear.algebra")
    #             entry: Symbol entry to insert
    #         """
    current = self.root
    parts = namespace.split(".")

    #         for part in parts:
    #             if part not in current.children:
    current.children[part] = TrieNode()
    current = current.children[part]

    current.symbols[name] = entry

    #     def lookup(self, name: str, namespace: str) -Optional[SymbolEntry]):
    #         """
    #         Lookup a symbol in a specific namespace

    #         Args:
    #             name: Symbol name to find
    #             namespace: Namespace path to search

    #         Returns:
    #             Symbol entry if found, None otherwise
    #         """
    current = self.root
    parts = namespace.split(".")

    #         for part in parts:
    #             if part not in current.children:
    #                 return None
    current = current.children[part]

            return current.symbols.get(name)

    #     def get_namespace(self, namespace: str) -List[SymbolEntry]):
    #         """
    #         Get all symbols in a namespace

    #         Args:
    #             namespace: Namespace path

    #         Returns:
    #             List of symbol entries in the namespace
    #         """
    current = self.root
    parts = namespace.split(".")

    #         for part in parts:
    #             if part not in current.children:
    #                 return []
    current = current.children[part]

            return list(current.symbols.values())

    #     def remove(self, name: str, namespace: str) -bool):
    #         """
    #         Remove a symbol from a namespace

    #         Args:
    #             name: Symbol name to remove
    #             namespace: Namespace path

    #         Returns:
    #             True if removal successful, False if not found
    #         """
    current = self.root
    parts = namespace.split(".")

    #         for part in parts:
    #             if part not in current.children:
    #                 return False
    current = current.children[part]

    #         if name in current.symbols:
    #             del current.symbols[name]
    #             return True

    #         return False

    #     def get_all_namespaces(self) -Dict[str, List[str]]):
    #         """
    #         Get all namespaces and their symbols

    #         Returns:
    #             Dictionary mapping namespace paths to symbol names
    #         """
    result = {}

    #         def traverse(node: TrieNode, path: str = ""):
    #             for part, child in node.children.items():
    #                 current_path = f"{path}.{part}" if path else part
    #                 if child.symbols:
    result[current_path] = list(child.symbols.keys())
                    traverse(child, current_path)

            traverse(self.root)
    #         return result


class TrieNode
    #     """
    #     Node in the namespace trie
    #     """

    #     def __init__(self):
    self.children: Dict[str, "TrieNode"] = {}
    self.symbols: Dict[str, SymbolEntry] = {}
