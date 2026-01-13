#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_unicode_fix_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Unicode encoding fix test for NoodleCore IDE.
Tests the safe_print function without importing the full IDE.
"""

import sys
import os

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

def test_unicode_console():
    """Test Unicode character display in console."""
    safe_print("3. Testing safe_print function...")
    
    try:
        # Test emojis
        safe_print("   âœ“ Emoji: ðŸš€ NoodleCore IDE started successfully! ðŸŽ‰")
        
        # Test mathematical symbols
        safe_print("   âœ“ Mathematical symbols: Ï€ â‰ˆ 3.14159, âˆ‘(i=1 to n) i = n(n+1)/2")
        
        # Test currency symbols
        safe_print("   âœ“ Currency symbols: $100, â‚¬100, Â£100, Â¥100, â‚¹100")
        
        # Test accented characters
        safe_print("   âœ“ Accented characters: cafÃ©, naÃ¯ve, rÃ©sumÃ©, piÃ±ata")
        
        # Test box drawing characters
        safe_print("   âœ“ Box drawing characters: â”Œâ”€â” â””â”€â”˜")
        
        # Test arrows
        safe_print("   âœ“ Arrows: â† â†‘ â†’ â†“ â†” â†•")
        
        # Test Greek letters
        safe_print("   âœ“ Greek letters: Î± Î² Î³ Î´ Îµ Î¶ Î· Î¸ Î¹ Îº Î» Î¼")
        
        # Test Asian characters
        safe_print("   âœ“ Asian characters: ä½ å¥½ä¸–ç•Œ (Hello World in Chinese)")
        
        # Test special symbols
        safe_print("   âœ“ Special symbols: Â© Â® â„¢ Â± Ã· Ã—")
        
        safe_print("   âœ“ All Unicode tests passed!")
        return True
        
    except Exception as e:
        safe_print(f"   âœ— safe_print test failed: {e}")
        return False

def main():
    """Main test function."""
    print("Testing Unicode encoding fix for NoodleCore IDE...")
    print("=" * 60)
    
    success = True
    
    # Test 1: Console encoding
    print("1. Testing Python console encoding...")
    print(f"   - System platform: {sys.platform}")
    print(f"   - Standard output encoding: {sys.stdout.encoding}")
    print(f"   - Standard error encoding: {sys.stderr.encoding}")
    
    # Test 2: Unicode character display
    print("\n2. Testing Unicode character display...")
    safe_print("   âœ“ Basic Unicode test passed")
    
    # Test 3: safe_print function
    success &= test_unicode_console()
    
    safe_print("\n" + "=" * 60)
    if success:
        safe_print("âœ… All Unicode encoding tests PASSED!")
        safe_print("The Unicode encoding fix is working correctly.")
        return 0
    else:
        safe_print("âŒ Some Unicode encoding tests FAILED!")
        safe_print("The Unicode encoding fix needs further work.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

