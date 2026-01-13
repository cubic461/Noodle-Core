# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Script to categorize files in noodle-core/src/noodlecore/ by functionality
# """
import os
import json
import pathlib.Path

function categorize_files()
    base_dir = Path(".")  # Current directory (noodle-core/src/noodlecore)

    #     # Define file categories based on naming patterns
    categories = {
    #         "ai": [],
    #         "api": [],
    #         "auth": [],
    #         "cache": [],
    #         "cli": [],
    #         "compiler": [],
    #         "config": [],
    #         "database": [],
    #         "debug": [],
    #         "distributed": [],
    #         "error": [],
    #         "execution": [],
    #         "ffi": [],
    #         "gpu": [],
    #         "ide": [],
    #         "import": [],
    #         "indexing": [],
    #         "mathematical": [],
    #         "memory": [],
    #         "monitoring": [],
    #         "optimization": [],
    #         "parser": [],
    #         "performance": [],
    #         "plugin": [],
    #         "runtime": [],
    #         "sandbox": [],
    #         "security": [],
    #         "testing": [],
    #         "trm": [],
    #         "utils": [],
    #         "validation": [],
    #         "vector": [],
    #         "websocket": [],
    #         "other": []
    #     }

    #     # Get all Python files in the directory
    python_files = list(base_dir.glob("*.py"))
        print(f"Found {len(python_files)} Python files")

    #     for file_path in python_files:
    filename = file_path.name.lower()

    #         # Categorize based on filename patterns
    #         if "ai_" in filename or filename.startswith("ai"):
                categories["ai"].append(str(file_path))
    #         elif "api" in filename:
                categories["api"].append(str(file_path))
    #         elif "auth" in filename:
                categories["auth"].append(str(file_path))
    #         elif "cache" in filename:
                categories["cache"].append(str(file_path))
    #         elif "cli" in filename:
                categories["cli"].append(str(file_path))
    #         elif "compiler" in filename:
                categories["compiler"].append(str(file_path))
    #         elif "config" in filename:
                categories["config"].append(str(file_path))
    #         elif "database" in filename or "db" in filename or "sql" in filename or "duckdb" in filename or "postgresql" in filename or "sqlite" in filename:
                categories["database"].append(str(file_path))
    #         elif "debug" in filename:
                categories["debug"].append(str(file_path))
    #         elif "distributed" in filename:
                categories["distributed"].append(str(file_path))
    #         elif "error" in filename:
                categories["error"].append(str(file_path))
    #         elif "execution" in filename or "executor" in filename:
                categories["execution"].append(str(file_path))
    #         elif "ffi" in filename or "bridge" in filename:
                categories["ffi"].append(str(file_path))
    #         elif "gpu" in filename:
                categories["gpu"].append(str(file_path))
    #         elif "ide" in filename:
                categories["ide"].append(str(file_path))
    #         elif "import" in filename:
                categories["import"].append(str(file_path))
    #         elif "index" in filename:
                categories["indexing"].append(str(file_path))
    #         elif "mathematical" in filename or "matrix" in filename:
                categories["mathematical"].append(str(file_path))
    #         elif "memory" in filename:
                categories["memory"].append(str(file_path))
    #         elif "monitor" in filename or "metrics" in filename:
                categories["monitoring"].append(str(file_path))
    #         elif "optimization" in filename or "optimizer" in filename:
                categories["optimization"].append(str(file_path))
    #         elif "parser" in filename or "lexer" in filename:
                categories["parser"].append(str(file_path))
    #         elif "performance" in filename or "benchmark" in filename:
                categories["performance"].append(str(file_path))
    #         elif "plugin" in filename:
                categories["plugin"].append(str(file_path))
    #         elif "runtime" in filename:
                categories["runtime"].append(str(file_path))
    #         elif "sandbox" in filename:
                categories["sandbox"].append(str(file_path))
    #         elif "security" in filename:
                categories["security"].append(str(file_path))
    #         elif "test" in filename:
                categories["testing"].append(str(file_path))
    #         elif "trm" in filename:
                categories["trm"].append(str(file_path))
    #         elif "util" in filename:
                categories["utils"].append(str(file_path))
    #         elif "validation" in filename or "validator" in filename:
                categories["validation"].append(str(file_path))
    #         elif "vector" in filename:
                categories["vector"].append(str(file_path))
    #         elif "websocket" in filename:
                categories["websocket"].append(str(file_path))
    #         else:
                categories["other"].append(str(file_path))

    #     # Print categorized files
    #     for category, files in categories.items():
    #         if files:
    print(f"\n = == {category.upper()} ({len(files)} files) ===")
    #             for file_path in sorted(files):
                    print(f"  {file_path}")

    #     # Save categorization to JSON
    #     with open("file_categorization.json", "w") as f:
    json.dump(categories, f, indent = 2)

        print("\nFile categorization saved to file_categorization.json")

if __name__ == "__main__"
        categorize_files()