"use strict";
/**
 * Minimal Backend Service Stub
 * Used only for activation - actual backend communication is optional
 */
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
exports.NoodleBackendService = void 0;
const vscode = __importStar(require("vscode"));
class NoodleBackendService {
    constructor() {
        this.outputChannel = vscode.window.createOutputChannel('Noodle Backend');
    }
    async initialize() {
        this.outputChannel.appendLine('Noodle Backend Service (Stub Mode)');
        this.outputChannel.appendLine('Backend service is running in stub mode');
        this.outputChannel.appendLine('To use the full backend, start the Noodle server on port 8080');
    }
    dispose() {
        this.outputChannel.dispose();
    }
}
exports.NoodleBackendService = NoodleBackendService;
//# sourceMappingURL=backendService.js.map