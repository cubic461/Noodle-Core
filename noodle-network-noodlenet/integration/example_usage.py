"""
Integration::Example Usage - example_usage.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Voorbeeld van hoe NoodleNet & AHR integratie te gebruiken
"""

import asyncio
import logging
from typing import Dict, Any

from .ahr_integration import NoodleNetAHRIntegration
from ..config import NoodleNetConfig

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def example_basic_usage():
    """Basis gebruik van de integratie"""
    logger.info("=== Basic Integration Usage Example ===")
    
    # Maak configuratie
    config = NoodleNetConfig()
    
    # Maak integratie instance
    integration = NoodleNetAHRIntegration(config)
    
    try:
        # Initialiseer
        await integration.initialize()
        logger.info("Integration initialized")
        
        # Start
        await integration.start()
        logger.info("Integration started")
        
        # Registreer een model
        await integration.register_model("my_model", "pytorch", "1.0")
        logger.info("Model registered")
        
        # Voer een distributed task uit
        result = await integration.execute_distributed_task(
            "matrix",
            {
                "matrix_a": [[1, 2, 3], [4, 5, 6]],
                "matrix_b": [[7, 8], [9, 10], [11, 12]],
                "operation": "multiply"
            }
        )
        logger.info(f"Matrix multiplication result: {result}")
        
        # Get status
        status = integration.get_integration_status()
        logger.info(f"Integration status: {status}")
        
    finally:
        # Stop
        await integration.stop()
        logger.info("Integration stopped")


async def example_advanced_usage():
    """Geavanceerd gebruik met custom handlers"""
    logger.info("=== Advanced Integration Usage Example ===")
    
    config = NoodleNetConfig()
    integration = NoodleNetAHRIntegration(config)
    
    # Custom handlers
    async def on_status_changed(status):
        logger.info(f"Status changed to: {status.value}")
    
    async def on_model_optimized(model_id, component_id):
        logger.info(f"Model optimized: {model_id}/{component_id}")
    
    async def on_node_discovered(node_id):
        logger.info(f"New node discovered: {node_id}")
    
    async def on_request_completed(model_id, component_id, metrics, success):
        logger.info(f"Request completed: {model_id}/{component_id} - Success: {success}")
    
    # Registreer handlers
    integration.set_status_changed_handler(on_status_changed)
    integration.set_model_optimized_handler(on_model_optimized)
    integration.set_node_discovered_handler(on_node_discovered)
    integration.set_request_completed_handler(on_request_completed)
    
    try:
        # Initialiseer en start
        await integration.initialize()
        await integration.start()
        
        # Configureer settings
        integration.set_integration_setting('auto_optimize', True)
        integration.set_integration_setting('optimization_threshold', 0.7)
        integration.set_integration_setting('max_concurrent_requests', 10)
        
        # Registreer meerdere modellen
        models = [
            ("resnet50", "pytorch", "1.0"),
            ("bert", "transformers", "1.0"),
            ("yolo", "onnx", "1.0")
        ]
        
        for model_id, model_type, version in models:
            await integration.register_model(model_id, model_type, version)
        
        # Voer verschillende soorten tasks uit
        tasks = [
            {
                "type": "matrix",
                "payload": {
                    "matrix_a": [[1, 2], [3, 4]],
                    "matrix_b": [[5, 6], [7, 8]],
                    "operation": "multiply"
                }
            },
            {
                "type": "neural_network",
                "payload": {
                    "model_path": "/models/bert",
                    "input_data": {"text": "Hello world"},
                    "config": {"max_length": 512}
                }
            },
            {
                "type": "database",
                "payload": {
                    "query": "SELECT * FROM users WHERE active = %s",
                    "params": [True],
                    "connection_string": "postgresql://user:pass@localhost:5432/db"
                }
            }
        ]
        
        # Voer tasks parallel uit
        results = await asyncio.gather(*[
            integration.execute_distributed_task(task["type"], task["payload"])
            for task in tasks
        ])
        
        logger.info(f"Task results: {len(results)} tasks completed")
        
        # Get gedetailleerd rapport
        report = integration.get_detailed_report()
        logger.info(f"Detailed report generated with {len(report)} sections")
        
    finally:
        await integration.stop()


async def example_error_handling():
    """Voorbeeld van error handling"""
    logger.info("=== Error Handling Example ===")
    
    config = NoodleNetConfig()
    integration = NoodleNetAHRIntegration(config)
    
    try:
        # Initialiseer en start
        await integration.initialize()
        await integration.start()
        
        # Registreer model
        await integration.register_model("test_model", "pytorch", "1.0")
        
        # Voer een task uit die kan mislukken
        try:
            result = await integration.execute_distributed_task(
                "matrix",
                {
                    "matrix_a": [[1, 2]],
                    "matrix_b": [[3, 4]],
                    "operation": "invalid_operation"  # Dit zal mislukken
                }
            )
            logger.info(f"Task result: {result}")
        except Exception as e:
            logger.error(f"Task failed: {e}")
        
        # Get status na error
        status = integration.get_integration_status()
        logger.info(f"Status after error: {status}")
        
    finally:
        await integration.stop()


async def example_performance_monitoring():
    """Voorbeeld van performance monitoring"""
    logger.info("=== Performance Monitoring Example ===")
    
    config = NoodleNetConfig()
    integration = NoodleNetAHRIntegration(config)
    
    try:
        # Initialiseer en start
        await integration.initialize()
        await integration.start()
        
        # Registreer model
        await integration.register_model("perf_test_model", "pytorch", "1.0")
        
        # Voer meerdere tasks uit voor performance test
        num_tasks = 10
        start_time = asyncio.get_event_loop().time()
        
        tasks = []
        for i in range(num_tasks):
            task = integration.execute_distributed_task(
                "matrix",
                {
                    "matrix_a": [[i, i+1]],
                    "matrix_b": [[i+2, i+3]],
                    "operation": "multiply"
                }
            )
            tasks.append(task)
        
        # Wacht op alle tasks
        results = await asyncio.gather(*tasks)
        
        end_time = asyncio.get_event_loop().time()
        total_time = end_time - start_time
        
        logger.info(f"Completed {num_tasks} tasks in {total_time:.2f} seconds")
        logger.info(f"Average time per task: {total_time/num_tasks:.2f} seconds")
        
        # Get performance metrics
        status = integration.get_integration_status()
        metrics = status['metrics']
        
        logger.info(f"Performance metrics:")
        logger.info(f"  - Total requests processed: {metrics['requests_processed']}")
        logger.info(f"  - Average latency: {metrics['average_latency']:.2f}s")
        logger.info(f"  - Total execution time: {metrics['total_execution_time']:.2f}s")
        
    finally:
        await integration.stop()


async def main():
    """Hoofd functie om alle voorbeelden uit te voeren"""
    logger.info("Starting NoodleNet & AHR Integration Examples")
    
    try:
        # Voer alle voorbeelden uit
        await example_basic_usage()
        await example_advanced_usage()
        await example_error_handling()
        await example_performance_monitoring()
        
    except Exception as e:
        logger.error(f"Error running examples: {e}")
        raise
    
    logger.info("All examples completed successfully")


if __name__ == "__main__":
    asyncio.run(main())

