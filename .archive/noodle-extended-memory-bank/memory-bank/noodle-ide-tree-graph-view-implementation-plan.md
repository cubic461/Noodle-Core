# Noodle-IDE Multi-Project Tree/Graph View Implementation Plan

## Overview

This document outlines the implementation plan for a multi-project Tree/Graph View in Noodle-IDE, allowing users to visualize and navigate multiple projects simultaneously with dependency analysis capabilities.

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Noodle-IDE Frontend                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Project     │  │ Tree/Graph  │  │ Project     │         │
│  │ Selector    │  │ View        │  │ Manager     │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    Tauri Backend                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Project     │  │ File System │  │ Dependency  │         │
│  │ Analyzer    │  │ Operations  │  │ Analyzer    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   Noodle Core                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Runtime     │  │ Language    │  │ File System │         │
│  │ Engine      │  │ Server      │  │ APIs        │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## Detailed Implementation Plan

### Phase 1: Project Analyzer Backend (M1)

#### 1.1 Project Structure Analyzer (`project_analyzer.py`)

**Location**: `noodle-dev/src/noodle/runtime/project_analyzer.py`

**Purpose**: Scan project directories and generate project structure metadata

**Key Components**:
```python
class ProjectAnalyzer:
    def __init__(self, root_path: str):
        self.root_path = Path(root_path)
        self.project_structure = {}

    def scan_directory(self) -> Dict:
        """Scan directory and detect files, languages, and dependencies"""

    def detect_language(self, file_path: Path) -> str:
        """Detect programming language based on file extension and content"""

    def extract_dependencies(self, file_path: Path) -> List[str]:
        """Extract import statements and dependencies from source files"""

    def generate_project_structure(self) -> Dict:
        """Generate comprehensive project structure with metadata"""

    def save_project_structure(self, output_path: Path):
        """Save project structure to .noodle/project_structure.json"""
```

**Supported Languages**:
- Python (.py, requirements.txt, setup.py)
- JavaScript/TypeScript (.js, .ts, package.json)
- Noodle (.noodle)
- JSON, YAML, XML configuration files
- Markdown documentation

**Dependency Detection**:
- Import statements (Python, JavaScript, TypeScript)
- Package managers (pip, npm, yarn)
- Noodle module declarations
- Configuration file references

#### 1.2 Project Manager Enhancement (`project_manager.py`)

**Location**: `noodle-dev/src/noodle/runtime/project_manager.py`

**Enhancements**:
- Add multi-project support
- Project context management
- Project metadata storage

**New Methods**:
```python
class ProjectManager:
    def __init__(self):
        self.projects: Dict[str, ProjectContext] = {}

    def add_project(self, project_path: str, project_name: str) -> ProjectContext:
        """Add a new project to the manager"""

    def remove_project(self, project_id: str) -> bool:
        """Remove a project from the manager"""

    def get_project(self, project_id: str) -> Optional[ProjectContext]:
        """Get project context by ID"""

    def list_projects(self) -> List[ProjectContext]:
        """List all active projects"""

    def switch_project(self, project_id: str) -> bool:
        """Switch active project context"""
```

#### 1.3 Project Context Structure

```python
@dataclass
class ProjectContext:
    id: str
    name: str
    root_path: Path
    project_structure: Dict
    dependencies: Dict[str, List[str]]
    last_updated: datetime
    language: str
    metadata: Dict[str, Any]
```

### Phase 2: TreeView Component (M2)

#### 2.1 Project Tree Component (`ProjectTree.tsx`)

**Location**: `noodle-ide/src/components/ProjectTree.tsx`

**Features**:
- Hierarchical file and directory display
- File type icons and language indicators
- Expandable/collapsible directories
- File selection and opening
- Context menu for file operations

**Interface**:
```typescript
interface ProjectTreeProps {
  project: ProjectContext;
  onFileSelect: (filePath: string) => void;
  onFileOpen: (filePath: string) => void;
  onFileCreate: (dirPath: string, fileName: string) => void;
  onFileDelete: (filePath: string) => void;
  onFileRename: (oldPath: string, newPath: string) => void;
  selectedFile?: string;
}

interface TreeNode {
  id: string;
  name: string;
  type: 'file' | 'directory';
  path: string;
  language?: string;
  children?: TreeNode[];
  icon?: string;
  modified?: Date;
  size?: number;
}
```

