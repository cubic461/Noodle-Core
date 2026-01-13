# Dev Tools Usage Documentation

## Overview
This document describes how to use the `dev-tools/analyze_project.py` script to analyze the Noodle codebase, generate dependency graphs, and create searchable vector embeddings of code entities.

### Purpose
The tool aims to improve developer experience by:
- Providing an overview of code structure (functions, classes, files)
- Generating dependency graphs to visualize relationships
- Enabling semantic search through code using embeddings
- Helping identify circular dependencies and architectural patterns

### Status
✅ As of 2025-10-02, the prototype is functional but currently limited to a demonstration setup. The script runs without errors, but currently scans an incorrect source path (`../noodle-core/src`), leading to zero Python files being analyzed. Fixes are planned for the next iteration.

---

## How to Use

### 1. Running the Analysis

#### Via VS Code Task (Recommended)
1. Open the Noodle root directory in VS Code.
2. Press `Ctrl+Shift+P` to open the command palette.
3. Select "Tasks: Run Task" → "Analyze Project".
4. The script will execute in the integrated terminal and prompt you for interactive queries.

#### Via Command Line
```bash
cd "c:\Users\micha\Noodle"
python dev-tools/analyze_project.py
# Then type queries, e.g. "sheaf", "circular import", and "stop" to exit.
```

#### Quick Non-Interactive Run
```bash
echo "stop" | python dev-tools/analyze_project.py
```

### 2. Output Files
After running, the tool generates output in `dev-tools/code_index/`:
- `code_graph.graphml` – Dependency graph in GraphML format (open with VS Code Graphviz or Mermaid preview)
- `code_metadata.json` – Metadata for all code entities (functions, classes)
- `code_index.faiss` – Vector search index (created if entities are found)

### 3. Interactive Search
Once the analysis completes, you can enter queries like:
- "sheaf"
- "circular import"
- "class Sheaf"
- "memory management"

Type `stop` to exit the interactive mode.

---

## Current Limitations and Known Issues

### ⚠️ Critical Issue: Source Path
- The script currently uses `SOURCE_DIR = "../noodle-core/src"`, which resolves incorrectly when run from `dev-tools/` or the project root.
- **Impact**: No Python files are found, so the analysis runs on an empty set.
- **Fix needed**: Update `SOURCE_DIR` to `"noodle-core/src"` (relative to project root) or use absolute paths.

### Other Notes
- Graph and vector index creation is functional but produces empty outputs due to the path issue.
- Cycle detection is implemented but not yet effective without import parsing.
- Error handling is present for syntax errors during AST parsing.

---

## Dependencies

Install required Python packages via:
```bash
pip install -r dev-tools/requirements.txt
```

Key packages:
- `sentence-transformers` – For generating code embeddings
- `faiss-cpu` – For efficient similarity search
- `networkx` – For dependency graph construction

---

## Planned Enhancements

### Short Term (Next Iteration)
1. **Fix Source Path**: Correct `SOURCE_DIR` to point to actual codebase.
2. **Import Analysis**: Parse import statements for true dependency mapping.
3. **Cycle Detection**: Enhance to report circular imports meaningfully.

### Mid Term
- Docstring indexing for richer semantic search.
- Integration with memory-bank for logging analysis results.
- VS Code extension for real-time querying and graph visualization.

### Long Term
- Real-time dependency tracking during development.
- Automated architectural feedback and refactoring suggestions.
- Integration with Noodle IDE vision (tree/graph views, search panels).

---

## Troubleshooting

### No Files Found
- Ensure `SOURCE_DIR` in `analyze_project.py` points to your `noodle-core/src` directory.
- Verify the directory contains `.py` files.

### FAISS/Embedding Issues
- If embeddings fail to generate, check `sentence-transformers` installation and internet connection for model download.
- Empty code lists (e.g., due to syntax errors) will skip index creation gracefully.

### Graph Visualization
- Use VS Code extensions like "Graphviz (dot) language support" or "Mermaid Preview" to view `.graphml` files.
- Alternatively, convert to other formats with networkx or external tools.

---

## Contact and Feedback
For issues or suggestions, log in the memory-bank or contact the Developer Experience Engineer role.

---

*Document created: 2025-10-02*
*Status: Prototype – functional but path-limited*
