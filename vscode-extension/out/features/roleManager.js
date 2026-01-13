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
exports.RoleManager = void 0;
const vscode = __importStar(require("vscode"));
const roleBasedAIService_1 = require("../services/roleBasedAIService");
class RoleManager {
    constructor(context) {
        this.context = context;
        this.disposables = [];
        this.roleService = new roleBasedAIService_1.RoleBasedAIService();
        this.outputChannel = vscode.window.createOutputChannel('Noodle AI Role Manager');
        this.statusBarItem = vscode.window.createStatusBarItem('noodle.roleManager', vscode.StatusBarAlignment.Right, 110);
        this.state = {
            currentRole: null,
            availableRoles: [],
            recentRoles: [],
            favoriteRoles: [],
            workspaceRoles: {}
        };
        this.loadState();
        this.setupStatusBar();
        this.registerCommands();
        this.setupEventHandlers();
    }
    /**
     * Load saved state from workspace
     */
    async loadState() {
        try {
            // Load from workspace state
            const savedState = this.context.workspaceState.get('noodleRoleManagerState');
            if (savedState) {
                this.state = { ...this.state, ...savedState };
            }
            // Load recent roles from global state
            const recentRoles = this.context.globalState.get('noodleRecentRoles', []);
            this.state.recentRoles = recentRoles;
            // Load favorite roles from global state
            const favoriteRoles = this.context.globalState.get('noodleFavoriteRoles', []);
            this.state.favoriteRoles = favoriteRoles;
            // Initialize role service
            await this.roleService.initializeRoles();
            this.state.availableRoles = this.roleService.getAvailableRoles();
            this.state.currentRole = this.roleService.getCurrentRole();
            // Restore workspace-specific roles
            const workspaceFolders = vscode.workspace.workspaceFolders;
            if (workspaceFolders) {
                const workspaceKey = workspaceFolders.map(f => f.uri.fsPath).join(',');
                const savedWorkspaceRole = this.context.globalState.get(`noodleWorkspaceRole_${workspaceKey}`);
                if (savedWorkspaceRole) {
                    this.state.workspaceRoles[workspaceKey] = savedWorkspaceRole;
                    await this.roleService.setCurrentRole(savedWorkspaceRole);
                    this.state.currentRole = this.roleService.getCurrentRole();
                }
            }
            this.updateStatusBar();
        }
        catch (error) {
            this.outputChannel.appendLine(`❌ Failed to load role manager state: ${error}`);
        }
    }
    /**
     * Save state to workspace
     */
    async saveState() {
        try {
            await this.context.workspaceState.update('noodleRoleManagerState', this.state);
            await this.context.globalState.update('noodleRecentRoles', this.state.recentRoles);
            await this.context.globalState.update('noodleFavoriteRoles', this.state.favoriteRoles);
            // Save workspace-specific role
            const workspaceFolders = vscode.workspace.workspaceFolders;
            if (workspaceFolders) {
                const workspaceKey = workspaceFolders.map(f => f.uri.fsPath).join(',');
                if (this.state.currentRole) {
                    await this.context.globalState.update(`noodleWorkspaceRole_${workspaceKey}`, this.state.currentRole.id);
                }
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`❌ Failed to save role manager state: ${error}`);
        }
    }
    /**
     * Setup status bar
     */
    setupStatusBar() {
        this.statusBarItem.command = 'noodle.roleManager.show';
        this.statusBarItem.show();
        this.updateStatusBar();
    }
    /**
     * Update status bar
     */
    updateStatusBar() {
        if (this.state.currentRole) {
            this.statusBarItem.text = `$(robot) ${this.state.currentRole.name}`;
            this.statusBarItem.tooltip = `Current AI Role: ${this.state.currentRole.name}\n${this.state.currentRole.description}`;
        }
        else {
            this.statusBarItem.text = '$(robot) No Role';
            this.statusBarItem.tooltip = 'No AI role selected';
        }
    }
    /**
     * Register commands
     */
    registerCommands() {
        // Show role manager
        const showCommand = vscode.commands.registerCommand('noodle.roleManager.show', () => this.showRoleManager());
        this.disposables.push(showCommand);
        // Quick role switch
        const quickSwitchCommand = vscode.commands.registerCommand('noodle.roleManager.quickSwitch', () => this.quickSwitchRole());
        this.disposables.push(quickSwitchCommand);
        // Switch to specific role
        const switchToCommand = vscode.commands.registerCommand('noodle.roleManager.switchTo', (roleId) => this.switchToRole(roleId));
        this.disposables.push(switchToCommand);
        // Add to favorites
        const addToFavoritesCommand = vscode.commands.registerCommand('noodle.roleManager.addToFavorites', (roleId) => this.addToFavorites(roleId));
        this.disposables.push(addToFavoritesCommand);
        // Remove from favorites
        const removeFromFavoritesCommand = vscode.commands.registerCommand('noodle.roleManager.removeFromFavorites', (roleId) => this.removeFromFavorites(roleId));
        this.disposables.push(removeFromFavoritesCommand);
        // Configure role
        const configureCommand = vscode.commands.registerCommand('noodle.roleManager.configure', (roleId) => this.configureRole(roleId));
        this.disposables.push(configureCommand);
        // Create custom role
        const createCommand = vscode.commands.registerCommand('noodle.roleManager.create', () => this.createCustomRole());
        this.disposables.push(createCommand);
        // Export role
        const exportCommand = vscode.commands.registerCommand('noodle.roleManager.export', (roleId) => this.exportRole(roleId));
        this.disposables.push(exportCommand);
        // Import role
        const importCommand = vscode.commands.registerCommand('noodle.roleManager.import', () => this.importRole());
        this.disposables.push(importCommand);
        // Reset to default
        const resetCommand = vscode.commands.registerCommand('noodle.roleManager.reset', () => this.resetToDefault());
        this.disposables.push(resetCommand);
    }
    /**
     * Setup event handlers
     */
    setupEventHandlers() {
        // Handle workspace changes
        const workspaceChangeDisposable = vscode.workspace.onDidChangeWorkspaceFolders(async () => {
            await this.handleWorkspaceChange();
        });
        this.disposables.push(workspaceChangeDisposable);
        // Handle configuration changes
        const configChangeDisposable = vscode.workspace.onDidChangeConfiguration(async (event) => {
            if (event.affectsConfiguration('noodle.ai')) {
                await this.handleConfigurationChange();
            }
        });
        this.disposables.push(configChangeDisposable);
    }
    /**
     * Show role manager UI
     */
    async showRoleManager() {
        const panel = vscode.window.createWebviewPanel('noodleRoleManager', 'Noodle AI Role Manager', vscode.ViewColumn.One, {
            enableScripts: true,
            retainContextWhenHidden: true
        });
        panel.webview.html = await this.getRoleManagerWebviewContent(panel);
        // Handle messages from webview
        panel.webview.onDidReceiveMessage(async (message) => {
            await this.handleWebviewMessage(message);
        });
    }
    /**
     * Quick role switch
     */
    async quickSwitchRole() {
        const recentRoles = this.state.recentRoles
            .map(roleId => this.roleService.getRoleById(roleId))
            .filter(role => role !== null);
        const allRoles = this.state.availableRoles;
        const items = allRoles.map(role => ({
            label: role.name,
            description: role.description,
            detail: `Category: ${role.category}`,
            roleId: role.id,
            isFavorite: this.state.favoriteRoles.includes(role.id),
            isRecent: this.state.recentRoles.includes(role.id)
        }));
        const selected = await vscode.window.showQuickPick(items, {
            placeHolder: 'Select an AI role...',
            matchOnDescription: true,
            matchOnDetail: true
        });
        if (selected) {
            await this.switchToRole(selected.roleId);
        }
    }
    /**
     * Switch to specific role
     */
    async switchToRole(roleId) {
        const role = this.roleService.getRoleById(roleId);
        if (!role) {
            vscode.window.showErrorMessage(`AI role with ID ${roleId} not found`);
            return;
        }
        const success = await this.roleService.setCurrentRole(roleId);
        if (success) {
            this.state.currentRole = this.roleService.getCurrentRole();
            // Add to recent roles
            this.addToRecentRoles(roleId);
            // Update status bar
            this.updateStatusBar();
            // Save state
            await this.saveState();
            vscode.window.showInformationMessage(`Switched to ${role.name} role`);
        }
    }
    /**
     * Add role to recent roles
     */
    addToRecentRoles(roleId) {
        // Remove if already exists
        this.state.recentRoles = this.state.recentRoles.filter(id => id !== roleId);
        // Add to beginning
        this.state.recentRoles.unshift(roleId);
        // Keep only last 10
        if (this.state.recentRoles.length > 10) {
            this.state.recentRoles = this.state.recentRoles.slice(0, 10);
        }
    }
    /**
     * Add role to favorites
     */
    async addToFavorites(roleId) {
        if (!this.state.favoriteRoles.includes(roleId)) {
            this.state.favoriteRoles.push(roleId);
            await this.saveState();
            vscode.window.showInformationMessage('Added to favorites');
        }
    }
    /**
     * Remove role from favorites
     */
    async removeFromFavorites(roleId) {
        this.state.favoriteRoles = this.state.favoriteRoles.filter(id => id !== roleId);
        await this.saveState();
        vscode.window.showInformationMessage('Removed from favorites');
    }
    /**
     * Configure role
     */
    async configureRole(roleId) {
        const role = this.roleService.getRoleById(roleId);
        if (!role)
            return;
        const documentContent = await this.roleService.getRoleDocument(roleId);
        // Show role document in new editor
        const document = await vscode.workspace.openTextDocument({
            content: documentContent || `# ${role.name}\n\n${role.description}`,
            language: 'markdown'
        });
        await vscode.window.showTextDocument(document);
    }
    /**
     * Create custom role
     */
    async createCustomRole() {
        const name = await vscode.window.showInputBox({
            prompt: 'Enter role name',
            placeHolder: 'e.g., Custom Expert'
        });
        if (!name)
            return;
        const description = await vscode.window.showInputBox({
            prompt: 'Enter role description',
            placeHolder: 'Describe what this role specializes in...'
        });
        if (!description)
            return;
        const category = await vscode.window.showQuickPick([
            'development',
            'architecture',
            'review',
            'debugging',
            'documentation',
            'testing',
            'optimization',
            'security'
        ], {
            placeHolder: 'Select role category'
        });
        if (!category)
            return;
        // Create role document template
        const template = `# ${name}

## Role Description
${description}

## Key Responsibilities
- Responsibility 1
- Responsibility 2
- Responsibility 3

## Communication Style
- Tone: [professional/friendly/technical/etc.]
- Level of detail: [concise/detailed/comprehensive]
- Response format: [bullet points/paragraphs/code examples/etc.]

## Areas of Expertise
- Expertise area 1
- Expertise area 2
- Expertise area 3

## Interaction Guidelines
- How to handle questions outside expertise
- Preferred approach to problem-solving
- When to ask clarifying questions

## Example Scenarios
Describe how this role would handle typical scenarios or provide example interactions.

---
*This role description was created for ${name}*
`;
        // Show in new editor for user to customize
        const document = await vscode.workspace.openTextDocument({
            content: template,
            language: 'markdown'
        });
        await vscode.window.showTextDocument(document);
        vscode.window.showInformationMessage('Custom role template created. Customize and save to add to your roles.');
    }
    /**
     * Export role
     */
    async exportRole(roleId) {
        const role = this.roleService.getRoleById(roleId);
        if (!role)
            return;
        const documentContent = await this.roleService.getRoleDocument(roleId);
        const exportData = {
            role: role,
            documentContent: documentContent,
            exportedAt: new Date().toISOString(),
            version: '1.0'
        };
        const uri = await vscode.window.showSaveDialog({
            defaultUri: vscode.Uri.file(`${role.name.replace(/\s+/g, '_')}_role.json`),
            filters: {
                'JSON Files': ['json']
            }
        });
        if (uri) {
            const content = JSON.stringify(exportData, null, 2);
            await vscode.workspace.fs.writeFile(uri, Buffer.from(content, 'utf8'));
            vscode.window.showInformationMessage(`Role ${role.name} exported successfully`);
        }
    }
    /**
     * Import role
     */
    async importRole() {
        const uri = await vscode.window.showOpenDialog({
            canSelectMany: false,
            openLabel: 'Import Role',
            filters: {
                'JSON Files': ['json']
            }
        });
        if (!uri)
            return;
        try {
            const content = await vscode.workspace.fs.readFile(uri);
            const importData = JSON.parse(content.toString());
            // Validate import data
            if (!importData.role || !importData.documentContent) {
                throw new Error('Invalid role file format');
            }
            // Show imported role for review
            const document = await vscode.workspace.openTextDocument({
                content: importData.documentContent,
                language: 'markdown'
            });
            await vscode.window.showTextDocument(document);
            vscode.window.showInformationMessage('Role imported for review. Save to add to your roles.');
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to import role: ${error}`);
        }
    }
    /**
     * Reset to default role
     */
    async resetToDefault() {
        const defaultRole = this.state.availableRoles.find(role => role.is_default);
        if (defaultRole) {
            await this.switchToRole(defaultRole.id);
        }
        else {
            vscode.window.showErrorMessage('No default role found');
        }
    }
    /**
     * Handle workspace change
     */
    async handleWorkspaceChange() {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (workspaceFolders) {
            const workspaceKey = workspaceFolders.map(f => f.uri.fsPath).join(',');
            const savedWorkspaceRole = this.context.globalState.get(`noodleWorkspaceRole_${workspaceKey}`);
            if (savedWorkspaceRole) {
                await this.roleService.setCurrentRole(savedWorkspaceRole);
                this.state.currentRole = this.roleService.getCurrentRole();
                this.updateStatusBar();
            }
        }
    }
    /**
     * Handle configuration change
     */
    async handleConfigurationChange() {
        await this.loadState();
    }
    /**
     * Handle webview messages
     */
    async handleWebviewMessage(message) {
        switch (message.type) {
            case 'switchRole':
                await this.switchToRole(message.roleId);
                break;
            case 'addToFavorites':
                await this.addToFavorites(message.roleId);
                break;
            case 'removeFromFavorites':
                await this.removeFromFavorites(message.roleId);
                break;
            case 'configureRole':
                await this.configureRole(message.roleId);
                break;
            case 'createRole':
                await this.createCustomRole();
                break;
            case 'exportRole':
                await this.exportRole(message.roleId);
                break;
            case 'importRole':
                await this.importRole();
                break;
            case 'resetRole':
                await this.resetToDefault();
                break;
            case 'getState':
                // Send current state to webview
                break;
        }
    }
    /**
     * Get role manager webview content
     */
    async getRoleManagerWebviewContent(panel) {
        const nonce = this.getNonce();
        const cspSource = [
            `default-src 'none';`,
            `script-src 'nonce-${nonce}' 'unsafe-inline';`,
            `style-src 'nonce-${nonce}' 'unsafe-inline';`
        ].join(' ');
        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="${cspSource}">
    <title>Noodle AI Role Manager</title>
    <style>
        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--vscode-panel-border);
        }
        .header h1 {
            margin: 0;
            font-size: 18px;
            color: var(--vscode-foreground);
        }
        .tabs {
            display: flex;
            margin-bottom: 20px;
        }
        .tab {
            padding: 8px 16px;
            cursor: pointer;
            border: 1px solid var(--vscode-panel-border);
            background-color: var(--vscode-editor-background);
            margin-right: 2px;
        }
        .tab.active {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
        }
        .content {
            border: 1px solid var(--vscode-panel-border);
            border-radius: 4px;
            padding: 16px;
        }
        .role-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }
        .role-card {
            border: 1px solid var(--vscode-panel-border);
            border-radius: 6px;
            padding: 16px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .role-card:hover {
            border-color: var(--vscode-button-background);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .role-card.current {
            border-color: var(--vscode-button-background);
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
        }
        .role-name {
            font-weight: bold;
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .role-actions {
            display: flex;
            gap: 8px;
        }
        .role-action {
            background: none;
            border: none;
            cursor: pointer;
            opacity: 0.7;
            font-size: 0.9em;
        }
        .role-action:hover {
            opacity: 1;
        }
        .role-description {
            margin-bottom: 8px;
            opacity: 0.8;
        }
        .role-meta {
            font-size: 0.8em;
            color: var(--vscode-descriptionForeground);
        }
        .button {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            border: none;
            border-radius: 4px;
            padding: 8px 16px;
            cursor: pointer;
            margin-right: 8px;
        }
        .button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }
        .button.secondary {
            background-color: var(--vscode-button-secondaryBackground);
            color: var(--vscode-button-secondaryForeground);
        }
        .button.secondary:hover {
            background-color: var(--vscode-button-secondaryHoverBackground);
        }
        .search-box {
            width: 100%;
            padding: 8px;
            margin-bottom: 16px;
            border: 1px solid var(--vscode-input-border);
            border-radius: 4px;
            background-color: var(--vscode-input-background);
            color: var(--vscode-input-foreground);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 Noodle AI Role Manager</h1>
            <div>
                <button class="button" onclick="createRole()">Create Role</button>
                <button class="button secondary" onclick="importRole()">Import Role</button>
                <button class="button secondary" onclick="resetRole()">Reset to Default</button>
            </div>
        </div>
        
        <div class="tabs">
            <div class="tab active" onclick="showTab('all')">All Roles</div>
            <div class="tab" onclick="showTab('favorites')">Favorites</div>
            <div class="tab" onclick="showTab('recent')">Recent</div>
        </div>

        <div class="content">
            <input type="text" class="search-box" placeholder="Search roles..." onkeyup="searchRoles(this.value)">
            
            <div class="role-grid" id="roleGrid">
                <!-- Roles will be populated here -->
            </div>
        </div>
    </div>

    <script nonce="${nonce}">
        const vscode = acquireVsCodeApi();
        
        let currentTab = 'all';
        let allRoles = ${JSON.stringify(this.state.availableRoles)};
        let favoriteRoles = ${JSON.stringify(this.state.favoriteRoles)};
        let recentRoles = ${JSON.stringify(this.state.recentRoles)};
        let currentRoleId = ${JSON.stringify(this.state.currentRole?.id || null)};
        let filteredRoles = allRoles;

        function showTab(tabName) {
            currentTab = tabName;
            
            // Update tab styles
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            event.target.classList.add('active');
            
            // Filter roles based on tab
            if (tabName === 'favorites') {
                filteredRoles = allRoles.filter(role => favoriteRoles.includes(role.id));
            } else if (tabName === 'recent') {
                filteredRoles = allRoles.filter(role => recentRoles.includes(role.id));
            } else {
                filteredRoles = allRoles;
            }
            
            renderRoles();
        }

        function renderRoles() {
            const roleGrid = document.getElementById('roleGrid');
            roleGrid.innerHTML = '';
            
            filteredRoles.forEach(role => {
                const roleCard = document.createElement('div');
                roleCard.className = 'role-card';
                if (role.id === currentRoleId) {
                    roleCard.classList.add('current');
                }
                
                const isFavorite = favoriteRoles.includes(role.id);
                const isRecent = recentRoles.includes(role.id);
                
                roleCard.innerHTML = \`
                    <div class="role-name">
                        \${role.name}
                        <div class="role-actions">
                            \${isFavorite ? '⭐' : '<span class="role-action" onclick="toggleFavorite(\\'' + role.id + '\\')">☆</span>'}
                            <span class="role-action" onclick="configureRole('\\'' + role.id + '\\')">⚙️</span>
                        </div>
                    </div>
                    <div class="role-description">\${role.description}</div>
                    <div class="role-meta">
                        Category: \${role.category} | Tags: \${role.tags.join(', ')}
                        \${isRecent ? ' | 🕐 Recent' : ''}
                    </div>
                \`;
                
                roleCard.addEventListener('click', (e) => {
                    if (!e.target.classList.contains('role-action')) {
                        switchRole(role.id);
                    }
                });
                
                roleGrid.appendChild(roleCard);
            });
        }

        function switchRole(roleId) {
            vscode.postMessage({
                type: 'switchRole',
                roleId: roleId
            });
        }

        function toggleFavorite(roleId) {
            vscode.postMessage({
                type: favoriteRoles.includes(roleId) ? 'removeFromFavorites' : 'addToFavorites',
                roleId: roleId
            });
        }

        function configureRole(roleId) {
            vscode.postMessage({
                type: 'configureRole',
                roleId: roleId
            });
        }

        function createRole() {
            vscode.postMessage({ type: 'createRole' });
        }

        function importRole() {
            vscode.postMessage({ type: 'importRole' });
        }

        function resetRole() {
            vscode.postMessage({ type: 'resetRole' });
        }

        function searchRoles(query) {
            if (!query.trim()) {
                filteredRoles = currentTab === 'favorites' ? 
                    allRoles.filter(role => favoriteRoles.includes(role.id)) :
                    currentTab === 'recent' ?
                    allRoles.filter(role => recentRoles.includes(role.id)) :
                    allRoles;
            } else {
                const lowerQuery = query.toLowerCase();
                filteredRoles = allRoles.filter(role => 
                    role.name.toLowerCase().includes(lowerQuery) ||
                    role.description.toLowerCase().includes(lowerQuery) ||
                    role.tags.some(tag => tag.toLowerCase().includes(lowerQuery))
                );
            }
            renderRoles();
        }

        // Initial render
        renderRoles();
    </script>
</body>
</html>`;
    }
    /**
     * Get nonce for security
     */
    getNonce() {
        let text = '';
        const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for (let i = 0; i < 32; i++) {
            text += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        return text;
    }
    /**
     * Get current state
     */
    getState() {
        return { ...this.state };
    }
    /**
     * Dispose role manager
     */
    dispose() {
        this.disposables.forEach(disposable => disposable.dispose());
        this.outputChannel.dispose();
        this.statusBarItem.dispose();
        this.roleService.dispose();
    }
}
exports.RoleManager = RoleManager;
//# sourceMappingURL=roleManager.js.map