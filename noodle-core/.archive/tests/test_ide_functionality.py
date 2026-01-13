#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ide_functionality.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive NoodleCore IDE Functionality Test Script

This script tests key IDE functionalities by:
1. Parsing IDE initialization output for feature availability
2. Testing syntax fixer with a malformed .nc file
3. Testing database connectivity
4. Checking AI provider availability
5. Checking self-improvement and TRM integration
6. Generating comprehensive report
"""

import sys
import os
import re
import subprocess
import tempfile
import sqlite3
import shutil
from pathlib import Path
from contextlib import contextmanager
import time

# Ensure noodle-core paths are available
noodle_core_dir = Path(__file__).parent
src_dir = noodle_core_dir / "src"
ide_dir = src_dir / "noodlecore" / "desktop" / "ide"

sys.path.insert(0, str(noodle_core_dir))
sys.path.insert(0, str(src_dir))
sys.path.insert(0, str(ide_dir))

def parse_ide_features(stdout: str) -> dict:
    """Parse IDE initialization output for feature availability."""
    features = {}
    
    # Syntax highlighter
    if re.search(r'\[OK\]\s+Enhanced syntax highlighter loaded successfully', stdout):
        features['syntax_highlighter'] = 'OK'
    elif re.search(r'\[ERROR\]\s+Enhanced syntax highlighter not available', stdout):
        features['syntax_highlighter'] = 'Fallback'
    else:
        features['syntax_highlighter'] = 'Missing'
    
    # Progress Manager
    if re.search(r'\[OK\]\s+Progress Manager loaded successfully', stdout):
        features['progress_manager'] = 'OK'
    elif re.search(r'\[ERROR\]\s+Progress Manager not available', stdout):
        features['progress_manager'] = 'Missing'
    else:
        features['progress_manager'] = 'Unknown'
    
    # Syntax Fixer versions
    if re.search(r'\[OK\]\s+Enhanced NoodleCore Syntax Fixer V3', stdout):
        features['syntax_fixer'] = 'V3 (TRM)'
    elif re.search(r'\[OK\]\s+Fallback to Enhanced NoodleCore Syntax Fixer V2', stdout):
        features['syntax_fixer'] = 'V2'
    elif re.search(r'\[OK\]\s+Fallback to Enhanced NoodleCore Syntax Fixer V1', stdout):
        features['syntax_fixer'] = 'V1'
    elif re.search(r'\[OK\]\s+Final fallback to basic NoodleCore Syntax Fixer', stdout):
        features['syntax_fixer'] = 'Basic'
    else:
        features['syntax_fixer'] = 'None'
    
    # Self-Improvement
    if re.search(r'\[OK\]\s+Self-Improvement Integration initialized successfully', stdout):
        features['self_improvement'] = 'OK'
    else:
        features['self_improvement'] = 'Missing'
    
    # TRM Integration
    if re.search(r'\[OK\]\s+(TRM Controller Integration|TRM Agent) initialized successfully', stdout):
        features['trm'] = 'OK'
    else:
        features['trm'] = 'Missing'
    
    # Noodle Runtime
    if 'NoodleCore Command Runtime loaded successfully' in stdout:
        features['noodle_runtime'] = 'OK'
    else:
        features['noodle_runtime'] = 'Missing'
    
    # Git Tools
    if 'NoodleCore Git tools loaded successfully' in stdout:
        features['git_tools'] = 'OK'
    else:
        features['git_tools'] = 'Missing'
    
    # AI Config
    if 'AI config loaded' in stdout:
        features['ai_config'] = 'Loaded'
    else:
        features['ai_config'] = 'Not loaded'
    
    # Count OK/ERROR
    ok_matches = re.findall(r'\[OK\]', stdout)
    error_matches = re.findall(r'\[ERROR\]', stdout)
    features['ok_count'] = len(ok_matches)
    features['error_count'] = len(error_matches)
    
    return features

def test_ide_initialization() -> dict:
    """Test IDE initialization by running constructor."""
    print("Testing IDE initialization...")
    
    cmd = [
        sys.executable, '-c',
        "from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE; "
        "_ = NativeNoodleCoreIDE()"
    ]
    
    try:
        result = subprocess.run(
            cmd,
            cwd=str(noodle_core_dir),
            capture_output=True,
            text=True,
            timeout=20
        )
        
        if result.returncode == 0:
            features = parse_ide_features(result.stdout)
            return {'status': 'OK', 'features': features, 'stdout_snippet': result.stdout[-1000:]}
        else:
            return {'status': 'Failed', 'error': result.stderr, 'features': {}}
            
    except subprocess.TimeoutExpired:
        return {'status': 'Timeout', 'error': 'IDE init timed out (likely GUI issue)'}
    except Exception as e:
        return {'status': 'Error', 'error': str(e)}

def test_syntax_fixer():
    """Test enhanced syntax fixer functionality."""
    print("Testing syntax fixer...")
    
    os.chdir(ide_dir)
    
    report = {'status': 'Not available'}
    
    # Test V3 first
    try:
        from enhanced_syntax_fixer_v3 import EnhancedNoodleCoreSyntaxFixerV3
        
        # Mock minimal config
        class MockDBConfig:
            pass
        
        fixer = EnhancedNoodleCoreSyntaxFixerV3(
            enable_ai=False,
            enable_real_time=False,
            enable_learning=False,
            enable_trm=False,
            database_config=None,
            trm_config=None
        )
        
        # Test invalid code
        invalid_code = """
