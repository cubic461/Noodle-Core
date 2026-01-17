# NIP v3.0.0 Plugin System

Welcome to the NIP (Noodle Intelligence Platform) Plugin System! This guide will help you create, publish, and share plugins for NIP v3.0.0.

## 📋 Table of Contents

- [Introduction](#introduction)
- [Plugin Types](#plugin-types)
- [Quick Start](#quick-start)
- [Plugin API](#plugin-api)
- [Advanced Features](#advanced-features)
- [Publishing Plugins](#publishing-plugins)
- [Best Practices](#best-practices)
- [Examples](#examples)

## 🎯 Introduction

The NIP Plugin System allows developers to extend NIP's functionality by creating custom plugins that integrate seamlessly with the platform. Plugins can add tools, providers, guards, and hooks.

### Key Features

- **Hot Loading**: Load/unload plugins without restarting NIP
- **Version Management**: Compatible with semantic versioning
- **Dependency Resolution**: Automatic dependency handling
- **Sandboxed Execution**: Safe plugin isolation
- **Marketplace Integration**: Easy sharing and discovery

## 🔌 Plugin Types

### 1. Tool Plugins
Extend NIP's capabilities by adding new tools and commands.

**Use Cases:**
- Custom data processors
- External API integrations
- Specialized analyzers
- Custom formatters

### 2. Provider Plugins
Provide data or services to other plugins and the core system.

**Use Cases:**
- Data source connectors
- Authentication providers
- Storage backends
- Message queues

### 3. Guard Plugins
Add validation, security, and policy enforcement.

**Use Cases:**
- Input validation
- Access control
- Rate limiting
- Content filtering

### 4. Hook Plugins
React to system events and lifecycle changes.

**Use Cases:**
- Logging and monitoring
- Notifications
- State synchronization
- Custom triggers

## 🚀 Quick Start

### Installation

1. Create a new plugin file:
```bash
# Navigate to plugins directory
cd C:/Users/micha/Noodle/plugins/examples

# Create your plugin
touch MyFirstPlugin.py
```

2. Extend the base Plugin class:
```python
from plugins.plugin_base import Plugin, PluginMetadata

class MyFirstPlugin(Plugin):
    def __init__(self):
        metadata = PluginMetadata(
            name="my_first_plugin",
            version="1.0.0",
            description="My first NIP plugin",
            author="Your Name",
            plugin_type="tool"
        )
        super().__init__(metadata)
    
    def initialize(self):
        """Called when plugin is loaded"""
        self.log_info("MyFirstPlugin initialized!")
    
    def register_tools(self):
        """Register custom tools"""
        return [
            {
                "name": "hello_world",
                "description": "Say hello to the world",
                "function": self.hello_world
            }
        ]
    
    def hello_world(self, name="World"):
        return f"Hello, {name}!"
```

3. Load your plugin:
```python
from plugins.plugin_base import PluginLoader

loader = PluginLoader()
plugin = loader.load_plugin("plugins/examples/MyFirstPlugin.py")
```

## 📚 Plugin API

### PluginMetadata

```python
@dataclass
class PluginMetadata:
    name: str                    # Unique plugin identifier
    version: str                 # Semantic version (e.g., "1.0.0")
    description: str             # Human-readable description
    author: str                  # Plugin author
    plugin_type: str             # "tool", "provider", "guard", "hook"
    dependencies: List[str]      # List of required plugins
    min_nip_version: str         # Minimum NIP version required
    permissions: List[str]       # Required permissions
    tags: List[str]              # Searchable tags
    homepage: str = ""           # Plugin homepage URL
    repository: str = ""         # Source repository URL
    license: str = "MIT"         # License type
```

### Base Plugin Class

```python
class Plugin:
    def __init__(self, metadata: PluginMetadata):
        self.metadata = metadata
        self.enabled = True
        self.context = None
    
    # Lifecycle hooks
    def initialize(self):
        """Called when plugin is loaded"""
        pass
    
    def enable(self):
        """Called when plugin is enabled"""
        self.enabled = True
    
    def disable(self):
        """Called when plugin is disabled"""
        self.enabled = False
    
    def cleanup(self):
        """Called before plugin is unloaded"""
        pass
    
    # Registration methods (override these)
    def register_tools(self) -> List[dict]:
        """Register tool plugins"""
        return []
    
    def register_providers(self) -> List[dict]:
        """Register provider plugins"""
        return []
    
    def register_guards(self) -> List[dict]:
        """Register guard plugins"""
        return []
    
    def register_hooks(self) -> List[dict]:
        """Register hook plugins"""
        return []
    
    # Utility methods
    def log_info(self, message: str):
        """Log info message"""
        pass
    
    def log_error(self, message: str):
        """Log error message"""
        pass
    
    def get_config(self, key: str, default=None):
        """Get plugin configuration value"""
        pass
    
    def set_config(self, key: str, value):
        """Set plugin configuration value"""
        pass
```

## 🔧 Advanced Features

### Configuration

Plugins can access configuration through the context:

```python
def initialize(self):
    api_key = self.get_config("api_key", "default_key")
    self.log_info(f"Configured with API key: {api_key}")
```

### Dependencies

Specify dependencies in metadata:

```python
metadata = PluginMetadata(
    name="my_plugin",
    version="1.0.0",
    dependencies=["another_plugin>=1.0.0", "utils_plugin>=2.0.0"]
)
```

### Event Hooks

Register event handlers:

```python
def register_hooks(self):
    return [
        {
            "event": "before_tool_execution",
            "handler": self.before_tool_execution
        },
        {
            "event": "after_tool_execution",
            "handler": self.after_tool_execution
        }
    ]

def before_tool_execution(self, tool_name, args):
    self.log_info(f"Executing tool: {tool_name}")
    # Modify args or veto execution
    return args
```

### Tool Definitions

Define tools with schemas:

```python
def register_tools(self):
    return [
        {
            "name": "analyze_data",
            "description": "Analyze input data",
            "parameters": {
                "type": "object",
                "properties": {
                    "data": {
                        "type": "string",
                        "description": "Data to analyze"
                    },
                    "options": {
                        "type": "object",
                        "description": "Analysis options"
                    }
                },
                "required": ["data"]
            },
            "function": self.analyze_data
        }
    ]
```

## 📦 Publishing Plugins

### Plugin Structure

```
my_plugin/
├── README.md              # Documentation
├── plugin.py              # Main plugin code
├── requirements.txt       # Python dependencies
├── config.json           # Default configuration
└── tests/                # Unit tests
    └── test_plugin.py
```

### Validation Checklist

- [ ] Plugin extends `Plugin` base class
- [ ] All required metadata fields provided
- [ ] Dependencies are specified
- [ ] Tools have proper schemas
- [ ] Error handling implemented
- [ ] Documentation complete
- [ ] Tests passing
- [ ] License specified

### Publishing Process

1. **Validate Plugin**
```bash
python scripts/publish_plugin.py validate plugins/MyPlugin
```

2. **Test Plugin**
```bash
python scripts/publish_plugin.py test plugins/MyPlugin
```

3. **Publish to Marketplace**
```bash
python scripts/publish_plugin.py publish plugins/MyPlugin
```

See `scripts/publish_plugin.py` for details.

### Marketplace Format

```json
{
  "plugins": [
    {
      "id": "unique_plugin_id",
      "name": "Plugin Name",
      "version": "1.0.0",
      "description": "Plugin description",
      "author": "Author Name",
      "type": "tool",
      "url": "https://github.com/user/repo",
      "downloads": 1000,
      "rating": 4.5,
      "tags": ["utility", "productivity"],
      "dependencies": [],
      "min_nip_version": "3.0.0",
      "license": "MIT",
      "verified": true,
      "last_updated": "2026-01-17T18:00:00Z"
    }
  ]
}
```

## 💡 Best Practices

### 1. Keep It Simple
- Focus on a single responsibility
- Avoid overly complex logic
- Document everything

### 2. Error Handling
```python
def my_tool(self, input_data):
    try:
        result = self.process(input_data)
        return {"success": True, "data": result}
    except Exception as e:
        self.log_error(f"Error processing: {str(e)}")
        return {"success": False, "error": str(e)}
```

### 3. Resource Management
```python
def initialize(self):
    self.connection = self.create_connection()

def cleanup(self):
    if self.connection:
        self.connection.close()
```

### 4. Version Compatibility
- Use semantic versioning
- Document breaking changes
- Test with multiple NIP versions

### 5. Security
- Validate all inputs
- Use secure defaults
- Don't expose sensitive data
- Request minimal permissions

### 6. Performance
- Cache expensive operations
- Use async I/O when possible
- Avoid blocking operations
- Profile your code

### 7. Testing
```python
def test_my_tool():
    plugin = MyPlugin()
    plugin.initialize()
    result = plugin.my_tool("test")
    assert result["success"] == True
    plugin.cleanup()
```

## 📖 Examples

See the `plugins/examples/` directory for complete working examples:

- **HelloWorldPlugin.py**: Simple demonstration plugin
- **AnalysisPlugin.py**: Code analysis tool plugin

## 🤝 Community

- **Issues**: Report bugs and request features
- **Discussions**: Ask questions and share ideas
- **Contributions**: Pull requests welcome

## 📄 License

This plugin system is part of NIP v3.0.0 and follows the same license.

---

**Happy Plugin Development! 🎉**

For questions or support, please refer to the examples or open an issue.