#### 2.2 Tree Node Renderer

```typescript
const TreeNode: React.FC<TreeNodeProps> = ({ node, depth, onSelect, onContextMenu }) => {
  const [isExpanded, setIsExpanded] = useState(false);

  const handleToggle = () => {
    if (node.type === 'directory') {
      setIsExpanded(!isExpanded);
    }
  };

  const handleClick = () => {
    onSelect(node);
  };

  return (
    <div className="tree-node" style={{ paddingLeft: `${depth * 20}px` }}>
      <div className="node-content" onClick={handleClick} onContextMenu={() => onContextMenu(node)}>
        <span className="node-icon">{getIcon(node)}</span>
        <span className="node-name">{node.name}</span>
        <span className="node-meta">{getNodeMeta(node)}</span>
      </div>
      {isExpanded && node.children && (
        <div className="node-children">
          {node.children.map(child => (
            <TreeNode key={child.id} node={child} depth={depth + 1} {...props} />
          ))}
        </div>
      )}
    </div>
  );
};
```

#### 2.3 Project Selector Component (`ProjectSelector.tsx`)

**Location**: `noodle-ide/src/components/ProjectSelector.tsx`

**Features**:
- Directory picker for project selection
- Recent projects list
- Project search and filtering
- Project preview with basic stats

**Interface**:
```typescript
interface ProjectSelectorProps {
  onProjectSelect: (projectPath: string, projectName: string) => void;
  currentProjects: ProjectContext[];
  onClose: () => void;
}
```

### Phase 3: GraphView Component (M3)

#### 3.1 Dependency Graph Component (`ProjectGraph.tsx`)

**Location**: `noodle-ide/src/components/ProjectGraph.tsx`

**Features**:
- Interactive dependency visualization
- Force-directed graph layout
- Node filtering and grouping
- Zoom and pan controls
- Dependency path highlighting

**Interface**:
```typescript
interface ProjectGraphProps {
  project: ProjectContext;
  onNodeSelect: (node: GraphNode) => void;
  onEdgeSelect: (edge: GraphEdge) => void;
  selectedNode?: string;
  layout?: 'force' | 'hierarchical' | 'circular';
}

interface GraphNode {
  id: string;
  label: string;
  type: 'file' | 'module' | 'package';
  language?: string;
  path?: string;
  dependencies?: string[];
  dependents?: string[];
  metrics?: NodeMetrics;
}

interface GraphEdge {
  id: string;
  source: string;
  target: string;
  type: 'import' | 'require' | 'include';
  weight?: number;
}
```

#### 3.2 Graph Visualization Engine

**Technology**: D3.js or React Flow

**Features**:
- Force-directed layout algorithm
- Interactive node and edge manipulation
- Zoom and pan controls
- Search and filter functionality
- Export to image/SVG

```typescript
const GraphVisualization: React.FC<GraphVisualizationProps> = ({ nodes, edges, onNodeClick }) => {
  const [simulation, setSimulation] = useState<d3.Simulation<GraphNode, GraphEdge> | null>(null);

  useEffect(() => {
    if (nodes.length > 0 && edges.length > 0) {
      const sim = d3.forceSimulation(nodes)
        .force('link', d3.forceLink(edges).id((d: any) => d.id).distance(100))
        .force('charge', d3.forceManyBody().strength(-300))
        .force('center', d3.forceCenter(width / 2, height / 2));

      setSimulation(sim);
    }
  }, [nodes, edges]);

  return (
    <svg width={width} height={height}>
      <g>
        {edges.map(edge => (
          <line key={edge.id} x1={edge.source.x} y1={edge.source.y}
                x2={edge.target.x} y2={edge.target.y} stroke="#999" strokeWidth={2} />
        ))}
        {nodes.map(node => (
          <g key={node.id} transform={`translate(${node.x},${node.y})`}
             onClick={() => onNodeClick(node)}>
            <circle r={20} fill={getNodeColor(node.type)} />
            <text textAnchor="middle" dy=".35em" fontSize={12} fill="white">
              {node.label}
            </text>
          </g>
        ))}
      </g>
    </svg>
  );
};
```

### Phase 4: Multi-Project Support (M4)

#### 4.1 Project Manager Component (`ProjectManager.tsx`)

**Location**: `noodle-ide/src/components/ProjectManager.tsx`

