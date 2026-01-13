# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Test script for AI Role Manager
# """

import sys
import os

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try
    #     from noodlecore.ai.role_manager import AIRoleManager
        print('✅ Role manager imports successfully')

    #     # Test role manager initialization
        print('Testing role manager initialization...')
    manager = AIRoleManager(workspace_root='.')

    #     # Get all roles
    roles = manager.get_all_roles()
    #     print(f'✅ Role manager initialized with {len(roles)} roles')

    #     for role in roles:
            print(f'  - {role.name}: {role.description[:50]}...')

    #     # Test role document reading
    #     if roles:
    first_role = roles[0]
    #         print(f'\\nTesting document reading for role: {first_role.name}')
    doc_content = manager.read_role_document(first_role.id)
    #         if doc_content:
                print(f'✅ Successfully read role document ({len(doc_content)} characters)')
                print(f'Document preview: {doc_content[:100]}...')
    #         else:
                print('⚠️ No document content found')

        print('\\n🎉 All tests passed! Role manager is working correctly.')

except Exception as e
        print(f'❌ Error: {e}')
    #     import traceback
        traceback.print_exc()