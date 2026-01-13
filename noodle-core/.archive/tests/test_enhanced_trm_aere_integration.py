#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_trm_aere_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive Unit Tests for Enhanced TRM and AERE Integration

This module provides comprehensive unit tests for the enhanced TRM and AERE components,
validating functionality, performance, integration, and backward compatibility.
"""

import unittest
import sys
import time
import uuid
import asyncio
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime

# Add the parent directory to the path so we can import the modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.noodlecore.noodlecore_trm_agent import TRMAgent, TaskComplexity, ReasoningStrategy, TaskResult
from src.noodlecore.ai.aere_engine import (
    AEREngine, ErrorContext, ResolutionTrace, AIProvider, 
    GuardrailType, ResolutionStep, GuardrailSystem, ExplainabilitySystem
)
from src.noodlecore.ai_agents.agent_orchestrator import (
    AgentOrchestrator, AgentStatus, TaskPriority, OrchestratorTask, 
    TaskResult as OrchestratorTaskResult
)
from src.noodlecore.ai_agents.agent_lifecycle_manager import (
    AgentLifecycleManager, AgentState, LifecycleEvent, AgentLifecycleConfig
)
from src.noodlecore.ai_agents.enhanced_ai_integration import (
    EnhancedAIIntegration, IntegrationMode, IntegrationConfig, EnhancedTask, IntegrationMetrics
)

class TestEnhancedTRMAgent(unittest.TestCase):
    """Test cases for enhanced TRM Agent."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.trm_agent = TRMAgent({
            "reasoning_engine": "enhanced",
            "max_recursion_depth": 10,
            "reasoning_timeout": 60,
            "cache_size": 1000
            "knowledge_graph_enabled": True
        })
        
        self.test_config = {
            "task_description": "Fix syntax error in function",
            "context": {
                "file_path": "/test/file.nc",
                "line_number": 15,
                "error_message": "Missing semicolon",
                "code_snippet": "def test_function():\n    return True"
            }
        }
    
    def test_initialization(self):
        """Test TRM agent initialization."""
        result = self.trm_agent.start()
        self.assertTrue(result, "TRM agent should start successfully")
        self.assertEqual(self.trm_agent.active, True)
        
        status = self.trm_agent.get_status()
        self.assertIn("active", status)
        self.assertIn("reasoning_engine", status)
        self.assertEqual(status["reasoning_engine"], "enhanced_trm")
    
    def test_reasoning_about_task(self):
        """Test task reasoning functionality."""
        result = self.trm_agent.reason_about_task(
            self.test_config["task_description"],
            self.test_config["context"]
        )
        
        self.assertTrue(result["status"], "Reasoning should succeed")
        self.assertIn("reasoning", result, "Should contain reasoning")
        self.assertIn("task_complexity", result, "Should assess task complexity")
        self.assertIn("recommendations", result, "Should provide recommendations")
        self.assertIn("confidence", result, "Should provide confidence score")
        self.assertIsInstance(result["confidence"], (int, float))
    
    def test_knowledge_graph_integration(self):
        """Test knowledge graph functionality."""
        if not self.trm_agent.knowledge_graph:
            self.skip("Knowledge graph not enabled")
        
        # Test adding nodes
        test_node_id = "test_node"
        success = self.trm_agent.knowledge_graph.add_node(
            test_node_id, "test_type", {"test": "data"}
        )
        self.assertTrue(success, "Should add node successfully")
        
        # Test adding relationships
        success = self.trm_agent.knowledge_graph.add_relationship(
            "test_node", "related_node", "test_relationship"
        )
        self.assertTrue(success, "Should add relationship successfully")
        
        # Test querying related nodes
        related = self.trm_agent.knowledge_graph.query_related_nodes(
            test_node_id, max_depth=2
        )
        self.assertIsInstance(related, list, "Should return list of related nodes")
        
        # Test finding similar problems
        similar = self.trm_agent.knowledge_graph.find_similar_problems(
            "test_signature", 0.7
        )
        self.assertIsInstance(similar, list, "Should return list of similar problems")
    
    def test_recursive_problem_solving(self):
        """Test recursive problem solving."""
        # Create a complex task that should trigger recursion
        complex_task = {
            "task_id": str(uuid.uuid4()),
            "description": "Fix complex nested syntax error",
            "priority": "high",
            "data": {
                "complexity": "critical",
                "nested_depth": 5
            }
        }
        
        result = self.trm_agent.reason_about_task(
            complex_task["description"],
            complex_task
        )
        
        self.assertTrue(result["status"], "Complex task reasoning should succeed")
        self.assertEqual(result["task_complexity"], "critical", "Should identify critical complexity")
        
        # Check if subtasks were created
        self.assertIn("subtasks", result, "Should decompose complex task")
        self.assertGreater(len(result["subtasks"]), 1, "Should create at least one subtask")
    
    def test_context_aware_decision_making(self):
        """Test context-aware decision making."""
        context_with_file = {
            "file_path": "/test/complex.nc",
            "project_structure": {"imports": ["os", "sys"], "functions": ["main", "helper"]},
            "previous_attempts": [{"error": "similar issue", "solution": "added import"}]
        }
        
        result = self.trm_agent.reason_about_task(
            "Analyze file structure",
            context_with_file
        )
        
        self.assertTrue(result["status"], "Context-aware reasoning should succeed")
        self.assertIn("reasoning", result, "Should contain context-aware reasoning")
        
        # Check if project structure was used in reasoning
        reasoning = result.get("reasoning", "")
        self.assertIn("project_structure", reasoning.lower(), "Should use project structure in reasoning")
    
    def test_execute_task(self):
        """Test task execution."""
        task = {
            "task_id": str(uuid.uuid4()),
            "description": "Apply syntax fix",
            "reasoning_result": {
                "success": True,
                "reasoning": "Analysis complete",
                "suggested_fixes": [{"fix": "add semicolon", "confidence": 0.9}]
            }
        }
        
        result = self.trm_agent.execute_task(task)
        
        self.assertTrue(result["status"], "Task execution should succeed")
        self.assertIn("result", result, "Should contain execution result")
        self.assertEqual(result["task_id"], task["task_id"])
    
    def test_caching_and_performance(self):
        """Test caching and performance monitoring."""
        # Test cache functionality
        self.trm_agent.configure({"cache_size": 100})
        
        # Test performance metrics
        metrics = self.trm_agent.get_metrics()
        self.assertIn("cache_hit_rate", metrics, "Should track cache hit rate")
        self.assertIn("success_rate", metrics, "Should track success rate")
        self.assertIn("average_reasoning_time", metrics, "Should track average reasoning time")
        
        # Test knowledge graph status
        kg_status = self.trm_agent.get_knowledge_graph_status()
        self.assertTrue(kg_status["enabled"], "Knowledge graph should be enabled")
        self.assertIn("nodes", kg_status, "Should track node count")
        self.assertIn("relationships", kg_status, "Should track relationship count")

