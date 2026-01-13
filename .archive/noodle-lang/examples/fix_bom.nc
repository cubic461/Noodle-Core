# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
import os


function fix_bom_issues()
    #     for root, dirs, files in os.walk("."):
    #         for file in files:
    #             if file.endswith(".py"):
    filepath = os.path.join(root, file)
    #                 try:
    #                     with open(filepath, "rb") as f:
    content_bytes = f.read()

    #                     # Try to detect and remove BOM
    #                     if content_bytes.startswith(b"\xef\xbb\xbf"):
    content_bytes = content_bytes[3:]
                            print(f"Removed BOM from {filepath}")

    #                     # Try to decode as UTF-8
    #                     try:
    content = content_bytes.decode("utf-8")
    #                     except UnicodeDecodeError:
    #                         # Try to decode with errors='replace'
    content = content_bytes.decode("utf-8", errors="replace")
    #                         print(f"Decoded with replacement in {filepath}")

    #                     # Write back in UTF-8 without BOM
    #                     with open(filepath, "wb") as f:
                            f.write(content.encode("utf-8"))

    #                 except Exception as e:
                        print(f"Error processing {filepath}: {e}")


if __name__ == "__main__"
        fix_bom_issues()