**Features**:
- Sidebar with list of open projects
- Project switching
- Project context indicators
- Project actions (close, restart, settings)

**Interface**:
```typescript
interface ProjectManagerProps {
  projects: ProjectContext[];
  activeProjectId: string;
  onProjectSwitch: (projectId: string) => void;
  onProjectClose: (projectId: string) => void;
  onProjectSettings: (projectId: string) => void;
}

interface ProjectTab {
  id: string;
  name: string;
  path: string;
  type: 'tree' | 'graph';
  status: 'active' | 'inactive' | 'loading';
  lastModified?: Date;
}
```

#### 4.2 View Switching Component

```typescript
const ViewSwitcher: React.FC<ViewSwitcherProps> = ({ project, onViewChange }) => {
  const [currentView, setCurrentView] = useState<'tree' | 'graph'>('tree');

  const handleViewChange = (view: 'tree' | 'graph') => {
    setCurrentView(view);
    onViewChange(view);
  };

  return (
    <div className="view-switcher">
      <button
        className={`view-button ${currentView === 'tree' ? 'active' : ''}`}
        onClick={() => handleViewChange('tree')}
      >
        <TreeIcon />
        Tree View
      </button>
      <button
        className={`view-button ${currentView === 'graph' ? 'active' : ''}`}
        onClick={() => handleViewChange('graph')}
      >
        <NetworkIcon />
        Graph View
      </button>
    </div>
  );
};
```

#### 4.3 Unified Project Container

```typescript
const ProjectContainer: React.FC<ProjectContainerProps> = ({ project }) => {
  const [view, setView] = useState<'tree' | 'graph'>('tree');
  const [selectedFile, setSelectedFile] = useState<string | null>(null);

  const renderView = () => {
    switch (view) {
      case 'tree':
        return (
          <ProjectTree
            project={project}
            onFileSelect={setSelectedFile}
            selectedFile={selectedFile}
          />
        );
      case 'graph':
        return (
          <ProjectGraph
            project={project}
            onNodeSelect={(node) => {
              if (node.type === 'file' && node.path) {
                setSelectedFile(node.path);
              }
            }}
          />
        );
      default:
        return null;
    }
  };

  return (
    <div className="project-container">
      <div className="project-header">
        <h2>{project.name}</h2>
        <ViewSwitcher project={project} onViewChange={setView} />
      </div>
      <div className="project-content">
        {renderView()}
      </div>
    </div>
  );
};
```

### Phase 5: AI Hints and Analysis (M5)

#### 5.1 Dependency Analyzer (`dependency_analyzer.py`)

**Location**: `noodle-dev/src/noodle/runtime/dependency_analyzer.py`

**Features**:
- Circular dependency detection
- Dead code analysis
- Dependency impact analysis
- Performance bottleneck identification

```python
class DependencyAnalyzer:
    def __init__(self, project_structure: Dict):
        self.project_structure = project_structure
        self.dependency_graph = {}

    def build_dependency_graph(self) -> Dict:
        """Build dependency graph from project structure"""

    def detect_circular_dependencies(self) -> List[List[str]]:
        """Detect circular dependencies in the project"""

    def find_dead_code(self) -> List[str]:
        """Identify potentially unused code"""

    def analyze_dependency_impact(self, file_path: str) -> Dict:
        """Analyze impact of changing a specific file"""

    def identify_bottlenecks(self) -> List[Dict]:
        """Identify potential performance bottlenecks"""
```

#### 5.2 AI Hints Component (`AIHints.tsx`)

**Location**: `noodle-ide/src/components/AIHints.tsx`

**Features**:
- Circular dependency warnings
- Dead code suggestions
- Refactoring recommendations
- Performance optimization hints

