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
exports.RoleBasedAIService = void 0;
const vscode = __importStar(require("vscode"));
const backendService_1 = require("./backendService");
class RoleBasedAIService {
    constructor() {
        this.disposables = [];
        this.backendService = new backendService_1.NoodleBackendService();
        this.outputChannel = vscode.window.createOutputChannel('Noodle AI Roles');
        this.currentContext = {
            currentRole: null,
            availableRoles: [],
            workspaceContext: {},
            conversationHistory: [],
            memoryContext: {}
        };
        this.initializeRoles();
    }
    /**
     * Initialize AI roles from backend
     */
    async initializeRoles() {
        try {
            const response = await this.backendService.makeRequest('/api/v1/ai/roles', 'GET');
            if (response.success && response.data) {
                this.currentContext.availableRoles = response.data.roles || [];
                // Set default role if available
                const defaultRole = this.currentContext.availableRoles.find(role => role.is_default);
                if (defaultRole) {
                    this.currentContext.currentRole = defaultRole;
                }
                this.outputChannel.appendLine(`✅ Loaded ${this.currentContext.availableRoles.length} AI roles`);
            }
            else {
                this.outputChannel.appendLine(`❌ Failed to load AI roles: ${response.error?.message}`);
                // Fallback to default roles if backend fails
                this.loadFallbackRoles();
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`❌ Error initializing AI roles: ${error}`);
            this.loadFallbackRoles();
        }
    }
    /**
     * Load fallback roles when backend is unavailable
     */
    loadFallbackRoles() {
        this.currentContext.availableRoles = [
            {
                id: 'noodlecore-manager',
                name: 'NoodleCore Manager',
                description: 'Central orchestrator for all IDE operations and task coordination',
                category: 'orchestration',
                tags: ['orchestration', 'coordination', 'management'],
                is_default: true,
                document_path: '',
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            },
            {
                id: 'code-architect',
                name: 'Code Architect',
                description: 'System design and architectural guidance for NoodleCore development',
                category: 'architecture',
                tags: ['design', 'architecture', 'system'],
                is_default: false,
                document_path: '',
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            },
            {
                id: 'noodlecore-developer',
                name: 'NoodleCore Developer',
                description: 'Expert in NoodleCore language development and implementation',
                category: 'development',
                tags: ['development', 'coding', 'noodlecore'],
                is_default: false,
                document_path: '',
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            },
            {
                id: 'code-reviewer',
                name: 'Code Reviewer',
                description: 'Quality assurance and code review specialist',
                category: 'review',
                tags: ['review', 'quality', 'testing'],
                is_default: false,
                document_path: '',
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            }
        ];
        // Set default role
        const defaultRole = this.currentContext.availableRoles.find(role => role.is_default);
        if (defaultRole) {
            this.currentContext.currentRole = defaultRole;
        }
    }
    /**
     * Get current role context
     */
    getCurrentContext() {
        return { ...this.currentContext };
    }
    /**
     * Get available roles
     */
    getAvailableRoles() {
        return [...this.currentContext.availableRoles];
    }
    /**
     * Get current role
     */
    getCurrentRole() {
        return this.currentContext.currentRole;
    }
    /**
     * Set current role
     */
    async setCurrentRole(roleId) {
        const role = this.currentContext.availableRoles.find(r => r.id === roleId);
        if (!role) {
            vscode.window.showErrorMessage(`AI role with ID ${roleId} not found`);
            return false;
        }
        this.currentContext.currentRole = role;
        // Store role preference in workspace state
        const workspaceState = vscode.workspace.getConfiguration('noodle.ai');
        await workspaceState.update('selectedRole', roleId);
        vscode.window.showInformationMessage(`Switched to AI role: ${role.name}`);
        return true;
    }
    /**
     * Get role by ID
     */
    getRoleById(roleId) {
        return this.currentContext.availableRoles.find(role => role.id === roleId) || null;
    }
    /**
     * Get roles by category
     */
    getRolesByCategory(category) {
        return this.currentContext.availableRoles.filter(role => role.category === category);
    }
    /**
     * Search roles
     */
    searchRoles(query) {
        const lowerQuery = query.toLowerCase();
        return this.currentContext.availableRoles.filter(role => role.name.toLowerCase().includes(lowerQuery) ||
            role.description.toLowerCase().includes(lowerQuery) ||
            role.tags.some(tag => tag.toLowerCase().includes(lowerQuery)));
    }
    /**
     * Get role document content
     */
    async getRoleDocument(roleId) {
        try {
            const response = await this.backendService.makeRequest(`/api/v1/ai/roles/${roleId}/document`, 'GET');
            if (response.success && response.data) {
                return response.data.content;
            }
            else {
                this.outputChannel.appendLine(`❌ Failed to get role document: ${response.error?.message}`);
                return null;
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`❌ Error getting role document: ${error}`);
            return null;
        }
    }
    /**
     * Make role-based AI request
     */
    async makeRoleBasedRequest(request) {
        if (!request.role) {
            throw new Error('Role is required for role-based AI request');
        }
        try {
            // Get role document for context
            const roleDocument = await this.getRoleDocument(request.role.id);
            // Prepare request payload
            const payload = {
                message: request.message,
                role: request.role,
                role_document: roleDocument,
                context: request.context,
                workspace_files: request.workspaceFiles,
                selection: request.selection,
                conversation_history: this.currentContext.conversationHistory.slice(-10),
                memory_context: this.currentContext.memoryContext,
                provider: request.provider || 'openai',
                model: request.model || 'gpt-4',
                request_id: this.generateRequestId()
            };
            const response = await this.backendService.makeRequest('/api/v1/ai/role-chat', 'POST', payload);
            if (response.success && response.data) {
                // Update conversation history
                this.currentContext.conversationHistory.push({
                    role: 'user',
                    content: request.message,
                    timestamp: new Date().toISOString(),
                    role_id: request.role.id
                });
                this.currentContext.conversationHistory.push({
                    role: 'assistant',
                    content: response.data.response,
                    timestamp: new Date().toISOString(),
                    role_id: request.role.id,
                    provider: request.provider,
                    model: request.model
                });
                return response.data;
            }
            else {
                throw new Error(response.error?.message || 'Role-based AI request failed');
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`❌ Role-based AI request failed: ${error}`);
            throw error;
        }
    }
    /**
     * Analyze code with role context
     */
    async analyzeCodeWithRole(code, roleId) {
        const role = roleId ? this.getRoleById(roleId) : this.currentContext.currentRole;
        if (!role) {
            throw new Error('No AI role available for code analysis');
        }
        const request = {
            message: `Analyze the following NoodleCore code:\n\n${code}`,
            role: role,
            selection: code
        };
        return await this.makeRoleBasedRequest(request);
    }
    /**
     * Generate code with role context
     */
    async generateCodeWithRole(prompt, roleId) {
        const role = roleId ? this.getRoleById(roleId) : this.currentContext.currentRole;
        if (!role) {
            throw new Error('No AI role available for code generation');
        }
        const request = {
            message: `Generate NoodleCore code based on this request: ${prompt}`,
            role: role
        };
        return await this.makeRoleBasedRequest(request);
    }
    /**
     * Refactor code with role context
     */
    async refactorCodeWithRole(code, refactorType, roleId) {
        const role = roleId ? this.getRoleById(roleId) : this.currentContext.currentRole;
        if (!role) {
            throw new Error('No AI role available for code refactoring');
        }
        const request = {
            message: `Refactor the following NoodleCore code for ${refactorType}:\n\n${code}`,
            role: role,
            selection: code,
            context: { refactor_type: refactorType }
        };
        return await this.makeRoleBasedRequest(request);
    }
    /**
     * Explain code with role context
     */
    async explainCodeWithRole(code, roleId) {
        const role = roleId ? this.getRoleById(roleId) : this.currentContext.currentRole;
        if (!role) {
            throw new Error('No AI role available for code explanation');
        }
        const request = {
            message: `Explain the following NoodleCore code:\n\n${code}`,
            role: role,
            selection: code
        };
        return await this.makeRoleBasedRequest(request);
    }
    /**
     * Fix code errors with role context
     */
    async fixCodeWithRole(code, errors, roleId) {
        const role = roleId ? this.getRoleById(roleId) : this.currentContext.currentRole;
        if (!role) {
            throw new Error('No AI role available for code fixing');
        }
        const errorContext = errors.map(err => `${err.message} at line ${err.line}`).join('\n');
        const request = {
            message: `Fix the following errors in this NoodleCore code:\n\nErrors:\n${errorContext}\n\nCode:\n${code}`,
            role: role,
            selection: code,
            context: { errors }
        };
        return await this.makeRoleBasedRequest(request);
    }
    /**
     * Update memory context
     */
    updateMemoryContext(newContext) {
        this.currentContext.memoryContext = {
            ...this.currentContext.memoryContext,
            ...newContext,
            last_updated: new Date().toISOString()
        };
    }
    /**
     * Get memory context
     */
    getMemoryContext() {
        return { ...this.currentContext.memoryContext };
    }
    /**
     * Clear conversation history
     */
    clearConversationHistory() {
        this.currentContext.conversationHistory = [];
    }
    /**
     * Get conversation history
     */
    getConversationHistory() {
        return [...this.currentContext.conversationHistory];
    }
    /**
     * Generate request ID
     */
    generateRequestId() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    /**
     * Dispose service
     */
    dispose() {
        this.disposables.forEach(disposable => disposable.dispose());
        this.outputChannel.dispose();
    }
}
exports.RoleBasedAIService = RoleBasedAIService;
//# sourceMappingURL=roleBasedAIService.js.map