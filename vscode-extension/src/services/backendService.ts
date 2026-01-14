/**
 * Minimal Backend Service Stub
 * Used only for activation - actual backend communication is optional
 */

import * as vscode from 'vscode';

export interface NoodleResponse {
    success: boolean;
    data?: any;
    error?: {
        code: number;
        message: string;
        details?: any;
    };
    requestId: string;
    timestamp: string;
}

export class NoodleBackendService {
    private outputChannel: vscode.OutputChannel;

    constructor() {
        this.outputChannel = vscode.window.createOutputChannel('Noodle Backend');
    }

    async initialize(): Promise<void> {
        this.outputChannel.appendLine('Noodle Backend Service (Stub Mode)');
        this.outputChannel.appendLine('Backend service is running in stub mode');
        this.outputChannel.appendLine('To use the full backend, start the Noodle server on port 8080');
    }

    dispose(): void {
        this.outputChannel.dispose();
    }
}
