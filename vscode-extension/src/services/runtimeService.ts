import * as vscode from 'vscode';
import { NoodleBackendService } from './backendService';

export class NoodleRuntimeService {
    private backendService: NoodleBackendService;

    constructor() {
        this.backendService = new NoodleBackendService();
    }

    public async startRuntime(): Promise<void> {
        try {
            vscode.window.showInformationMessage('🚀 Starting Noodle runtime...');

            const response = await this.backendService.getServerInfo();

            if (response.success && response.data) {
                vscode.window.showInformationMessage(
                    `✅ Noodle runtime is running!
                    Version: ${response.data.version}
                    Status: ${response.data.status}`
                );
            } else {
                vscode.window.showErrorMessage(`❌ Failed to start runtime: ${response.error?.message || 'Unknown error'}`);
            }
        } catch (error) {
            vscode.window.showErrorMessage(`❌ Runtime service error: ${error}`);
        }
    }

    public async stopRuntime(): Promise<void> {
        try {
            vscode.window.showInformationMessage('🛑 Stopping Noodle runtime...');

            // For now, just show a message since we can't actually stop the backend
            vscode.window.showInformationMessage(
                'ℹ️ Runtime stop requested. Please stop the backend server manually.'
            );
        } catch (error) {
            vscode.window.showErrorMessage(`❌ Runtime service error: ${error}`);
        }
    }

    public async checkRuntimeStatus(): Promise<void> {
        try {
            const response = await this.backendService.getDatabaseStatus();

            if (response.success && response.data) {
                const status = response.data.status || 'unknown';
                vscode.window.showInformationMessage(`📊 Database status: ${status}`);
            } else {
                vscode.window.showErrorMessage(`❌ Failed to get runtime status: ${response.error?.message || 'Unknown error'}`);
            }
        } catch (error) {
            vscode.window.showErrorMessage(`❌ Runtime service error: ${error}`);
        }
    }
}