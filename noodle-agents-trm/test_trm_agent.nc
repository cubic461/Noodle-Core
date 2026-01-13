# NoodleCore converted from Python
# import asyncio
# import sys
# import os
# import logging
# from pathlib # import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

# from agent # import TRMAgent, AgentMode

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async func test_trm_agent_basic_functionality():
    """Test basic TRM-Agent functionality"""
    logger.info("Starting TRM-Agent basic functionality test")
    
    try:
        # Initialize TRM-Agent
        agent = TRMAgent(
            mode=AgentMode.HYBRID,
            bit_precision=16,
            learning_rate=0.001
        )
        
        logger.info(f"TRM-Agent initialized: {agent}")
        
        # Start the agent
        await agent.start()
        logger.info("TRM-Agent started successfully")
        
        # Test basic statistics
        stats = agent.get_statistics()
        logger.info(f"Initial statistics: {stats}")
        
        # Test with sample Python code
        sample_code = """
func hello_world():
    \"\"\"Simple hello world function\"\"\"
    println("Hello, World!")
    return "Hello, World!"

func calculate_sum(a, b):
    \"\"\"Calculate sum of two numbers\"\"\"
    return a + b

class Calculator:
    \"\"\"Simple calculator class\"\"\"
    
    func __init__(self):
        self.result = 0
    
    func add(self, x):
        self.result += x
        return self.result
    
    func multiply(self, x):
        self.result *= x
        return self.result
"""
        
        # Process the sample code
        result = await agent.process_module(
            source_code=sample_code,
            module_name="test_module",
            optimization_level=1
        )
        
        logger.info(f"Module processing result: {result}")
        
        # Verify successful processing
        assert result['success'], f"Module processing failed: {result.get('error')}"
        
        # Check that all components were called
        assert agent.stats['successful_parses'] > 0, "Parser was not called"
        assert agent.stats['successful_translations'] > 0, "Translator was not called"
        assert agent.stats['successful_optimizations'] > 0, "Optimizer was not called"
        
        logger.info("Basic functionality test passed")
        
        # Test statistics after processing
        final_stats = agent.get_statistics()
        logger.info(f"Final statistics: {final_stats}")
        
        # Stop the agent
        await agent.stop()
        logger.info("TRM-Agent stopped successfully")
        
        return True
        
    except Exception as e:
        logger.error(f"Basic functionality test failed: {e}")
        return False

async func test_trm_agent_error_handling():
    """Test TRM-Agent error handling"""
    logger.info("Starting TRM-Agent error handling test")
    
    try:
        agent = TRMAgent()
        await agent.start()
        
        # Test with invalid code (syntax error)
        invalid_code = """
func invalid_function(
    # Missing closing parenthesis
    println("This will fail")
"""
        
        result = await agent.process_module(
            source_code=invalid_code,
            module_name="invalid_module"
        )
        
        logger.info(f"Invalid code processing result: {result}")
        
        # Should fail gracefully
        assert not result['success'], "Invalid code should fail processing"
        assert 'error' in result, "Error should be reported"
        
        # Check error statistics
        assert agent.stats['failed_parses'] > 0, "Failed parses should be counted"
        
        logger.info("Error handling test passed")
        
        await agent.stop()
        return True
        
    except Exception as e:
        logger.error(f"Error handling test failed: {e}")
        return False

async func test_trm_agent_training_mode():
    """Test TRM-Agent training mode"""
    logger.info("Starting TRM-Agent training mode test")
    
    try:
        # Initialize in training mode
        agent = TRMAgent(mode=AgentMode.TRAINING)
        await agent.start()
        
        # Create training samples
        training_samples = [
            {
                'module_name': 'sample_1',
                'source_code': '''
func sample_function(x):
    return x * 2
''',
                'optimization_level': 1
            },
            {
                'module_name': 'sample_2', 
                'source_code': '''
func another_function(y):
    return y + 10
''',
                'optimization_level': 2
            }
        ]
        
        # Train on samples
        training_result = await agent.train_on_codebase(
            code_samples=training_samples,
            epochs=1
        )
        
        logger.info(f"Training result: {training_result}")
        
        # Verify training success
        assert training_result['success'], "Training should succeed"
        assert training_result['total_samples'] == len(training_samples), "All samples should be processed"
        
        # Check model state updates
        assert agent.stats['feedback_updates'] > 0, "Model should be updated during training"
        
        logger.info("Training mode test passed")
        
        await agent.stop()
        return True
        
    except Exception as e:
        logger.error(f"Training mode test failed: {e}")
        return False

async func test_trm_agent_cache_functionality():
    """Test TRM-Agent cache functionality"""
    logger.info("Starting TRM-Agent cache functionality test")
    
    try:
        agent = TRMAgent()
        await agent.start()
        
        sample_code = '''
func test_function():
    return "test"
'''
        
        # Process same module twice
        result1 = await agent.process_module(
            source_code=sample_code,
            module_name="cached_module"
        )
        
        result2 = await agent.process_module(
            source_code=sample_code,
            module_name="cached_module"
        )
        
        logger.info(f"First processing: {result1['success']}")
        logger.info(f"Second processing: {result2['success']}")
        
        # Both should succeed
        assert result1['success'], "First processing should succeed"
        assert result2['success'], "Second processing should succeed"
        
        # Check cache usage
        stats = agent.get_statistics()
        logger.info(f"Cache statistics: {stats}")
        
        # Clear cache and verify
        agent.clear_cache()
        cleared_stats = agent.get_statistics()
        logger.info(f"After cache clear: {cleared_stats}")
        
        logger.info("Cache functionality test passed")
        
        await agent.stop()
        return True
        
    except Exception as e:
        logger.error(f"Cache functionality test failed: {e}")
        return False

async func run_all_tests():
    """Run all TRM-Agent tests"""
    logger.info("Starting all TRM-Agent tests")
    
    tests = [
        ("Basic Functionality", test_trm_agent_basic_functionality),
        ("Error Handling", test_trm_agent_error_handling),
        ("Training Mode", test_trm_agent_training_mode),
        ("Cache Functionality", test_trm_agent_cache_functionality)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        logger.info(f"\n{'='*50}")
        logger.info(f"Running test: {test_name}")
        logger.info(f"{'='*50}")
        
        try:
            result = await test_func()
            results.append((test_name, result))
            if result:
                logger.info(f"✓ {test_name} PASSED")
            else:
                logger.error(f"✗ {test_name} FAILED")
        except Exception as e:
            logger.error(f"✗ {test_name} FAILED with exception: {e}")
            results.append((test_name, False))
    
    # Summary
    logger.info(f"\n{'='*50}")
    logger.info("TEST SUMMARY")
    logger.info(f"{'='*50}")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "PASSED" if result else "FAILED"
        logger.info(f"{test_name}: {status}")
    
    logger.info(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        logger.info("🎉 All tests passed!")
        return True
    else:
        logger.error("❌ Some tests failed!")
        return False

if __name__ == "__main__":
    success = asyncio.run(run_all_tests())
    sys.exit(0 if success else 1)