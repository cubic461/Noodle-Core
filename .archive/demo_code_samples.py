"""
Noodle::Demo Code Samples - demo_code_samples.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore LSP Server - Demo Code Samples
These files will be used for the demo video recording
"""

# ============================================================================
# FILE 1: main.py (for auto-completion and go-to-definition demos)
# ============================================================================

import os
import sys
from utils import helper
from data_processor import DataProcessor


class MainApplication:
    """Main application class for demo purposes"""
    
    def __init__(self):
        self.config = self.load_config()
        self.processor = DataProcessor()
    
    def load_config(self):
        """Load configuration settings"""
        # Show auto-completion after 'os.path.'
        config_path = os.path.join(os.getcwd(), "config.json")
        
        # More auto-completion examples
        files = os.listdir(os.path.dirname(__file__))
        
        return {"path": config_path, "files": files}
    
    def process_data(self, input_data):
        """Process input data using helper functions"""
        # Go-to-definition target (F12 here)
        total = helper.calculate_total([1, 2, 3, 4, 5])
        
        # Go-to-definition target (F12 here)
        processed = helper.advanced_calculation(input_data, multiplier=2)
        
        return total, processed
    
    def run_pattern_matching(self):
        """Demo pattern matching features"""
        data = {"type": "user", "name": "Alice", "role": "admin"}
        
        # Pattern matching completion demo
        match data:
            case {"type": "user", "name": str(name)}:
                print(f"User: {name}")
            case {"type": "admin", "permissions": [*perms]} if len(perms) > 5:
                print(f"Admin with elevated permissions")
            case {"type": _, **rest}:
                print(f"Unknown type with data: {rest}")
            case _:
                print("No match found")


def fibonacci_sequence():
    """Calculate fibonacci sequence - AI generation demo"""
    # Start comment for AI to complete:
    # Generate fibonacci function that takes n and returns the nth fibonacci number
    
    pass  # AI should generate the implementation


