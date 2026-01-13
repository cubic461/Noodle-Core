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
exports.NoodleRuntimeService = void 0;
const vscode = __importStar(require("vscode"));
const backendService_1 = require("./backendService");
class NoodleRuntimeService {
    constructor() {
        this.backendService = new backendService_1.NoodleBackendService();
    }
    async startRuntime() {
        try {
            vscode.window.showInformationMessage('🚀 Starting Noodle runtime...');
            const response = await this.backendService.getServerInfo();
            if (response.success && response.data) {
                vscode.window.showInformationMessage(`✅ Noodle runtime is running!
                    Version: ${response.data.version}
                    Status: ${response.data.status}`);
            }
            else {
                vscode.window.showErrorMessage(`❌ Failed to start runtime: ${response.error?.message || 'Unknown error'}`);
            }
        }
        catch (error) {
            vscode.window.showErrorMessage(`❌ Runtime service error: ${error}`);
        }
    }
    async stopRuntime() {
        try {
            vscode.window.showInformationMessage('🛑 Stopping Noodle runtime...');
            // For now, just show a message since we can't actually stop the backend
            vscode.window.showInformationMessage('ℹ️ Runtime stop requested. Please stop the backend server manually.');
        }
        catch (error) {
            vscode.window.showErrorMessage(`❌ Runtime service error: ${error}`);
        }
    }
    async checkRuntimeStatus() {
        try {
            const response = await this.backendService.getDatabaseStatus();
            if (response.success && response.data) {
                const status = response.data.status || 'unknown';
                vscode.window.showInformationMessage(`📊 Database status: ${status}`);
            }
            else {
                vscode.window.showErrorMessage(`❌ Failed to get runtime status: ${response.error?.message || 'Unknown error'}`);
            }
        }
        catch (error) {
            vscode.window.showErrorMessage(`❌ Runtime service error: ${error}`);
        }
    }
}
exports.NoodleRuntimeService = NoodleRuntimeService;
//# sourceMappingURL=runtimeService.js.map