```typescript
interface AIHint {
  id: string;
  type: 'warning' | 'suggestion' | 'error';
  title: string;
  description: string;
  location?: string;
  severity: 'low' | 'medium' | 'high';
  action?: {
    label: string;
    callback: () => void;
  };
}

const AIHints: React.FC<AIHintsProps> = ({ project }) => {
  const [hints, setHints] = useState<AIHint[]>([]);

  useEffect(() => {
    // Fetch AI hints from backend
    fetchAIHints(project.id).then(setHints);
  }, [project.id]);

  const getHintIcon = (type: AIHint['type']) => {
    switch (type) {
      case 'warning': return <AlertTriangleIcon />;
      case 'suggestion': return <LightbulbIcon />;
      case 'error': return <XCircleIcon />;
    }
  };

  return (
    <div className="ai-hints">
      <h3>AI Analysis</h3>
      <div className="hints-list">
        {hints.map(hint => (
          <div key={hint.id} className={`hint-item ${hint.type}`}>
            <div className="hint-header">
              {getHintIcon(hint.type)}
              <span className="hint-title">{hint.title}</span>
              <span className={`hint-severity ${hint.severity}`}>
                {hint.severity}
              </span>
            </div>
            <p className="hint-description">{hint.description}</p>
            {hint.location && (
              <div className="hint-location">
                Location: {hint.location}
              </div>
            )}
            {hint.action && (
              <button
                className="hint-action"
                onClick={hint.action.callback}
              >
                {hint.action.label}
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};
```

#### 5.3 Hover Metadata Component

```typescript
const FileMetadataTooltip: React.FC<FileMetadataTooltipProps> = ({ file, position }) => {
  const [isVisible, setIsVisible] = useState(false);

  const handleMouseEnter = () => {
    setIsVisible(true);
  };

  const handleMouseLeave = () => {
    setIsVisible(false);
  };

  return (
    <div
      className="file-metadata-tooltip"
      style={{
        position: 'absolute',
        left: position.x,
        top: position.y,
        display: isVisible ? 'block' : 'none'
      }}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <div className="tooltip-header">
        <h4>{file.name}</h4>
        <span className="file-type">{file.language}</span>
      </div>
      <div className="tooltip-content">
        <div className="metadata-row">
          <span>Size:</span>
          <span>{formatFileSize(file.size)}</span>
        </div>
        <div className="metadata-row">
          <span>Modified:</span>
          <span>{formatDate(file.modified)}</span>
        </div>
        <div className="metadata-row">
          <span>Dependencies:</span>
          <span>{file.dependencies?.length || 0}</span>
        </div>
        <div className="metadata-row">
          <span>Dependents:</span>
          <span>{file.dependents?.length || 0}</span>
        </div>
      </div>
    </div>
  );
};
```

## Integration Points

### 1. Tauri Backend Commands

**File**: `noodle-ide/src-tauri/src/lib.rs`

```rust
#[tauri::command]
async fn analyze_project(project_path: String) -> Result<ProjectAnalysis, String> {
    // Call Python project analyzer
    // Return project structure and dependencies
}

#[tauri::command]
async fn get_project_dependencies(project_id: String) -> Result<Dependencies, String> {
    // Get dependency graph for project
}

#[tauri::command]
async fn get_ai_hints(project_id: String) -> Result<Vec<AIHint>, String> {
    // Get AI analysis hints for project
}
```

### 2. Frontend API Service

**File**: `noodle-ide/src/services/projectApi.ts`

```typescript
export const projectApi = {
  async analyzeProject(projectPath: string): Promise<ProjectAnalysis> {
    return invoke('analyze_project', { projectPath });
  },

  async getProjectDependencies(projectId: string): Promise<Dependencies> {
    return invoke('get_project_dependencies', { projectId });
  },

  async getAIHints(projectId: string): Promise<AIHint[]> {
    return invoke('get_ai_hints', { projectId });
  },

  async openFile(filePath: string): Promise<void> {
    return invoke('open_file', { filePath });
  },

  async createFile(dirPath: string, fileName: string): Promise<void> {
    return invoke('create_file', { dirPath, fileName });
  },

  async deleteFile(filePath: string): Promise<void> {
    return invoke('delete_file', { filePath });
  },

  async renameFile(oldPath: string, newPath: string): Promise<void> {
    return invoke('rename_file', { oldPath, newPath });
  }
};
```

### 3. Main App Integration

**File**: `noodle-ide/src/App.tsx`

```typescript
const App: React.FC = () => {
  const [projects, setProjects] = useState<ProjectContext[]>([]);
  const [activeProjectId, setActiveProjectId] = useState<string | null>(null);

  const handleProjectSelect = async (projectPath: string, projectName: string) => {
    // Add new project
    const project = await addProject(projectPath, projectName);
    setProjects(prev => [...prev, project]);
    setActiveProjectId(project.id);
  };

  const handleProjectSwitch = (projectId: string) => {
    setActiveProjectId(projectId);
  };

  return (
    <div className="app">
      <ProjectSelector onProjectSelect={handleProjectSelect} />

      <div className="main-content">
        <ProjectManager
          projects={projects}
          activeProjectId={activeProjectId}
          onProjectSwitch={handleProjectSwitch}
        />

        {activeProjectId && (
          <ProjectContainer
            project={projects.find(p => p.id === activeProjectId)}
          />
        )}
      </div>
    </div>
  );
};
```