class TestEnhancedAEREngine(unittest.TestCase):
    """Test cases for enhanced AERE Engine."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.aere_engine = AEREngine({
            "timeout": 120,
            "max_retries": 3,
            "cache_size": 500,
            "guardrails_enabled": True,
            "explainability_enabled": True
        })
        
        self.test_error_context = ErrorContext(
            error_id="test_error",
            error_type="syntax_error",
            error_message="Test syntax error",
            file_path="/test/file.nc",
            line_number=15,
            code_snippet="def test():\n    pass"
        )
        
        self.test_providers = ["openai", "openrouter", "lm_studio", "z_ai"]
    
    def test_initialization(self):
        """Test AERE engine initialization."""
        result = self.aere_engine.start()
        self.assertTrue(result, "AERE engine should start successfully")
        self.assertEqual(self.aere_engine.active, True)
        
        status = self.aere_engine.get_status()
        self.assertIn("active", status)
        self.assertIn("guardrails_enabled", status)
        self.assertIn("explainability_enabled", status)
    
    def test_error_analysis(self):
        """Test error analysis functionality."""
        result = self.aere_engine.analyze_error({
            "error_info": self.test_error_context.__dict__
        })
        
        self.assertTrue(result["status"], "Error analysis should succeed")
        self.assertIn("analysis", result, "Should contain error analysis")
        self.assertIn("error_type", result["analysis"], "Should identify error type")
        self.assertIn("severity", result["analysis"], "Should assess error severity")
        self.assertIn("affected_components", result["analysis"], "Should identify affected components")
    
    def test_multi_provider_integration(self):
        """Test multi-provider AI integration."""
        # Test provider status
        provider_status = self.aere_engine.get_provider_status()
        self.assertIsInstance(provider_status, dict, "Should return provider status dictionary")
        
        # Test each provider
        for provider in self.test_providers:
            self.assertIn(provider, provider_status, f"Should have status for {provider}")
            self.assertIn("available", provider_status[provider], f"Should check availability for {provider}")
            self.assertIn("info", provider_status[provider], f"Should have info for {provider}")
    
    def test_guardrail_system(self):
        """Test guardrail system functionality."""
        # Test with content that should be blocked
        harmful_content = "This code contains harmful content"
        test_data = {"content": harmful_content, "test": True}
        
        violations = self.aere_engine.guardrail_system.check_guardrails(
            test_data, self.test_error_context
        )
        
        self.assertGreater(len(violations), 0, "Should detect harmful content")
        
        # Test with safe content
        safe_content = "This is safe code content"
        safe_data = {"content": safe_content, "test": True}
        
        safe_violations = self.aere_engine.guardrail_system.check_guardrails(
            safe_data, self.test_error_context
        )
        
        self.assertEqual(len(safe_violations), 0, "Should not flag safe content")
    
    def test_explainability(self):
        """Test explainable AI functionality."""
        # Create a mock resolution trace
        trace = ResolutionTrace(
            trace_id="test_trace",
            error_context=self.test_error_context,
            steps=[],
            final_resolution={"success": True},
            overall_confidence=0.8,
            success=True
        )
        
        explanation = self.aere_engine.explainability_system.generate_explanation(trace)
        
        self.assertTrue(explanation, "Should generate explanation")
        self.assertIn("summary", explanation, "Should provide summary")
        self.assertIn("decision_process", explanation, "Should trace decision process")
        self.assertIn("confidence_breakdown", explanation, "Should analyze confidence factors")
        self.assertIn("traceability", explanation, "Should provide traceability information")
    
    def test_resolution_application(self):
        """Test resolution application."""
        resolution = {
            "resolution": {
                "steps": [{"action": "add_semicolon", "line": 15}],
                "code_changes": [{"type": "insert", "content": ";"}]
            },
            "success": True
        }
        
        result = self.aere_engine.apply_resolution(resolution)
        
        self.assertTrue(result["status"], "Resolution application should succeed")
        self.assertIn("applied", result, "Should indicate resolution was applied")
        self.assertIn("successful_changes", result, "Should count successful changes")
        self.assertEqual(result["successful_changes"], 1)
    
    def test_caching_and_performance(self):
        """Test caching and performance monitoring."""
        # Test cache functionality
        self.aere_engine.configure({"cache_size": 200})
        
        # Test performance metrics
        metrics = self.aere_engine.get_metrics()
        self.assertIn("cache_hit_rate", metrics, "Should track cache hit rate")
        self.assertIn("success_rate", metrics, "Should track success rate")
        self.assertIn("provider_usage", metrics, "Should track provider usage")
        
        # Test guardrail violations
        self.assertIn("guardrail_violations", metrics, "Should track guardrail violations")

class TestAgentOrchestrator(unittest.TestCase):
    """Test cases for Agent Orchestrator."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.orchestrator = AgentOrchestrator({
            "max_concurrent": 10,
            "timeout": 300,
            "load_balance_strategy": "round_robin",
            "failover_enabled": True
        })
        
        self.test_agent_info = {
            "agent_id": "test_agent",
            "agent_type": "test_type",
            "name": "Test Agent",
            "capabilities": ["test_capability"],
            "health_score": 1.0,
            "max_concurrent_tasks": 5
            "endpoint": "test://endpoint"
        }
    
    def test_agent_registration(self):
        """Test agent registration."""
        result = self.orchestrator.register_agent(self.test_agent_info)
        
        self.assertTrue(result, "Agent registration should succeed")
        
        # Check agent status
        status = self.orchestrator.get_agent_status("test_agent")
        self.assertIsNotNone(status, "Should return agent status")
        self.assertEqual(status["agent_id"], "test_agent")
        self.assertEqual(status["status"], "idle", "Agent should be idle initially")
    
    def test_task_submission(self):
        """Test task submission and assignment."""
        task_id = self.orchestrator.submit_task(
            "test_task",
            {"description": "Test task"},
            priority="high"
        )
        
        self.assertIsNotNone(task_id, "Should return task ID")
        
        # Check task status
        status = self.orchestrator.get_task_status(task_id)
        self.assertIsNotNone(status, "Should return task status")
        self.assertEqual(status["status"], "pending", "Task should be pending initially")
        
        # Wait a moment for assignment
        time.sleep(0.1)
        
        # Check if task was assigned
        updated_status = self.orchestrator.get_task_status(task_id)
        self.assertEqual(updated_status["status"], "assigned", "Task should be assigned")
        self.assertIsNotNone(updated_status["assigned_agent"], "Task should have assigned agent")
    
    def test_load_balancing(self):
        """Test load balancing functionality."""
        # Register multiple agents
        agents = [
            {
                "agent_id": f"agent_{i}",
                "agent_type": "test_type",
                "capabilities": ["test_capability"],
                "health_score": 0.8 + (i * 0.1),
                "weight": 1.0 + (i * 0.1)
            }
            for i in range(5)
        ]
        
        for agent in agents:
            self.orchestrator.register_agent(agent)
        
        # Submit multiple tasks
        task_ids = []
        for i in range(10):
            task_id = self.orchestrator.submit_task(
                f"test_task_{i}",
                {"description": f"Load balance test task {i}"},
                priority="medium"
            )
            task_ids.append(task_id)
        
        # Check load balancing
        time.sleep(0.5)  # Allow time for assignment
        
        # Verify tasks are distributed across agents
        assigned_agents = set()
        for task_id in task_ids:
            status = self.orchestrator.get_task_status(task_id)
            if status["status"] == "assigned":
                assigned_agents.add(status["assigned_agent"])
        
        # Should have used multiple agents
        self.assertGreater(len(assigned_agents), 1, "Should distribute tasks across multiple agents")
        
        # Check orchestrator metrics
        metrics = self.orchestrator.get_orchestrator_status()
        self.assertIn("load_balance_efficiency", metrics, "Should track load balancing efficiency")
        self.assertGreater(metrics["registered_agents"], 5, "Should have 5 registered agents")

