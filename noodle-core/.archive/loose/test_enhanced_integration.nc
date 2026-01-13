# Test file for enhanced syntax fixer integration

# This file contains various syntax issues to test the enhanced fixer

def test_function() {
    # Missing semicolon
    print("Hello World")
    
    # Unclosed string
    print("This is a test
    
    # Invalid syntax
    let x = 5 + = 3
    
    # Another issue
    if x > 5 {
        print("x is greater than 5")
    else {
        print("x is not greater than 5")
    # Missing closing brace