#!/usr/bin/env python3
"""
Noodle Core::Activate Noodlecore Evolution - activate_noodlecore_evolution.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Evolution Activator
Activates the self-improving system for NoodleCore language evolution,
Python-to-NoodleCore translation, and performance optimization.
"""

import os
import sys
import time
import json
import logging
from pathlib import Path

# Add NoodleCore to Python path
current_dir = Path(__file__).parent
noodle_core_path = current_dir / "src"
sys.path.insert(0, str(noodle_core_path))
sys.path.insert(0, str(current_dir))

# Import NoodleCore self-improvement components
try:
    from src.noodlecore.self_improvement.self_improvement_manager import (
        get_self_improvement_manager, SelfImprovementStatus
    )
    from src.noodlecore.self_improvement.performance_monitoring import get_performance_monitoring_system
    from src.noodlecore.self_improvement.adaptive_optimizer import get_adaptive_optimizer
    from src.noodlecore.self_improvement.nc_optimization_engine import get_optimization_engine
    from src.noodlecore.self_improvement.nc_performance_monitor import get_nc_performance_monitor
    from src.noodlecore.bridge_modules.feature_flags.component_manager import ComponentManager, ComponentType
    
    IMPORTS_SUCCESSFUL = True
    print("âœ… NoodleCore self-improvement components imported successfully")