class TestAgentLifecycleManager(unittest.TestCase):
    """Test cases for Agent Lifecycle Manager."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.lifecycle_manager = AgentLifecycleManager({
            "health_check_interval": 30,
            "max_restarts": 3,
            "auto_restart": True
        })
        
        self.test_agent_config = AgentLifecycleConfig(
            agent_id="test_agent",
            agent_type="test_type",
            startup_timeout=60,
            max_restarts=3,
            auto_restart=True,
            resource_limits={"memory": "1GB", "cpu": "50%"},
            dependencies=["dependency1", "dependency2"]
        )
    
    def test_agent_lifecycle(self):
        """Test agent lifecycle management."""
        # Register agent
        result = self.lifecycle_manager.register_agent(self.test_agent_config)
        self.assertTrue(result, "Agent registration should succeed")
        
        # Start agent
        result = self.lifecycle_manager.start_agent("test_agent")
        self.assertTrue(result, "Agent start should succeed")
        
        # Check agent status
        status = self.lifecycle_manager.get_agent_status("test_agent")
        self.assertEqual(status["status"], "running", "Agent should be running")
        
        # Test health monitoring
        time.sleep(0.1)  # Allow time for health check
        
        # Check health status
        health_status = self.lifecycle_manager.get_agent_status("test_agent")
        self.assertIsNotNone(health_status, "Should return health status")
        self.assertIn("health_score", health_status, "Should have health score")
        self.assertIn("uptime", health_status, "Should track uptime")
        
        # Stop agent
        result = self.lifecycle_manager.stop_agent("test_agent")
        self.assertTrue(result, "Agent stop should succeed")
        
        # Check final status
        final_status = self.lifecycle_manager.get_agent_status("test_agent")
        self.assertEqual(final_status["status"], "stopped", "Agent should be stopped")
    
    def test_resource_management(self):
        """Test resource management."""
        # Start agent to test resource allocation
        self.lifecycle_manager.start_agent("test_agent")
        time.sleep(0.1)
        
        # Check allocated resources
        resources = self.lifecycle_manager.get_agent_resources("test_agent")
        self.assertIsNotNone(resources, "Should return allocated resources")
        self.assertGreater(len(resources), 0, "Should have allocated resources")
        
        # Stop agent
        self.lifecycle_manager.stop_agent("test_agent")
        
        # Check resources are deallocated
        final_resources = self.lifecycle_manager.get_agent_resources("test_agent")
        self.assertEqual(len(final_resources), 0, "Resources should be deallocated when agent stops")

class TestEnhancedAIIntegration(unittest.TestCase):
    """Test cases for Enhanced AI Integration."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.integration = EnhancedAIIntegration({
            "mode": "auto",
            "trm_enabled": True,
            "aere_enabled": True,
            "performance_monitoring": True,
            "caching_enabled": True,
            "load_balancing": True,
            "failover_enabled": True
        })
        
        self.test_task_config = {
            "task_description": "Test syntax task",
            "context": {
                "file_path": "/test/file.nc",
                "error_message": "Test error"
            }
        }
    
    def test_integration_modes(self):
        """Test different integration modes."""
        # Test TRM-only mode
        self.integration.configure({"mode": "trm_only"})
        result = self.integration.process_syntax_task(
            self.test_task_config["task_description"],
            self.test_task_config["context"]
        )
        
        self.assertTrue(result["success"], "TRM-only mode should succeed")
        self.assertEqual(result["integration_mode"], "trm_only")
        self.assertIn("trm_analysis", result, "Should contain TRM analysis")
        
        # Test AERE-only mode
        self.integration.configure({"mode": "aere_only"})
        result = self.integration.process_syntax_task(
            self.test_task_config["task_description"],
            self.test_task_config["context"]
        )
        
        self.assertTrue(result["success"], "AERE-only mode should succeed")
        self.assertEqual(result["integration_mode"], "aere_only")
        self.assertIn("aere_analysis", result, "Should contain AERE analysis")
        
        # Test hybrid mode
        self.integration.configure({"mode": "hybrid"})
        result = self.integration.process_syntax_task(
            self.test_task_config["task_description"],
            self.test_task_config["context"]
        )
        
        self.assertTrue(result["success"], "Hybrid mode should succeed")
        self.assertEqual(result["integration_mode"], "hybrid")
        self.assertIn("trm_analysis", result, "Should contain TRM analysis")
        self.assertIn("aere_analysis", result, "Should contain AERE analysis")
        self.assertIn("combined_result", result, "Should contain combined result")
    
    def test_performance_monitoring(self):
        """Test performance monitoring."""
        # Process some tasks to generate metrics
        for i in range(5):
            self.integration.process_syntax_task(
                f"Performance test task {i}",
                self.test_task_config
            )
        
        # Get metrics
        metrics = self.integration.get_metrics()
        
        self.assertIn("total_tasks", metrics, "Should track total tasks")
        self.assertIn("successful_tasks", metrics, "Should track successful tasks")
        self.assertIn("performance_score", metrics, "Should track performance score")
        self.assertIn("component_metrics", metrics, "Should track component metrics")
    
    def test_backward_compatibility(self):
        """Test backward compatibility with existing interfaces."""
        # Test that enhanced integration works with existing syntax fixer
        # This would require importing the actual syntax fixer and testing integration
        # For now, we'll test the interface compatibility
        
        # Check that integration provides expected interface methods
        self.assertTrue(hasattr(self.integration, 'process_syntax_task'), "Should have process_syntax_task method")
        self.assertTrue(hasattr(self.integration, 'get_integration_status'), "Should have get_integration_status method")
        self.assertTrue(hasattr(self.integration, 'get_metrics'), "Should have get_metrics method")
        self.assertTrue(hasattr(self.integration, 'configure'), "Should have configure method")

