/**
 * Tree Provider for Noodle VS Code Extension
 * 
 * Provides tree view for Noodle-specific features and navigation.
 */

import * as vscode from 'vscode';
import * as path from 'path';

export class NoodleTreeProvider implements vscode.TreeDataProvider<NoodleTreeItem> {
    private _onDidChangeTreeData: vscode.EventEmitter<NoodleTreeItem | undefined | null | void> = new vscode.EventEmitter<NoodleTreeItem | undefined | null | void>();
    readonly onDidChangeTreeData: vscode.Event<NoodleTreeItem | undefined | null | void> = this._onDidChangeTreeData.event;
    
    private context: vscode.ExtensionContext;
    private items: NoodleTreeItem[] = [];
    
    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.initializeItems();
    }
    
    /**
     * Initialize tree items
     */
    private initializeItems(): void {
        this.items = [
            new NoodleTreeItem(
                '🤖 AI Assistant',
                vscode.TreeItemCollapsibleState.Expanded,
                'ai-assistant',
                'Open AI chat and get intelligent code assistance'
            ),
            new NoodleTreeItem(
                '🔍 Code Analysis',
                vscode.TreeItemCollapsibleState.Expanded,
                'code-analysis',
                'Analyze code for issues and improvements'
            ),
            new NoodleTreeItem(
                '🚀 Performance',
                vscode.TreeItemCollapsibleState.Expanded,
                'performance',
                'Monitor extension performance and metrics'
            ),
            new NoodleTreeItem(
                '🔧 Ecosystem',
                vscode.TreeItemCollapsibleState.Expanded,
                'ecosystem',
                'Manage ecosystem integrations and services'
            ),
            new NoodleTreeItem(
                '⚙️ Settings',
                vscode.TreeItemCollapsibleState.None,
                'settings',
                'Configure extension settings'
            )
        ];
    }
    
    /**
     * Get tree item
     */
    public getTreeItem(element: NoodleTreeItem): vscode.TreeItem {
        return element;
    }
    
    /**
     * Get children
     */
    public getChildren(element?: NoodleTreeItem): Thenable<NoodleTreeItem[]> {
        if (!element) {
            // Root level - return main categories
            return Promise.resolve(this.items);
        }
        
        // Return children based on parent
        switch (element.id) {
            case 'ai-assistant':
                return Promise.resolve([
                    new NoodleTreeItem(
                        '💬 Chat',
                        vscode.TreeItemCollapsibleState.None,
                        'ai-chat',
                        'Open AI chat interface'
                    ),
                    new NoodleTreeItem(
                        '🔮 Assist',
                        vscode.TreeItemCollapsibleState.None,
                        'ai-assist',
                        'Get AI assistance for selected code'
                    )
                ]);
                
            case 'code-analysis':
                return Promise.resolve([
                    new NoodleTreeItem(
                        '📊 Analyze File',
                        vscode.TreeItemCollapsibleState.None,
                        'analyze-file',
                        'Analyze current file'
                    ),
                    new NoodleTreeItem(
                        '🔍 Find Issues',
                        vscode.TreeItemCollapsibleState.None,
                        'find-issues',
                        'Find issues in workspace'
                    )
                ]);
                
            case 'performance':
                return Promise.resolve([
                    new NoodleTreeItem(
                        '📈 Show Metrics',
                        vscode.TreeItemCollapsibleState.None,
                        'show-metrics',
                        'Show performance metrics'
                    ),
                    new NoodleTreeItem(
                        '📊 Status',
                        vscode.TreeItemCollapsibleState.None,
                        'show-status',
                        'Show extension status'
                    )
                ]);
                
            case 'ecosystem':
                return Promise.resolve([
                    new NoodleTreeItem(
                        '📋 Git',
                        vscode.TreeItemCollapsibleState.None,
                        'git-integration',
                        'Git integration status'
                    ),
                    new NoodleTreeItem(
                        '🐙 GitHub',
                        vscode.TreeItemCollapsibleState.None,
                        'github-integration',
                        'GitHub integration status'
                    ),
                    new NoodleTreeItem(
                        '🔄 CI/CD',
                        vscode.TreeItemCollapsibleState.None,
                        'cicd-integration',
                        'CI/CD pipeline status'
                    )
                ]);
                
            case 'settings':
                return Promise.resolve([
                    new NoodleTreeItem(
                        '⚙️ Configuration',
                        vscode.TreeItemCollapsibleState.None,
                        'configuration',
                        'Open extension configuration'
                    ),
                    new NoodleTreeItem(
                        '🎨 Themes',
                        vscode.TreeItemCollapsibleState.None,
                        'themes',
                        'Change extension theme'
                    )
                ]);
                
            default:
                return Promise.resolve([]);
        }
    }
    
    /**
     * Refresh tree
     */
    public refresh(): void {
        this.initializeItems();
        this._onDidChangeTreeData.fire(undefined);
    }
    
    /**
     * Handle tree item selection
     */
    public handleTreeItemSelection(item: NoodleTreeItem): void {
        switch (item.id) {
            case 'ai-chat':
                vscode.commands.executeCommand('noodle.ai.chat');
                break;
            case 'ai-assist':
                vscode.commands.executeCommand('noodle.ai.assist');
                break;
            case 'analyze-file':
                vscode.commands.executeCommand('noodle.analyze.code');
                break;
            case 'find-issues':
                vscode.commands.executeCommand('noodle.analyze.code');
                break;
            case 'show-metrics':
                vscode.commands.executeCommand('noodle.performance.showMetrics');
                break;
            case 'show-status':
                vscode.commands.executeCommand('noodle.ecosystem.showStatus');
                break;
            case 'git-integration':
                vscode.commands.executeCommand('noodle.ecosystem.showStatus');
                break;
            case 'github-integration':
                vscode.commands.executeCommand('noodle.ecosystem.showStatus');
                break;
            case 'cicd-integration':
                vscode.commands.executeCommand('noodle.ecosystem.showStatus');
                break;
            case 'configuration':
                vscode.commands.executeCommand('workbench.action.openSettings', '@ext:noodle');
                break;
            case 'themes':
                vscode.commands.executeCommand('workbench.action.openSettings', '@ext:noodle');
                break;
        }
    }
}

