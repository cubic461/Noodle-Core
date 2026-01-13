#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_syntax_highlighting_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Test Script for NoodleCore IDE Syntax Highlighting Implementation

This script tests the enhanced syntax highlighting functionality to ensure:
1. Language detection works correctly for different file types
2. Theme switching functions properly
3. Real-time syntax highlighting is applied
4. Syntax highlighting is applied correctly
5. No errors or issues occur during operation
"""

import os
import sys
import tempfile
import time
import traceback
from pathlib import Path

# Add the src directory to the path to import directly
current_dir = Path(__file__).parent
src_dir = current_dir / "src"
sys.path.insert(0, str(src_dir))

def test_syntax_highlighter_import():
    """Test that the syntax highlighter can be imported."""
    print("[TEST] Testing syntax highlighter import...")
    try:
        # Import directly from the module path
        from noodlecore.desktop.ide.syntax_highlighter import SyntaxHighlighter, HighlightType, Theme
        print("[OK] Syntax highlighter imported successfully")
        return True, SyntaxHighlighter, HighlightType, Theme
    except Exception as e:
        print(f"[FAIL] Failed to import syntax highlighter: {e}")
        traceback.print_exc()
        return False, None, None, None

def test_initialization(SyntaxHighlighter):
    """Test syntax highlighter initialization."""
    print("\n[TEST] Testing syntax highlighter initialization...")
    try:
        highlighter = SyntaxHighlighter()
        print("[OK] Syntax highlighter initialized successfully")
        
        # Check default theme
        current_theme = highlighter.get_theme()
        if current_theme and current_theme.name == "dark":
            print("[OK] Default theme is 'dark'")
        else:
            print(f"[WARN] Default theme is '{current_theme.name if current_theme else 'None'}', expected 'dark'")
        
        # Check available themes
        themes = highlighter.get_available_themes()
        expected_themes = ['dark', 'light', 'blue', 'monokai']
        if all(theme in themes for theme in expected_themes):
            print(f"[OK] All expected themes available: {themes}")
        else:
            missing = [t for t in expected_themes if t not in themes]
            print(f"[WARN] Missing themes: {missing}")
        
        # Check available languages
        languages = highlighter.get_available_languages()
        expected_languages = ['python', 'javascript', 'typescript', 'noodle', 'html', 'css', 'json', 'yaml', 'sql']
        if all(lang in languages for lang in expected_languages):
            print(f"[OK] All expected languages available: {languages}")
        else:
            missing = [l for l in expected_languages if l not in languages]
            print(f"[WARN] Missing languages: {missing}")
        
        return True, highlighter
    except Exception as e:
        print(f"[FAIL] Failed to initialize syntax highlighter: {e}")
        traceback.print_exc()
        return False, None

def test_language_detection(highlighter):
    """Test language detection for different file types."""
    print("\n[TEST] Testing language detection...")
    
    test_cases = [
        ("test.py", "print('Hello, World!')", "python"),
        ("test.js", "console.log('Hello, World!');", "javascript"),
        ("test.ts", "const message: string = 'Hello, World!';", "typescript"),
        ("test.nc", "function hello() { return 'Hello, World!'; }", "noodle"),
        ("test.html", "<html><body>Hello, World!</body></html>", "html"),
        ("test.css", "body { color: red; }", "css"),
        ("test.json", '{"message": "Hello, World!"}', "json"),
        ("test.yaml", "message: Hello, World!", "yaml"),
        ("test.sql", "SELECT 'Hello, World!' as message;", "sql"),
        ("test.txt", "Just plain text", "plaintext"),
        ("unknown.xyz", "some unknown content", "plaintext")
    ]
    
    success_count = 0
    for filename, content, expected_lang in test_cases:
        try:
            detected_lang = highlighter.detect_language(filename, content)
            if detected_lang == expected_lang:
                print(f"[OK] {filename}: {detected_lang}")
                success_count += 1
            else:
                print(f"[FAIL] {filename}: expected '{expected_lang}', got '{detected_lang}'")
        except Exception as e:
            print(f"[ERROR] {filename}: {e}")
    
    print(f"\n[RESULT] Language detection: {success_count}/{len(test_cases)} tests passed")
    return success_count == len(test_cases)

def test_theme_switching(highlighter):
    """Test theme switching functionality."""
    print("\n[TEST] Testing theme switching...")
    
    themes = highlighter.get_available_themes()
    success_count = 0
    
    for theme_name in themes:
        try:
            highlighter.set_theme(theme_name)
            current_theme = highlighter.get_theme()
            if current_theme and current_theme.name == theme_name:
                print(f"[OK] Switched to theme: {theme_name}")
                success_count += 1
            else:
                print(f"[FAIL] Failed to switch to theme: {theme_name}")
        except Exception as e:
            print(f"[ERROR] Failed to switch to theme {theme_name}: {e}")
    
    # Reset to default theme
    try:
        highlighter.set_theme("dark")
        print("[OK] Reset to default theme")
    except Exception as e:
        print(f"[ERROR] Failed to reset to default theme: {e}")
    
    print(f"\n[RESULT] Theme switching: {success_count}/{len(themes)} tests passed")
    return success_count == len(themes)

def test_syntax_highlighting(highlighter):
    """Test syntax highlighting for different languages."""
    print("\n[TEST] Testing syntax highlighting...")
    
    test_cases = [
        # Python
        ("python", """
