# Converted from Python to NoodleCore
# Original file: src

import os
import re

for root, dirs, files in os.walk("noodle-dev")
    #     for file in files:
    #         if file.endswith(".py"):
    filepath = os.path.join(root, file)
    #             with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()
    new_content = re.sub(r"from src\.noodle", "from noodle", content)
    #             if new_content != content:
    #                 with open(filepath, "w", encoding="utf-8") as f:
                        f.write(new_content)
                    print(f"Fixed imports in {filepath}")
