# Noodle-IDE Multi-Project Tree/Graph View Architecture

## Overview

This document outlines the architectural design for implementing a multi-project Tree/Graph View in Noodle-IDE. The solution will enable users to visualize and navigate multiple projects simultaneously with both hierarchical tree views and dependency graph visualizations.

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Noodle-IDE Frontend                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Project Selector│  │   TreeView      │  │   GraphView     │ │
│  │                 │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    Tauri Backend                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  ProjectManager │  │ ProjectAnalyzer │  │  FileHandler    │ │
│  │                 │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   File System & Projects                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Project A     │  │   Project B     │  │   Project C     │ │
│  │  (.noodle/)     │  │  (.noodle/)     │  │  (.noodle/)     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Detailed Component Design

### 1. Backend Architecture

#### 1.1 Project Analyzer (`project_analyzer.py`)

**Location**: `noodle-dev/src/noodle/runtime/project_analyzer.py`

**Purpose**: Scans project directories and generates dependency information

**Core Components**:
```python
class ProjectAnalyzer:
    def __init__(self, project_path: Path):
        self.project_path = project_path
        self.dependencies = {}
        self.file_metadata = {}

    def scan_project(self) -> Dict:
        """Scan project and return structure with dependencies"""

    def detect_language(self, file_path: Path) -> str:
        """Detect programming language of file"""

    def extract_dependencies(self, file_path: Path, content: str) -> List[str]:
        """Extract import/dependency statements from file"""

    def generate_project_structure(self) -> Dict:
        """Generate hierarchical project structure"""
```

**Supported Languages & Patterns**:
- Python: `import`, `from ... import`
- JavaScript/TypeScript: `require`, `import`
- Java: `import`, `package`
- C/C++: `#include`
- Noodle: `use`, `import`

#### 1.2 Enhanced Project Manager (`project_manager.py`)

**Location**: Extend existing `noodle-dev/src/noodle/runtime/project_manager.py`

**New Features**:
```python
class MultiProjectManager(ProjectManager):
    def __init__(self):
        super().__init__()
        self.open_projects: Dict[str, ProjectContext] = {}
        self.project_analyzer = ProjectAnalyzer()

    def open_project(self, project_path: Path) -> ProjectContext:
        """Open a new project and create context"""

    def switch_project(self, project_id: str) -> ProjectContext:
        """Switch active project context"""

    def get_project_dependencies(self, project_id: str) -> DependencyGraph:
        """Get dependency graph for project"""
```

**Project Context Structure**:
```python
@dataclass
class ProjectContext:
    id: str
    name: str
    path: Path
    structure: Dict
    dependencies: DependencyGraph
    last_scanned: datetime
    files: List[FileInfo]

@dataclass
class FileInfo:
    path: Path
    name: str
    type: str  # file/directory
    language: str
    size: int
    modified: datetime
    dependencies: List[str]
```

#### 1.3 Project Structure Generator

**Purpose**: Creates `.noodle/project_structure.json` for each project

**Output Format**:
```json
{
  "projectName": "MyProject",
  "lastUpdated": "2025-09-14T09:45:00Z",
  "rootPath": "/path/to/project",
  "structure": {
    "type": "directory",
    "name": "src",
    "path": "/path/to/project/src",
    "children": [
      {
        "type": "file",
        "name": "main.py",
        "path": "/path/to/project/src/main.py",
        "language": "python",
        "size": 2048,
        "modified": "2025-09-14T09:40:00Z",
        "dependencies": ["utils.py", "config.py"]
      }
    ]
  },
  "dependencies": {
    "nodes": [
      {"id": "main.py", "label": "main.py", "type": "file"},
      {"id": "utils.py", "label": "utils.py", "type": "file"}
    ],
    "edges": [
      {"source": "main.py", "target": "utils.py", "type": "import"}
    ]
  },
  "metadata": {
    "totalFiles": 25,
    "totalDirectories": 8,
    "languages": {"python": 20, "json": 5},
    "lastScanDuration": 1.2
  }
}
```

### 2. Frontend Architecture

#### 2.1 Project Selector Component

**Location**: `noodle-ide/src/components/ProjectSelector.tsx`

**Features**:
- List all open projects in sidebar
- Add/remove projects
- Set active project
- Project search/filter

