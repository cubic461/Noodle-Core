"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NoodleWorkspaceManager = void 0;
const path = __importStar(require("path"));
const vscode = __importStar(require("vscode"));
/**
 * NoodleCore Workspace Manager
 *
 * Manages NoodleCore workspace structure, project explorer,
 * and file management functionality.
 */
class NoodleWorkspaceManager {
    constructor(context) {
        this.context = context;
        this.disposables = [];
        this.projectExplorerProvider = new NoodleProjectExplorerProvider();
        this.initializeWorkspace();
        this.registerCommands();
        this.setupEventHandlers();
    }
    /**
     * Initialize workspace
     */
    async initializeWorkspace() {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (workspaceFolders && workspaceFolders.length > 0) {
            this.workspaceRoot = workspaceFolders[0].uri;
            await this.detectProjectType();
            await this.setupWorkspaceStructure();
        }
    }
    /**
     * Detect NoodleCore project type
     */
    async detectProjectType() {
        if (!this.workspaceRoot) {
            return;
        }
        // Check for project configuration files
        const configFiles = [
            'noodle.json',
            'noodle.config.json',
            '.noodleconfig',
            'project.noodle'
        ];
        for (const configFile of configFiles) {
            const configPath = vscode.Uri.joinPath(this.workspaceRoot, configFile);
            try {
                await vscode.workspace.fs.stat(configPath);
                this.loadProjectConfig(configPath);
                return;
            }
            catch (error) {
                // Config file doesn't exist, continue checking
            }
        }
        // No config found, create default project structure
        await this.createDefaultProject();
    }
    /**
     * Load project configuration
     */
    async loadProjectConfig(configPath) {
        try {
            const configContent = await vscode.workspace.fs.readFile(configPath);
            const config = JSON.parse(configContent.toString());
            // Update workspace state with project configuration
            this.context.workspaceState.update('noodleProjectConfig', config);
            vscode.window.showInformationMessage(`NoodleCore project loaded: ${config.name || 'Untitled Project'}`);
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to load NoodleCore project configuration: ${error}`);
        }
    }
    /**
     * Create default project structure
     */
    async createDefaultProject() {
        if (!this.workspaceRoot) {
            return;
        }
        const projectName = path.basename(this.workspaceRoot.fsPath);
        // Create default directories
        const directories = [
            'src',
            'src/agents',
            'src/models',
            'src/pipelines',
            'src/datasets',
            'tests',
            'docs',
            'config',
            'output',
            '.noodle'
        ];
        for (const dir of directories) {
            const dirPath = vscode.Uri.joinPath(this.workspaceRoot, dir);
            try {
                await vscode.workspace.fs.createDirectory(dirPath);
            }
            catch (error) {
                // Directory might already exist
            }
        }
        // Create default project configuration
        const defaultConfig = {
            name: projectName,
            version: '1.0.0',
            description: 'NoodleCore AI Project',
            author: '',
            license: 'MIT',
            dependencies: {
                'noodle-core': '^1.0.0'
            },
            scripts: {
                'build': 'noodle build',
                'run': 'noodle run',
                'test': 'noodle test',
                'debug': 'noodle debug'
            },
            ai: {
                defaultModel: 'gpt-4',
                agents: [],
                models: [],
                pipelines: []
            }
        };
        const configPath = vscode.Uri.joinPath(this.workspaceRoot, 'noodle.json');
        const configContent = JSON.stringify(defaultConfig, null, 2);
        await vscode.workspace.fs.writeFile(configPath, Buffer.from(configContent));
        vscode.window.showInformationMessage(`Created default NoodleCore project structure for ${projectName}`);
    }
    /**
     * Setup workspace structure
     */
    async setupWorkspaceStructure() {
        if (!this.workspaceRoot) {
            return;
        }
        // Register project explorer
        const treeDataProvider = vscode.window.createTreeView('noodleProjectExplorer', {
            treeDataProvider: this.projectExplorerProvider,
            showCollapseAll: true
        });
        this.disposables.push(treeDataProvider);
        // Setup file watchers
        const fileWatcher = vscode.workspace.createFileSystemWatcher(new vscode.RelativePattern(this.workspaceRoot, '**/*.{nc,noodle,json,md}'));
        fileWatcher.onDidChange(() => this.refreshProjectExplorer());
        fileWatcher.onDidCreate(() => this.refreshProjectExplorer());
        fileWatcher.onDidDelete(() => this.refreshProjectExplorer());
        this.disposables.push(fileWatcher);
    }
    /**
     * Register workspace commands
     */
    registerCommands() {
        // Create new NoodleCore project
        const createProjectCommand = vscode.commands.registerCommand('noodle.createProject', () => this.createNewProject());
        this.disposables.push(createProjectCommand);
        // Add new agent
        const addAgentCommand = vscode.commands.registerCommand('noodle.addAgent', () => this.addNewAgent());
        this.disposables.push(addAgentCommand);
        // Add new model
        const addModelCommand = vscode.commands.registerCommand('noodle.addModel', () => this.addNewModel());
        this.disposables.push(addModelCommand);
        // Add new pipeline
        const addPipelineCommand = vscode.commands.registerCommand('noodle.addPipeline', () => this.addNewPipeline());
        this.disposables.push(addPipelineCommand);
        // Build project
        const buildCommand = vscode.commands.registerCommand('noodle.build', () => this.buildProject());
        this.disposables.push(buildCommand);
        // Run project
        const runCommand = vscode.commands.registerCommand('noodle.run', () => this.runProject());
        this.disposables.push(runCommand);
        // Debug project
        const debugCommand = vscode.commands.registerCommand('noodle.debug', () => this.debugProject());
        this.disposables.push(debugCommand);
        // Refresh project explorer
        const refreshCommand = vscode.commands.registerCommand('noodle.refreshExplorer', () => this.refreshProjectExplorer());
        this.disposables.push(refreshCommand);
    }
    /**
     * Setup event handlers
     */
    setupEventHandlers() {
        // Handle workspace folder changes
        const workspaceChangeDisposable = vscode.workspace.onDidChangeWorkspaceFolders(() => {
            this.initializeWorkspace();
        });
        this.disposables.push(workspaceChangeDisposable);
    }
    /**
     * Create new NoodleCore project
     */
    async createNewProject() {
        const projectPath = await vscode.window.showOpenDialog({
            canSelectFolders: true,
            canSelectFiles: false,
            openLabel: 'Select Project Directory'
        });
        if (projectPath && projectPath.length > 0) {
            const workspaceRoot = projectPath[0];
            const projectName = await vscode.window.showInputBox({
                prompt: 'Project Name',
                placeHolder: 'My NoodleCore Project'
            });
            if (projectName) {
                // Create project structure
                await this.createProjectStructure(workspaceRoot, projectName);
                // Open the new project
                vscode.commands.executeCommand('vscode.openFolder', workspaceRoot);
            }
        }
    }
    /**
     * Create project structure
     */
    async createProjectStructure(projectPath, projectName) {
        const directories = [
            'src',
            'src/agents',
            'src/models',
            'src/pipelines',
            'src/datasets',
            'tests',
            'docs',
            'config',
            'output',
            '.noodle'
        ];
        for (const dir of directories) {
            const dirUri = vscode.Uri.joinPath(projectPath, dir);
            await vscode.workspace.fs.createDirectory(dirUri);
        }
        // Create project configuration
        const config = {
            name: projectName,
            version: '1.0.0',
            description: 'NoodleCore AI Project',
            author: '',
            license: 'MIT',
            dependencies: {
                'noodle-core': '^1.0.0'
            },
            scripts: {
                'build': 'noodle build',
                'run': 'noodle run',
                'test': 'noodle test',
                'debug': 'noodle debug'
            },
            ai: {
                defaultModel: 'gpt-4',
                agents: [],
                models: [],
                pipelines: []
            }
        };
        const configUri = vscode.Uri.joinPath(projectPath, 'noodle.json');
        const configContent = JSON.stringify(config, null, 2);
        await vscode.workspace.fs.writeFile(configUri, Buffer.from(configContent));
        // Create main entry file
        const mainUri = vscode.Uri.joinPath(projectPath, 'src/main.nc');
        const mainContent = `// ${projectName}
// Main entry point for NoodleCore AI project

func main() {
    println("Hello, NoodleCore AI!");
    
    // Initialize AI agents
    // TODO: Add your AI agents here
    
    // Load models
    // TODO: Add your AI models here
    
    // Setup pipelines
    // TODO: Add your AI pipelines here
}

main();
`;
        await vscode.workspace.fs.writeFile(mainUri, Buffer.from(mainContent));
    }
    /**
     * Add new agent
     */
    async addNewAgent() {
        if (!this.workspaceRoot) {
            vscode.window.showErrorMessage('No workspace opened');
            return;
        }
        const agentName = await vscode.window.showInputBox({
            prompt: 'Agent Name',
            placeHolder: 'MyAgent'
        });
        if (agentName) {
            const agentPath = vscode.Uri.joinPath(this.workspaceRoot, `src/agents/${agentName}.nc`);
            const agentContent = `// ${agentName} Agent
// AI Agent definition for ${agentName}

agent ${agentName} {
    role: "assistant",
    capabilities: ["code_analysis", "debugging", "optimization"],
    tools: ["editor", "terminal", "file_system"],
    prompt: "You are a helpful AI assistant specialized in ${agentName} tasks.",
    model: "gpt-4",
    temperature: 0.7,
    max_tokens: 2048
}

// Agent implementation
func ${agentName.toLowerCase()}_execute(task: string) {
    println("Executing ${agentName} agent for task: " + task);
    
    // TODO: Implement agent logic here
    
    return "Task completed by ${agentName}";
}
`;
            await vscode.workspace.fs.writeFile(agentPath, Buffer.from(agentContent));
            // Open the new agent file
            const document = await vscode.workspace.openTextDocument(agentPath);
            await vscode.window.showTextDocument(document);
            this.refreshProjectExplorer();
        }
    }
    /**
     * Add new model
     */
    async addNewModel() {
        if (!this.workspaceRoot) {
            vscode.window.showErrorMessage('No workspace opened');
            return;
        }
        const modelName = await vscode.window.showInputBox({
            prompt: 'Model Name',
            placeHolder: 'MyModel'
        });
        if (modelName) {
            const modelPath = vscode.Uri.joinPath(this.workspaceRoot, `src/models/${modelName}.nc`);
            const modelContent = `// ${modelName} Model
// AI Model definition for ${modelName}

ai model ${modelName} {
    type: "neural_network",
    architecture: "feedforward",
    layers: [
        { type: "input", size: 784 },
        { type: "hidden", size: 128, activation: "relu" },
        { type: "output", size: 10, activation: "softmax" }
    ],
    optimizer: "adam",
    loss: "categorical_crossentropy",
    metrics: ["accuracy"],
    learning_rate: 0.001,
    batch_size: 32,
    epochs: 10
}

// Model training function
func ${modelName.toLowerCase()}_train(dataset: Dataset) {
    println("Training ${modelName} model...");
    
    // TODO: Implement training logic here
    
    return "Training completed";
}

// Model prediction function
func ${modelName.toLowerCase()}_predict(input: Tensor) {
    println("Making prediction with ${modelName} model...");
    
    // TODO: Implement prediction logic here
    
    return prediction_result;
}
`;
            await vscode.workspace.fs.writeFile(modelPath, Buffer.from(modelContent));
            // Open the new model file
            const document = await vscode.workspace.openTextDocument(modelPath);
            await vscode.window.showTextDocument(document);
            this.refreshProjectExplorer();
        }
    }
    /**
     * Add new pipeline
     */
    async addNewPipeline() {
        if (!this.workspaceRoot) {
            vscode.window.showErrorMessage('No workspace opened');
            return;
        }
        const pipelineName = await vscode.window.showInputBox({
            prompt: 'Pipeline Name',
            placeHolder: 'MyPipeline'
        });
        if (pipelineName) {
            const pipelinePath = vscode.Uri.joinPath(this.workspaceRoot, `src/pipelines/${pipelineName}.nc`);
            const pipelineContent = `// ${pipelineName} Pipeline
// AI Pipeline definition for ${pipelineName}

pipeline ${pipelineName} {
    input: "dataset",
    output: "model",
    steps: [
        {
            name: "preprocess",
            type: "data_preprocessing",
            config: {
                normalize: true,
                remove_outliers: true,
                fill_missing: "mean"
            }
        },
        {
            name: "train",
            type: "model_training",
            config: {
                epochs: 10,
                batch_size: 32,
                validation_split: 0.2
            }
        },
        {
            name: "evaluate",
            type: "model_evaluation",
            config: {
                metrics: ["accuracy", "precision", "recall", "f1_score"]
            }
        }
    ],
    parallel: false,
    cache_intermediate: true
}

// Pipeline execution function
func ${pipelineName.toLowerCase()}_run(data: Dataset) {
    println("Running ${pipelineName} pipeline...");
    
    // TODO: Implement pipeline logic here
    
    return pipeline_result;
}
`;
            await vscode.workspace.fs.writeFile(pipelinePath, Buffer.from(pipelineContent));
            // Open the new pipeline file
            const document = await vscode.workspace.openTextDocument(pipelinePath);
            await vscode.window.showTextDocument(document);
            this.refreshProjectExplorer();
        }
    }
    /**
     * Build project
     */
    async buildProject() {
        if (!this.workspaceRoot) {
            vscode.window.showErrorMessage('No workspace opened');
            return;
        }
        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: 'Building NoodleCore Project',
            cancellable: true
        }, async (progress, token) => {
            progress.report({ increment: 0, message: 'Starting build...' });
            // TODO: Implement actual build logic
            // This would integrate with NoodleCore build system
            progress.report({ increment: 50, message: 'Compiling...' });
            // Simulate build process
            await new Promise(resolve => setTimeout(resolve, 2000));
            progress.report({ increment: 50, message: 'Finalizing...' });
            if (token.isCancellationRequested) {
                return;
            }
            vscode.window.showInformationMessage('Build completed successfully!');
        });
    }
    /**
     * Run project
     */
    async runProject() {
        if (!this.workspaceRoot) {
            vscode.window.showErrorMessage('No workspace opened');
            return;
        }
        // TODO: Implement actual run logic
        // This would integrate with NoodleCore runtime
        const terminal = vscode.window.createTerminal({
            name: 'NoodleCore Run',
            cwd: this.workspaceRoot.fsPath
        });
        terminal.sendText('noodle run');
        terminal.show();
    }
    /**
     * Debug project
     */
    async debugProject() {
        if (!this.workspaceRoot) {
            vscode.window.showErrorMessage('No workspace opened');
            return;
        }
        // TODO: Implement actual debug logic
        // This would integrate with NoodleCore debug adapter
        vscode.debug.startDebugging(undefined, {
            type: 'noodle',
            name: 'Debug NoodleCore Project',
            request: 'launch',
            program: '${workspaceFolder}/src/main.nc',
            cwd: '${workspaceFolder}',
            console: 'integratedTerminal'
        });
    }
    /**
     * Refresh project explorer
     */
    refreshProjectExplorer() {
        this.projectExplorerProvider.refresh();
    }
    /**
     * Compile active file
     */
    async compileActiveFile() {
        const activeEditor = vscode.window.activeTextEditor;
        if (!activeEditor) {
            vscode.window.showErrorMessage('No active file to compile');
            return;
        }
        const document = activeEditor.document;
        const fileName = path.basename(document.uri.fsPath);
        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: `Compiling ${fileName}`,
            cancellable: true
        }, async (progress, token) => {
            progress.report({ increment: 0, message: 'Starting compilation...' });
            // TODO: Implement actual compilation with NoodleCore backend
            // This would integrate with the backend server
            progress.report({ increment: 50, message: 'Compiling...' });
            // Simulate compilation process
            await new Promise(resolve => setTimeout(resolve, 1500));
            progress.report({ increment: 50, message: 'Finalizing...' });
            if (token.isCancellationRequested) {
                return;
            }
            vscode.window.showInformationMessage(`✅ ${fileName} compiled successfully!`);
        });
    }
    /**
     * Run active file
     */
    async runActiveFile() {
        const activeEditor = vscode.window.activeTextEditor;
        if (!activeEditor) {
            vscode.window.showErrorMessage('No active file to run');
            return;
        }
        const document = activeEditor.document;
        const fileName = path.basename(document.uri.fsPath);
        // TODO: Implement actual execution with NoodleCore backend
        // This would integrate with the backend server
        const terminal = vscode.window.createTerminal({
            name: 'NoodleCore Run',
            cwd: this.workspaceRoot?.fsPath
        });
        terminal.sendText(`noodle run "${document.uri.fsPath}"`);
        terminal.show();
        vscode.window.showInformationMessage(`🏃 Running ${fileName}...`);
    }
    /**
     * Dispose workspace manager
     */
    dispose() {
        this.disposables.forEach(disposable => disposable.dispose());
    }
}
exports.NoodleWorkspaceManager = NoodleWorkspaceManager;
/**
 * NoodleCore Project Explorer Provider
 */
class NoodleProjectExplorerProvider {
    constructor() {
        this._onDidChangeTreeData = new vscode.EventEmitter();
        this.onDidChangeTreeData = this._onDidChangeTreeData.event;
        this.updateWorkspaceRoot();
    }
    /**
     * Update workspace root
     */
    updateWorkspaceRoot() {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (workspaceFolders && workspaceFolders.length > 0) {
            this.workspaceRoot = workspaceFolders[0].uri;
        }
    }
    /**
     * Refresh tree data
     */
    refresh() {
        this._onDidChangeTreeData.fire(undefined);
    }
    /**
     * Get tree item
     */
    getTreeItem(element) {
        return element;
    }
    /**
     * Get children
     */
    async getChildren(element) {
        if (!this.workspaceRoot) {
            return [];
        }
        if (!element) {
            // Root level
            return this.getRootItems();
        }
        // Get children of element
        return element.getChildren();
    }
    /**
     * Get root items
     */
    async getRootItems() {
        const items = [];
        // Add source directory
        items.push(new NoodleProjectItem('src', vscode.TreeItemCollapsibleState.Expanded, vscode.Uri.joinPath(this.workspaceRoot, 'src'), 'folder'));
        // Add tests directory
        items.push(new NoodleProjectItem('tests', vscode.TreeItemCollapsibleState.Expanded, vscode.Uri.joinPath(this.workspaceRoot, 'tests'), 'folder'));
        // Add docs directory
        items.push(new NoodleProjectItem('docs', vscode.TreeItemCollapsibleState.Collapsed, vscode.Uri.joinPath(this.workspaceRoot, 'docs'), 'folder'));
        // Add config directory
        items.push(new NoodleProjectItem('config', vscode.TreeItemCollapsibleState.Collapsed, vscode.Uri.joinPath(this.workspaceRoot, 'config'), 'folder'));
        // Add output directory
        items.push(new NoodleProjectItem('output', vscode.TreeItemCollapsibleState.Collapsed, vscode.Uri.joinPath(this.workspaceRoot, 'output'), 'folder'));
        // Add project configuration file
        items.push(new NoodleProjectItem('noodle.json', vscode.TreeItemCollapsibleState.None, vscode.Uri.joinPath(this.workspaceRoot, 'noodle.json'), 'file'));
        return items;
    }
}
/**
 * NoodleCore Project Item
 */
class NoodleProjectItem extends vscode.TreeItem {
    constructor(label, collapsibleState, resourceUri, itemType) {
        super(label, collapsibleState);
        this.label = label;
        this.collapsibleState = collapsibleState;
        this.resourceUri = resourceUri;
        this.itemType = itemType;
        this.children = [];
        this.tooltip = `${this.itemType}: ${this.label}`;
        this.contextValue = this.itemType;
        if (this.itemType === 'file') {
            this.command = {
                command: 'vscode.open',
                title: 'Open File',
                arguments: [this.resourceUri]
            };
        }
    }
    /**
     * Get children
     */
    async getChildren() {
        if (this.itemType === 'file' || !this.resourceUri) {
            return [];
        }
        try {
            const entries = await vscode.workspace.fs.readDirectory(this.resourceUri);
            const items = [];
            for (const [name, type] of entries) {
                const childUri = vscode.Uri.joinPath(this.resourceUri, name);
                const isDirectory = type === vscode.FileType.Directory;
                items.push(new NoodleProjectItem(name, isDirectory ? vscode.TreeItemCollapsibleState.Collapsed : vscode.TreeItemCollapsibleState.None, childUri, isDirectory ? 'folder' : 'file'));
            }
            return items;
        }
        catch (error) {
            console.error(`Error reading directory ${this.resourceUri}:`, error);
            return [];
        }
    }
}
//# sourceMappingURL=workspaceManager.js.map