/**
 * Tree item class
 */
export class NoodleTreeItem extends vscode.TreeItem {
    public id: string;
    public description?: string;
    
    constructor(
        public label: string,
        public collapsibleState: vscode.TreeItemCollapsibleState,
        id: string,
        description?: string
    ) {
        super(label, collapsibleState);
        this.id = id;
        this.description = description;
        this.tooltip = description || label;
        this.contextValue = id;
        
        // Set appropriate icon
        this.iconPath = new vscode.ThemeIcon(
            this.getIconName(id),
            this.getIconPath(id)
        );
    }
    
    /**
     * Get icon name
     */
    private getIconName(id: string): string {
        const iconMap: { [key: string]: string } = {
            'ai-assistant': 'robot',
            'code-analysis': 'search',
            'performance': 'graph',
            'ecosystem': 'plug',
            'settings': 'gear',
            'ai-chat': 'comment-discussion',
            'ai-assist': 'zap',
            'analyze-file': 'file-code',
            'find-issues': 'warning',
            'show-metrics': 'graph-line',
            'show-status': 'check',
            'git-integration': 'source-control',
            'github-integration': 'github',
            'cicd-integration': 'repo-sync',
            'configuration': 'settings-gear',
            'themes': 'paintcan'
        };
        
        return iconMap[id] || 'circle-outline';
    }
    
    /**
     * Get icon path
     */
    private getIconPath(id: string): string {
        // In a real implementation, this would return the path to the icon file
        // For now, we'll use the built-in icons
        return '';
    }
}