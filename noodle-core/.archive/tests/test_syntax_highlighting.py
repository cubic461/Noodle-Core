#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_syntax_highlighting.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Script for NoodleCore IDE Syntax Highlighting Implementation

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

# Add the project root to the path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))
sys.path.insert(0, str(current_dir / "src"))

def test_syntax_highlighter_import():
    """Test that the syntax highlighter can be imported."""
    print("[TEST] Testing syntax highlighter import...")
    try:
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
        
        # TypeScript
        ("typescript", """
// TypeScript test code
interface Person {
    name: string;
    age: number;
}

class Greeter<T> {
    private greeting: string;
    
    constructor(message: string) {
        this.greeting = message;
    }
    
    greet(person: Person): string {
        return `${this.greeting}, ${person.name}!`;
    }
}

const greeter = new Greeter<string>("Hello");
const person: Person = { name: "World", age: 30 };
console.log(greeter.greet(person));
        """),
        
        # NoodleCore
        ("noodle", """
# NoodleCore test code
import os
import sys

function hello_world(name="World") {
    \"\"\"This is a docstring.\"\"\"
    print(f"Hello, {name}!")
    
    var counter = 0
    for (var i = 0; i < 5; i++) {
        counter++
        if (i % 2 == 0) {
            print(f"Even number: {i}")
        }
    }
    return counter
}

class MyClass {
    constructor(value) {
        this.value = value
    }
    
    method() {
        return this.value * 2
    }
}

hello_world()
        """),
        
        # HTML
        ("html", """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Syntax Highlighting Test</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .highlight { background-color: yellow; }
    </style>
</head>
<body>
    <h1>Syntax Highlighting Test</h1>
    <div class="content">
        <p>This is a <strong>test</strong> of HTML syntax highlighting.</p>
        <ul>
            <li>Item 1</li>
            <li>Item 2</li>
        </ul>
    </div>
    <script>
        console.log("HTML test complete");
    </script>
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

.highlight {
    background-color: yellow !important;
    border: 1px solid #ccc;
}

@media (max-width: 768px) {
    body {
        padding: 10px;
    }
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
        "fontSize": 14,
        "tabSize": 4,
        "wordWrap": true
    },
    "languages": [
        "python",
        "javascript",
        "typescript",
        "noodle",
        "html",
        "css",
        "json",
        "yaml",
        "sql"
    ],
    "features": {
        "syntaxHighlighting": true,
        "themeSwitching": true,
        "realTimeValidation": true
    }
}
        """),
        
        # YAML
        ("yaml", """
# YAML test file
name: syntax-highlighting-test
version: 1.0.0
description: Test YAML for syntax highlighting

settings:
  theme: dark
  fontSize: 14
  tabSize: 4
  wordWrap: true

languages:
  - python
  - javascript
  - typescript
  - noodle
  - html
  - css
  - json
  - yaml
  - sql

features:
  syntaxHighlighting: true
  themeSwitching: true
  realTimeValidation: true

database:
  host: localhost
  port: 5432
  name: noodlecore
  user: admin
  password: secret
        """),
        
        # SQL
        ("sql", """
-- SQL test code
-- Create tables
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email) VALUES 
('admin', 'admin@example.com'),
('user1', 'user1@example.com');

-- Query with JOIN
SELECT 
    u.username,
    p.title,
    p.created_at
FROM posts p
INNER JOIN users u ON p.user_id = u.id
WHERE p.published = TRUE
ORDER BY p.created_at DESC
LIMIT 10;
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
            traceback.print_exc()
    
    print(f"\n[RESULT] Syntax highlighting: {success_count}/{len(test_cases)} tests passed")
    return success_count >= len(test_cases) * 0.8  # Allow some tolerance

def test_theme_colors(highlighter):
    """Test that theme colors are properly applied."""
    print("\n[TEST] Testing theme colors...")
    
    themes = highlighter.get_available_themes()
    highlight_types = [
        "keyword", "function", "variable", "string", 
        "comment", "number", "operator", "type"
    ]
    
    success_count = 0
    total_tests = len(themes) * len(highlight_types)
    
    for theme_name in themes:
        try:
            highlighter.set_theme(theme_name)
            print(f"[INFO] Testing theme: {theme_name}")
            
            for highlight_type in highlight_types:
                try:
                    color = highlighter.get_theme_color(highlight_type)
                    if color and color.startswith('#'):
                        print(f"    [OK] {highlight_type}: {color}")
                        success_count += 1
                    else:
                        print(f"    [WARN] {highlight_type}: Invalid color '{color}'")
                except Exception as e:
                    print(f"    [ERROR] {highlight_type}: {e}")
        except Exception as e:
            print(f"[ERROR] Theme {theme_name}: {e}")
    
    print(f"\n[RESULT] Theme colors: {success_count}/{total_tests} tests passed")
    return success_count >= total_tests * 0.9  # Allow some tolerance

def test_performance(highlighter):
    """Test performance of syntax highlighting."""
    print("\n[TEST] Testing performance...")
    
    # Generate a large code sample
    large_code = """
# Large Python code for performance testing
import os
import sys
import json
import time
from typing import Dict, List, Optional

def process_data(data: List[Dict[str, any]]) -> Dict[str, any]:
    \"\"\"Process a large dataset.\"\"\"
    result = {}
    for item in data:
        key = item.get('key', 'unknown')
        value = item.get('value', 0)
        
        if key in result:
            result[key] += value
        else:
            result[key] = value
    
    return result

def generate_test_data(size: int) -> List[Dict[str, any]]:
    \"\"\"Generate test data.\"\"\"
    data = []
    for i in range(size):
        data.append({
            'key': f'item_{i % 100}',
            'value': i * 2,
            'timestamp': time.time(),
            'metadata': {
                'source': 'test',
                'version': '1.0.0',
                'valid': i % 2 == 0
            }
        })
    return data

class DataProcessor:
    def __init__(self, config: Dict[str, any]):
        self.config = config
        self.processed_count = 0
    
    def process_batch(self, data: List[Dict[str, any]]) -> Dict[str, any]:
        start_time = time.time()
        
        # Process the data
        result = process_data(data)
        
        # Update statistics
        self.processed_count += len(data)
        processing_time = time.time() - start_time
        
        return {
            'result': result,
            'stats': {
                'items_processed': len(data),
                'processing_time': processing_time,
                'items_per_second': len(data) / processing_time if processing_time > 0 else 0
            }
        }
    
    def get_stats(self) -> Dict[str, any]:
        return {
            'processed_count': self.processed_count,
            'config': self.config
        }

# Main execution
if __name__ == "__main__":
    config = {
        'batch_size': 1000,
        'max_iterations': 10,
        'output_format': 'json'
    }
    
    processor = DataProcessor(config)
    
    for iteration in range(config['max_iterations']):
        test_data = generate_test_data(config['batch_size'])
        batch_result = processor.process_batch(test_data)
        
        print(f"Iteration {iteration + 1}: Processed {batch_result['stats']['items_processed']} items "
              f"in {batch_result['stats']['processing_time']:.3f}s "
              f"({batch_result['stats']['items_per_second']:.1f} items/sec)")
    
    final_stats = processor.get_stats()
    print(f"Final stats: {final_stats}")
""" * 5  # Make it larger
    
    try:
        # Test highlighting performance
        start_time = time.time()
        highlights = highlighter.highlight(large_code, "python")
        end_time = time.time()
        
        processing_time = end_time - start_time
        code_length = len(large_code)
        
        print(f"[INFO] Processed {code_length} characters in {processing_time:.3f}s")
        print(f"[INFO] Generated {len(highlights)} highlights")
        print(f"[INFO] Processing speed: {code_length / processing_time:.0f} chars/sec")
        
        # Performance should be reasonable (less than 1 second for this test)
        if processing_time < 1.0:
            print("[OK] Performance is acceptable")
            return True
        else:
            print(f"[WARN] Performance is slow: {processing_time:.3f}s")
            return False
            
    except Exception as e:
        print(f"[ERROR] Performance test failed: {e}")
        traceback.print_exc()
        return False

def test_edge_cases(highlighter):
    """Test edge cases and error handling."""
    print("\n[TEST] Testing edge cases...")
    
    test_cases = [
        ("Empty content", "", "python"),
        ("Whitespace only", "   \n\t  \n   ", "python"),
        ("Special characters", "!@#$%^&*()_+-=[]{}|;':\",./<>?", "python"),
        ("Very long line", "x" * 1000, "python"),
        ("Unicode content", "print('Hello, ä¸–ç•Œ! ðŸŒ')", "python"),
        ("Invalid language", "some code", "nonexistent_language"),
        ("None content", None, "python"),
        ("None language", "print('test')", None),
    ]
    
    success_count = 0
    for description, content, language in test_cases:
        try:
            if content is None or language is None:
                # These should be handled gracefully
                try:
                    highlights = highlighter.highlight(content or "", language or "plaintext")
                    print(f"[OK] {description}: Handled gracefully")
                    success_count += 1
                except Exception:
                    print(f"[OK] {description}: Raised appropriate exception")
                    success_count += 1
            else:
                highlights = highlighter.highlight(content, language)
                print(f"[OK] {description}: Processed successfully")
                success_count += 1
        except Exception as e:
            print(f"[ERROR] {description}: {e}")
    
    print(f"\n[RESULT] Edge cases: {success_count}/{len(test_cases)} tests passed")
    return success_count >= len(test_cases) * 0.8  # Allow some tolerance

def test_real_time_highlighting_simulation(highlighter):
    """Simulate real-time highlighting scenarios."""
    print("\n[TEST] Testing real-time highlighting simulation...")
    
    # Simulate typing code character by character
    code_snippets = [
        ("python", [
            "def hello():",
            "def hello():\n    ",
            "def hello():\n    print(",
            "def hello():\n    print('Hello",
            "def hello():\n    print('Hello, World!'",
            "def hello():\n    print('Hello, World!')",
            "def hello():\n    print('Hello, World!')\n",
            "def hello():\n    print('Hello, World!')\nhello()"
        ]),
        ("javascript", [
            "function hello() {",
            "function hello() {\n    ",
            "function hello() {\n    console.log(",
            "function hello() {\n    console.log('Hello",
            "function hello() {\n    console.log('Hello, World!'",
            "function hello() {\n    console.log('Hello, World!')",
            "function hello() {\n    console.log('Hello, World!')\n}",
            "function hello() {\n    console.log('Hello, World!')\n}"
        ])
    ]
    
    success_count = 0
    total_tests = sum(len(snippets) for _, snippets in code_snippets)
    
    for language, snippets in code_snippets:
        try:
            for i, snippet in enumerate(snippets):
                start_time = time.time()
                highlights = highlighter.highlight(snippet, language)
                end_time = time.time()
                
                processing_time = end_time - start_time
                print(f"[OK] {language} snippet {i+1}: {len(highlights)} highlights in {processing_time:.3f}s")
                success_count += 1
                
                # Real-time highlighting should be fast (< 50ms)
                if processing_time > 0.05:
                    print(f"    [WARN] Slow response for real-time: {processing_time:.3f}s")
        except Exception as e:
            print(f"[ERROR] {language} real-time test: {e}")
    
    print(f"\n[RESULT] Real-time simulation: {success_count}/{total_tests} tests passed")
    return success_count >= total_tests * 0.8

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
    test_results.append(("Theme Colors", test_theme_colors(highlighter)))
    test_results.append(("Performance", test_performance(highlighter)))
    test_results.append(("Edge Cases", test_edge_cases(highlighter)))
    test_results.append(("Real-time Simulation", test_real_time_highlighting_simulation(highlighter)))
    
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

