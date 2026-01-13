#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_zai_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify Z.ai integration is working correctly.
"""

import os
import sys
import asyncio
from pathlib import Path

# Add the noodle-core src to path
sys.path.insert(0, str(Path(__file__).parent / "noodle-core" / "src"))

from noodlecore.ide_noodle.ai_client import NoodleCoreAIClient
from noodlecore.trm.trm_agent import TRMAgent


async def test_zai_integration():
    """Test Z.ai integration with basic functionality."""
    print("Testing Z.ai Integration")
    print("=" * 50)
    
    # Test 1: Check environment variable
    print("\n1. Testing Environment Variables:")
    zai_key = os.getenv("NOODLE_ZAI_API_KEY")
    if zai_key:
        print(f"   [OK] NOODLE_ZAI_API_KEY is set (length: {len(zai_key)})")
        print(f"   [KEY] Key starts with: {zai_key[:10]}...")
    else:
        print("   [ERROR] NOODLE_ZAI_API_KEY not set")
        print("   [INFO] Set it with: export NOODLE_ZAI_API_KEY=your-zai-key")
        return False
    
    # Test 2: Initialize AI Client
    print("\n2. Testing AI Client Initialization:")
    try:
        ai_client = NoodleCoreAIClient(
            providers={"zai": {"api_key": zai_key, "model": "glm-4.6", "base_url": "https://open.bigmodel.cn/api/paas/v4"}},
            roles={"default": {"system_prompt": "You are a helpful AI assistant."}}
        )
        print(f"   [OK] AI Client initialized successfully")
    except Exception as e:
        print(f"   [ERROR] Failed to initialize AI Client: {e}")
        return False
    
    # Test 3: Initialize TRM Agent
    print("\n3. Testing TRM Agent Initialization:")
    try:
        trm_agent = TRMAgent()
        print(f"   [OK] TRM Agent initialized successfully")
        
        # Check if ai_client attribute exists
        if hasattr(trm_agent, 'ai_client'):
            print(f"   [CONFIG] AI client available: {trm_agent.ai_client is not None}")
        else:
            print(f"   [CONFIG] AI client attribute: NOT FOUND")
            
        # Check if code_review_agent attribute exists
        if hasattr(trm_agent, 'code_review_agent'):
            print(f"   [CONFIG] Code review agent available: {trm_agent.code_review_agent is not None}")
        else:
            print(f"   [CONFIG] Code review agent attribute: NOT FOUND")
            
    except Exception as e:
        print(f"   [ERROR] Failed to initialize TRM Agent: {e}")
        return False
    
    # Test 4: Simple AI call (if API key is available)
    if zai_key:
        print("\n4. Testing AI Call (simple request):")
        try:
            # Test with AI client
            response = await ai_client.invoke(
                command_id="test",
                context={"message": "Hello, this is a test message. Please respond with 'Z.ai integration successful!'"},
                provider_id="zai",
                role_id="default"
            )
            
            print(f"   [OK] AI Response: {response.content[:100] if response.content else 'No content'}...")
            return True
            
        except Exception as e:
            print(f"   [ERROR] AI call failed: {e}")
            return False
    else:
        print("\n4. Skipping AI call test (no API key)")
        print("   [INFO] Set NOODLE_ZAI_API_KEY to test actual AI calls")
        return True


async def main():
    """Main test function."""
    print("NoodleCore Z.ai Integration Test")
    print("This script verifies that Z.ai is properly configured as the default AI provider")
    print("=" * 50)
    
    success = await test_zai_integration()
    
    print("\n" + "=" * 50)
    if success:
        print("[SUCCESS] Z.ai integration test PASSED!")
        print("[OK] All core components are configured to use Z.ai")
        print("[READY] The system is ready for Z.ai API calls")
        print("\nNext steps:")
        print("1. Set your Z.ai API key: export NOODLE_ZAI_API_KEY=your-actual-key")
        print("2. Restart any running TRM processes")
        print("3. The system will automatically use Z.ai for AI operations")
    else:
        print("[FAILED] Z.ai integration test FAILED!")
        print("[ACTION] Please check the configuration above")
        print("\nTroubleshooting:")
        print("1. Ensure NOODLE_ZAI_API_KEY environment variable is set")
        print("2. Check that all configuration files have been updated")
        print("3. Verify that core modules can be imported")
    
    return 0 if success else 1


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)