**Interface**:
```typescript
interface ProjectSelectorProps {
  projects: ProjectContext[];
  activeProjectId: string;
  onProjectSelect: (projectId: string) => void;
  onProjectAdd: (projectPath: string) => void;
  onProjectRemove: (projectId: string) => void;
}
```

#### 2.2 TreeView Component

**Location**: `noodle-ide/src/components/TreeView.tsx`

**Features**:
- Hierarchical file/folder display
- Expand/collapse directories
- File icons based on type
- Context menu for file operations
- Search within project

**Interface**:
```typescript
interface TreeViewProps {
  project: ProjectContext;
  onFileSelect: (file: FileInfo) => void;
  onFileOpen: (file: FileInfo) => void;
  selectedFile?: string;
  viewMode: 'tree' | 'flat';
}
```

#### 2.3 GraphView Component

**Location**: `noodle-ide/src/components/GraphView.tsx`

**Features**:
- Dependency graph visualization
- Interactive nodes and edges
- Zoom and pan controls
- Layout algorithms (force-directed, hierarchical)
- AI hints overlay

**Interface**:
```typescript
interface GraphViewProps {
  project: ProjectContext;
  onNodeSelect: (node: GraphNode) => void;
  layout: 'force' | 'hierarchical' | 'circular';
  showAIHints: boolean;
}
```

#### 2.4 View Switcher Component

**Location**: `noodle-ide/src/components/ViewSwitcher.tsx`

**Features**:
- Toggle between Tree and Graph views
- View mode customization
- Split view option (Tree + Graph)

### 3. Data Flow Architecture

#### 3.1 Project Loading Flow

```
User selects project directory
    ↓
Tauri receives directory path
    ↓
ProjectManager.open_project() called
    ↓
ProjectAnalyzer.scan_project() executed
    ↓
Project structure and dependencies extracted
    ↓
.noodle/project_structure.json generated
    ↓
Frontend receives ProjectContext via IPC
    ↓
TreeView/GraphView components render
```

#### 3.2 Dependency Detection Flow

```
File system change detected
    ↓
ProjectAnalyzer triggered
    ↓
File content analyzed for dependencies
    ↓
Dependency graph updated
    ↓
Frontend notified via WebSocket
    ↓
GraphView updates visualization
```

### 4. Integration with Existing Systems

#### 4.1 Tauri Commands

**New Commands**:
```rust
#[tauri::command]
async fn open_project(path: String) -> Result<ProjectContext, String> {
    // Open project and return context
}

#[tauri::command]
async fn get_project_structure(project_id: String) -> Result<ProjectStructure, String> {
    // Return cached or fresh project structure
}

#[tauri::command]
async fn scan_project_dependencies(project_id: String) -> Result<DependencyGraph, String> {
    // Rescan project dependencies
}
```

#### 4.2 State Management

**Using Zustand Store**:
```typescript
interface ProjectStore {
  projects: Map<string, ProjectContext>;
  activeProjectId: string | null;
  viewMode: 'tree' | 'graph' | 'split';

  // Actions
  openProject: (path: string) => Promise<void>;
  closeProject: (projectId: string) => void;
  setActiveProject: (projectId: string) => void;
  setViewMode: (mode: 'tree' | 'graph' | 'split') => void;
}
```

#### 4.3 File Operations Integration

**Integration with existing Monaco Editor**:
```typescript
// When file is selected in TreeView/GraphView
const handleFileSelect = (file: FileInfo) => {
  // Open file in Monaco Editor
  editorManager.openFile(file.path);

  // Update active file in store
  projectStore.setActiveFile(file.path);
};
```

### 5. Performance Considerations

#### 5.1 Caching Strategy

- **Project Structure Cache**: Store in `.noodle/project_structure.json`
- **Dependency Cache**: Cache parsed dependencies in memory
- **File Metadata Cache**: Cache file stats and language detection
- **Incremental Updates**: Only rescan changed files

#### 5.2 Lazy Loading

- **Directory Expansion**: Load child nodes on demand
- **Graph Rendering**: Render visible nodes only
- **File Content**: Load file content only when opened

#### 5.3 Virtualization

- **Large Directories**: Virtual scrolling for file lists
- **Large Graphs**: Level-of-detail rendering for graphs

### 6. AI Integration

#### 6.1 Dependency Analysis AI