def test_function:
    print("missing parenthesis
        return result
"""
        
        result = fixer.validate_content(invalid_code)
        
        if isinstance(result, dict):
            report = {
                'status': 'OK',
                'version': 'V3',
                'result_keys': list(result.keys()),
                'valid': result.get('valid', False)
            }
        else:
            report = {'status': 'Invalid result format'}
            
    except ImportError:
        # Test V2
        try:
            from enhanced_syntax_fixer_v2 import EnhancedNoodleCoreSyntaxFixerV2
            fixer = EnhancedNoodleCoreSyntaxFixerV2(enable_ai=False, enable_real_time=False)
            invalid_code = 'def test: print("error"'
            result = fixer.validate_content(invalid_code)
            report = {'status': 'OK (V2)', 'valid': result.get('valid', False)}
        except ImportError:
            # Test V1
            try:
                from enhanced_syntax_fixer import EnhancedNoodleCoreSyntaxFixer
                fixer = EnhancedNoodleCoreSyntaxFixer(enable_ai=False)
                result = fixer.validate_content('def test print("error"')
                report = {'status': 'OK (V1)'}
            except ImportError:
                report = {'status': 'No fixer available'}
    
    os.chdir(noodle_core_dir)
    return report

def test_database_connectivity():
    """Test database connectivity for learning systems."""
    print("Testing database connectivity...")
    
    db_path = Path('noodlecore_syntax_fixer_learning.db')
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Test table creation
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS syntax_fixes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                file_path TEXT,
                fixes_applied INTEGER,
                ai_used BOOLEAN
            )
        """)
        
        # Test insert
        cursor.execute(
            "INSERT INTO syntax_fixes (file_path, fixes_applied, ai_used) VALUES (?, ?, ?)",
            ('test.nc', 1, False)
        )
        
        conn.commit()
        
        # Test query
        count = cursor.execute("SELECT COUNT(*) FROM syntax_fixes").fetchone()[0]
        
        conn.close()
        
        if db_path.exists():
            # Clean up test data (keep table structure)
            os.remove(db_path)
        
        return {'status': 'OK', 'table_test': True, 'insert_count': count}
        
    except Exception as e:
        return {'status': 'Failed', 'error': str(e)}

def test_ai_chat_functionality():
    """Test AI chat providers availability."""
    print("Testing AI chat...")
    
    features = {}
    
    # Test provider classes
    providers = [
        'OpenAIProvider',
        'OpenRouterProvider', 
        'LMStudioProvider',
        'ZAIProvider'
    ]
    
    available_providers = []
    for provider in providers:
        try:
            mod = __import__('noodlecore.desktop.ide.native_gui_ide', fromlist=[provider])
            cls = getattr(mod, provider)
            # Test instantiation
            instance = cls()
            available_providers.append(provider)
            features[provider] = 'OK'
        except Exception as e:
            features[provider] = f'Error: {str(e)[:50]}'
    
    return {
        'status': 'OK' if available_providers else 'No providers',
        'providers': available_providers
    }