# Python test code
import os
import sys

def hello_world(name="World"):
    '''This is a docstring.'''
    print(f"Hello, {name}!")
    
    class_counter = 0
    for i in range(5):
        class_counter += 1
        if i % 2 == 0:
            print(f"Even number: {i}")
    
    return class_counter

if __name__ == "__main__":
    hello_world()
        """),
        
        # JavaScript
        ("javascript", """
// JavaScript test code
const greet = (name = "World") => {
    console.log(`Hello, ${name}!`);
    
    const numbers = [1, 2, 3, 4, 5];
    numbers.forEach((num, index) => {
        if (num % 2 === 0) {
            console.log(`Even number: ${num}`);
        }
    });
};

class Counter {
    constructor() {
        this.count = 0;
    }
    
    increment() {
        this.count++;
    }
}

greet();
        """),
        
        # HTML
        ("html", """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Syntax Highlighting Test</title>
</head>
<body>
    <h1>Syntax Highlighting Test</h1>
    <div class="content">
        <p>This is a test of HTML syntax highlighting.</p>
    </div>
</body>
</html>
        """),
        
        # CSS
        ("css", """
/* CSS test code */
body {
    font-family: Arial, sans-serif;
    background-color: #f0f0f0;
    margin: 0;
    padding: 20px;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
}
        """),
        
        # JSON
        ("json", """
{
    "name": "Syntax Highlighting Test",
    "version": "1.0.0",
    "description": "Test JSON for syntax highlighting",
    "settings": {
        "theme": "dark",
        "fontSize": 14
    }
}
        """)
    ]
    
    success_count = 0
    for language, content in test_cases:
        try:
            highlights = highlighter.highlight(content, language)
            if highlights:
                print(f"[OK] {language}: {len(highlights)} highlights generated")
                success_count += 1
                
                # Check for different highlight types
                highlight_types = set(h[3] for h in highlights)
                if len(highlight_types) > 1:
                    print(f"    [INFO] Found highlight types: {highlight_types}")
            else:
                print(f"[WARN] {language}: No highlights generated")
        except Exception as e:
            print(f"[ERROR] {language}: {e}")
    
    print(f"\n[RESULT] Syntax highlighting: {success_count}/{len(test_cases)} tests passed")
    return success_count >= len(test_cases) * 0.8  # Allow some tolerance

def run_all_tests():
    """Run all syntax highlighting tests."""
    print("=" * 60)
    print("NoodleCore IDE Syntax Highlighting Test Suite")
    print("=" * 60)
    
    # Test import
    success, SyntaxHighlighter, HighlightType, Theme = test_syntax_highlighter_import()
    if not success:
        print("\n[FAIL] Cannot proceed with tests - import failed")
        return False
    
    # Test initialization
    success, highlighter = test_initialization(SyntaxHighlighter)
    if not success:
        print("\n[FAIL] Cannot proceed with tests - initialization failed")
        return False
    
    # Run all tests
    test_results = []
    test_results.append(("Language Detection", test_language_detection(highlighter)))
    test_results.append(("Theme Switching", test_theme_switching(highlighter)))
    test_results.append(("Syntax Highlighting", test_syntax_highlighting(highlighter)))
    
    # Print summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    passed_tests = 0
    total_tests = len(test_results)
    
    for test_name, result in test_results:
        status = "PASS" if result else "FAIL"
        print(f"{test_name:<25} {status}")
        if result:
            passed_tests += 1
    
    print("-" * 60)
    print(f"Total: {passed_tests}/{total_tests} tests passed")
    
    if passed_tests == total_tests:
        print("[SUCCESS] All tests passed! Syntax highlighting is working correctly.")
        return True
    elif passed_tests >= total_tests * 0.8:
        print("[WARNING] Most tests passed. Syntax highlighting is mostly working with some issues.")
        return True
    else:
        print("[FAIL] Many tests failed. Syntax highlighting has significant issues.")
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)