class TestIntegrationCompatibility(unittest.TestCase):
    """Test backward compatibility with existing interfaces."""
    
    def test_trm_interface_compatibility(self):
        """Test TRM interface compatibility."""
        # Check that enhanced TRM agent has expected methods
        trm_agent = TRMAgent()
        
        # Test core interface methods
        self.assertTrue(hasattr(trm_agent, 'reason_about_task'), "Should have reason_about_task method")
        self.assertTrue(hasattr(trm_agent, 'execute_task'), "Should have execute_task method")
        self.assertTrue(hasattr(trm_agent, 'get_task_history'), "Should have get_task_history method")
        self.assertTrue(hasattr(trm_agent, 'get_status'), "Should have get_status method")
        self.assertTrue(hasattr(trm_agent, 'configure'), "Should have configure method")
        self.assertTrue(hasattr(trm_agent, 'start'), "Should have start method")
        self.assertTrue(hasattr(trm_agent, 'stop'), "Should have stop method")
        
        # Test enhanced features
        self.assertTrue(hasattr(trm_agent, 'knowledge_graph'), "Should have knowledge graph")
        self.assertTrue(hasattr(trm_agent, 'get_knowledge_graph_status'), "Should have knowledge graph status method")
    
    def test_aere_interface_compatibility(self):
        """Test AERE interface compatibility."""
        # Check that enhanced AERE engine has expected methods
        aere_engine = AEREngine()
        
        # Test core interface methods
        self.assertTrue(hasattr(aere_engine, 'analyze_error'), "Should have analyze_error method")
        self.assertTrue(hasattr(aere_engine, 'apply_resolution'), "Should have apply_resolution method")
        self.assertTrue(hasattr(aere_engine, 'get_status'), "Should have get_status method")
        self.assertTrue(hasattr(aere_engine, 'get_provider_status'), "Should have get_provider_status method")
        self.assertTrue(hasattr(aere_engine, 'get_metrics'), "Should have get_metrics method")
        self.assertTrue(hasattr(aere_engine, 'configure'), "Should have configure method")
        self.assertTrue(hasattr(aere_engine, 'start'), "Should have start method")
        self.assertTrue(hasattr(aere_engine, 'stop'), "Should have stop method")
        
        # Test enhanced features
        self.assertTrue(hasattr(aere_engine, 'guardrail_system'), "Should have guardrail system")
        self.assertTrue(hasattr(aere_engine, 'explainability_system'), "Should have explainability system")
        
        # Test provider interfaces
        for provider_name in ['openai', 'openrouter', 'lm_studio', 'z_ai']:
            self.assertTrue(hasattr(aere_engine, f'get_{provider_name}_provider'), 
                          f"Should have {provider_name} provider")

def run_tests():
    """Run all test suites."""
    # Create test suite
    test_suite = unittest.TestSuite()
    
    # Add test cases
    test_suite.addTest(TestEnhancedTRMAgent, 'test_trm'))
    test_suite.addTest(TestEnhancedAEREngine, 'test_aere'))
    test_suite.addTest(TestAgentOrchestrator, 'test_agent'))
    test_suite.addTest(TestAgentLifecycleManager, 'test_lifecycle'))
    test_suite.addTest(TestEnhancedAIIntegration, 'test_integration'))
    test_suite.addTest(TestIntegrationCompatibility, 'test_trm_interface'))
    test_suite.addTest(TestIntegrationCompatibility, 'test_aere_interface'))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Print results
    print(f"\n{'='*'}{'='*'}")
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    
    return result.wasSuccessful()

if __name__ == "__main__":
    success = run_tests()
    sys.exit(0 if success else 1)

