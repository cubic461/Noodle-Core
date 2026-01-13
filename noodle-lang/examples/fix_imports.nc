# Converted from Python to NoodleCore
# Original file: src

import os
import re

# Change to the correct directory
search_directory = "noodle-core"

# print(f"Searching for import fixes in {search_directory}...")

for root, dirs, files in os.walk(search_directory)
    #     for file in files:
    #         if file.endswith(".py"):
    filepath = os.path.join(root, file)
    #             try:
    #                 with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

    #                 # Fix imports from src.noodle to noodle
    new_content = re.sub(r"from src\.noodle", "from noodle", content)

    #                 # Also fix imports that might reference the wrong path
    new_content = re.sub(r"from noodle_dev", "from noodle", new_content)
    new_content = re.sub(
    #                     r"from src\.noodle_dev", "from noodle", new_content
    #                 )

    #                 if new_content != content:
    #                     with open(filepath, "w", encoding="utf-8") as f:
                            f.write(new_content)
                        print(f"Fixed imports in {filepath}")
    #                 else:
                        print(f"No changes needed in {filepath}")

    #             except Exception as e:
                    print(f"Error processing {filepath}: {e}")

print "Import fix script completed."
