"""
Test Suite::Noodle Core - test_patterns.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

from src.noodlecore.ai_agents.context_learning_engine import ContextLearningEngine, CodeContext, FixOutcome, PatternType
from unittest.mock import Mock
from datetime import datetime

# Create a test context and fix outcome
context = CodeContext(
    context_id='test_context',
    file_path='/test/file.py',
    project_id='test_project',
    language='python',
    code_snippet='def test_function():\n    return True',
    surrounding_code='',
    imports=['os'],
    functions=['test_function'],
    classes=[],
    variables=['result'],
    dependencies=[],
    metadata={},
    timestamp=datetime.now()
)

fix_outcome = FixOutcome(
    fix_id='test_fix',
    context_id='test_context',
    original_code='def test_function():\n    return True',
    fixed_code='def test_function():\n    return True',
    fix_type='syntax_fix',
    success=True,
    confidence=0.9,
    error_message=None,
    validation_result=None,
    user_feedback=None,
    timestamp=datetime.now()
)

# Create a mock context learning engine
mock_db_pool = Mock()
mock_model_registry = Mock()
mock_config_manager = Mock()

engine = ContextLearningEngine(
    model_registry=mock_model_registry,
    config_manager=mock_config_manager,
    db_pool=mock_db_pool,
    learning_path='/tmp/test_learning'
)

# Extract patterns
patterns = engine._extract_patterns(context, fix_outcome)

# Print pattern types and PatternType enum values
print('Pattern types extracted:')
for p in patterns:
    print(f'  - {p.pattern_type} (value: {p.pattern_type.value})')
    
print('Available PatternType values:')
for pt in PatternType:
    print(f'  - {pt.value}')

