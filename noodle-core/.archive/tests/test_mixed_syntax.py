#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_mixed_syntax.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test mixed Python/NoodleCore syntax file
"""

from src.noodlecore.desktop.ide.noodlecore_syntax_fixer import NoodleCoreSyntaxFixer

# Create test content with mixed syntax
test_content = """# NoodleCore converted from Python
#!/usr/bin/env python3

func hello_world():
    println("Hello # from Python!")
    return "Hello World"

func calculate_sum(a, b):
    result = a + b
    var result = a + b
    return result

func main():
    println("Starting Python test script...")
    
    message = hello_world()
    var message = hello_world()
    
    sum_result = calculate_sum(5, 3)
    var sum_result = calculate_sum(5, 3)
    
    println("Python test script completed!")

if __name__ == "__main__":
    main()
"""

# Write test file
with open('test_mixed_syntax.nc', 'w') as f:
    f.write(test_content)

# Test the fixer
fixer = NoodleCoreSyntaxFixer()
result = fixer.fix_file('test_mixed_syntax.nc', create_backup=False)

print(f"Fixes applied: {result['fixes_applied']}")
for fix in result.get('fixes', []):
    print(f"  Line {fix['line']}: {fix['description']}")
    print(f"    Original: {fix['original']}")
    print(f"    Fixed: {fix['fixed']}")

