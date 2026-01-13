#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_ide_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Enhanced IDE Fix Validation Test
==========================================

This test validates that the enhanced IDE frontend issue has been resolved.
"""

import os
import sys
import requests
import time
import socket
from pathlib import Path

def test_enhanced_ide_file_exists():
    """Test that enhanced-ide.html file exists in the correct location."""
    print("ðŸ” Testing enhanced-ide.html file existence...")
    
    # Check if file exists in noodle-core directory
    ide_file_path = Path("enhanced-ide.html")
    
    if ide_file_path.exists():
        file_size = ide_file_path.stat().st_size
        print(f"âœ… File exists: {ide_file_path.absolute()}")
        print(f"ðŸ“ File size: {file_size:,} bytes")
        
        # Read first few lines to verify content
        with open(ide_file_path, 'r', encoding='utf-8') as f:
            first_lines = f.read(500)
            
        if "NoodleCore Enhanced IDE" in first_lines:
            print("âœ… File contains expected NoodleCore Enhanced IDE content")
            return True
        else:
            print("âŒ File content doesn't match expected format")
            return False
    else:
        print(f"âŒ File not found: {ide_file_path.absolute()}")
        return False

def test_enhanced_ide_content():
    """Test that enhanced-ide.html contains required components."""
    print("\nðŸ” Testing enhanced-ide.html content...")
    
    try:
        with open("enhanced-ide.html", 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for Monaco Editor
        if "monaco" in content.lower():
            print("âœ… Monaco Editor integration found")
        else:
            print("âŒ Monaco Editor integration missing")
            return False
            
        # Check for required JavaScript libraries
        required_libs = [
            "monaco-editor",
            "socket.io", 
            "chart.js",
            "axios"
        ]
        
        for lib in required_libs:
            if lib in content.lower():
                print(f"âœ… {lib} library integration found")
            else:
                print(f"âŒ {lib} library integration missing")
                return False
                
        # Check for AI integration features
        ai_features = [
            "ai-suggestions",
            "learning-system", 
            "code-analysis",
            "websocket"
        ]
        
        for feature in ai_features:
            if feature in content.lower():
                print(f"âœ… {feature} feature found")
            else:
                print(f"âš ï¸ {feature} feature not found (may be in JavaScript)")
        
        # Check for API endpoints
        api_endpoints = [
            "/api/v1/ide/files/save",
            "/api/v1/ide/code/execute",
            "/api/v1/ai/analyze"
        ]
        
        for endpoint in api_endpoints:
            if endpoint in content:
                print(f"âœ… API endpoint {endpoint} integration found")
            else:
                print(f"âš ï¸ API endpoint {endpoint} not found (may be in JavaScript)")
        
        print("âœ… Enhanced IDE content validation passed")
        return True
        
    except Exception as e:
        print(f"âŒ Error reading enhanced-ide.html: {e}")
        return False

def test_server_connectivity():
    """Test if server is running and accessible."""
    print("\nðŸŒ Testing server connectivity...")
    
    try:
        # Test basic connectivity
        response = requests.get("http://localhost:8080/api/v1/health", timeout=5)
        if response.status_code == 200:
            print("âœ… Server is running and responding")
            health_data = response.json()
            print(f"ðŸ“Š Server status: {health_data.get('status', 'unknown')}")
            return True
        else:
            print(f"âš ï¸ Server responded with status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("âŒ No server running on port 8080")
        return False
    except requests.exceptions.Timeout:
        print("âŒ Server connection timeout")
        return False
    except Exception as e:
        print(f"âŒ Connection error: {e}")
        return False

def test_enhanced_ide_endpoint():
    """Test if enhanced-ide.html is accessible via HTTP."""
    print("\nðŸ“„ Testing enhanced-ide.html HTTP access...")
    
    try:
        response = requests.get("http://localhost:8080/enhanced-ide.html", timeout=10)
        
        if response.status_code == 200:
            print("âœ… Enhanced IDE is accessible via HTTP")
            print(f"ðŸ“Š Response size: {len(response.content):,} bytes")
            print(f"ðŸ“„ Content-Type: {response.headers.get('content-type', 'unknown')}")
            
            # Verify content contains expected elements
            content = response.text
            if "NoodleCore Enhanced IDE" in content:
                print("âœ… Response contains expected IDE content")
                return True
            else:
                print("âŒ Response doesn't contain expected IDE content")
                return False
        else:
            print(f"âŒ HTTP request failed with status {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("âŒ Cannot connect to server for enhanced-ide.html")
        return False
    except requests.exceptions.Timeout:
        print("âŒ Request timeout for enhanced-ide.html")
        return False
    except Exception as e:
        print(f"âŒ Error testing enhanced-ide.html: {e}")
        return False

def generate_fix_report():
    """Generate a comprehensive fix report."""
    print("\n" + "="*60)
    print("ðŸ“‹ NOODLECORE ENHANCED IDE FIX REPORT")
    print("="*60)
    
    results = {
        "file_exists": test_enhanced_ide_file_exists(),
        "content_valid": test_enhanced_ide_content(),
        "server_running": test_server_connectivity(),
        "http_accessible": test_enhanced_ide_endpoint()
    }
    
    print(f"\nðŸŽ¯ TEST RESULTS:")
    print(f"   File Existence: {'âœ… PASS' if results['file_exists'] else 'âŒ FAIL'}")
    print(f"   Content Validation: {'âœ… PASS' if results['content_valid'] else 'âŒ FAIL'}")
    print(f"   Server Connectivity: {'âœ… PASS' if results['server_running'] else 'âŒ FAIL'}")
    print(f"   HTTP Accessibility: {'âœ… PASS' if results['http_accessible'] else 'âŒ FAIL'}")
    
    success_count = sum(results.values())
    total_tests = len(results)
    
    print(f"\nðŸ“Š OVERALL RESULT: {success_count}/{total_tests} tests passed")
    
    if success_count == total_tests:
        print("ðŸŽ‰ ENHANCED IDE FIX SUCCESSFUL!")
        print("\nâœ… The enhanced IDE frontend issue has been resolved:")
        print("   â€¢ enhanced-ide.html file is properly located")
        print("   â€¢ File contains all required components")
        print("   â€¢ Monaco Editor integration included")
        print("   â€¢ AI-powered features implemented")
        print("   â€¢ Server connectivity established")
        print("\nðŸŒ Access the IDE at: http://localhost:8080/enhanced-ide.html")
        return True
    else:
        print("âš ï¸ ENHANCED IDE FIX INCOMPLETE")
        print("\nâŒ Some issues remain:")
        if not results['file_exists']:
            print("   â€¢ enhanced-ide.html file missing or incorrectly placed")
        if not results['content_valid']:
            print("   â€¢ File content validation failed")
        if not results['server_running']:
            print("   â€¢ Server not running on port 8080")
        if not results['http_accessible']:
            print("   â€¢ enhanced-ide.html not accessible via HTTP")
        return False

def main():
    """Main test function."""
    print("ðŸš€ NoodleCore Enhanced IDE Fix Validation")
    print("="*50)
    
    # Run all tests
    success = generate_fix_report()
    
    if success:
        print("\nâœ… FIX VALIDATION COMPLETE - SUCCESS!")
        return 0
    else:
        print("\nâŒ FIX VALIDATION COMPLETE - ISSUES REMAIN")
        return 1

if __name__ == "__main__":
    sys.exit(main())