def test_self_improvement():
    """Test self-improvement features."""
    print("Testing self-improvement...")
    
    os.chdir(ide_dir)
    
    try:
        from self_improvement_integration import SelfImprovementIntegration
        features = {'import': 'OK'}
        
        # Test instantiation (requires IDE mock)
        class MockIDE:
            pass
        
        integration = SelfImprovementIntegration(MockIDE())
        features['instantiation'] = 'OK'
        
    except Exception as e:
        features = {'error': str(e)}
    
    os.chdir(noodle_core_dir)
    return {'status': 'Available' if 'OK' in features.values() else 'Missing', 'details': features}

def test_trm_integration():
    """Test TRM integration."""
    print("Testing TRM...")
    
    os.chdir(ide_dir)
    
    try:
        from trm_controller_integration import TRMControllerIntegration
        features = {'controller': 'OK'}
        
        class MockIDE:
            pass
        
        integration = TRMControllerIntegration(MockIDE())
        status = integration.get_integration_status()
        features['status_call'] = 'OK' if isinstance(status, dict) else 'Invalid'
        
    except Exception as e:
        features = {'error': str(e)}
    
    try:
        from ..noodlecore_trm_agent import TRMAgent
        features['agent'] = 'OK'
    except:
        features['agent'] = 'Missing'
    
    os.chdir(noodle_core_dir)
    return {'status': 'Partial' if len(features) > 1 else 'Missing', 'details': features}

def generate_report(tests: dict):
    """Generate comprehensive report."""
    print("\n" + "="*80)
    print("NOODLECORE IDE FUNCTIONALITY TEST REPORT")
    print("="*80)
    
    # IDE Mode determination
    ide_test = tests['ide_init']
    error_count = ide_test['features'].get('error_count', 0)
    if error_count <= 3:
        mode = 'Full Feature Mode'
    elif error_count <= 7:
        mode = 'Simplified Mode'
    else:
        mode = 'Degraded Mode'
    
    print(f"1. IDE Mode: {mode}")
    print(f"   OK indicators: {ide_test['features'].get('ok_count', 0)}")
    print(f"   ERROR indicators: {error_count}")
    
    print(f"\n2. Syntax Fixer: {tests['syntax_fixer']['status']}")
    if tests['syntax_fixer']['status'] != 'Not available':
        print(f"   Version: {tests['syntax_fixer'].get('version', 'Unknown')}")
    
    print(f"\n3. Database Connectivity: {tests['db']['status']}")
    
    print(f"\n4. AI Chat: {tests['ai_chat']['status']}")
    print(f"   Providers: {', '.join(tests['ai_chat']['providers'])}")
    
    print(f"\n5. Self-Improvement: {tests['self_improve']['status']}")
    
    print(f"\n6. TRM Integration: {tests['trm']['status']}")
    
    print("\nDetailed Features:")
    for feature, status in ide_test['features'].items():
        if isinstance(status, str) and status.startswith('OK') or status == True:
            print(f"  âœ… {feature}")
        else:
            print(f"  âŒ {feature}: {status}")
    
    # Summary
    passed = sum(1 for t in tests.values() if t.get('status') == 'OK')
    total = len(tests)
    print(f"\nSUMMARY: {passed}/{total} core tests passed")
    print("="*80)

def main():
    """Run all tests."""
    tests = {}
    
    print("Starting NoodleCore IDE functionality tests...")
    
    # Test 1: IDE Initialization
    tests['ide_init'] = test_ide_initialization()
    
    # Test 2: Syntax Fixer
    tests['syntax_fixer'] = test_syntax_fixer()
    
    # Test 3: Database
    tests['db'] = test_database_connectivity()
    
    # Test 4: AI Chat
    tests['ai_chat'] = test_ai_chat_functionality()
    
    # Test 5: Self-Improvement
    tests['self_improve'] = test_self_improvement()
    
    # Test 6: TRM
    tests['trm'] = test_trm_integration()
    
    # Generate report
    generate_report(tests)
    
    return tests

if __name__ == "__main__":
    main()

