/**
 * File Manager for Noodle IDE
 * Handles file operations, project management, and file tree navigation
 */

class FileManager {
    constructor(api, ideManager) {
        this.api = api;
        this.ideManager = ideManager;
        this.currentProject = null;
        this.openFiles = new Map();
        this.fileTree = document.getElementById('file-tree');
        this.fileTabs = document.getElementById('file-tabs');
        this.contextMenu = document.getElementById('file-context-menu');

        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadProject();
    }

    setupEventListeners() {
        // File operations
        document.getElementById('btn-new-file').addEventListener('click', () => this.createNewFile());
        document.getElementById('btn-new-folder').addEventListener('click', () => this.createNewFolder());
        document.getElementById('btn-refresh-files').addEventListener('click', () => this.refreshFileTree());

        // Context menu events
        this.fileTree.addEventListener('contextmenu', (e) => this.showContextMenu(e));
        document.addEventListener('click', () => this.hideContextMenu());

        // File tab close events
        this.fileTabs.addEventListener('click', (e) => {
            if (e.target.classList.contains('tab-close')) {
                this.closeFileTab(e.target.closest('.tab'));
            }
        });

        // File tab selection
        this.fileTabs.addEventListener('click', (e) => {
            if (e.target.classList.contains('tab') || e.target.closest('.tab')) {
                const tab = e.target.classList.contains('tab') ? e.target : e.target.closest('.tab');
                this.switchToFile(tab.dataset.file);
            }
        });
    }

    async loadProject() {
        try {
            const projectPath = 'current';
            const project = await this.ideManager.loadProject(projectPath);
            this.currentProject = project;
            await this.refreshFileTree();
        } catch (error) {
            console.error('Failed to load project:', error);
        }
    }

    async refreshFileTree() {
        try {
            const response = await this.api.listFiles('current');
            if (response.success) {
                this.renderFileTree(response.data.files);
            }
        } catch (error) {
            console.error('Failed to refresh file tree:', error);
        }
    }

    renderFileTree(files) {
        this.fileTree.innerHTML = '';

        // Add project root
        const projectItem = this.createFileTreeItem({
            name: 'Current Project',
            type: 'project',
            icon: '📂'
        });
        this.fileTree.appendChild(projectItem);

        // Add files
        files.forEach(file => {
            const item = this.createFileTreeItem(file);
            this.fileTree.appendChild(item);
        });
    }

    createFileTreeItem(file) {
        const item = document.createElement('div');
        item.className = 'file-item';
        item.dataset.type = file.type;
        item.dataset.name = file.name;
        item.dataset.path = file.path || '';

        item.innerHTML = `
            <span class="file-icon">${file.icon || this.getFileIcon(file.type)}</span>
            <span class="file-name">${file.name}</span>
            <div class="file-actions">
                ${file.type !== 'folder' ? '<button class="btn-icon small" title="Open">📄</button>' : ''}
                ${file.type !== 'folder' ? '<button class="btn-icon small" title="Run">▶️</button>' : ''}
            </div>
        `;

        // Add click handlers
        item.addEventListener('click', (e) => {
            if (e.target.classList.contains('btn-icon')) return;
            if (file.type === 'folder') {
                this.toggleFolder(item);
            } else {
                this.openFile(file.path);
            }
        });

        return item;
    }

    getFileIcon(type) {
        const icons = {
            'folder': '📁',
            'noodle': '🟨',
            'py': '🐍',
            'js': '📜',
            'html': '🌐',
            'css': '🎨',
            'md': '📝'
        };
        return icons[type] || '📄';
    }

    async openFile(filePath) {
        try {
            const fileInfo = await this.ideManager.openFile(filePath);
            this.addFileTab(fileInfo);
            this.loadFileContent(fileInfo);
        } catch (error) {
            console.error('Failed to open file:', error);
        }
    }

    addFileTab(fileInfo) {
        // Remove active class from existing tabs
        this.fileTabs.querySelectorAll('.tab').forEach(tab => {
            tab.classList.remove('active');
        });

        // Check if tab already exists
        let existingTab = this.fileTabs.querySelector(`[data-file="${fileInfo.path}"]`);
        if (existingTab) {
            existingTab.classList.add('active');
            return;
        }

        // Create new tab
        const tab = document.createElement('div');
        tab.className = 'tab active';
        tab.dataset.file = fileInfo.path;
        tab.innerHTML = `
            <span class="tab-name">${fileInfo.name}</span>
            <button class="tab-close">×</button>
        `;

        this.fileTabs.appendChild(tab);
        this.openFiles.set(fileInfo.path, fileInfo);
    }

    loadFileContent(fileInfo) {
        const editor = document.getElementById('code-editor');
        if (editor) {
            editor.value = fileInfo.content || '';
            this.updateEditorMode(fileInfo.file_type || 'noodle');
        }
    }

    switchToFile(filePath) {
        // Update tab selection
        this.fileTabs.querySelectorAll('.tab').forEach(tab => {
            tab.classList.remove('active');
            if (tab.dataset.file === filePath) {
                tab.classList.add('active');
            }
        });

        // Load file content
        const fileInfo = this.openFiles.get(filePath);
        if (fileInfo) {
            this.loadFileContent(fileInfo);
        }
    }

    closeFileTab(tab) {
        const filePath = tab.dataset.file;
        tab.remove();
        this.openFiles.delete(filePath);

        // Switch to another open file if available
        const remainingTabs = this.fileTabs.querySelectorAll('.tab');
        if (remainingTabs.length > 0) {
            this.switchToFile(remainingTabs[0].dataset.file);
        } else {
            this.showWelcomeScreen();
        }
    }

    showWelcomeScreen() {
        document.getElementById('editor-tabs').innerHTML = `
            <div class="tab active" data-file="welcome">
                <span class="tab-name">Welcome</span>
                <button class="tab-close">×</button>
            </div>
        `;

        const editor = document.getElementById('code-editor');
        if (editor) {
            editor.value = '// Welcome to Noodle IDE\n// Start coding in Noodle language...\n\n';
            this.updateEditorMode('noodle');
        }
    }

    async createNewFile() {
        const fileName = prompt('Enter file name:');
        if (fileName) {
            try {
                await this.ideManager.createFile(fileName);
                await this.refreshFileTree();
            } catch (error) {
                console.error('Failed to create file:', error);
            }
        }
    }

    async createNewFolder() {
        const folderName = prompt('Enter folder name:');
        if (folderName) {
            // Folder creation would be implemented here
            await this.refreshFileTree();
        }
    }

    showContextMenu(event) {
        event.preventDefault();
        this.contextMenu.style.display = 'block';
        this.contextMenu.style.left = event.pageX + 'px';
        this.contextMenu.style.top = event.pageY + 'px';
    }

    hideContextMenu() {
        this.contextMenu.style.display = 'none';
    }

    updateEditorMode(mode) {
        // Update editor mode and syntax highlighting
        const editor = document.getElementById('code-editor');
        const cursorPosition = document.getElementById('cursor-position');

        if (editor) {
            editor.dataset.mode = mode;
        }

        if (cursorPosition) {
            cursorPosition.textContent = `Mode: ${mode}`;
        }
    }

    getOpenFiles() {
        return Array.from(this.openFiles.values());
    }

    getCurrentFile() {
        const activeTab = this.fileTabs.querySelector('.tab.active');
        if (activeTab && activeTab.dataset.file !== 'welcome') {
            return this.openFiles.get(activeTab.dataset.file);
        }
        return null;
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = FileManager;
} else if (typeof window !== 'undefined') {
    window.FileManager = FileManager;
}