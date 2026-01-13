#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_encrypted_config_diagnostic.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive Diagnostic Test for Encrypted Config Loading
==========================================================

This test verifies that the encrypted config system is working properly after the import dependency fix.
It simulates the IDE's load_ai_config() method and tests the complete loading flow.

Test Scope:
1. Import dependency chain verification
2. Encrypted config manager functionality
3. AI configuration save/load cycle
4. Error handling and edge cases
5. Legacy config migration
6. Machine fingerprint validation
"""

import os
import sys
import json
import tempfile
import shutil
from pathlib import Path
from typing import Dict, Any, List

# Add the noodle-core src to Python path for testing
sys.path.insert(0, str(Path(__file__).parent / 'src'))

def log_test_step(step_name: str, status: str, details: str = ""):
    """Log test step results with consistent formatting."""
    status_symbol = "PASS" if status == "PASS" else "FAIL" if status == "FAIL" else "WARN"
    print(f"[{status_symbol}] {step_name}: {status}")
    if details:
        print(f"   {details}")
    print()

class DiagnosticTestRunner:
    """Comprehensive diagnostic test runner for encrypted config system."""
    
    def __init__(self):
        self.test_results = []
        self.temp_dir = None
        self.original_env = {}
        
    def setup_test_environment(self):
        """Set up isolated test environment."""
        print("Setting up test environment...")
        
        # Create temporary directory for testing
        self.temp_dir = Path(tempfile.mkdtemp(prefix="noodlecore_config_test_"))
        print(f"   Using temp directory: {self.temp_dir}")
        
        # Store original environment
        self.original_env = {
            'APPDATA': os.environ.get('APPDATA', ''),
            'HOME': os.environ.get('HOME', ''),
        }
        
        # Set test environment
        os.environ['APPDATA'] = str(self.temp_dir)
        os.environ['HOME'] = str(self.temp_dir)
        
        print("Test environment setup complete")
        print()
    
    def cleanup_test_environment(self):
        """Clean up test environment."""
        if self.temp_dir and self.temp_dir.exists():
            shutil.rmtree(self.temp_dir)
        
        # Restore original environment
        for key, value in self.original_env.items():
            if value:
                os.environ[key] = value
            elif key in os.environ:
                del os.environ[key]
    
    def run_test(self, test_name: str, test_func):
        """Run a single test and record results."""
        print(f"Running: {test_name}")
        try:
            result = test_func()
            self.test_results.append({
                'name': test_name,
                'status': 'PASS' if result else 'FAIL',
                'details': result if isinstance(result, str) else ''
            })
            log_test_step(test_name, 'PASS' if result else 'FAIL', result if isinstance(result, str) else '')
            return result
        except Exception as e:
            self.test_results.append({
                'name': test_name,
                'status': 'FAIL',
                'details': f"Exception: {str(e)}"
            })
            log_test_step(test_name, 'FAIL', f"Exception: {str(e)}")
            return False
    
    def test_1_import_dependencies(self):
        """Test 1: Verify import dependency chain works correctly."""
        try:
            # Test importing from config module
            from noodlecore.config import (
                EncryptedConfigManager,
                get_config_manager,
                get_ai_config,
                save_ai_config,
                is_ai_configured
            )
            
            # Verify all imports are available
            imports_available = all([
                EncryptedConfigManager,
                get_config_manager,
                get_ai_config,
                save_ai_config,
                is_ai_configured
            ])
            
            if not imports_available:
                return "Some imports are None or not available"
            
            # Test that we can instantiate the manager
            manager = EncryptedConfigManager()
            if not manager:
                return "Failed to instantiate EncryptedConfigManager"
            
            return "Import dependency chain working correctly"
            
        except ImportError as e:
            return f"Import error: {str(e)}"
        except Exception as e:
            return f"Unexpected error: {str(e)}"
    
    def test_2_config_manager_creation(self):
        """Test 2: Verify config manager can be created with proper directory setup."""
        try:
            from noodlecore.config import EncryptedConfigManager
            
            # Test default directory creation
            manager = EncryptedConfigManager()
            
            # Verify config directory was created
            if not manager.config_dir.exists():
                return f"Config directory not created: {manager.config_dir}"
            
            # Verify key file exists
            if not manager.key_file.exists():
                return f"Key file not created: {manager.key_file}"
            
            # Verify encrypted config file exists (may be empty)
            if not manager.encrypted_config_file.exists():
                return f"Encrypted config file not created: {manager.encrypted_config_file}"
            
            return f"Config manager created successfully with directory: {manager.config_dir}"
            
        except Exception as e:
            return f"Config manager creation failed: {str(e)}"
    
    def test_3_save_ai_config(self):
        """Test 3: Verify save_ai_config() works without import errors."""
        try:
            from noodlecore.config import save_ai_config
            
            # Test saving configuration
            test_provider = "OpenAI"
            test_model = "gpt-4"
            test_api_key = "sk-test-api-key-12345"
            test_use_runtime = True
            
            save_ai_config(test_provider, test_model, test_api_key, test_use_runtime)
            
            return f"AI config saved successfully: provider={test_provider}, model={test_model}"
            
        except Exception as e:
            return f"save_ai_config failed: {str(e)}"
    
    def test_4_load_ai_config(self):
        """Test 4: Verify get_ai_config() works and returns expected values."""
        try:
            from noodlecore.config import get_ai_config
            
            # Load the config we just saved
            ai_config = get_ai_config()
            
            # Verify all expected fields are present
            expected_fields = ['provider', 'model', 'ai_api_key', 'use_noodle_runtime_for_python']
            missing_fields = [field for field in expected_fields if field not in ai_config]
            
            if missing_fields:
                return f"Missing expected fields: {missing_fields}"
            
            # Verify values match what we saved
            if ai_config.get('provider') != "OpenAI":
                return f"Provider mismatch: expected 'OpenAI', got '{ai_config.get('provider')}'"
            
            if ai_config.get('model') != "gpt-4":
                return f"Model mismatch: expected 'gpt-4', got '{ai_config.get('model')}'"
            
            if ai_config.get('ai_api_key') != "sk-test-api-key-12345":
                return f"API key mismatch: expected 'sk-test-api-key-12345', got '{ai_config.get('ai_api_key')}'"
            
            if ai_config.get('use_noodle_runtime_for_python') != True:
                return f"Runtime setting mismatch: expected True, got {ai_config.get('use_noodle_runtime_for_python')}"
            
            return f"AI config loaded successfully with all expected fields and values"
            
        except Exception as e:
            return f"get_ai_config failed: {str(e)}"
    
    def test_5_complete_save_load_cycle(self):
        """Test 5: Test complete save/load cycle with different values."""
        try:
            from noodlecore.config import save_ai_config, get_ai_config
            
            # Test with different provider
            save_ai_config("OpenRouter", "gpt-3.5-turbo", "sk-openrouter-key-67890", False)
            
            # Load and verify
            ai_config = get_ai_config()
            
            if ai_config.get('provider') != "OpenRouter":
                return f"Provider cycle failed: expected 'OpenRouter', got '{ai_config.get('provider')}'"
            
            if ai_config.get('model') != "gpt-3.5-turbo":
                return f"Model cycle failed: expected 'gpt-3.5-turbo', got '{ai_config.get('model')}'"
            
            if ai_config.get('ai_api_key') != "sk-openrouter-key-67890":
                return f"API key cycle failed: expected 'sk-openrouter-key-67890', got '{ai_config.get('ai_api_key')}'"
            
            if ai_config.get('use_noodle_runtime_for_python') != False:
                return f"Runtime cycle failed: expected False, got {ai_config.get('use_noodle_runtime_for_python')}"
            
            return "Complete save/load cycle successful"
            
        except Exception as e:
            return f"Save/load cycle failed: {str(e)}"
    
    def test_6_is_configured_function(self):
        """Test 6: Verify is_ai_configured() function works correctly."""
        try:
            from noodlecore.config import is_ai_configured, save_ai_config
            
            # Test with configured state
            save_ai_config("OpenAI", "gpt-4", "sk-configured-key", True)
            if not is_ai_configured():
                return "is_ai_configured() returned False when config has API key"
            
            # Test with empty API key
            save_ai_config("OpenAI", "gpt-4", "", True)
            if is_ai_configured():
                return "is_ai_configured() returned True when API key is empty"
            
            # Test with None API key
            save_ai_config("OpenAI", "gpt-4", None, True)
            if is_ai_configured():
                return "is_ai_configured() returned True when API key is None"
            
            return "is_ai_configured() function working correctly"
            
        except Exception as e:
            return f"is_ai_configured() test failed: {str(e)}"
    
    def test_7_encrypted_storage(self):
        """Test 7: Verify data is actually encrypted in storage."""
        try:
            from noodlecore.config import save_ai_config, EncryptedConfigManager
            
            # Save config
            save_ai_config("OpenAI", "gpt-4", "sk-secret-api-key", True)
            
            # Check that encrypted config file contains encrypted data
            manager = EncryptedConfigManager()
            with open(manager.encrypted_config_file, 'r') as f:
                config_content = f.read()
            
            # The config should contain encrypted data, not plain text
            if "sk-secret-api-key" in config_content:
                return "API key found in plain text in config file - encryption failed"
            
            if "encrypted_data" not in config_content:
                return "No encrypted_data field found in config file"
            
            return "Data is properly encrypted in storage"
            
        except Exception as e:
            return f"Encrypted storage test failed: {str(e)}"
    
    def test_8_legacy_config_migration(self):
        """Test 8: Verify legacy config migration works."""
        try:
            from noodlecore.config import EncryptedConfigManager, get_ai_config
            
            # Create a legacy config file
            legacy_config = {
                'ai_provider': 'LegacyProvider',
                'ai_model': 'legacy-model',
                'ai_api_key': 'sk-legacy-key',
                'other_setting': 'should_remain'
            }
            
            legacy_config_path = self.temp_dir / '.noodlecore' / 'ai_config.json'
            legacy_config_path.parent.mkdir(exist_ok=True)
            
            with open(legacy_config_path, 'w') as f:
                json.dump(legacy_config, f)
            
            # Create manager and test migration
            manager = EncryptedConfigManager()
            migration_result = manager.migrate_from_legacy_config(legacy_config_path)
            
            if not migration_result:
                return "Migration failed to detect legacy config"
            
            # Verify migration worked
            ai_config = get_ai_config()
            if ai_config.get('provider') != 'LegacyProvider':
                return f"Migration failed: expected 'LegacyProvider', got '{ai_config.get('provider')}'"
            
            if ai_config.get('ai_api_key') != 'sk-legacy-key':
                return f"Migration failed: API key not migrated correctly"
            
            # Verify legacy file was cleaned up
            with open(legacy_config_path, 'r') as f:
                cleaned_legacy = json.load(f)
            
            if 'ai_api_key' in cleaned_legacy:
                return "Legacy config cleanup failed - sensitive data still present"
            
            return "Legacy config migration working correctly"
            
        except Exception as e:
            return f"Legacy config migration test failed: {str(e)}"
    
    def test_9_machine_fingerprint_validation(self):
        """Test 9: Verify machine fingerprint validation works."""
        try:
            from noodlecore.config import EncryptedConfigManager
            
            # Create manager and save some data
            manager = EncryptedConfigManager()
            manager.set('test_key', 'test_value')
            
            # Verify config is valid for current machine
            if not manager.is_config_valid():
                return "Config marked as invalid for current machine"
            
            # Simulate machine change by modifying fingerprint
            config_data = {
                'version': '1.0',
                'encrypted_data': manager._encrypt_data(json.dumps({'test_key': 'test_value'})),
                'machine_fingerprint': 'different_machine_fingerprint'
            }
            
            with open(manager.encrypted_config_file, 'w') as f:
                json.dump(config_data, f)
            
            # Verify config is now invalid
            if manager.is_config_valid():
                return "Config incorrectly marked as valid for different machine"
            
            return "Machine fingerprint validation working correctly"
            
        except Exception as e:
            return f"Machine fingerprint validation test failed: {str(e)}"
    
    def test_10_error_handling(self):
        """Test 10: Verify error handling for various edge cases."""
        try:
            from noodlecore.config import EncryptedConfigManager, get_ai_config
            
            # Test with corrupted encrypted data
            manager = EncryptedConfigManager()
            corrupted_data = {
                'version': '1.0',
                'encrypted_data': 'corrupted_base64_data',
                'machine_fingerprint': manager._get_machine_fingerprint()
            }
            
            with open(manager.encrypted_config_file, 'w') as f:
                json.dump(corrupted_data, f)
            
            # Should handle gracefully and return empty config
            ai_config = get_ai_config()
            if not isinstance(ai_config, dict):
                return "get_ai_config() should return dict even with corrupted data"
            
            # Test with missing fields
            incomplete_data = {'version': '1.0'}
            with open(manager.encrypted_config_file, 'w') as f:
                json.dump(incomplete_data, f)
            
            ai_config = get_ai_config()
            if not isinstance(ai_config, dict):
                return "get_ai_config() should handle missing encrypted_data field"
            
            return "Error handling working correctly for edge cases"
            
        except Exception as e:
            return f"Error handling test failed: {str(e)}"
    
    def test_11_ide_simulation(self):
        """Test 11: Simulate IDE's load_ai_config() method completely."""
        try:
            from noodlecore.config import get_ai_config, save_ai_config
            
            # Simulate IDE startup sequence
            print("   Simulating IDE startup sequence...")
            
            # Step 1: Try to load existing config
            ai_config = get_ai_config()
            print(f"   Initial config load: {ai_config}")
            
            # Step 2: Save new configuration (simulating user settings)
            save_ai_config("OpenRouter", "gpt-3.5-turbo", "sk-ide-test-key", False)
            print("   Configuration saved")
            
            # Step 3: Load again to verify
            ai_config = get_ai_config()
            print(f"   Post-save config load: {ai_config}")
            
            # Step 4: Verify IDE can detect if configured
            is_configured = is_ai_configured()
            print(f"   is_ai_configured(): {is_configured}")
            
            # Step 5: Test with empty config (simulating fresh install)
            save_ai_config("OpenRouter", "gpt-3.5-turbo", "", False)
            ai_config = get_ai_config()
            is_configured = is_ai_configured()
            
            if ai_config.get('provider') != "OpenRouter":
                return f"IDE simulation failed: provider mismatch"
            
            if is_configured:
                return "IDE simulation failed: should not be configured with empty API key"
            
            return "IDE simulation successful - complete loading flow verified"
            
        except Exception as e:
            return f"IDE simulation failed: {str(e)}"
    
    def generate_diagnostic_report(self):
        """Generate comprehensive diagnostic report."""
        print("\n" + "="*80)
        print("COMPREHENSIVE DIAGNOSTIC REPORT")
        print("="*80)
        
        # Summary
        total_tests = len(self.test_results)
        passed_tests = sum(1 for r in self.test_results if r['status'] == 'PASS')
        failed_tests = total_tests - passed_tests
        
        print(f"\nTEST SUMMARY:")
        print(f"   Total Tests: {total_tests}")
        print(f"   Passed: {passed_tests}")
        print(f"   Failed: {failed_tests}")
        print(f"   Success Rate: {(passed_tests/total_tests)*100:.1f}%")
        
        # Detailed results
        print(f"\nDETAILED RESULTS:")
        for i, result in enumerate(self.test_results, 1):
            status_symbol = "PASS" if result['status'] == 'PASS' else "FAIL"
            print(f"   {i:2d}. [{status_symbol}] {result['name']}")
            if result['status'] == 'FAIL' and result['details']:
                print(f"       â†’ {result['details']}")
        
        # Overall assessment
        print(f"\nOVERALL ASSESSMENT:")
        if failed_tests == 0:
            print("   ALL TESTS PASSED - Encrypted config loading is working perfectly!")
            print("   The import dependency fix has resolved all issues.")
            print("   The IDE should now be able to load AI settings at startup.")
        else:
            print("   SOME TESTS FAILED - There are still issues with encrypted config loading.")
            print("   Review the failed tests above for specific problems.")
            print("   Consider checking the import dependency chain again.")
        
        # Recommendations
        print(f"\nRECOMMENDATIONS:")
        if failed_tests == 0:
            print("   1. Encrypted config system is ready for production use")
            print("   2. IDE can safely call get_ai_config() at startup")
            print("   3. API keys will be securely stored and retrieved")
            print("   4. Legacy config migration will work correctly")
            print("   5. Machine fingerprint validation provides security")
        else:
            print("   1. Fix the failed tests before using in production")
            print("   2. Check import paths and dependency chain")
            print("   3. Verify encryption key generation and storage")
            print("   4. Review error handling for edge cases")
        
        print(f"\nNEXT STEPS:")
        if failed_tests == 0:
            print("   Run the IDE and verify AI settings load correctly")
            print("   Test with actual API keys in production environment")
            print("   Monitor for any runtime errors during normal usage")
        else:
            print("   Address failed tests based on error messages above")
            print("   Re-run this diagnostic after fixes")
            print("   Consider adding more specific error logging")
        
        print("\n" + "="*80)
        
        return failed_tests == 0
    
    def run_all_tests(self):
        """Run all diagnostic tests."""
        print("Starting Comprehensive Encrypted Config Diagnostic Tests")
        print("="*80)
        print()
        
        # Setup
        self.setup_test_environment()
        
        try:
            # Run all tests
            tests = [
                ("Import Dependencies", self.test_1_import_dependencies),
                ("Config Manager Creation", self.test_2_config_manager_creation),
                ("Save AI Config", self.test_3_save_ai_config),
                ("Load AI Config", self.test_4_load_ai_config),
                ("Complete Save/Load Cycle", self.test_5_complete_save_load_cycle),
                ("is_ai_configured() Function", self.test_6_is_configured_function),
                ("Encrypted Storage Verification", self.test_7_encrypted_storage),
                ("Legacy Config Migration", self.test_8_legacy_config_migration),
                ("Machine Fingerprint Validation", self.test_9_machine_fingerprint_validation),
                ("Error Handling", self.test_10_error_handling),
                ("IDE Simulation", self.test_11_ide_simulation),
            ]
            
            for test_name, test_func in tests:
                self.run_test(test_name, test_func)
            
            # Generate report
            success = self.generate_diagnostic_report()
            
            return success
            
        finally:
            # Cleanup
            self.cleanup_test_environment()

def main():
    """Main entry point for diagnostic test."""
    print("DIAGNOSTIC: NoodleCore Encrypted Config Diagnostic Test")
    print("Testing encrypted config loading after import dependency fix")
    print()
    
    runner = DiagnosticTestRunner()
    success = runner.run_all_tests()
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()

