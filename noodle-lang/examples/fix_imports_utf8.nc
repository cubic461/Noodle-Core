# Converted from Python to NoodleCore
# Original file: src

import os
import re

# Fix imports in all Python files in the tests directory
for root, dirs, files in os.walk("tests")
    #     for file in files:
    #         if file.endswith(".py"):
    filepath = os.path.join(root, file)
    #             with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

    #             # Replace 'from src.noodle' with 'from noodle'
    updated_content = re.sub(r"from src\.noodle", "from noodle", content)

    #             if updated_content != content:
    #                 with open(filepath, "w", encoding="utf-8") as f:
                        f.write(updated_content)
                    print(f"Fixed imports in {filepath}")