**Features**:
- Circular dependency detection
- Unused dependency identification
- Dependency bottleneck analysis
- Module cohesion suggestions

**Implementation**:
```python
class DependencyAIAnalyzer:
    def analyze_graph(self, graph: DependencyGraph) -> List[AIHint]:
        """Generate AI hints for dependency optimization"""

    def detect_circular_deps(self, graph: DependencyGraph) -> List[List[str]]:
        """Detect circular dependencies"""

    def suggest_refactoring(self, graph: DependencyGraph) -> List[RefactoringSuggestion]:
        """Suggest dependency refactoring opportunities"""
```

#### 6.2 Visualization AI

**Features**:
- Optimal graph layout suggestions
- Color coding for dependency health
- Highlight critical paths
- Anomaly detection in dependency patterns

### 7. Error Handling & Validation

#### 7.1 File System Errors

- **Permission Errors**: Graceful handling with user notification
- **Missing Files**: Update project structure automatically
- **Corrupted Projects**: Recovery mode with backup options

#### 7.2 Dependency Validation

- **Invalid References**: Highlight broken dependencies
- **Version Conflicts**: Detect and report version mismatches
- **Circular Dependencies**: Visual warning and resolution suggestions

### 8. Testing Strategy

#### 8.1 Unit Tests

- **ProjectAnalyzer**: Test dependency extraction for various languages
- **DependencyGraph**: Test graph operations and algorithms
- **File Operations**: Test file system integration

#### 8.2 Integration Tests

- **Project Loading**: Test end-to-end project opening flow
- **View Updates**: Test UI updates when project changes
- **Error Scenarios**: Test error handling and recovery

#### 8.3 Performance Tests

- **Large Projects**: Test with projects containing 10,000+ files
- **Memory Usage**: Monitor memory consumption during operations
- **Rendering Performance**: Test UI responsiveness with large datasets

### 9. Security Considerations

#### 9.1 File System Access

- **Path Validation**: Prevent directory traversal attacks
- **Permission Checks**: Verify read access to project files
- **Sandboxed Operations**: Restrict file operations to project directories

#### 9.2 Data Protection

- **No Sensitive Data**: Ensure no sensitive data is stored in project files
- **Anonymized Analytics**: Usage data collection without user identification
- **Secure Communication**: Encrypted IPC for project data transfer

### 10. Deployment & Maintenance

#### 10.1 Incremental Rollout

- **Feature Flags**: Enable/disable Tree/Graph view features
- **Gradual Release**: Roll out to user segments
- **Feedback Collection**: Monitor usage and collect feedback

#### 10.2 Documentation

- **User Guide**: Document features and usage patterns
- **Developer Documentation**: API documentation for components
- **Migration Guide**: Upgrade path for existing projects

## Implementation Roadmap

### Phase 1: Core Backend (M1)
1. Implement `ProjectAnalyzer` class
2. Create project structure JSON generator
3. Integrate with existing `ProjectManager`
4. Add Tauri commands for project operations

### Phase 2: Tree View (M2)
1. Create `TreeView` React component
2. Implement file system rendering
3. Add file selection and opening
4. Integrate with Monaco Editor

### Phase 3: Graph View (M3)
1. Create `GraphView` React component
2. Implement dependency graph visualization
3. Add interactive features (zoom, pan, select)
4. Integrate with graph layout algorithms

### Phase 4: Multi-Project Support (M4)
1. Create `ProjectSelector` component
2. Implement project switching
3. Add multi-project sidebar
4. Enhance state management

### Phase 5: AI Features (M5)
1. Implement dependency AI analysis
2. Add AI hints to GraphView
3. Create circular dependency detection
4. Add optimization suggestions

## Success Metrics

### Performance Metrics
- Project scan time: < 2 seconds for 1000 files
- Graph rendering time: < 500ms for 100 nodes
- Memory usage: < 100MB for large projects

### User Experience Metrics
- Project loading success rate: > 99%
- File selection response time: < 100ms
- User satisfaction: > 4.5/5 rating

### Code Quality Metrics
- Test coverage: > 90%
- Code documentation: > 80%
- Performance regression: < 5% degradation

This architecture provides a comprehensive foundation for implementing the multi-project Tree/Graph View in Noodle-IDE while maintaining compatibility with existing systems and ensuring scalability for future enhancements.
