# Database Plugin System Implementation

## Overview
This document details the implementation of the Plugin System for Database Backends in Stap 8 of the Noodle roadmap. The system provides an extensible architecture for loading database backends dynamically, supporting both Python and FFI-based implementations.

## Key Features
- **Dynamic Discovery**: Scans `database/backends/` for *.py modules that subclass `DatabaseBackend`, loads them using importlib.
- **Runtime Loading**: `DatabasePluginLoader` registers backends by name (or class 'backend_name'), supports FFI detection (via 'ffi_init' method).
- **Central Management**: `DatabaseManager` handles configs, switching between backends, connection, and proxies all operations (insert, select, transactions).
- **FFI Support**: Backends can define `ffi_init()` for non-Python (C/Rust) loading; current focus on Python but extensible.
- **Security**: Loader checks for valid subclasses, manager validates configs and handles errors.

## Usage Example
```python
from noodle.database.database_manager import get_database_manager
from noodle.database.backends.base import BackendConfig

manager = get_database_manager()

# Register configs
sqlite_config = BackendConfig(name="sqlite", connection_string="test.db")
manager.register_config("sqlite", sqlite_config)

# Switch and use
manager.switch_backend("sqlite")
manager.create_table("users", {"id": "INTEGER PRIMARY KEY", "name": "TEXT"})

# Insert
manager.insert("users", {"name": "Alice"})

# Switch to another (e.g., postgresql)
# manager.switch_backend("postgresql")
```

## Testing
Integration tests in `tests/integration/test_plugin_system_integration.py` verify loading backends, switching, basic operations (create/insert/select), FFI detection, and unload.

## Integration with Existing Backends
- **sqlite.py, postgresql.py**: Automatically discovered as they subclass `DatabaseBackend`.
- **FFI Example**: A backend can add `def ffi_init(self):` to load C libs via ctypes.
- Manager proxies all abstract methods, ensuring seamless switching.

## Future Extensions
- **Non-Python Plugins**: Full FFI loading (e.g., Rust backends via pyo3).
- **Configuration Validation**: Schema validation for backend configs.
- **Load Balancing**: Auto-switch based on query type/performance.
- **Homomorphic/ZKP Integration**: Backends can opt-in for encrypted queries.

## Status
✅ Implemented. Extensible for FFI, ready for security features (Homomorphic Encryption, ZKP) in other backends.

Last updated: 2025-09-25
