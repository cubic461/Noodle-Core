"""
Test suite for TRM Agent
Copyright (c) 2025 Michael van Erp. All rights reserved.
"""

import asyncio
import sys
import logging
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from noodle_agents_trm.agent import TRMAgent, AgentMode
from noodle_agents_trm.parser import TRMParser
from noodle_agents_trm.translator import TRMTranslator

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def test_basic_functionality():
    """Test basic TRM agent functionality"""
    print("=" * 60)
    print("Testing TRM Agent")
    print("=" * 60)

    # Test 1: Parser
    print("\n[1] Testing Parser...")
    parser = TRMParser()
    test_code = """
def hello_world():
    print("Hello, World!")
    return 42
"""
    result = await parser.parse_async(test_code)
    print(f"  Parse success: {result.success}")
    if result.success:
        print(f"  Module: {result.module_name}")
        print(f"  Parse time: {result.parse_time:.3f}s")

    # Test 2: Translator
    print("\n[2] Testing Translator...")
    translator = TRMTranslator()
    if result.success:
        trans_result = await translator.translate_async(result.ast)
        print(f"  Translation success: {trans_result.success}")
        if trans_result.success:
            print(f"  IR type: {trans_result.ir.get('type')}")

    # Test 3: Full Agent
    print("\n[3] Testing Full Agent...")
    agent = TRMAgent(mode=AgentMode.HYBRID)
    agent_result = await agent.process_code(test_code)
    print(f"  Process success: {agent_result['success']}")
    print(f"  Stats: {agent_result['stats']}")

    print("\n" + "=" * 60)
    print("All tests completed!")
    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(test_basic_functionality())
