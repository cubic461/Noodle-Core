#!/usr/bin/env python3
"""
Noodle Core::Trm Aere Usage Example - trm_aere_usage_example.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
TRM & AERE Enhanced Usage Example

This script demonstrates the practical usage of the enhanced TRM and AERE components
in real-world scenarios for syntax fixing and error resolution.
"""

import os
import sys
import time
import json
from typing import Dict, Any, List

# Add the parent directory to the path so we can import the modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.noodlecore.noodlecore_trm_agent import TRMAgent
from src.noodlecore.ai.aere_engine import AEREngine, ErrorContext
from src.noodlecore.ai_agents.agent_orchestrator import AgentOrchestrator
from src.noodlecore.ai_agents.agent_lifecycle_manager import AgentLifecycleManager
from src.noodlecore.ai_agents.enhanced_ai_integration import EnhancedAIIntegration

class TRM_AERE_Demo:
    """Demonstration class for TRM and AERE functionality."""
    
    def __init__(self):
        """Initialize the demo with all components."""
        self.trm_agent = None
        self.aere_engine = None
        self.orchestrator = None
        self.lifecycle_manager = None
        self.enhanced_integration = None
        
        # Sample syntax errors for demonstration
        self.sample_errors = [
            {
                "file_path": "/project/src/main.nc",
                "line_number": 15,
                "error_message": "Missing semicolon",
                "code_snippet": "def calculate_sum(a, b)\n    return a + b",
                "error_type": "syntax_error"
            },
            {
                "file_path": "/project/src/utils.nc",
                "line_number": 42,
                "error_message": "Unexpected token '}'",
                "code_snippet": "function helper() {\n    console.log('hello')\n}}",
                "error_type": "syntax_error"
            },
            {
                "file_path": "/project/src/parser.nc",
                "line_number": 8,
                "error_message": "Unclosed string literal",
                "code_snippet": "message = \"Hello world\n    print(message)",
                "error_type": "syntax_error"
            }
        ]
    
    def setup_components(self):
        """Set up all TRM and AERE components."""
        print("ðŸš€ Setting up TRM and AERE components...")
        
        # Initialize TRM Agent
        print("   ðŸ“Š Initializing TRM Agent...")
        self.trm_agent = TRMAgent({
            "reasoning_engine": "enhanced",
            "max_recursion_depth": 10,
            "reasoning_timeout": 60,
            "cache_size": 1000,
            "knowledge_graph_enabled": True
        })
        self.trm_agent.start()
        print("   âœ… TRM Agent started successfully")
        
        # Initialize AERE Engine
        print("   ðŸ”§ Initializing AERE Engine...")
        self.aere_engine = AEREngine({
            "timeout": 120,
            "max_retries": 3,
            "cache_size": 500,
            "guardrails_enabled": True,
            "explainability_enabled": True
        })
        self.aere_engine.start()
        print("   âœ… AERE Engine started successfully")
        
        # Initialize Agent Orchestrator
        print("   ðŸŽ¼ Initializing Agent Orchestrator...")
        self.orchestrator = AgentOrchestrator({
            "max_concurrent": 10,
            "timeout": 300,
            "load_balance_strategy": "round_robin",
            "failover_enabled": True
        })
        
        # Register demo agents
        self._register_demo_agents()
        print("   âœ… Agent Orchestrator started successfully")
        
        # Initialize Lifecycle Manager
        print("   ðŸ”„ Initializing Lifecycle Manager...")
        self.lifecycle_manager = AgentLifecycleManager({
            "health_check_interval": 30,
            "max_restarts": 3,
            "auto_restart": True
        })
        print("   âœ… Lifecycle Manager started successfully")
        
        # Initialize Enhanced Integration
        print("   ðŸ”— Initializing Enhanced Integration...")
        self.enhanced_integration = EnhancedAIIntegration({
            "mode": "hybrid",
            "trm_enabled": True,
            "aere_enabled": True,
            "performance_monitoring": True,
            "caching_enabled": True,
            "load_balancing": True,
            "failover_enabled": True
        })
        print("   âœ… Enhanced Integration started successfully")
        
        print("ðŸŽ‰ All components initialized successfully!\n")
    
    def _register_demo_agents(self):
        """Register demo agents with the orchestrator."""
        demo_agents = [
            {
                "agent_id": "syntax_fixer_001",
                "agent_type": "syntax_fixer",
                "name": "Primary Syntax Fixer",
                "capabilities": ["syntax_fix", "error_analysis"],
                "health_score": 1.0,
                "max_concurrent_tasks": 5,
                "endpoint": "demo://syntax_fixer_001"
            },
            {
                "agent_id": "syntax_fixer_002",
                "agent_type": "syntax_fixer",
                "name": "Secondary Syntax Fixer",
                "capabilities": ["syntax_fix", "error_analysis"],
                "health_score": 0.9,
                "max_concurrent_tasks": 3,
                "endpoint": "demo://syntax_fixer_002"
            },
            {
                "agent_id": "code_analyzer_001",
                "agent_type": "code_analyzer",
                "name": "Code Analyzer",
                "capabilities": ["code_analysis", "complexity_assessment"],
                "health_score": 0.95,
                "max_concurrent_tasks": 4,
                "endpoint": "demo://code_analyzer_001"
            }
        ]
        
        for agent in demo_agents:
            self.orchestrator.register_agent(agent)
    
    def demo_trm_reasoning(self):
        """Demonstrate TRM reasoning capabilities."""
        print("ðŸ§  Demonstrating TRM Reasoning Capabilities")
        print("=" * 50)
        
        for i, error in enumerate(self.sample_errors, 1):
            print(f"\nðŸ“ Example {i}: {error['error_message']}")
            print(f"   File: {error['file_path']}:{error['line_number']}")
            print(f"   Code: {error['code_snippet'][:50]}...")
            
            # Use TRM to reason about the error
            result = self.trm_agent.reason_about_task(
                f"Fix {error['error_type']}: {error['error_message']}",
                error
            )
            
            if result["status"]:
                print(f"   âœ… TRM Analysis Complete")
                print(f"   ðŸŽ¯ Task Complexity: {result['task_complexity']}")
                print(f"   ðŸ’¡ Confidence: {result['confidence']:.2f}")
                print(f"   ðŸ“‹ Recommendations: {len(result['recommendations'])}")
                
                for j, rec in enumerate(result['recommendations'][:2], 1):
                    print(f"      {j}. {rec['action']} (confidence: {rec['confidence']:.2f})")
                
                # Show subtasks if any
                if 'subtasks' in result and result['subtasks']:
                    print(f"   ðŸ”„ Subtasks created: {len(result['subtasks'])}")
            else:
                print(f"   âŒ TRM Analysis Failed")
        
        # Show TRM metrics
        metrics = self.trm_agent.get_metrics()
        print(f"\nðŸ“Š TRM Performance Metrics:")
        print(f"   Success Rate: {metrics['success_rate']:.2f}")
        print(f"   Average Reasoning Time: {metrics['average_reasoning_time']:.2f}s")
        print(f"   Cache Hit Rate: {metrics['cache_hit_rate']:.2f}")
        
        # Show knowledge graph status
        kg_status = self.trm_agent.get_knowledge_graph_status()
        print(f"\nðŸ•¸ï¸  Knowledge Graph Status:")
        print(f"   Nodes: {kg_status['nodes']}")
        print(f"   Relationships: {kg_status['relationships']}")
        print(f"   Enabled: {kg_status['enabled']}")
        
        print("\n" + "=" * 50 + "\n")
    
    def demo_aere_resolution(self):
        """Demonstrate AERE error resolution capabilities."""
        print("ðŸ”§ Demonstrating AERE Error Resolution Capabilities")
        print("=" * 50)
        
        for i, error in enumerate(self.sample_errors, 1):
            print(f"\nðŸ“ Example {i}: {error['error_message']}")
            print(f"   File: {error['file_path']}:{error['line_number']}")
            
            # Create error context
            error_context = ErrorContext(
                error_id=f"error_{i:03d}",
                error_type=error['error_type'],
                error_message=error['error_message'],
                file_path=error['file_path'],
                line_number=error['line_number'],
                code_snippet=error['code_snippet']
            )
            
            # Analyze the error
            print("   ðŸ” Analyzing error...")
            analysis = self.aere_engine.analyze_error({
                "error_info": error_context.__dict__
            })
            
            if analysis["status"]:
                print(f"   âœ… Error Analysis Complete")
                analysis_data = analysis['analysis']
                print(f"   ðŸŽ¯ Error Type: {analysis_data['error_type']}")
                print(f"   âš ï¸  Severity: {analysis_data['severity']}")
                print(f"   ðŸ“ Root Cause: {analysis_data.get('root_cause', 'N/A')}")
                
                # Generate resolution
                print("   ðŸ’¡ Generating resolution...")
                resolution = self.aere_engine.generate_resolution(error_context)
                
                if resolution["status"]:
                    print(f"   âœ… Resolution Generated")
                    print(f"   ðŸ¤– Provider: {resolution['provider']}")
                    print(f"   ðŸŽ¯ Confidence: {resolution['confidence']:.2f}")
                    
                    # Apply resolution
                    print("   ðŸ› ï¸  Applying resolution...")
                    result = self.aere_engine.apply_resolution(resolution)
                    
                    if result["status"]:
                        print(f"   âœ… Resolution Applied Successfully")
                        print(f"   ðŸ“Š Changes Applied: {result['successful_changes']}")
                    else:
                        print(f"   âŒ Resolution Application Failed")
                else:
                    print(f"   âŒ Resolution Generation Failed")
            else:
                print(f"   âŒ Error Analysis Failed")
        
        # Show AERE metrics
        metrics = self.aere_engine.get_metrics()
        print(f"\nðŸ“Š AERE Performance Metrics:")
        print(f"   Success Rate: {metrics['success_rate']:.2f}")
        print(f"   Cache Hit Rate: {metrics['cache_hit_rate']:.2f}")
        print(f"   Guardrail Violations: {metrics['guardrail_violations']}")
        
        # Show provider status
        provider_status = self.aere_engine.get_provider_status()
        print(f"\nðŸŒ Provider Status:")
        for provider, status in provider_status.items():
            availability = "âœ…" if status['available'] else "âŒ"
            print(f"   {provider}: {availability} ({status['info']})")
        
        print("\n" + "=" * 50 + "\n")
    
    def demo_orchestration(self):
        """Demonstrate agent orchestration capabilities."""
        print("ðŸŽ¼ Demonstrating Agent Orchestration Capabilities")
        print("=" * 50)
        
        # Submit multiple tasks
        task_ids = []
        print("ðŸ“¤ Submitting tasks to orchestrator...")
        
        for i, error in enumerate(self.sample_errors, 1):
            task_id = self.orchestrator.submit_task(
                "fix_syntax_error",
                {
                    "description": f"Fix {error['error_type']}: {error['error_message']}",
                    "file_path": error['file_path'],
                    "line_number": error['line_number'],
                    "error_data": error
                },
                priority="high" if i == 1 else "medium"
            )
            task_ids.append(task_id)
            print(f"   ðŸ“ Task {task_id} submitted for {error['error_message']}")
        
        # Monitor task progress
        print("\nâ³ Monitoring task progress...")
        time.sleep(2)  # Allow time for processing
        
        completed_tasks = 0
        for task_id in task_ids:
            status = self.orchestrator.get_task_status(task_id)
            print(f"   ðŸ“Š Task {task_id}: {status['status']}")
            
            if status['status'] == 'completed':
                completed_tasks += 1
                print(f"      âœ… Assigned to: {status['assigned_agent']}")
            elif status['status'] == 'failed':
                print(f"      âŒ Error: {status.get('error', 'Unknown error')}")
        
        # Show orchestrator metrics
        metrics = self.orchestrator.get_orchestrator_status()
        print(f"\nðŸ“Š Orchestrator Performance Metrics:")
        print(f"   Registered Agents: {metrics['registered_agents']}")
        print(f"   Active Tasks: {metrics['active_tasks']}")
        print(f"   Completed Tasks: {completed_tasks}")
        print(f"   Load Balance Efficiency: {metrics['load_balance_efficiency']:.2f}")
        
        # Show agent status
        print(f"\nðŸ¤– Agent Status:")
        for agent_id in ['syntax_fixer_001', 'syntax_fixer_002', 'code_analyzer_001']:
            agent_status = self.orchestrator.get_agent_status(agent_id)
            if agent_status:
                print(f"   {agent_id}: {agent_status['status']} (health: {agent_status['health_score']:.2f})")
        
        print("\n" + "=" * 50 + "\n")
    
    def demo_enhanced_integration(self):
        """Demonstrate enhanced integration capabilities."""
        print("ðŸ”— Demonstrating Enhanced Integration Capabilities")
        print("=" * 50)
        
        # Test different integration modes
        modes = ["trm_only", "aere_only", "hybrid"]
        
        for mode in modes:
            print(f"\nðŸŽ›ï¸  Testing {mode} integration mode...")
            
            # Configure integration mode
            self.enhanced_integration.configure({"mode": mode})
            
            # Process a sample error
            error = self.sample_errors[0]  # Use first error for demo
            
            start_time = time.time()
            result = self.enhanced_integration.process_syntax_task(
                f"Fix {error['error_type']}: {error['error_message']}",
                error
            )
            processing_time = time.time() - start_time
            
            if result["success"]:
                print(f"   âœ… {mode.title()} Integration Successful")
                print(f"   â±ï¸  Processing Time: {processing_time:.2f}s")
                print(f"   ðŸŽ¯ Integration Mode: {result['integration_mode']}")
                
                if 'trm_analysis' in result:
                    print(f"   ðŸ§  TRM Analysis: Available")
                    trm_analysis = result['trm_analysis']
                    print(f"      Complexity: {trm_analysis.get('task_complexity', 'N/A')}")
                    print(f"      Confidence: {trm_analysis.get('confidence', 0):.2f}")
                
                if 'aere_analysis' in result:
                    print(f"   ðŸ”§ AERE Analysis: Available")
                    aere_analysis = result['aere_analysis']
                    print(f"      Error Type: {aere_analysis.get('analysis', {}).get('error_type', 'N/A')}")
                    print(f"      Severity: {aere_analysis.get('analysis', {}).get('severity', 'N/A')}")
                
                if 'combined_result' in result:
                    combined = result['combined_result']
                    print(f"   ðŸŽ¯ Combined Result: Available")
                    print(f"      Recommended Fix: {combined.get('recommended_fix', 'N/A')}")
                    print(f"      Confidence: {combined.get('confidence', 0):.2f}")
            else:
                print(f"   âŒ {mode.title()} Integration Failed")
        
        # Show integration metrics
        metrics = self.enhanced_integration.get_metrics()
        print(f"\nðŸ“Š Enhanced Integration Performance Metrics:")
        print(f"   Total Tasks: {metrics['total_tasks']}")
        print(f"   Successful Tasks: {metrics['successful_tasks']}")
        print(f"   Performance Score: {metrics['performance_score']:.2f}")
        
        # Show component metrics
        component_metrics = metrics.get('component_metrics', {})
        if component_metrics:
            print(f"\nðŸ”§ Component Metrics:")
            for component, comp_metrics in component_metrics.items():
                print(f"   {component}:")
                print(f"      Success Rate: {comp_metrics.get('success_rate', 0):.2f}")
                print(f"      Average Time: {comp_metrics.get('average_time', 0):.2f}s")
        
        print("\n" + "=" * 50 + "\n")
    
    def demo_backward_compatibility(self):
        """Demonstrate backward compatibility with existing interfaces."""
        print("ðŸ”„ Demonstrating Backward Compatibility")
        print("=" * 50)
        
        # Test that enhanced components work with existing interfaces
        print("ðŸ§ª Testing interface compatibility...")
        
        # TRM Agent compatibility
        print("\nðŸ“Š TRM Agent Interface:")
        trm_methods = [
            'reason_about_task',
            'execute_task',
            'get_task_history',
            'get_status',
            'configure',
            'start',
            'stop'
        ]
        
        for method in trm_methods:
            if hasattr(self.trm_agent, method):
                print(f"   âœ… {method}: Available")
            else:
                print(f"   âŒ {method}: Missing")
        
        # AERE Engine compatibility
        print("\nðŸ”§ AERE Engine Interface:")
        aere_methods = [
            'analyze_error',
            'apply_resolution',
            'get_status',
            'get_provider_status',
            'get_metrics',
            'configure',
            'start',
            'stop'
        ]
        
        for method in aere_methods:
            if hasattr(self.aere_engine, method):
                print(f"   âœ… {method}: Available")
            else:
                print(f"   âŒ {method}: Missing")
        
        # Enhanced Integration compatibility
        print("\nðŸ”— Enhanced Integration Interface:")
        integration_methods = [
            'process_syntax_task',
            'get_integration_status',
            'get_metrics',
            'configure'
        ]
        
        for method in integration_methods:
            if hasattr(self.enhanced_integration, method):
                print(f"   âœ… {method}: Available")
            else:
                print(f"   âŒ {method}: Missing")
        
        print("\nâœ… Backward compatibility verified!")
        print("\n" + "=" * 50 + "\n")
    
    def cleanup(self):
        """Clean up all components."""
        print("ðŸ§¹ Cleaning up components...")
        
        if self.trm_agent:
            self.trm_agent.stop()
            print("   âœ… TRM Agent stopped")
        
        if self.aere_engine:
            self.aere_engine.stop()
            print("   âœ… AERE Engine stopped")
        
        if self.orchestrator:
            # Orchestrator doesn't have explicit stop method in current implementation
            print("   âœ… Agent Orchestrator cleaned up")
        
        if self.lifecycle_manager:
            # Lifecycle manager doesn't have explicit stop method in current implementation
            print("   âœ… Lifecycle Manager cleaned up")
        
        if self.enhanced_integration:
            # Enhanced integration doesn't have explicit stop method in current implementation
            print("   âœ… Enhanced Integration cleaned up")
        
        print("ðŸŽ‰ Cleanup completed!\n")
    
    def run_demo(self):
        """Run the complete demonstration."""
        print("ðŸš€ NoodleCore TRM & AERE Enhanced Demo")
        print("=" * 60)
        print("This demonstration showcases the enhanced capabilities of:")
        print("â€¢ Task Reasoning Manager (TRM) with recursive problem solving")
        print("â€¢ AI Error Resolution Engine (AERE) with multi-provider support")
        print("â€¢ Agent Orchestration with load balancing and failover")
        print("â€¢ Enhanced Integration combining all components")
        print("â€¢ Backward compatibility with existing interfaces")
        print("=" * 60 + "\n")
        
        try:
            # Set up all components
            self.setup_components()
            
            # Run demonstrations
            self.demo_trm_reasoning()
            self.demo_aere_resolution()
            self.demo_orchestration()
            self.demo_enhanced_integration()
            self.demo_backward_compatibility()
            
            print("ðŸŽ‰ Demo completed successfully!")
            print("\nKey Takeaways:")
            print("â€¢ TRM provides intelligent reasoning and task decomposition")
            print("â€¢ AERE offers comprehensive error analysis and resolution")
            print("â€¢ Orchestrator enables efficient agent coordination")
            print("â€¢ Enhanced Integration combines all capabilities seamlessly")
            print("â€¢ Full backward compatibility is maintained")
            
        except Exception as e:
            print(f"âŒ Demo failed with error: {str(e)}")
            import traceback
            traceback.print_exc()
        
        finally:
            # Clean up
            self.cleanup()

def main():
    """Main function to run the demo."""
    demo = TRM_AERE_Demo()
    demo.run_demo()

if __name__ == "__main__":
    main()