if __name__ == "__main__":
    app = MainApplication()
    
    # Demo: Error diagnostics
    # Syntax error below (missing closing bracket)
    sample_data = [1, 2, 3  # â† Error squiggle should appear here
    
    # After fixing, show this working
    result = app.process_data(sample_data)
    print(f"Processing result: {result}")
    
    # Run pattern matching demo
    app.run_pattern_matching()


# ============================================================================
# FILE 2: utils/helper.py (for go-to-definition demo)
# ============================================================================

def calculate_total(numbers):
    """
    Calculate the total sum of numbers.
    
    Args:
        numbers: List of numeric values
        
    Returns:
        Sum of all numbers
    """
    return sum(numbers)


def advanced_calculation(data, multiplier=1):
    """
    Perform advanced calculation with optional multiplier.
    
    Args:
        data: Input data to process
        multiplier: Multiplication factor
        
    Returns:
        Processed result
    """
    if isinstance(data, (list, tuple)):
        return [item * multiplier for item in data]
    else:
        return data * multiplier


def string_utilities():
    """String manipulation utilities"""
    # Auto-completion examples
    text = "Hello NoodleCore LSP Server"
    
    # Show string method completion
    upper_text = text.upper()
    split_result = text.split()
    
    return upper_text, split_result


# ============================================================================
# FILE 3: data_processor.py (for pattern matching demo)
# ============================================================================

class DataProcessor:
    """Advanced data processor with pattern matching"""
    
    def __init__(self):
        self.cache = {}
    
    def process_complex_pattern(self, data):
        """
        Process complex data patterns using match statements.
        """
        match data:
            # Pattern 1: Simple dictionary
            case {"type": "create", "data": {"id": int(id), "name": str(name)}}:
                return self.create_item(id, name)
            
            # Pattern 2: List with specific structure
            case [{"action": "update", "payload": payload}, *rest]:
                return self.batch_update(payload, rest)
            
            # Pattern 3: Nested structures
            case {"user": {"profile": {"settings": {"theme": theme, **other_settings}}, **profile_data}, **user_data}:
                return self.update_user_theme(theme, other_settings)
            
            # Pattern 4: Guard conditions
            case {"type": "admin", "permissions": [*perms]} if len(perms) > 10:
                return self.grant_admin_access(perms)
            
            # Pattern 5: Default case
            case _:
                return self.default_processing(data)
    
    def create_item(self, id, name):
        """Create new item"""
        return {"status": "created", "id": id, "name": name}
    
    def batch_update(self, payload, remaining):
        """Batch update items"""
        return {"status": "batch_updated", "payload": payload, "remaining": len(remaining)}
    
    def update_user_theme(self, theme, settings):
        """Update user theme settings"""
        return {"action": "theme_updated", "theme": theme, "additional_settings": len(settings)}
    
    def grant_admin_access(self, permissions):
        """Grant admin access"""
        return {"access": "granted", "permission_count": len(permissions)}
    
    def default_processing(self, data):
        """Default data processing"""
        return {"status": "unknown", "data_type": type(data).__name__}


# ============================================================================
# FILE 4: fibonacci.py (for AI integration demo)
# ============================================================================

# Start with just this comment (AI will generate the function):
# Function to calculate the nth fibonacci number with caching optimization


# ============================================================================
# FILE 5: types.py (for type checking and completion demo)
# ============================================================================

from typing import List, Dict, Optional, Union, Tuple
from dataclasses import dataclass


@dataclass
class User:
    """User data model"""
    id: int
    name: str
    email: Optional[str]
    permissions: List[str]


@dataclass
class Admin(User):
    """Admin user with extended permissions"""
    role: str
    department: str


class UserManager:
    """User management system"""
    
    def __init__(self):
        self.users: Dict[int, User] = {}
        self.admins: List[Admin] = []
    
    def add_user(self, user: User) -> bool:
        """Add a new user"""
        if user.id in self.users:
            return False
        self.users[user.id] = user
        return True
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Find user by email address"""
        # Show completion for User attributes
        for user in self.users.values():
            if user.email == email:
                return user
        return None
    
    def promote_to_admin(self, user: User, role: str, department: str) -> Admin:
        """Promote user to admin role"""
        admin = Admin(
            id=user.id,
            name=user.name,
            email=user.email,
            permissions=user.permissions + ["admin"],
            role=role,
            department=department
        )
        self.admins.append(admin)
        return admin


# ============================================================================
# FILE 6: errors.py (for error diagnostics demo)
# ============================================================================

def function_with_errors():
    """This function contains intentional errors for demo"""
    
    # Missing import would cause error
    # import non_existent_module
    
    # Syntax error: unclosed bracket
    data = {
        "key1": "value1",
        "key2": "value2",
        # Missing closing bracket
    
    # Type error: operation on incompatible types
    result = "string" + 123
    
    # Undefined variable usage
    print(undefined_variable)
    
    # Attribute error: method doesn't exist
    text = "hello"
    text.non_existent_method()
    
    # Index error: accessing beyond list bounds
    my_list = [1, 2, 3]
    item = my_list[10]
    
    return data


def function_with_fix():
    """This function shows the fixes for above errors"""
    
    # Proper import
    import json
    
    # Fixed syntax
    data = {
        "key1": "value1",
        "key2": "value2",
    }
    
    # Fixed type conversion
    result = "string" + str(123)
    
    # Defined variable
    defined_variable = "I'm defined now!"
    print(defined_variable)
    
    # Correct method
    text = "hello"
    upper_text = text.upper()
    
    # Safe index access
    my_list = [1, 2, 3]
    item = my_list[0] if my_list else None
    
    return data


# ============================================================================
# Setup Commands for VS Code
# ============================================================================

"""
VS Code Settings for Demo:

1. Install NoodleCore LSP Extension:
   - Open Extensions view (Ctrl+Shift+X)
   - Search "NoodleCore LSP"
   - Install and enable

2. Configure Python Environment:
   - Create virtual environment: python -m venv venv
   - Activate: venv\Scripts\activate (Windows)
   - Install packages: pip install -r requirements.txt

3. Enable LSP Features:
   - Settings > Python > LSP: Enable
   - Settings > Python > IntelliSense: Enable
   - Settings > Python > Auto-complete: Enable

4. Set Theme:
   - File > Preferences > Color Theme
   - Select "Monokai Dimmed" or "Dark+"

5. Set Font:
   - Install Fira Code or JetBrains Mono
   - Settings > Font Family: "Fira Code"
   - Enable ligatures: "editor.fontLigatures": true
"""


