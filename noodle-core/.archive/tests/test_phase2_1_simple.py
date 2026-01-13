#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_phase2_1_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Phase 2.1 Test

This test focuses on verifying that the Phase 2.1 components
can be imported and instantiated correctly without complex mocking.
"""

import os
import sys
import unittest
from pathlib import Path

# Add src directory to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

class TestPhase21Simple(unittest.TestCase):
    """Simple Phase 2.1 Test"""
    
    def test_import_enhanced_syntax_fixer_v2(self):
        """Test that EnhancedNoodleCoreSyntaxFixerV2 can be imported."""
        try:
            from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
            self.assertIsNotNone(EnhancedNoodleCoreSyntaxFixerV2, "EnhancedNoodleCoreSyntaxFixerV2 should be importable")
            print("[OK] EnhancedNoodleCoreSyntaxFixerV2 can be imported")
        except ImportError as e:
            self.fail(f"Failed to import EnhancedNoodleCoreSyntaxFixerV2: {e}")
    
    def test_import_phase2_1_components(self):
        """Test that Phase 2.1 components can be imported."""
        components = [
            "noodlecore.noodlecore_self_improvement_system_v2.NoodleCoreSelfImproverV2",
            "noodlecore.ai_agents.syntax_fixer_learning.FixResultCollector",
            "noodlecore.ai_agents.syntax_fixer_learning.PatternAnalyzer",
            "noodlecore.ai_agents.syntax_fixer_learning.LearningEngine",
            "noodlecore.ai_agents.syntax_fixer_learning.FeedbackProcessor"
        ]
        
        for component in components:
            try:
                module_path, class_name = component.rsplit('.', 1)
                module = __import__(module_path, fromlist=[component])
                cls = getattr(module, class_name)
                self.assertIsNotNone(cls, f"{class_name} should be importable")
                print(f"[OK] {class_name} can be imported")
            except ImportError as e:
                self.fail(f"Failed to import {class_name}: {e}")
    
    def test_basic_syntax_fixer_v2_functionality(self):
        """Test basic EnhancedNoodleCoreSyntaxFixerV2 functionality."""
        try:
            from noodlecore.desktop.ide.enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
            
            # Test instantiation
            fixer = EnhancedNoodleCoreSyntaxFixerV2(
                enable_ai=False,
                enable_real_time=False,
                enable_learning=False
            )
            self.assertIsNotNone(fixer, "EnhancedNoodleCoreSyntaxFixerV2 should be instantiable")
            
            # Test basic validation
            test_content = "// Test NoodleCore content\nfunc test() {\n    return 42;\n}"
            
            # Test validation through real_time_validator if available
            if fixer.real_time_validator:
                result = fixer.real_time_validator.validate_content(test_content)
                self.assertIsInstance(result, list, "validate_content should return a list")
            
            # Test status
            status = fixer.get_status()
            self.assertIsInstance(status, dict, "get_status should return a dict")
            self.assertEqual(status.get("version"), "v2", "Version should be v2")
            
            print("[OK] EnhancedNoodleCoreSyntaxFixerV2 basic functionality works")
            
        except Exception as e:
            self.fail(f"EnhancedNoodleCoreSyntaxFixerV2 functionality test failed: {e}")
    
    def test_database_config_creation(self):
        """Test database configuration creation."""
        try:
            from noodlecore.database.database_manager import DatabaseConfig
            
            # Test basic config creation
            config = DatabaseConfig()
            self.assertIsNotNone(config, "DatabaseConfig should be instantiable")
            
            # Test config properties
            self.assertTrue(hasattr(config, 'database'), "DatabaseConfig should have database attribute")
            self.assertTrue(hasattr(config, 'connection_string'), "DatabaseConfig should have connection_string attribute")
            self.assertTrue(hasattr(config, 'max_connections'), "DatabaseConfig should have max_connections attribute")
            self.assertTrue(hasattr(config, 'timeout'), "DatabaseConfig should have timeout attribute")
            
            print("[OK] DatabaseConfig creation works")
            
        except Exception as e:
            self.fail(f"DatabaseConfig creation test failed: {e}")
    
    def test_phase2_1_integration(self):
        """Test Phase 2.1 integration."""
        try:
            from noodlecore.noodlecore_self_improvement_system_v2 import NoodleCoreSelfImproverV2
            from noodlecore.ai_agents.syntax_fixer_learning import (
                FixResultCollector, PatternAnalyzer, LearningEngine, FeedbackProcessor
            )
            
            # Test instantiation of Phase 2.1 system without database
            system = NoodleCoreSelfImproverV2(config={'enable_database': False})
            self.assertIsNotNone(system, "NoodleCoreSelfImproverV2 should be instantiable")
            
            # Test instantiation of components
            collector = FixResultCollector()
            analyzer = PatternAnalyzer()
            engine = LearningEngine()
            processor = FeedbackProcessor()
            
            self.assertIsNotNone(collector, "FixResultCollector should be instantiable")
            self.assertIsNotNone(analyzer, "PatternAnalyzer should be instantiable")
            self.assertIsNotNone(engine, "LearningEngine should be instantiable")
            self.assertIsNotNone(processor, "FeedbackProcessor should be instantiable")
            
            print("[OK] Phase 2.1 integration works")
            
        except Exception as e:
            self.fail(f"Phase 2.1 integration test failed: {e}")


if __name__ == "__main__":
    print("=" * 60)
    print("Phase 2.1 Simple Tests")
    print("=" * 60)
    
    # Run tests
    unittest.main(verbosity=2)

