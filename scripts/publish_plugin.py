#!/usr/bin/env python3
"""
NIP v3.0.0 Plugin Publisher

This script handles the validation, testing, and publishing of plugins
to the NIP plugin marketplace.

Usage:
    python publish_plugin.py validate <plugin_path>
    python publish_plugin.py test <plugin_path>
    python publish_plugin.py publish <plugin_path>
    python publish_plugin.py list
    python publish_plugin.py search <query>
"""

import sys
import os
import json
import ast
import argparse
from pathlib import Path
from typing import Dict, List, Any, Tuple
from datetime import datetime


class PluginPublisher:
    """Handles plugin validation, testing, and publishing."""
    
    def __init__(self, marketplace_path: str = None):
        """
        Initialize the plugin publisher.
        
        Args:
            marketplace_path: Path to marketplace.json file
        """
        if marketplace_path is None:
            # Default to plugins/marketplace.json in the NIP directory
            script_dir = Path(__file__).parent
            marketplace_path = script_dir.parent / "plugins" / "marketplace.json"
        
        self.marketplace_path = Path(marketplace_path)
        self.marketplace = self._load_marketplace()
    
    def _load_marketplace(self) -> Dict[str, Any]:
        """Load the marketplace registry."""
        if not self.marketplace_path.exists():
            return {
                "version": "1.0.0",
                "last_updated": datetime.utcnow().isoformat() + "Z",
                "total_plugins": 0,
                "categories": [],
                "plugins": [],
                "statistics": {
                    "total_downloads": 0,
                    "total_plugins": 0,
                    "official_plugins": 0,
                    "community_plugins": 0,
                    "featured_plugins": 0,
                    "average_rating": 0.0
                },
                "metadata": {
                    "format_version": "1.0",
                    "nip_version": "3.0.0",
                    "supported_nip_versions": ["3.0.0"]
                }
            }
        
        with open(self.marketplace_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def _save_marketplace(self):
        """Save the marketplace registry."""
        self.marketplace["last_updated"] = datetime.utcnow().isoformat() + "Z"
        
        # Update statistics
        self._update_statistics()
        
        with open(self.marketplace_path, 'w', encoding='utf-8') as f:
            json.dump(self.marketplace, f, indent=2, ensure_ascii=False)
    
    def _update_statistics(self):
        """Update marketplace statistics."""
        plugins = self.marketplace.get("plugins", [])
        
        total_downloads = sum(p.get("downloads", 0) for p in plugins)
        official_count = sum(1 for p in plugins if p.get("official", False))
        community_count = sum(1 for p in plugins if not p.get("official", False))
        featured_count = sum(1 for p in plugins if p.get("featured", False))
        
        ratings = [p.get("rating", 0) for p in plugins if p.get("rating", 0) > 0]
        avg_rating = sum(ratings) / len(ratings) if ratings else 0.0
        
        self.marketplace["total_plugins"] = len(plugins)
        self.marketplace["statistics"] = {
            "total_downloads": total_downloads,
            "total_plugins": len(plugins),
            "official_plugins": official_count,
            "community_plugins": community_count,
            "featured_plugins": featured_count,
            "average_rating": round(avg_rating, 2)
        }
    
    def validate(self, plugin_path: str) -> Tuple[bool, List[str], List[str]]:
        """
        Validate a plugin.
        
        Args:
            plugin_path: Path to plugin file or directory
            
        Returns:
            Tuple of (is_valid, errors, warnings)
        """
        errors = []
        warnings = []
        
        path = Path(plugin_path)
        
        # Check if path exists
        if not path.exists():
            return False, [f"Path does not exist: {plugin_path}"], []
        
        # Determine if it's a file or directory
        if path.is_file():
            plugin_file = path
        else:
            # Look for main plugin file
            plugin_file = None
            for file in path.glob("*.py"):
                if file.name != "__init__.py":
                    plugin_file = file
                    break
            
            if plugin_file is None:
                return False, ["No plugin file found in directory"], []
        
        # Read plugin file
        try:
            with open(plugin_file, 'r', encoding='utf-8') as f:
                code = f.read()
        except Exception as e:
            return False, [f"Error reading file: {str(e)}"], []
        
        # Parse Python file
        try:
            tree = ast.parse(code)
        except SyntaxError as e:
            return False, [f"Syntax error: {e.msg} at line {e.lineno}"], []
        
        # Find Plugin class
        plugin_class = None
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef):
                # Check if it inherits from Plugin
                for base in node.bases:
                    base_name = None
                    if isinstance(base, ast.Name):
                        base_name = base.id
                    elif isinstance(base, ast.Attribute):
                        base_name = base.attr
                    
                    if base_name == "Plugin":
                        plugin_class = node
                        break
        
        if plugin_class is None:
            errors.append("No class found that inherits from Plugin base class")
            return False, errors, warnings
        
        # Check for required methods
        required_methods = ["initialize", "enable", "disable", "cleanup"]
        found_methods = []
        
        for item in plugin_class.body:
            if isinstance(item, ast.FunctionDef):
                found_methods.append(item.name)
        
        for method in required_methods:
            if method not in found_methods:
                warnings.append(f"Missing recommended method: {method}()")
        
        # Check for registration methods
        registration_methods = ["register_tools", "register_providers", 
                               "register_guards", "register_hooks"]
        
        if not any(method in found_methods for method in registration_methods):
            warnings.append("Plugin doesn't register any tools, providers, guards, or hooks")
        
        # Check for metadata
        has_metadata = False
        for item in plugin_class.body:
            if isinstance(item, ast.FunctionDef) and item.name == "__init__":
                # Look for PluginMetadata in __init__
                for node in ast.walk(item):
                    if isinstance(node, ast.Call):
                        if isinstance(node.func, ast.Name):
                            if node.func.id == "PluginMetadata":
                                has_metadata = True
                                break
        
        if not has_metadata:
            warnings.append("PluginMetadata not found in __init__ - plugin may not work correctly")
        
        # Check for README
        readme_path = path.parent / "README.md" if path.is_file() else path / "README.md"
        if not readme_path.exists():
            warnings.append("No README.md found - plugins should have documentation")
        
        return (len(errors) == 0, errors, warnings)
    
    def test(self, plugin_path: str) -> Tuple[bool, str]:
        """
        Test a plugin by loading and running basic tests.
        
        Args:
            plugin_path: Path to plugin file
            
        Returns:
            Tuple of (success, output)
        """
        try:
            # Add parent directory to path
            path = Path(plugin_path)
            if path.is_file():
                parent_dir = path.parent
            else:
                parent_dir = path
            
            # Try to import plugin_base
            sys.path.insert(0, str(parent_dir.parent))
            
            from plugins.plugin_base import PluginLoader
            
            # Try to load plugin
            loader = PluginLoader()
            
            if path.is_file():
                plugin = loader.load_plugin(str(path))
            else:
                # Find plugin file in directory
                plugin_file = None
                for file in path.glob("*.py"):
                    if file.name != "__init__.py":
                        plugin_file = file
                        break
                
                if plugin_file is None:
                    return False, "No plugin file found"
                
                plugin = loader.load_plugin(str(plugin_file))
            
            if plugin is None:
                return False, "Failed to load plugin"
            
            # Run basic tests
            output = []
            output.append(f"✅ Plugin loaded successfully")
            output.append(f"   Name: {plugin.metadata.name}")
            output.append(f"   Version: {plugin.metadata.version}")
            output.append(f"   Type: {plugin.metadata.plugin_type}")
            output.append(f"   Description: {plugin.metadata.description}")
            output.append(f"   Author: {plugin.metadata.author}")
            
            # Check registered components
            tools = plugin.register_tools()
            providers = plugin.register_providers()
            guards = plugin.register_guards()
            hooks = plugin.register_hooks()
            
            output.append(f"\n📦 Registered Components:")
            output.append(f"   Tools: {len(tools)}")
            for tool in tools:
                output.append(f"      - {tool.get('name', 'unnamed')}: {tool.get('description', '')}")
            
            output.append(f"   Providers: {len(providers)}")
            for provider in providers:
                output.append(f"      - {provider.get('name', 'unnamed')}: {provider.get('description', '')}")
            
            output.append(f"   Guards: {len(guards)}")
            for guard in guards:
                output.append(f"      - {guard.get('name', 'unnamed')}: {guard.get('description', '')}")
            
            output.append(f"   Hooks: {len(hooks)}")
            for hook in hooks:
                output.append(f"      - {hook.get('event', 'unnamed')}")
            
            # Cleanup
            plugin.cleanup()
            
            return True, "\n".join(output)
        
        except Exception as e:
            return False, f"Error testing plugin: {str(e)}"
    
    def publish(self, plugin_path: str, metadata: Dict[str, Any] = None) -> Tuple[bool, str]:
        """
        Publish a plugin to the marketplace.
        
        Args:
            plugin_path: Path to plugin file
            metadata: Optional additional metadata
            
        Returns:
            Tuple of (success, message)
        """
        try:
            # Validate first
            is_valid, errors, warnings = self.validate(plugin_path)
            
            if not is_valid:
                return False, f"Validation failed:\n" + "\n".join(errors)
            
            if warnings:
                print(f"⚠️  Warnings:\n" + "\n".join(warnings))
            
            # Load plugin to get metadata
            path = Path(plugin_path)
            if path.is_file():
                plugin_file = path
            else:
                for file in path.glob("*.py"):
                    if file.name != "__init__.py":
                        plugin_file = file
                        break
            
            # Import and load plugin
            sys.path.insert(0, str(plugin_file.parent.parent))
            from plugins.plugin_base import PluginLoader
            
            loader = PluginLoader()
            plugin = loader.load_plugin(str(plugin_file))
            
            if plugin is None:
                return False, "Failed to load plugin"
            
            # Create marketplace entry
            entry = {
                "id": f"{plugin.metadata.name}-plugin",
                "name": plugin.metadata.name.replace("_", " ").title(),
                "version": plugin.metadata.version,
                "description": plugin.metadata.description,
                "long_description": metadata.get("long_description", plugin.metadata.description) if metadata else plugin.metadata.description,
                "author": plugin.metadata.author,
                "author_email": metadata.get("author_email", "") if metadata else "",
                "type": plugin.metadata.plugin_type,
                "categories": metadata.get("categories", plugin.metadata.tags) if metadata else plugin.metadata.tags,
                "url": metadata.get("url", "") if metadata else "",
                "download_url": metadata.get("download_url", "") if metadata else "",
                "homepage": metadata.get("homepage", plugin.metadata.homepage) if metadata else plugin.metadata.homepage,
                "repository": metadata.get("repository", plugin.metadata.repository) if metadata else plugin.metadata.repository,
                "documentation": metadata.get("documentation", "") if metadata else "",
                "bugs": metadata.get("bugs", "") if metadata else "",
                "downloads": 0,
                "stars": 0,
                "rating": 0.0,
                "rating_count": 0,
                "tags": plugin.metadata.tags,
                "dependencies": plugin.metadata.dependencies,
                "min_nip_version": plugin.metadata.min_nip_version,
                "license": plugin.metadata.license,
                "verified": False,
                "featured": False,
                "official": False,
                "install_count": 0,
                "created_at": datetime.utcnow().isoformat() + "Z",
                "updated_at": datetime.utcnow().isoformat() + "Z",
                "tools": [
                    {
                        "name": tool.get("name", ""),
                        "description": tool.get("description", "")
                    }
                    for tool in plugin._tools
                ]
            }
            
            # Check if plugin already exists
            existing = None
            for i, p in enumerate(self.marketplace.get("plugins", [])):
                if p.get("id") == entry["id"]:
                    existing = i
                    break
            
            if existing is not None:
                # Update existing plugin
                self.marketplace["plugins"][existing].update(entry)
                self.marketplace["plugins"][existing]["updated_at"] = datetime.utcnow().isoformat() + "Z"
                message = f"✅ Plugin '{entry['name']}' updated successfully in marketplace!"
            else:
                # Add new plugin
                self.marketplace["plugins"].append(entry)
                message = f"✅ Plugin '{entry['name']}' published successfully to marketplace!"
            
            # Save marketplace
            self._save_marketplace()
            
            # Cleanup
            plugin.cleanup()
            
            return True, message
        
        except Exception as e:
            return False, f"Error publishing plugin: {str(e)}"
    
    def list_plugins(self) -> str:
        """List all plugins in the marketplace."""
        plugins = self.marketplace.get("plugins", [])
        
        if not plugins:
            return "No plugins in marketplace"
        
        output = [f"\n📦 NIP Plugin Marketplace ({len(plugins)} plugins)\n"]
        
        for plugin in plugins:
            featured = "⭐ " if plugin.get("featured") else ""
            official = "🔹 " if plugin.get("official") else ""
            rating = f"{'⭐' * int(plugin.get('rating', 0))} ({plugin.get('rating', 0):.1f})" if plugin.get('rating') > 0 else "No ratings"
            downloads = plugin.get("downloads", 0)
            
            output.append(f"{featured}{official}{plugin['name']} v{plugin['version']}")
            output.append(f"   {plugin['description']}")
            output.append(f"   Author: {plugin.get('author', 'Unknown')}")
            output.append(f"   Rating: {rating} | Downloads: {downloads:,}")
            output.append(f"   Type: {plugin.get('type', 'tool')} | License: {plugin.get('license', 'Unknown')}")
            output.append("")
        
        return "\n".join(output)
    
    def search(self, query: str) -> str:
        """Search for plugins in the marketplace."""
        plugins = self.marketplace.get("plugins", [])
        query_lower = query.lower()
        
        results = []
        for plugin in plugins:
            # Search in name, description, tags, author
            if (query_lower in plugin.get("name", "").lower() or
                query_lower in plugin.get("description", "").lower() or
                query_lower in plugin.get("long_description", "").lower() or
                any(query_lower in tag.lower() for tag in plugin.get("tags", [])) or
                query_lower in plugin.get("author", "").lower()):
                results.append(plugin)
        
        if not results:
            return f"No plugins found matching '{query}'"
        
        output = [f"\n🔍 Found {len(results)} plugins matching '{query}':\n"]
        
        for plugin in results:
            featured = "⭐ " if plugin.get("featured") else ""
            rating = f"{plugin.get('rating', 0):.1f}" if plugin.get('rating') > 0 else "N/A"
            
            output.append(f"{featured}{plugin['name']} v{plugin['version']} (⭐ {rating})")
            output.append(f"   {plugin['description']}")
            output.append(f"   Tags: {', '.join(plugin.get('tags', []))}")
            output.append("")
        
        return "\n".join(output)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="NIP Plugin Publisher - Validate, test, and publish plugins"
    )
    parser.add_argument(
        "action",
        choices=["validate", "test", "publish", "list", "search"],
        help="Action to perform"
    )
    parser.add_argument(
        "path",
        nargs="?",
        help="Path to plugin file or directory (for validate, test, publish)"
    )
    parser.add_argument(
        "--marketplace",
        help="Path to marketplace.json file",
        default=None
    )
    parser.add_argument(
        "-y", "--yes",
        action="store_true",
        help="Auto-confirm prompts"
    )
    
    args = parser.parse_args()
    
    publisher = PluginPublisher(args.marketplace)
    
    if args.action == "validate":
        if not args.path:
            print("❌ Error: path required for validation")
            return 1
        
        is_valid, errors, warnings = publisher.validate(args.path)
        
        if is_valid:
            print("✅ Plugin validation passed!")
            if warnings:
                print("\n⚠️  Warnings:")
                for warning in warnings:
                    print(f"   - {warning}")
            return 0
        else:
            print("❌ Plugin validation failed!")
            print("\nErrors:")
            for error in errors:
                print(f"   - {error}")
            return 1
    
    elif args.action == "test":
        if not args.path:
            print("❌ Error: path required for testing")
            return 1
        
        success, output = publisher.test(args.path)
        print(output)
        return 0 if success else 1
    
    elif args.action == "publish":
        if not args.path:
            print("❌ Error: path required for publishing")
            return 1
        
        if not args.yes:
            response = input(f"Publish plugin at '{args.path}' to marketplace? [y/N] ")
            if response.lower() != 'y':
                print("Cancelled")
                return 1
        
        success, message = publisher.publish(args.path)
        print(message)
        return 0 if success else 1
    
    elif args.action == "list":
        output = publisher.list_plugins()
        print(output)
        return 0
    
    elif args.action == "search":
        if not args.path:
            print("❌ Error: search query required")
            return 1
        
        output = publisher.search(args.path)
        print(output)
        return 0
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