## Testing Strategy

### 1. Unit Tests

**Project Analyzer**:
- Directory scanning functionality
- Language detection accuracy
- Dependency extraction correctness
- Project structure generation

**Tree View**:
- Node rendering
- Tree expansion/collapse
- File selection handling
- Context menu actions

**Graph View**:
- Graph layout algorithms
- Node and edge interactions
- Zoom and pan functionality
- Search and filtering

### 2. Integration Tests

**Project Management**:
- Project creation and deletion
- Project switching
- File operations across projects
- Dependency tracking

**Frontend-Backend**:
- API communication
- File system operations
- Real-time updates
- Error handling

### 3. End-to-End Tests

**User Workflows**:
- Project selection and opening
- Navigation between Tree and Graph views
- File opening and editing
- AI hint generation and interaction

## Performance Considerations

### 1. Large Project Handling

- Virtual scrolling for file trees
- Lazy loading of graph nodes
- Incremental updates for project changes
- Debounced file system operations

### 2. Memory Management

- Efficient data structures for dependency graphs
- Cleanup of unused project contexts
- Garbage collection for old analysis data
- Optimized rendering with React.memo

### 3. Caching Strategy

- Project structure caching
- Dependency graph caching
- File metadata caching
- AI hints caching with expiration

## Security Considerations

### 1. File System Access

- Path validation to prevent directory traversal
- Permission checking for file operations
- Sandboxed project contexts
- Secure file handling

### 2. Data Protection

- Encrypted project metadata storage
- Secure communication with backend
- User data isolation
- Audit logging for sensitive operations

## Deployment and Maintenance

### 1. Version Control

- Semantic versioning for components
- Backward compatibility for project formats
- Migration scripts for older projects
- Change log documentation

### 2. Monitoring

- Performance metrics collection
- Error tracking and reporting
- User behavior analytics
- System health monitoring

### 3. Updates

- Automatic project structure updates
- Dependency analysis improvements
- AI model updates
- UI/UX enhancements

## Timeline and Milestones

### Week 1-2: Project Analyzer Backend
- [ ] Implement directory scanning
- [ ] Add language detection
- [ ] Create dependency extraction
- [ ] Generate project structure JSON

### Week 3-4: TreeView Component
- [ ] Create ProjectTree component
- [ ] Implement file operations
- [ ] Add project selector
- [ ] Integrate with backend

### Week 5-6: GraphView Component
- [ ] Create ProjectGraph component
- [ ] Implement graph visualization
- [ ] Add interactive features
- [ ] Optimize performance

### Week 7-8: Multi-Project Support
- [ ] Implement project manager
- [ ] Add view switching
- [ ] Create project tabs
- [ ] Handle project contexts

### Week 9-10: AI Hints and Analysis
- [ ] Implement dependency analyzer
- [ ] Create AI hints component
- [ ] Add hover metadata
- [ ] Integrate analysis features

### Week 11-12: Testing and Refinement
- [ ] Unit and integration tests
- [ ] Performance optimization
- [ ] Security review
- [ ] Documentation and deployment

## Success Metrics

### 1. Technical Metrics

- Project loading time < 2 seconds for 1000+ files
- Graph rendering time < 1 second for 500+ nodes
- Memory usage < 100MB for typical projects
- 95%+ test coverage

### 2. User Experience Metrics

- Task completion time for common operations
- User satisfaction surveys
- Feature adoption rates
- Error frequency and resolution time

### 3. Quality Metrics

- Bug density < 0.1 per KLOC
- Code review compliance
- Documentation completeness
- Performance regression prevention

## Conclusion

This implementation plan provides a comprehensive approach to building a multi-project Tree/Graph View for Noodle-IDE. The modular design allows for incremental development and testing, while the focus on performance, security, and user experience ensures a high-quality result. The plan aligns with the existing architecture and follows best practices for React, Tauri, and Python development.
