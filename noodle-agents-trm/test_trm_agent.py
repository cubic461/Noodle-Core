"""
Test suite for TRM Agent components
Copyright (c) 2025 Michael van Erp. All rights reserved.
"""

import sys
import asyncio

# Test each component independently
async def test_parser():
    """Test TRM Parser"""
    print("\n" + "="*60)
    print("Testing TRM Parser")
    print("="*60)

    from parser import TRMParser

    parser = TRMParser()
    test_code = """
def hello_world():
    print("Hello, World!")
    return 42
"""

    result = await parser.parse_async(test_code)
    print(f"✓ Parse success: {result.success}")
    print(f"  Module: {result.module_name}")
    print(f"  Parse time: {result.parse_time:.3f}s")
    print(f"  AST type: {result.ast.get('type', 'N/A')}")

    assert result.success, "Parse should succeed"
    assert result.module_name == "module", "Module name should be 'module'"

    # Test cache
    await parser.parse_async(test_code)
    print(f"✓ Cache working: {parser.stats['cache_hits']} hit(s)")

    return True

async def test_translator():
    """Test TRM Translator"""
    print("\n" + "="*60)
    print("Testing TRM Translator")
    print("="*60)

    from translator import TRMTranslator

    translator = TRMTranslator()
    ast_data = {
        'type': 'Module',
        'fields': {
            'body': [
                {
                    'type': 'FunctionDef',
                    'fields': {
                        'name': 'test_func',
                        'args': {'args': []},
                        'body': []
                    }
                }
            ]
        }
    }

    result = await translator.translate_async(ast_data)
    print(f"✓ Translation success: {result.success}")
    print(f"  IR type: {result.ir.get('type', 'N/A')}")
    print(f"  Nodes: {len(result.ir.get('nodes', []))}")

    assert result.success, "Translation should succeed"

    return True

async def test_optimizer():
    """Test TRM Optimizer"""
    print("\n" + "="*60)
    print("Testing TRM Optimizer")
    print("="*60)

    from optimizer import TRMOptimizer

    optimizer = TRMOptimizer(learning_rate=0.001)
    test_ir = {
        'type': 'IRModule',
        'name': 'test_module',
        'nodes': [
            {'type': 'IRFunction', 'name': 'func1'}
        ]
    }

    result = await optimizer.optimize_async(test_ir)
    print(f"✓ Optimization success: {result.success}")
    print(f"  Improvement: {result.improvement:.1%}")
    print(f"  Stats: {optimizer.get_stats()}")

    assert result.success, "Optimization should succeed"

    return True

async def test_feedback():
    """Test TRM Feedback"""
    print("\n" + "="*60)
    print("Testing TRM Feedback")
    print("="*60)

    from feedback import TRMFeedback

    feedback = TRMFeedback()

    # Record some feedback
    await feedback.record_performance(
        code_hash=12345,
        ast_size=100,
        ir_size=80,
        optimization_gain=0.2
    )

    await feedback.record_performance(
        code_hash=67890,
        ast_size=150,
        ir_size=120,
        optimization_gain=0.25
    )

    data = await feedback.get_feedback_data()
    print(f"✓ Feedback entries: {len(data)}")
    print(f"  Average gain: {feedback.stats['average_optimization_gain']:.2%}")

    assert len(data) == 2, "Should have 2 feedback entries"

    await feedback.cleanup()
    return True

async def test_patch_agent():
    """Test Patch Agent"""
    print("\n" + "="*60)
    print("Testing Patch Agent")
    print("="*60)

    from patch_agent import PatchAgent, PatchType

    agent = PatchAgent()
    test_code = "def hello(): return 'world'"

    result = await agent.apply_patch_async(test_code, PatchType.OPTIMIZATION)
    print(f"✓ Patch success: {result.success}")
    print(f"  Patch type: {result.patch_type.value}")
    print(f"  Changes: {result.changes_made}")
    print(f"  Stats: {agent.get_stats()}")

    assert result.success, "Patch should succeed"

    return True

async def main():
    """Run all tests"""
    print("\n" + "🧪 "*20)
    print("TRM Agent Component Tests")
    print("🧪 "*20)

    tests = [
        ("Parser", test_parser),
        ("Translator", test_translator),
        ("Optimizer", test_optimizer),
        ("Feedback", test_feedback),
        ("Patch Agent", test_patch_agent),
    ]

    passed = 0
    failed = 0

    for name, test_func in tests:
        try:
            await test_func()
            passed += 1
            print(f"\n✅ {name} test PASSED")
        except Exception as e:
            failed += 1
            print(f"\n❌ {name} test FAILED: {e}")

    print("\n" + "="*60)
    print(f"Results: {passed} passed, {failed} failed")
    print("="*60)

    if failed == 0:
        print("🎉 All tests passed!")
        return 0
    else:
        print(f"⚠️  {failed} test(s) failed")
        return 1

if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