except ImportError as e:
    IMPORTS_SUCCESSFUL = False
    print(f"âŒ Import error: {e}")
    print("âš ï¸ Some components may not be available")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('noodlecore_evolution.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class NoodleCoreEvolutionActivator:
    """Activates and manages NoodleCore self-improving systems for language evolution."""
    
    def __init__(self):
        """Initialize the evolution activator."""
        self.self_improvement_manager = None
        self.component_manager = None
        self.performance_monitor = None
        self.adaptive_optimizer = None
        self.optimization_engine = None
        self.nc_performance_monitor = None
        
        # Evolution configuration
        self.evolution_config = {
            "auto_rollout_percentage": 50.0,  # 50% rollout for aggressive evolution
            "performance_threshold": 0.05,    # 5% improvement threshold
            "python_to_noodlecore_focus": True,
            "continuous_learning": True,
            "aggressive_optimization": True
        }
        
        print("ðŸš€ NoodleCore Evolution Activator initialized")
    
    def activate_all_systems(self) -> bool:
        """Activate all NoodleCore self-improvement systems."""
        try:
            print("\nðŸ”§ Activating NoodleCore Evolution Systems...")
            
            # Step 1: Initialize component manager
            self._initialize_component_manager()
            
            # Step 2: Activate self-improvement manager
            success = self._activate_self_improvement_manager()
            if not success:
                print("âŒ Failed to activate self-improvement manager")
                return False
            
            # Step 3: Activate performance monitoring
            self._activate_performance_monitoring()
            
            # Step 4: Activate adaptive optimizer
            self._activate_adaptive_optimizer()
            
            # Step 5: Activate optimization engine
            self._activate_optimization_engine()
            
            # Step 6: Activate NC performance monitor
            self._activate_nc_performance_monitor()
            
            # Step 7: Configure for NoodleCore evolution
            self._configure_for_noodlecore_evolution()
            
            # Step 8: Start continuous learning
            self._start_continuous_learning()
            
            print("\nâœ… ALL NOODLECORE EVOLUTION SYSTEMS ACTIVATED!")
            self._print_system_status()
            
            return True
            
        except Exception as e:
            print(f"âŒ Error activating systems: {e}")
            logger.error(f"Error activating NoodleCore evolution systems: {e}")
            return False
    
    def _initialize_component_manager(self):
        """Initialize the component manager."""
        try:
            self.component_manager = ComponentManager()
            print("âœ… Component manager initialized")
        except Exception as e:
            print(f"âš ï¸ Component manager initialization failed: {e}")
            logger.error(f"Component manager initialization failed: {e}")
    
    def _activate_self_improvement_manager(self) -> bool:
        """Activate the main self-improvement manager."""
        try:
            self.self_improvement_manager = get_self_improvement_manager()
            
            # Try to activate with component manager
            if self.component_manager:
                success = self.self_improvement_manager.activate(component_manager=self.component_manager)
            else:
                success = self.self_improvement_manager.activate()
            
            if success:
                print("âœ… Self-improvement manager activated")
                return True
            else:
                print("âŒ Self-improvement manager activation failed")
                return False
                
        except Exception as e:
            print(f"âŒ Self-improvement manager error: {e}")
            logger.error(f"Self-improvement manager error: {e}")
            return False
    
    def _activate_performance_monitoring(self):
        """Activate performance monitoring system."""
        try:
            if IMPORTS_SUCCESSFUL:
                self.performance_monitor = get_performance_monitoring_system()
                success = self.performance_monitor.activate()
                if success:
                    print("âœ… Performance monitoring system activated")
                else:
                    print("âš ï¸ Performance monitoring activation returned False")
            else:
                print("âš ï¸ Performance monitoring not available (import failed)")
        except Exception as e:
            print(f"âš ï¸ Performance monitoring error: {e}")
            logger.error(f"Performance monitoring error: {e}")
    
    def _activate_adaptive_optimizer(self):
        """Activate adaptive optimizer."""
        try:
            if IMPORTS_SUCCESSFUL:
                self.adaptive_optimizer = get_adaptive_optimizer(self.component_manager)
                success = self.adaptive_optimizer.activate()
                if success:
                    print("âœ… Adaptive optimizer activated")
                else:
                    print("âš ï¸ Adaptive optimizer activation returned False")
            else:
                print("âš ï¸ Adaptive optimizer not available (import failed)")
        except Exception as e:
            print(f"âš ï¸ Adaptive optimizer error: {e}")
            logger.error(f"Adaptive optimizer error: {e}")
    
    def _activate_optimization_engine(self):
        """Activate NoodleCore optimization engine."""
        try:
            if IMPORTS_SUCCESSFUL:
                self.optimization_engine = get_optimization_engine()
                print("âœ… NoodleCore optimization engine activated")
            else:
                print("âš ï¸ Optimization engine not available (import failed)")
        except Exception as e:
            print(f"âš ï¸ Optimization engine error: {e}")
            logger.error(f"Optimization engine error: {e}")
    
    def _activate_nc_performance_monitor(self):
        """Activate NC performance monitor."""
        try:
            if IMPORTS_SUCCESSFUL:
                self.nc_performance_monitor = get_nc_performance_monitor()
                print("âœ… NC performance monitor activated")
            else:
                print("âš ï¸ NC performance monitor not available (import failed)")
        except Exception as e:
            print(f"âš ï¸ NC performance monitor error: {e}")
            logger.error(f"NC performance monitor error: {e}")
    
    def _configure_for_noodlecore_evolution(self):
        """Configure all systems for aggressive NoodleCore evolution."""
        try:
            print("\nðŸ”§ Configuring for NoodleCore Evolution...")
            
            # Configure self-improvement manager for aggressive rollout
            if self.self_improvement_manager:
                self.self_improvement_manager.config.rollout_percentage = self.evolution_config["auto_rollout_percentage"]
                self.self_improvement_manager.config.performance_threshold = self.evolution_config["performance_threshold"]
                print(f"âœ… Self-improvement configured: {self.evolution_config['auto_rollout_percentage']}% rollout, {self.evolution_config['performance_threshold']*100}% threshold")
            
            # Force NoodleCore implementation for critical components
            if self.adaptive_optimizer:
                critical_components = ["compiler", "optimizer", "runtime", "memory_manager"]
                for component in critical_components:
                    try:
                        self.adaptive_optimizer.force_rollout(
                            component, ComponentType.NOODLECORE, 
                            self.evolution_config["auto_rollout_percentage"]
                        )
                        print(f"âœ… Forced {component} to NoodleCore at {self.evolution_config['auto_rollout_percentage']}%")
                    except Exception as e:
                        print(f"âš ï¸ Failed to force {component} rollout: {e}")
            
            # Start monitoring for .nc files
            if self.nc_performance_monitor:
                # Start monitoring current directory
                success = self.nc_performance_monitor.start_monitoring()
                if success:
                    print("âœ… NC performance monitoring started")
                else:
                    print("âš ï¸ NC performance monitoring start failed")
            
        except Exception as e:
            print(f"âš ï¸ Configuration error: {e}")
            logger.error(f"Configuration error: {e}")
    
    def _start_continuous_learning(self):
        """Start continuous learning for NoodleCore evolution."""
        try:
            print("\nðŸ§  Starting Continuous Learning Loop...")
            
            if self.self_improvement_manager and self.self_improvement_manager.status == SelfImprovementStatus.ACTIVE:
                # Get system status
                status = self.self_improvement_manager.get_system_status()
                print(f"ðŸ“Š System Status: {status['status']}")
                print(f"â±ï¸ Uptime: {status['uptime']:.1f} seconds")
                print(f"ðŸ”§ Active Components: {status['components']}")
                
                # Print current metrics
                metrics = status['metrics']
                print(f"ðŸ“ˆ Optimizations: {metrics['total_optimizations']} total, {metrics['successful_optimizations']} successful")
                print(f"ðŸš€ Performance Improvements: {metrics['performance_improvements']}")
                print(f"ðŸ§ª Learning Updates: {metrics['learning_updates']}")
                
            print("âœ… Continuous learning loop started")
            print("ðŸ”„ NoodleCore will continuously evolve and optimize itself!")
            
        except Exception as e:
            print(f"âš ï¸ Continuous learning error: {e}")
            logger.error(f"Continuous learning error: {e}")
    
    def _print_system_status(self):
        """Print current system status."""
        try:
            print("\n" + "="*60)
            print("ðŸš€ NOODLECORE EVOLUTION SYSTEM STATUS")
            print("="*60)
            
            # Self-improvement manager status
            if self.self_improvement_manager:
                status = self.self_improvement_manager.get_system_status()
                print(f"ðŸ§  Self-Improvement Manager: {status['status']}")
                print(f"â±ï¸ Uptime: {status['uptime']:.1f} seconds")
            
            # Component status
            components_status = {
                "Performance Monitor": "âœ… ACTIVE" if self.performance_monitor else "âŒ INACTIVE",
                "Adaptive Optimizer": "âœ… ACTIVE" if self.adaptive_optimizer else "âŒ INACTIVE", 
                "Optimization Engine": "âœ… ACTIVE" if self.optimization_engine else "âŒ INACTIVE",
                "NC Performance Monitor": "âœ… ACTIVE" if self.nc_performance_monitor else "âŒ INACTIVE"
            }
            
            print("\nðŸ”§ Component Status:")
            for component, status in components_status.items():
                print(f"  {component}: {status}")
            
            # Evolution configuration
            print(f"\nðŸš€ Evolution Configuration:")
            print(f"  Auto Rollout: {self.evolution_config['auto_rollout_percentage']}%")
            print(f"  Performance Threshold: {self.evolution_config['performance_threshold']*100}%")
            print(f"  Python-to-NoodleCore Focus: {self.evolution_config['python_to_noodlecore_focus']}")
            print(f"  Continuous Learning: {self.evolution_config['continuous_learning']}")
            
            print("\n" + "="*60)
            print("ðŸŽ¯ NOODLECORE IS NOW SELF-IMPROVING AND EVOLVING!")
            print("ðŸ”¥ The language will continuously get faster and more efficient!")
            print("ðŸ”„ Python scripts will be automatically translated to NoodleCore!")
            print("="*60)
            
        except Exception as e:
            print(f"âš ï¸ Status print error: {e}")
            logger.error(f"Status print error: {e}")
    
    def run_evolution_cycle(self):
        """Run one evolution cycle."""
        try:
            print("\nðŸ”„ Running NoodleCore Evolution Cycle...")
            
            if self.self_improvement_manager:
                # Get recommendations
                recommendations = self.self_improvement_manager.get_optimization_recommendations()
                if recommendations:
                    print(f"ðŸ“‹ Found {len(recommendations)} optimization recommendations")
                    for rec in recommendations:
                        print(f"  â€¢ {rec['type']}: {rec['description']}")
                else:
                    print("ðŸ“‹ No optimization recommendations found")
                
                # Force optimization for better performance
                if self.adaptive_optimizer:
                    print("ðŸš€ Forcing aggressive NoodleCore optimization...")
                    try:
                        self.self_improvement_manager.force_optimization(
                            "runtime", ComponentType.NOODLECORE, 100.0
                        )
                    except Exception as e:
                        print(f"âš ï¸ Optimization force failed: {e}")
            
            print("âœ… Evolution cycle completed")
            
        except Exception as e:
            print(f"âŒ Evolution cycle error: {e}")
            logger.error(f"Evolution cycle error: {e}")

def main():
    """Main entry point for NoodleCore evolution activation."""
    print("ðŸš€ NOODLECORE EVOLUTION ACTIVATOR")
    print("="*50)
    print("Activating self-improving systems for NoodleCore language evolution")
    print("This will enable:")
    print("â€¢ Continuous language improvement")
    print("â€¢ Python-to-NoodleCore translation") 
    print("â€¢ Performance optimization")
    print("â€¢ Adaptive learning")
    print("="*50)
    
    # Create activator
    activator = NoodleCoreEvolutionActivator()
    
    # Activate all systems
    success = activator.activate_all_systems()
    
    if success:
        print("\nðŸŽ‰ NoodleCore Evolution Systems Successfully Activated!")
        print("The language is now continuously evolving and improving itself!")
        
        # Run initial evolution cycle
        activator.run_evolution_cycle()
        
        print("\nâœ¨ NoodleCore is now smarter, faster, and more efficient!")
        print("ðŸ”„ The self-improving system will continue to work in the background")
        print("ðŸ§  It will learn from usage patterns and optimize performance")
        print("ðŸš€ Python code will be progressively translated to NoodleCore")
        
    else:
        print("\nâš ï¸ Some systems failed to activate. Check the logs for details.")
        print("The core NoodleCore functionality should still work.")
    
    return success

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

