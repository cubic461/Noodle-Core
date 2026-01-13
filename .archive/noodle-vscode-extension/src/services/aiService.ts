import * as vscode from 'vscode';
import { NoodleBackendService } from './backendService';

export class NoodleAIService {
    private backendService: NoodleBackendService;

    constructor() {
        this.backendService = new NoodleBackendService();
    }

    async chatWithAI(message: string): Promise<void> {
        try {
            vscode.window.showInformationMessage('🤖 Sending message to AI...');
            
            const response = await this.backendService.makeAIChatRequest(message, []);
            
            if (response.success && response.data) {
                // Display AI response in a new document
                const aiResponse = response.data.response || response.data.message || 'No response from AI';
                
                // Create a new document with the AI response
                const document = await vscode.workspace.openTextDocument({
                    content: `AI: ${aiResponse}`,
                    language: 'markdown'
                });
                
                await vscode.window.showTextDocument(document);
                
                vscode.window.showInformationMessage('✅ AI response received');
            } else {
                vscode.window.showErrorMessage(`❌ AI chat failed: ${response.error?.message || 'Unknown error'}`);
            }
        } catch (error) {
            vscode.window.showErrorMessage(`❌ AI chat error: ${error}`);
        }
    }

    public async generateCode(prompt: string): Promise<void> {
        try {
            vscode.window.showInformationMessage('🤖 Generating code...');

            const response = await this.backendService.executeCode(`// Generate: ${prompt}`);

            if (response.success && response.data) {
                vscode.window.showInformationMessage('✅ Code generated successfully!');

                // Show generated code in new document
                const document = await vscode.workspace.openTextDocument({
                    content: response.data.result || response.data.output || '// Generated code',
                    language: 'noodle'
                });
                await vscode.window.showTextDocument(document);
            } else {
                vscode.window.showErrorMessage(`❌ Code generation failed: ${response.error?.message || 'Unknown error'}`);
            }
        } catch (error) {
            vscode.window.showErrorMessage(`❌ AI service error: ${error}`);
        }
    }

    public async analyzeCode(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('⚠️ No active editor found');
            return;
        }

        const selection = editor.selection;
        const code = editor.document.getText(selection.isEmpty ? undefined : selection);

        try {
            vscode.window.showInformationMessage('🔍 Analyzing code...');

            const response = await this.backendService.analyzeCode(code);

            if (response.success && response.data) {
                const analysis = response.data.analysis || response.data.result || 'Analysis complete';

                // Show analysis in output channel
                const outputChannel = vscode.window.createOutputChannel('Noodle AI Analysis');
                outputChannel.appendLine('=== Code Analysis Results ===');
                outputChannel.appendLine(analysis);
                outputChannel.appendLine('=============================');
                outputChannel.show();

                vscode.window.showInformationMessage('✅ Code analysis complete! Check output panel for results.');
            } else {
                vscode.window.showErrorMessage(`❌ Code analysis failed: ${response.error?.message || 'Unknown error'}`);
            }
        } catch (error) {
            vscode.window.showErrorMessage(`❌ AI service error: ${error}`);
        }
    }

    public async optimizeCode(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('⚠️ No active editor found');
            return;
        }

        const selection = editor.selection;
        const code = editor.document.getText(selection.isEmpty ? undefined : selection);

        try {
            vscode.window.showInformationMessage('⚡ Optimizing code...');

            const response = await this.backendService.executeCode(`// Optimize: ${code}`);

            if (response.success && response.data) {
                const optimized = response.data.result || response.data.output || code;

                if (!selection.isEmpty) {
                    // Replace selection with optimized code
                    await editor.edit(editBuilder => {
                        editBuilder.replace(selection, optimized);
                    });
                } else {
                    // Show optimized code in new document
                    const document = await vscode.workspace.openTextDocument({
                        content: optimized,
                        language: editor.document.languageId
                    });
                    await vscode.window.showTextDocument(document);
                }

                vscode.window.showInformationMessage('✅ Code optimized successfully!');
            } else {
                vscode.window.showErrorMessage(`❌ Code optimization failed: ${response.error?.message || 'Unknown error'}`);
            }
        } catch (error) {
            vscode.window.showErrorMessage(`❌ AI service error: ${error}`);
        }
    }

    public async checkBackendConnection(): Promise<void> {
        this.backendService.showConnectionStatus();
    }
}