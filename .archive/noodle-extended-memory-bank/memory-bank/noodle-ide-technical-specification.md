# Noodle IDE Technical Specification

## Architecture Overview

The Noodle IDE will be built as a modern, cross-platform desktop application using Tauri (Rust backend + Web frontend) with Monaco Editor as the core editing component. This approach provides native performance, small binary size, and access to system APIs while maintaining web-based UI flexibility.

## Technology Stack

### Frontend
- **Framework**: React 18 with TypeScript
- **Editor**: Monaco Editor (VS Code's editor component)
- **UI Components**: Tailwind CSS + Headless UI
- **State Management**: Zustand for lightweight state management
- **Build Tool**: Vite for fast development and building
- **3D Visualization**: Three.js with React Three Fiber for WebGL-based 3D rendering
- **Data Visualization**: D3.js for advanced graph layouts and data analysis
- **Web Workers**: For heavy computation without UI blocking

### Backend
- **Framework**: Tauri (Rust-based)
- **File System**: Direct integration with Noodle Core filesystem
- **Process Management**: Rust-based process spawning and management
- **IPC**: Tauri's built-in IPC for frontend-backend communication

### Integration
- **Noodle Core**: Direct API calls to Noodle runtime
- **Language Server**: Custom LSP implementation in Noodle Core
- **File Watching**: Tauri's file system watcher API
- **Terminal**: Integrated terminal using xterm.js

## Component Architecture

### Core Components

#### 1. Editor Component
```typescript
interface EditorProps {
  filePath: string;
  content: string;
  language: string;
  onChange: (content: string) => void;
  onSave: () => void;
  diagnostics: Diagnostic[];
}
```

**Features**:
- Monaco Editor with Noodle language support
- Syntax highlighting via custom language definition
- Error squiggles and diagnostics
- Code folding and minimap
- Multiple cursor support
- Find and replace
- Auto-save functionality

#### 2. File Explorer Component
```typescript
interface FileExplorerProps {
  rootPath: string;
  onFileSelect: (path: string) => void;
  onFileCreate: (path: string) => void;
  onFileDelete: (path: string) => void;
  onFileRename: (oldPath: string, newPath: string) => void;
}
```

**Features**:
- Tree view of project files
- File creation, deletion, renaming
- Drag and drop support
- Context menus
- File icons based on extension
- Git status indicators

#### 3. Console Component
```typescript
interface ConsoleProps {
  output: ConsoleOutput[];
  onCommand: (command: string) => void;
  clearConsole: () => void;
}
```

**Features**:
- Real-time output from Noodle runtime
- Command input with history
- Syntax highlighting for output
- Clear and export functionality
- Multiple output channels (stdout, stderr, debug)

#### 4. 3D "Noodle Brain" Visualization Component
```typescript
interface NoodleBrainProps {
  projectData: ProjectGraphData;
  viewMode: '2d' | '3d';
  onNodeSelect: (nodeId: string) => void;
  onNodeFocus: (nodeId: string) => void;
  layoutAlgorithm: 'force' | 'hierarchical' | 'circular';
  showDependencies: boolean;
  showCodeFlow: boolean;
  aiInsights: AIInsight[];
}
```

**Features**:
- Interactive 3D visualization of project structure as a neural network
- Real-time updates of code relationships and dependencies
- Multiple layout algorithms for different perspectives
- AI-powered insights and recommendations
- Seamless switching between 2D and 3D views
- Node filtering and grouping capabilities
- Performance metrics visualization in 3D space
- Code flow animation and dependency highlighting

**Technical Implementation**:
- Built with Three.js and React Three Fiber for WebGL rendering
- Web Workers for heavy graph computation without UI blocking
- Rust-based backend for efficient graph analysis and layout calculation
- Custom shaders for visual effects and performance optimization
- GPU-accelerated rendering for large-scale project visualizations

#### 5. Debug Panel Component
```typescript
interface DebugPanelProps {
  breakpoints: Breakpoint[];
  variables: Variable[];
  callStack: StackFrame[];
  onBreakpointToggle: (line: number) => void;
  onStepOver: () => void;
  onStepInto: () => void;
  onStepOut: () => void;
}
```

**Features**:
- Breakpoint management
- Variable inspection
- Call stack visualization
- Step debugging controls
- Watch expressions

#### 5. 3D Brain Visualization Component
```typescript
interface BrainVisualizationProps {
  projectData: ProjectData;
  selectedNode: string | null;
  onNodeSelect: (nodeId: string) => void;
  onNodeHover: (nodeId: string) => void;
  viewMode: 'structure' | 'dependencies' | 'performance';
  filters: VisualizationFilters;
}
```

**Features**:
- Interactive 3D project structure visualization
- Real-time dependency mapping and analysis
- Force-directed graph layout algorithms
- Node filtering and grouping by type/functionality
- Performance metrics visualization
- Integration with AI assistant for code insights
- WebGL-based rendering with Three.js
- Camera controls (zoom, rotate, pan)
- Node selection and highlighting
- Context-sensitive information panels

### Layout System

```typescript
interface LayoutState {
  panels: {
    fileExplorer: { visible: boolean; width: number };
    editor: { visible: boolean; activeTab: string };
    console: { visible: boolean; height: number };
    debug: { visible: boolean; height: number };
    aiAssistant: { visible: boolean; width: number };
  };
  theme: 'light' | 'dark';
  fontSize: number;
}
```

**Features**:
- Resizable panels with persistence
- Collapsible sections
- Multiple editor tabs
- Draggable panel arrangement
- Theme switching
- Font size adjustment

## Integration with Noodle Core

### File System Integration

```rust
// Tauri command for file operations
#[tauri::command]
async fn read_file(path: String) -> Result<String, String> {
    // Call Noodle Core filesystem API
    let content = noodle_core::filesystem::read_file(&path)?;
    Ok(content)
}

#[tauri::command]
async fn write_file(path: String, content: String) -> Result<(), String> {
    // Call Noodle Core filesystem API
    noodle_core::filesystem::write_file(&path, &content)?;
    Ok(())
}

#[tauri::command]
async fn list_directory(path: String) -> Result<Vec<FileEntry>, String> {
    // Call Noodle Core filesystem API
    let entries = noodle_core::filesystem::list_directory(&path)?;
    Ok(entries)
}
```

### Runtime Integration

```rust
#[tauri::command]
async fn execute_noodle_code(code: String) -> Result<ExecutionResult, String> {
    // Execute code in Noodle runtime
    let result = noodle_core::runtime::execute(&code)?;
    Ok(result)
}

#[tauri::command]
async fn get_runtime_output() -> Result<Vec<OutputLine>, String> {
    // Get output from Noodle runtime
    let output = noodle_core::runtime::get_output()?;
    Ok(output)
}
```

### Language Server Protocol

```typescript
interface LanguageServer {
  initialize(): Promise<InitializeResult>;
  onDidChangeTextDocument(params: DidChangeTextDocumentParams): Promise<void>;
  onCompletion(params: CompletionParams): Promise<CompletionItem[]>;
  onHover(params: HoverParams): Promise<Hover | null>;
  onDefinition(params: DefinitionParams): Promise<Location | null>;
  onDiagnostics(): Promise<Diagnostic[]>;
}
```

## Performance Considerations

### Editor Performance
- Virtual scrolling for large files
- Debounced change events
- Incremental syntax highlighting
- Lazy loading of file content
- Memory-efficient text buffer management

### File System Performance
- Cached file tree structure
- Incremental file watching
- Batch file operations
- Async I/O operations
- Optimized directory traversal

### UI Performance
- React.memo for component optimization
- Virtual lists for large directories
- Debounced resize events
- Lazy loading of UI components
- Efficient state updates

## Security Considerations

### File System Access
- Sandboxed file access through Tauri
- Path validation and sanitization
- Permission-based file operations
- Secure file watching
- Protection against directory traversal

### Code Execution
- Isolated runtime environment
- Resource limits for executed code
- Safe error handling
- Input validation
- Output sanitization

## Development Workflow

### Project Structure
```
noodle-ide/
├── src/
│   ├── components/          # React components
│   ├── services/           # Business logic and API calls
│   ├── hooks/              # Custom React hooks
│   ├── utils/              # Utility functions
│   ├── types/              # TypeScript type definitions
│   └── App.tsx             # Main application component
├── src-tauri/
│   ├── src/
│   │   ├── main.rs         # Tauri application entry point
│   │   ├── commands.rs     # Tauri command handlers
│   │   └── noodle_integration.rs # Noodle Core integration
│   └── Cargo.toml          # Rust dependencies
├── public/                 # Static assets
├── tests/                  # Test files
└── package.json            # Node.js dependencies
```

### Build Process
1. **Development**: `npm run tauri dev` - Hot reload for both frontend and backend
2. **Building**: `npm run tauri build` - Create production binaries
3. **Testing**: `npm test` - Run unit and integration tests
4. **Linting**: `npm run lint` - Code quality checks

### Testing Strategy
- Unit tests for individual components
- Integration tests for Tauri commands
- End-to-end tests for critical workflows
- Performance tests for large file handling
- Security tests for file system access

## Deployment

### Distribution
- **Windows**: MSI installer and portable executable
- **macOS**: DMG installer and app bundle
- **Linux**: AppImage, DEB, and RPM packages

### Auto-updater
- Tauri's built-in auto-updater
- GitHub releases for distribution
- Delta updates for efficiency
- Rollback capability for failed updates

## Future Enhancements

### Plugin System
- WebAssembly-based plugins
- Plugin marketplace
- API for extending functionality
- Sandboxed plugin execution

### 3D "Noodle Brain" Visualization
- **Technology Stack**: Three.js for WebGL rendering, React Three Fiber for React integration
- **Core Components**:
  - `src/components/BrainVisualization/` - 3D visualization components
  - `src/services/GraphAnalyzer.ts` - Dependency analysis service
  - `src-tauri/src/brain_commands.rs` - Rust backend for 3D data processing
- **Features**:
  - Interactive 3D project structure visualization
  - Real-time dependency mapping and analysis
  - Force-directed graph layout algorithms
  - Node filtering and grouping by type/functionality
  - Performance metrics visualization
  - Integration with AI assistant for code insights

### Collaboration Features
- Real-time collaborative editing
- Shared debugging sessions
- Code review integration
- Team project management

### Advanced AI Integration
- Context-aware code suggestions
- Automated refactoring
- Performance optimization hints
- Documentation generation
- Test case generation

This technical specification provides a comprehensive foundation for building the Noodle IDE with modern technologies, robust integration with Noodle Core, and a scalable architecture for future enhancements.
