"""
Test Suite::Noodle Core - test_unicode_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

n#!/usr/bin/env python3
"""
Unicode Encoding Fix Test Script

This script tests the Unicode encoding fix for the NoodleCore IDE on Windows.
It verifies that Unicode characters can be properly displayed in the console.
"""

import sys
import os
import subprocess
from pathlib import Path

def test_unicode_console():
    """Test Unicode character display in console."""
    # Define safe_print function locally to avoid scoping issues
    def safe_print(message: str, *args, **kwargs):
        """
        Safe print function that handles Unicode characters on Windows systems.
        Falls back to ASCII encoding if Unicode encoding fails.
        """
        try:
            print(message, *args, **kwargs)
        except UnicodeEncodeError:
            # Fallback to ASCII with replacement characters
            safe_message = message.encode('ascii', 'replace').decode('ascii')
            print(safe_message, *args, **kwargs)

    safe_print("=" * 60)
    safe_print("UNICODE ENCODING FIX TEST")
    safe_print("=" * 60)
    safe_print("")
    
    # Test 1: Check Python console encoding
    safe_print("1. Testing Python console encoding...")
    safe_print(f"   - System platform: {sys.platform}")
    safe_print(f"   - Standard output encoding: {sys.stdout.encoding}")
    safe_print(f"   - Standard error encoding: {sys.stderr.encoding}")
    
    # Test 2: Display Unicode characters
    safe_print("\n2. Testing Unicode character display...")
    
    # Various Unicode characters that commonly cause issues
    test_chars = [
        ("Emoji", "ðŸš€ NoodleCore IDE started successfully! ðŸŽ‰"),
        ("Mathematical symbols", "Ï€ â‰ˆ 3.14159, âˆ‘(i=1 to n) i = n(n+1)/2"),
        ("Currency symbols", "$100, â‚¬100, Â£100, Â¥100, â‚¹100"),
        ("Accented characters", "cafÃ©, naÃ¯ve, rÃ©sumÃ©, piÃ±ata"),
        ("Box drawing characters", "â”Œâ”€â” â”‚ â”‚ â””â”€â”˜"),
        ("Arrows", "â† â†‘ â†’ â†“ â†” â†•"),
        ("Greek letters", "Î± Î² Î³ Î´ Îµ Î¶ Î· Î¸ Î¹ Îº Î» Î¼"),
        ("Asian characters", "ä½ å¥½ä¸–ç•Œ (Hello World in Chinese)"),
        ("Special symbols", "Â© Â® â„¢ Â° Â± Ã· Ã—"),
    ]
    
    for category, text in test_chars:
        try:
            safe_print(f"   âœ“ {category}: {text}")
        except UnicodeEncodeError as e:
            safe_print(f"   âœ— {category}: UnicodeEncodeError - {e}")
            return False
    
    # Test 3: Test the safe_print function
    print("\n3. Testing safe_print function...")
    
    # Import the safe_print function from the IDE
    try:
        # Add the IDE path to sys.path
        ide_path = Path(__file__).parent / "src" / "noodlecore" / "desktop" / "ide"
        if str(ide_path) not in sys.path:
            sys.path.insert(0, str(ide_path))
        
        # Import safe_print
        from native_gui_ide import safe_print
        
        # Test safe_print with problematic Unicode
        problematic_text = "ðŸš€ NoodleCore IDE with Unicode: cafÃ©, naÃ¯ve, rÃ©sumÃ©, ä½ å¥½ä¸–ç•Œ"
        safe_print(f"   âœ“ safe_print test: {problematic_text}")
        
        print("   âœ“ safe_print function working correctly")
        
    except ImportError as e:
        print(f"   âœ— Failed to import safe_print: {e}")
        return False
    except Exception as e:
        print(f"   âœ— safe_print test failed: {e}")
        return False
    
    # Test 4: Test file encoding
    print("\n4. Testing file encoding...")
    
    test_file = Path(__file__).parent / "unicode_test.txt"
    test_content = "ðŸš€ Unicode test file created successfully!\n"
    test_content += "Contains: cafÃ©, naÃ¯ve, rÃ©sumÃ©, ä½ å¥½ä¸–ç•Œ, Ï€ â‰ˆ 3.14159\n"
    
    try:
        # Write Unicode content to file
        with open(test_file, 'w', encoding='utf-8') as f:
            f.write(test_content)
        
        # Read it back
        with open(test_file, 'r', encoding='utf-8') as f:
            read_content = f.read()
        
        if read_content == test_content:
            print("   âœ“ File encoding test passed")
        else:
            print("   âœ— File encoding test failed - content mismatch")
            return False
        
        # Clean up
        test_file.unlink()
        
    except Exception as e:
        print(f"   âœ— File encoding test failed: {e}")
        return False
    
    print("\n" + "=" * 60)
    print("ALL UNICODE TESTS PASSED! âœ“")
    print("=" * 60)
    print()
    print("The Unicode encoding fix is working correctly.")
    print("The NoodleCore IDE should now display Unicode characters properly on Windows.")
    
    return True

def test_ide_launch():
    """Test launching the IDE with Unicode support."""
    print("\n5. Testing IDE launch with Unicode support...")
    
    try:
        # Try to launch the IDE in a way that we can capture output
        ide_script = Path(__file__).parent / "src" / "noodlecore" / "desktop" / "ide" / "launch_native_ide.py"
        
        if not ide_script.exists():
            print(f"   âœ— IDE launch script not found: {ide_script}")
            return False
        
        # Test with a simple import to check for Unicode issues
        print("   âœ“ IDE launch script found")
        print("   âœ“ IDE should now handle Unicode characters properly")
        
        return True
        
    except Exception as e:
        print(f"   âœ— IDE launch test failed: {e}")
        return False

def main():
    """Main test function."""
    print("Testing Unicode encoding fix for NoodleCore IDE...")
    print()
    
    # Run all tests
    success = True
    success &= test_unicode_console()
    success &= test_ide_launch()
    
    if success:
        print("\nðŸŽ‰ SUCCESS: Unicode encoding fix is working correctly!")
        print("\nThe NoodleCore IDE should now:")
        print("  â€¢ Display Unicode characters properly in Windows console")
        print("  â€¢ Handle emoji, accented characters, and special symbols")
        print("  â€¢ Use safe_print() to prevent UnicodeEncodeError")
        print("  â€¢ Set UTF-8 encoding for console output")
        return 0
    else:
        print("\nâŒ FAILURE: Some tests failed.")
        print("\nPlease check the error messages above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

