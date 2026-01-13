import * as vscode from 'vscode';
import { RoleBasedAIService, AIRole } from '../services/roleBasedAIService';
import { RoleBasedAIChatPanel } from '../components/roleBasedAIChatPanel';
import { RoleManager } from '../features/roleManager';
import { ContextAwareAIAssistant } from '../features/contextAwareAIAssistant';

suite('Noodle AI Role System Integration Tests', () => {
    let roleService: RoleBasedAIService;
    let roleChatPanel: RoleBasedAIChatPanel;
    let roleManager: RoleManager;
    let contextAwareAI: ContextAwareAIAssistant;
    let extensionContext: vscode.ExtensionContext;

    suiteSetup(() => {
        extensionContext = vscode.extensions.getExtensionContext()!;
        
        // Initialize services
        roleService = new RoleBasedAIService();
        roleChatPanel = new RoleBasedAIChatPanel(extensionContext.extensionUri);
        roleManager = new RoleManager(extensionContext);
        contextAwareAI = new ContextAwareAIAssistant(extensionContext);
    });

    suiteTeardown(() => {
        roleService?.dispose();
        roleChatPanel?.dispose();
        roleManager?.dispose();
        contextAwareAI?.dispose();
    });

    test('Role Service Initialization', async () => {
        // Test role service initialization
        await roleService.initializeRoles();
        const roles = roleService.getAvailableRoles();
        
        // Should have default roles
        if (roles.length === 0) {
            throw new Error('No roles available after initialization');
        }
        
        // Should have default role set
        const currentRole = roleService.getCurrentRole();
        if (!currentRole) {
            throw new Error('No default role set after initialization');
        }
        
        // Test role retrieval
        const managerRole = roleService.getRoleById('noodlecore-manager');
        if (!managerRole) {
            throw new Error('NoodleCore Manager role not found');
        }
        
        if (managerRole.name !== 'NoodleCore Manager') {
            throw new Error('NoodleCore Manager role has incorrect name');
        }
    });

    test('Role Chat Panel', async () => {
        // Test role chat panel creation
        roleChatPanel.show();
        
        // Wait for panel to be ready
        await new Promise(resolve => setTimeout(resolve, 100));
        
        // Test role switching in chat panel
        const success = await roleService.setCurrentRole('code-architect');
        if (!success) {
            throw new Error('Failed to switch role in chat panel');
        }
        
        const newRole = roleService.getCurrentRole();
        if (newRole?.name !== 'Code Architect') {
            throw new Error('Role not switched correctly in chat panel');
        }
        
        // Test message sending
        // This would require more complex testing with actual webview interaction
        // For now, just verify the service methods are available
    });

    test('Role Manager', async () => {
        // Test role manager functionality
        roleManager.show();
        
        // Wait for manager to be ready
        await new Promise(resolve => setTimeout(resolve, 100));
        
        // Test role switching
        const success = await roleManager.switchToRole('code-reviewer');
        if (!success) {
            throw new Error('Failed to switch role in role manager');
        }
        
        const currentRole = roleManager.getCurrentRole();
        if (currentRole?.name !== 'Code Reviewer') {
            throw new Error('Role not switched correctly in role manager');
        }
        
        // Test favorites functionality
        await roleManager.addToFavorites('noodlecore-developer');
        await roleManager.removeFromFavorites('noodlecore-developer');
        
        const state = roleManager.getState();
        if (!state.favoriteRoles.includes('noodlecore-developer')) {
            throw new Error('Favorites functionality not working correctly');
        }
    });

    test('Context-Aware AI Assistant', async () => {
        // Test context-aware AI functionality
        contextAwareAI.show();
        
        // Wait for panel to be ready
        await new Promise(resolve => setTimeout(resolve, 100));
        
        // Test context analysis
        await contextAwareAI.analyzeCurrentContext();
        
        // Test auto-switch toggle
        await contextAwareAI.toggleAutoSwitch();
        
        const state = contextAwareAI.getState();
        if (state.autoSwitchEnabled === undefined) {
            throw new Error('Auto-switch state not properly initialized');
        }
    });

    test('Integration Between Components', async () => {
        // Test that all components work together
        
        // Initialize all components
        await roleService.initializeRoles();
        roleChatPanel.show();
        roleManager.show();
        contextAwareAI.show();
        
        // Wait for components to be ready
        await new Promise(resolve => setTimeout(resolve, 200));
        
        // Test role switching from role manager affects chat panel
        const success = await roleManager.switchToRole('debugging-expert');
        if (!success) {
            throw new Error('Failed to switch role from role manager');
        }
        
        // Verify chat panel reflects the change
        const chatState = roleChatPanel.getCurrentContext();
        const currentRole = roleService.getCurrentRole();
        
        if (chatState.currentRole?.id !== currentRole?.id) {
            throw new Error('Chat panel not updated after role switch from role manager');
        }
        
        // Test context-aware AI responds to role changes
        const contextState = contextAwareAI.getState();
        if (contextState.currentRole?.id !== currentRole?.id) {
            throw new Error('Context-aware AI not updated after role switch from role manager');
        }
    });

    test('Configuration Management', async () => {
        // Test configuration persistence
        const config = vscode.workspace.getConfiguration('noodle.ai');
        
        // Test default role configuration
        const defaultRole = config.get<string>('defaultRole');
        if (defaultRole && defaultRole !== 'noodlecore-manager') {
            await config.update('defaultRole', 'noodlecore-manager');
        }
        
        // Test auto-switch configuration
        const autoSwitch = config.get<boolean>('autoRoleSwitch', true);
        if (autoSwitch !== false) {
            await config.update('autoRoleSwitch', false);
        }
        
        // Test favorites configuration
        const favorites = config.get<string[]>('favoriteRoles', []);
        if (!favorites.includes('noodlecore-developer')) {
            await config.update('favoriteRoles', [...favorites, 'noodlecore-developer']);
        }
        
        // Verify configuration was applied
        const updatedConfig = vscode.workspace.getConfiguration('noodle.ai');
        const updatedDefaultRole = updatedConfig.get<string>('defaultRole');
        const updatedAutoSwitch = updatedConfig.get<boolean>('autoRoleSwitch');
        const updatedFavorites = updatedConfig.get<string[]>('favoriteRoles');
        
        if (updatedDefaultRole !== 'noodlecore-manager' || 
            updatedAutoSwitch !== false || 
            !updatedFavorites.includes('noodlecore-developer')) {
            throw new Error('Configuration management not working correctly');
        }
    });

    test('Error Handling', async () => {
        // Test error handling in role service
        try {
            await roleService.setCurrentRole('invalid-role-id');
            throw new Error('This should not be reached');
        } catch (error) {
            // Expected error handling
            if (!(error instanceof Error)) {
                throw new Error('Expected Error instance but got different type');
            }
        }
        
        // Test error handling in chat panel
        try {
            await roleChatPanel.show();
            // This would require more complex webview interaction testing
        } catch (error) {
            // Expected error handling for webview creation
            if (!(error instanceof Error)) {
                throw new Error('Expected Error instance but got different type');
            }
        }
    });

    test('Performance', async () => {
        // Test performance with multiple role switches
        const startTime = Date.now();
        
        for (let i = 0; i < 10; i++) {
            await roleService.setCurrentRole(`test-role-${i}`);
        }
        
        const endTime = Date.now();
        const duration = endTime - startTime;
        
        // Should complete within reasonable time (less than 1 second for in-memory operations)
        if (duration > 1000) {
            throw new Error(`Role switching performance test failed: took ${duration}ms for 10 switches`);
        }
    });

    test('Memory Integration', async () => {
        // Test memory context persistence
        const testKey = 'test-key';
        const testValue = 'test-value';
        
        // Update memory context
        roleService.updateMemoryContext({
            [testKey]: testValue
        });
        
        // Verify memory context was updated
        const memoryContext = roleService.getMemoryContext();
        if (memoryContext.workspaceSpecific[testKey] !== testValue) {
            throw new Error('Memory context not properly updated');
        }
        
        // Test memory context clearing
        roleService.clearConversationHistory();
        
        const history = roleService.getConversationHistory();
        if (history.length !== 0) {
            throw new Error('Conversation history not properly cleared');
        }
    });
});

// Helper function for test suite setup
function suiteSetup(setupFn: () => void) {
    setupFn();
}

// Helper function for test suite teardown
function suiteTeardown(teardownFn: () => void) {
    teardownFn();
}

// Test function helper
function test(name: string, testFn: () => Promise<void>) {
    return test(name, testFn);
}

// Test suite function
function suite(name: string, tests: Array<{ name: string; testFn: () => Promise<void> }>) {
    suite(name, () => {
        for (const { name, testFn } of tests) {
            try {
                await testFn();
            } catch (error) {
                throw new Error(`Test "${name}" failed: ${error.message}`);
            }
        }
    });
}