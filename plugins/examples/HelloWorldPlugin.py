"""
HelloWorldPlugin - A comprehensive example plugin for NIP v3.0.0

This plugin demonstrates all the key features of the NIP plugin system:
- Plugin metadata definition
- Lifecycle hooks (initialize, enable, disable, cleanup)
- Tool registration and implementation
- Provider registration
- Guard registration
- Hook registration for event handling
- Configuration management
- Inter-plugin communication
- Logging and error handling
"""

from plugins.plugin_base import (
    Plugin, 
    PluginMetadata, 
    PluginContext
)
from typing import List, Dict, Any


class HelloWorldPlugin(Plugin):
    """
    A demonstration plugin that showcases all NIP plugin features.
    
    This plugin provides:
    - A simple greeting tool
    - A name provider
    - An input guard
    - Event hooks for lifecycle monitoring
    """
    
    def __init__(self):
        # Define plugin metadata
        metadata = PluginMetadata(
            name="hello_world",
            version="1.0.0",
            description="A comprehensive example plugin demonstrating all NIP features",
            author="NIP Development Team",
            plugin_type="tool",
            dependencies=[],
            min_nip_version="3.0.0",
            permissions=[],
            tags=["example", "demo", "tutorial"],
            homepage="https://github.com/nip/hello-world-plugin",
            repository="https://github.com/nip/hello-world-plugin",
            license="MIT"
        )
        
        # Initialize parent class
        super().__init__(metadata)
        
        # Plugin state
        self.greeting_count = 0
        self.default_greeting = "Hello"
    
    # ========== Lifecycle Methods ==========
    
    def initialize(self):
        """Called when the plugin is loaded."""
        self.log_info("🚀 HelloWorldPlugin is initializing...")
        
        # Load configuration
        self.default_greeting = self.get_config("greeting", "Hello")
        self.log_info(f"Default greeting set to: {self.default_greeting}")
        
        # Initialize shared state
        self.set_shared_state("hello_world_initialized", True)
        self.set_shared_state("hello_world_start_time", self._get_timestamp())
        
        self.log_info("✅ HelloWorldPlugin initialized successfully!")
    
    def enable(self):
        """Called when the plugin is enabled."""
        self.enabled = True
        self.log_info("🔓 HelloWorldPlugin enabled")
        self.emit_custom_event("plugin_enabled", {"plugin": "hello_world"})
    
    def disable(self):
        """Called when the plugin is disabled."""
        self.enabled = False
        self.log_info("🔒 HelloWorldPlugin disabled")
        self.emit_custom_event("plugin_disabled", {"plugin": "hello_world"})
    
    def cleanup(self):
        """Called before the plugin is unloaded."""
        self.log_info(f"🧹 Cleaning up HelloWorldPlugin...")
        self.log_info(f"📊 Total greetings served: {self.greeting_count}")
        
        # Clean up shared state
        if self.context:
            self.context.shared_state.pop("hello_world_initialized", None)
            self.context.shared_state.pop("hello_world_start_time", None)
        
        self.log_info("✨ Cleanup complete!")
    
    # ========== Tool Registration ==========
    
    def register_tools(self) -> List[Dict[str, Any]]:
        """Register plugin tools."""
        return [
            {
                "name": "hello",
                "description": "Say hello to someone",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "name": {
                            "type": "string",
                            "description": "Name of the person to greet"
                        },
                        "greeting": {
                            "type": "string",
                            "description": "Custom greeting (optional)"
                        }
                    },
                    "required": ["name"]
                },
                "function": self.hello_tool
            },
            {
                "name": "hello_stats",
                "description": "Get plugin usage statistics",
                "parameters": {
                    "type": "object",
                    "properties": {},
                    "required": []
                },
                "function": self.hello_stats_tool
            },
            {
                "name": "hello_broadcast",
                "description": "Broadcast a greeting to multiple recipients",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "names": {
                            "type": "array",
                            "items": {"type": "string"},
                            "description": "List of names to greet"
                        },
                        "message": {
                            "type": "string",
                            "description": "Custom message template"
                        }
                    },
                    "required": ["names"]
                },
                "function": self.hello_broadcast_tool
            }
        ]
    
    def register_providers(self) -> List[Dict[str, Any]]:
        """Register plugin providers."""
        return [
            {
                "name": "greeting_provider",
                "description": "Provides greeting data and suggestions",
                "function": self.greeting_provider
            }
        ]
    
    def register_guards(self) -> List[Dict[str, Any]]:
        """Register plugin guards."""
        return [
            {
                "name": "name_validator",
                "description": "Validates names before processing",
                "function": self.name_validator_guard
            }
        ]
    
    def register_hooks(self) -> List[Dict[str, Any]]:
        """Register event hooks."""
        return [
            {
                "event": "before_tool_execution",
                "handler": self.before_tool_execution_hook
            },
            {
                "event": "after_tool_execution",
                "handler": self.after_tool_execution_hook
            },
            {
                "event": "plugin_loaded",
                "handler": self.plugin_loaded_hook
            }
        ]
    
    # ========== Tool Implementations ==========
    
    def hello_tool(self, name: str, greeting: str = None) -> Dict[str, Any]:
        """
        Say hello to someone.
        
        Args:
            name: Name of the person to greet
            greeting: Optional custom greeting
            
        Returns:
            Dictionary with greeting result
        """
        try:
            # Use custom greeting or default
            greeting_word = greeting or self.default_greeting
            
            # Create greeting message
            message = f"{greeting_word}, {name}!"
            
            # Update counter
            self.greeting_count += 1
            
            # Log the greeting
            self.log_info(f"Greeting #{self.greeting_count}: {message}")
            
            # Return success result
            return {
                "success": True,
                "message": message,
                "count": self.greeting_count,
                "plugin": "hello_world"
            }
        
        except Exception as e:
            self.log_error(f"Error in hello_tool: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "plugin": "hello_world"
            }
    
    def hello_stats_tool(self) -> Dict[str, Any]:
        """
        Get plugin usage statistics.
        
        Returns:
            Dictionary with usage statistics
        """
        start_time = self.get_shared_state("hello_world_start_time", "Unknown")
        
        return {
            "success": True,
            "stats": {
                "greeting_count": self.greeting_count,
                "default_greeting": self.default_greeting,
                "enabled": self.enabled,
                "start_time": start_time
            },
            "plugin": "hello_world"
        }
    
    def hello_broadcast_tool(self, names: List[str], message: str = None) -> Dict[str, Any]:
        """
        Broadcast a greeting to multiple recipients.
        
        Args:
            names: List of names to greet
            message: Optional custom message template
            
        Returns:
            Dictionary with broadcast results
        """
        try:
            if not isinstance(names, list):
                return {
                    "success": False,
                    "error": "names must be a list"
                }
            
            results = []
            template = message or "{greeting}, {name}!"
            
            for name in names:
                greeting_msg = template.format(
                    greeting=self.default_greeting,
                    name=name
                )
                results.append({
                    "name": name,
                    "message": greeting_msg
                })
                self.greeting_count += 1
            
            self.log_info(f"Broadcast to {len(names)} recipients")
            
            return {
                "success": True,
                "results": results,
                "total_recipients": len(names),
                "plugin": "hello_world"
            }
        
        except Exception as e:
            self.log_error(f"Error in hello_broadcast_tool: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "plugin": "hello_world"
            }
    
    # ========== Provider Implementation ==========
    
    def greeting_provider(self, request: str = "suggestions") -> Dict[str, Any]:
        """
        Provide greeting-related data.
        
        Args:
            request: Type of data requested
            
        Returns:
            Dictionary with greeting data
        """
        greetings_data = {
            "suggestions": ["Hello", "Hi", "Hey", "Greetings", "Welcome"],
            "formal": ["Good morning", "Good afternoon", "Good evening"],
            "casual": ["Hiya", "Hey there", "What's up"],
            "international": ["Hola", "Bonjour", "Ciao", "Hallo"]
        }
        
        if request == "all":
            return greetings_data
        elif request in greetings_data:
            return {request: greetings_data[request]}
        else:
            return {"suggestions": greetings_data["suggestions"]}
    
    # ========== Guard Implementation ==========
    
    def name_validator_guard(self, name: str) -> tuple[bool, str]:
        """
        Validate names before processing.
        
        Args:
            name: Name to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not name or not isinstance(name, str):
            return False, "Name must be a non-empty string"
        
        if len(name) > 100:
            return False, "Name is too long (max 100 characters)"
        
        if any(char.isspace() for char in name) and len(name.split()) > 5:
            return False, "Name has too many words (max 5)"
        
        return True, ""
    
    # ========== Hook Implementations ==========
    
    def before_tool_execution_hook(self, data: Dict[str, Any]):
        """Called before any tool execution."""
        tool_name = data.get("tool_name", "unknown")
        self.log_debug(f"About to execute tool: {tool_name}")
    
    def after_tool_execution_hook(self, data: Dict[str, Any]):
        """Called after any tool execution."""
        tool_name = data.get("tool_name", "unknown")
        result = data.get("result", {})
        
        if result.get("success"):
            self.log_debug(f"Tool {tool_name} executed successfully")
        else:
            self.log_warning(f"Tool {tool_name} execution failed")
    
    def plugin_loaded_hook(self, data: Dict[str, Any]):
        """Called when another plugin is loaded."""
        plugin_name = data.get("plugin_name", "unknown")
        self.log_info(f"Another plugin detected: {plugin_name}")
    
    # ========== Utility Methods ==========
    
    def emit_custom_event(self, event_name: str, data: Dict[str, Any]):
        """
        Emit a custom event through the context.
        
        Args:
            event_name: Name of the event
            data: Event data
        """
        if self.context:
            self.context.emit_event(event_name, data)
    
    def _get_timestamp(self) -> str:
        """Get current timestamp as ISO string."""
        from datetime import datetime
        return datetime.utcnow().isoformat() + "Z"


# Plugin factory function
def create_plugin() -> HelloWorldPlugin:
    """Factory function to create the plugin instance."""
    return HelloWorldPlugin()


# Allow direct execution for testing
if __name__ == "__main__":
    print("HelloWorldPlugin - NIP v3.0.0 Example Plugin")
    print("=" * 50)
    
    plugin = HelloWorldPlugin()
    
    print(f"\nPlugin Name: {plugin.metadata.name}")
    print(f"Version: {plugin.metadata.version}")
    print(f"Type: {plugin.metadata.plugin_type}")
    print(f"Description: {plugin.metadata.description}")
    print(f"Author: {plugin.metadata.author}")
    
    # Simulate lifecycle
    plugin.initialize()
    plugin.enable()
    
    # Test tools
    print("\n" + "=" * 50)
    print("Testing hello_tool:")
    result = plugin.hello_tool("World")
    print(f"Result: {result}")
    
    print("\n" + "=" * 50)
    print("Testing hello_stats_tool:")
    stats = plugin.hello_stats_tool()
    print(f"Stats: {stats}")
    
    print("\n" + "=" * 50)
    print("Testing hello_broadcast_tool:")
    broadcast = plugin.hello_broadcast_tool(["Alice", "Bob", "Charlie"])
    print(f"Broadcast: {broadcast}")
    
    # Cleanup
    plugin.disable()
    plugin.cleanup()
    
    print("\n" + "=" * 50)
    print("✅ All tests passed!")
