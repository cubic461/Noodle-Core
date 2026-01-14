"use strict";
/**
 * Kubernetes Integration for Noodle VS Code Extension
 *
 * Provides comprehensive Kubernetes cluster management, deployment,
 * and resource monitoring capabilities.
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
exports.KubernetesIntegration = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
const child_process_1 = require("child_process");
const util_1 = require("util");
const execAsync = (0, util_1.promisify)(child_process_1.exec);
class KubernetesIntegration extends events_1.EventEmitter {
    constructor(context, serviceManager, configManager, eventBus, cacheManager, logger) {
        this.serviceManager = serviceManager;
        this.configManager = configManager;
        this.eventBus = eventBus;
        this.cacheManager = cacheManager;
        this.logger = logger;
        this.isInitialized = false;
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Kubernetes Integration');
        this.config = {};
    }
    /**
     * Initialize Kubernetes integration
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing Kubernetes integration...');
            // Load configuration
            await this.loadConfiguration();
            // Check kubectl availability
            await this.checkKubectlAvailability();
            // Validate connection
            await this.validateConnection();
            this.isInitialized = true;
            this.outputChannel.appendLine('Kubernetes integration initialized');
            this.emit('initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize Kubernetes integration: ${error.message}`);
            throw error;
        }
    }
    /**
     * Check if integration is enabled
     */
    isEnabled() {
        return this.configManager.get('ecosystem.kubernetes.enabled') || false;
    }
    /**
     * Get status
     */
    getStatus() {
        if (!this.isInitialized) {
            return 'not_initialized';
        }
        if (!this.isEnabled()) {
            return 'disabled';
        }
        return 'healthy';
    }
    /**
     * Show status
     */
    async showStatus() {
        try {
            this.outputChannel.appendLine('Kubernetes Integration Status');
            this.outputChannel.appendLine('===========================');
            // Configuration
            this.outputChannel.appendLine(`Configuration:`);
            this.outputChannel.appendLine(`  Enabled: ${this.isEnabled()}`);
            this.outputChannel.appendLine(`  Namespace: ${this.config.namespace || 'default'}`);
            this.outputChannel.appendLine(`  Context: ${this.config.context || 'default'}`);
            this.outputChannel.appendLine(`  Cluster: ${this.config.cluster || 'unknown'}`);
            // Connection status
            const connectionStatus = await this.checkConnectionStatus();
            this.outputChannel.appendLine(`\nConnection Status:`);
            this.outputChannel.appendLine(`  Connected: ${connectionStatus.connected}`);
            this.outputChannel.appendLine(`  Server: ${connectionStatus.server}`);
            this.outputChannel.appendLine(`  Version: ${connectionStatus.version}`);
            // Resource summary
            const resourceSummary = await this.getResourceSummary();
            this.outputChannel.appendLine(`\nResource Summary:`);
            this.outputChannel.appendLine(`  Pods: ${resourceSummary.pods}`);
            this.outputChannel.appendLine(`  Deployments: ${resourceSummary.deployments}`);
            this.outputChannel.appendLine(`  Services: ${resourceSummary.services}`);
            this.outputChannel.appendLine(`  Ingresses: ${resourceSummary.ingresses}`);
            this.outputChannel.show();
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to show status: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to show Kubernetes status: ${error.message}`);
        }
    }
    /**
     * Show Kubernetes status
     */
    async showKubernetesStatus() {
        try {
            this.outputChannel.appendLine('Kubernetes Integration Status');
            this.outputChannel.appendLine('===========================');
            // Configuration
            this.outputChannel.appendLine(`Configuration:`);
            this.outputChannel.appendLine(`  Enabled: ${this.isEnabled()}`);
            this.outputChannel.appendLine(`  Namespace: ${this.config.namespace || 'default'}`);
            this.outputChannel.appendLine(`  Context: ${this.config.context || 'default'}`);
            this.outputChannel.appendLine(`  Cluster: ${this.config.cluster || 'unknown'}`);
            // Connection status
            const connectionStatus = await this.checkConnectionStatus();
            this.outputChannel.appendLine(`\nConnection Status:`);
            this.outputChannel.appendLine(`  Connected: ${connectionStatus.connected}`);
            this.outputChannel.appendLine(`  Server: ${connectionStatus.server}`);
            this.outputChannel.appendLine(`  Version: ${connectionStatus.version}`);
            // Resource summary
            const resourceSummary = await this.getResourceSummary();
            this.outputChannel.appendLine(`\nResource Summary:`);
            this.outputChannel.appendLine(`  Pods: ${resourceSummary.pods}`);
            this.outputChannel.appendLine(`  Deployments: ${resourceSummary.deployments}`);
            this.outputChannel.appendLine(`  Services: ${resourceSummary.services}`);
            this.outputChannel.appendLine(`  Ingresses: ${resourceSummary.ingresses}`);
            this.outputChannel.show();
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to show status: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to show Kubernetes status: ${error.message}`);
        }
    }
    /**
     * Deploy manifest
     */
    async deploy(manifestPath) {
        try {
            this.outputChannel.appendLine(`Deploying Kubernetes manifest: ${manifestPath}`);
            // Validate manifest file
            if (!fs.existsSync(manifestPath)) {
                throw new Error(`Manifest file not found: ${manifestPath}`);
            }
            // Get namespace
            const namespace = this.config.namespace || 'default';
            // Apply manifest
            const command = `kubectl apply -f "${manifestPath}" -n ${namespace}`;
            const { stdout, stderr } = await execAsync(command);
            if (stderr && !stderr.includes('created') && !stderr.includes('configured')) {
                throw new Error(`kubectl apply failed: ${stderr}`);
            }
            this.outputChannel.appendLine(`Deployment successful: ${stdout}`);
            vscode.window.showInformationMessage(`Kubernetes manifest deployed successfully`);
            this.emit('deployed', { manifestPath, namespace });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to deploy manifest: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to deploy Kubernetes manifest: ${error.message}`);
            return false;
        }
    }
    /**
     * Scale deployment
     */
    async scale(deploymentName, replicas) {
        try {
            this.outputChannel.appendLine(`Scaling deployment ${deploymentName} to ${replicas} replicas`);
            // Get namespace
            const namespace = this.config.namespace || 'default';
            // Scale deployment
            const command = `kubectl scale deployment ${deploymentName} --replicas=${replicas} -n ${namespace}`;
            const { stdout, stderr } = await execAsync(command);
            if (stderr) {
                throw new Error(`kubectl scale failed: ${stderr}`);
            }
            this.outputChannel.appendLine(`Scale successful: ${stdout}`);
            vscode.window.showInformationMessage(`Deployment ${deploymentName} scaled to ${replicas} replicas`);
            this.emit('scaled', { deploymentName, replicas, namespace });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to scale deployment: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to scale deployment: ${error.message}`);
            return false;
        }
    }
    /**
     * Get pod logs
     */
    async getLogs(podName, follow, tail) {
        try {
            this.outputChannel.appendLine(`Getting logs for pod: ${podName}`);
            // Get namespace
            const namespace = this.config.namespace || 'default';
            // Build command
            let command = `kubectl logs ${podName} -n ${namespace}`;
            if (follow) {
                command += ' -f';
            }
            if (tail) {
                command += ` --tail=${tail}`;
            }
            // Show logs in output channel
            const child = (0, child_process_1.exec)(command);
            child.stdout?.on('data', (data) => {
                this.outputChannel.appendLine(data.toString());
            });
            child.stderr?.on('data', (data) => {
                this.outputChannel.appendLine(`Error: ${data.toString()}`);
            });
            child.on('close', (code) => {
                if (code !== 0) {
                    this.outputChannel.appendLine(`kubectl logs exited with code ${code}`);
                }
            });
            this.outputChannel.show();
            this.emit('logsRetrieved', { podName, namespace, follow, tail });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to get logs: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to get pod logs: ${error.message}`);
            return false;
        }
    }
    /**
     * Delete resource
     */
    async deleteResource(resourceType, resourceName) {
        try {
            this.outputChannel.appendLine(`Deleting ${resourceType}: ${resourceName}`);
            // Get namespace
            const namespace = this.config.namespace || 'default';
            // Delete resource
            const command = `kubectl delete ${resourceType} ${resourceName} -n ${namespace}`;
            const { stdout, stderr } = await execAsync(command);
            if (stderr && !stderr.includes('deleted')) {
                throw new Error(`kubectl delete failed: ${stderr}`);
            }
            this.outputChannel.appendLine(`Delete successful: ${stdout}`);
            vscode.window.showInformationMessage(`${resourceType} ${resourceName} deleted successfully`);
            this.emit('resourceDeleted', { resourceType, resourceName, namespace });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to delete resource: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to delete ${resourceType}: ${error.message}`);
            return false;
        }
    }
    /**
     * Port forward
     */
    async portForward(podName, localPort, remotePort) {
        try {
            this.outputChannel.appendLine(`Setting up port forward: ${localPort}:${remotePort} -> ${podName}`);
            // Get namespace
            const namespace = this.config.namespace || 'default';
            // Start port forwarding
            const command = `kubectl port-forward ${podName} ${localPort}:${remotePort} -n ${namespace}`;
            const child = (0, child_process_1.exec)(command);
            child.stdout?.on('data', (data) => {
                this.outputChannel.appendLine(data.toString());
            });
            child.stderr?.on('data', (data) => {
                this.outputChannel.appendLine(`Error: ${data.toString()}`);
            });
            child.on('close', (code) => {
                if (code !== 0) {
                    this.outputChannel.appendLine(`kubectl port-forward exited with code ${code}`);
                }
            });
            vscode.window.showInformationMessage(`Port forwarding setup: ${localPort}:${remotePort} -> ${podName}`);
            this.emit('portForwarded', { podName, localPort, remotePort, namespace });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to setup port forward: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to setup port forward: ${error.message}`);
            return false;
        }
    }
    /**
     * Create manifest
     */
    async createManifest(resourceType) {
        try {
            this.outputChannel.appendLine(`Creating ${resourceType} manifest template`);
            // Get template based on resource type
            const template = this.getManifestTemplate(resourceType);
            if (!template) {
                throw new Error(`Unsupported resource type: ${resourceType}`);
            }
            // Create file path
            const workspaceFolders = vscode.workspace.workspaceFolders;
            if (!workspaceFolders) {
                throw new Error('No workspace folder open');
            }
            const workspacePath = workspaceFolders[0].uri.fsPath;
            const k8sDir = path.join(workspacePath, 'k8s');
            // Ensure k8s directory exists
            if (!fs.existsSync(k8sDir)) {
                fs.mkdirSync(k8sDir, { recursive: true });
            }
            const fileName = `${resourceType}-template.yaml`;
            const filePath = path.join(k8sDir, fileName);
            // Write template to file
            fs.writeFileSync(filePath, template, 'utf8');
            // Open file in editor
            const document = await vscode.workspace.openTextDocument(filePath);
            await vscode.window.showTextDocument(document);
            vscode.window.showInformationMessage(`${resourceType} manifest template created: ${fileName}`);
            this.emit('manifestCreated', { resourceType, filePath });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to create manifest: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to create manifest: ${error.message}`);
            return false;
        }
    }
    /**
     * Load configuration
     */
    async loadConfiguration() {
        try {
            this.config = {
                kubeconfig: this.configManager.get('ecosystem.kubernetes.kubeconfig'),
                namespace: this.configManager.get('ecosystem.kubernetes.namespace'),
                context: this.configManager.get('ecosystem.kubernetes.context'),
                cluster: this.configManager.get('ecosystem.kubernetes.cluster')
            };
            this.outputChannel.appendLine('Kubernetes configuration loaded');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to load configuration: ${error.message}`);
        }
    }
    /**
     * Check kubectl availability
     */
    async checkKubectlAvailability() {
        try {
            const { stdout, stderr } = await execAsync('kubectl version --client');
            if (stderr) {
                throw new Error(`kubectl not available: ${stderr}`);
            }
            this.outputChannel.appendLine(`kubectl version: ${stdout}`);
        }
        catch (error) {
            throw new Error(`kubectl not available: ${error.message}`);
        }
    }
    /**
     * Validate connection
     */
    async validateConnection() {
        try {
            const { stdout, stderr } = await execAsync('kubectl cluster-info');
            if (stderr) {
                throw new Error(`Kubernetes connection failed: ${stderr}`);
            }
            this.outputChannel.appendLine(`Kubernetes cluster info: ${stdout}`);
        }
        catch (error) {
            throw new Error(`Kubernetes connection validation failed: ${error.message}`);
        }
    }
    /**
     * Check connection status
     */
    async checkConnectionStatus() {
        try {
            const { stdout } = await execAsync('kubectl cluster-info');
            // Parse server info
            const serverMatch = stdout.match(/Server is running at (.+)/);
            const server = serverMatch ? serverMatch[1] : 'unknown';
            // Get version
            const { stdout: versionOutput } = await execAsync('kubectl version --short');
            const versionMatch = versionOutput.match(/Server Version: (.+)/);
            const version = versionMatch ? versionMatch[1] : 'unknown';
            return {
                connected: true,
                server,
                version
            };
        }
        catch (error) {
            return {
                connected: false,
                server: 'unknown',
                version: 'unknown',
                error: error.message
            };
        }
    }
    /**
     * Get resource summary
     */
    async getResourceSummary() {
        try {
            const namespace = this.config.namespace || 'default';
            // Get pods
            const { stdout: podsOutput } = await execAsync(`kubectl get pods -n ${namespace} --no-headers`);
            const pods = podsOutput.split('\n').filter(line => line.trim()).length;
            // Get deployments
            const { stdout: deploymentsOutput } = await execAsync(`kubectl get deployments -n ${namespace} --no-headers`);
            const deployments = deploymentsOutput.split('\n').filter(line => line.trim()).length;
            // Get services
            const { stdout: servicesOutput } = await execAsync(`kubectl get services -n ${namespace} --no-headers`);
            const services = servicesOutput.split('\n').filter(line => line.trim()).length;
            // Get ingresses
            const { stdout: ingressesOutput } = await execAsync(`kubectl get ingress -n ${namespace} --no-headers`);
            const ingresses = ingressesOutput.split('\n').filter(line => line.trim()).length;
            return {
                pods,
                deployments,
                services,
                ingresses
            };
        }
        catch (error) {
            return {
                pods: 0,
                deployments: 0,
                services: 0,
                ingresses: 0,
                error: error.message
            };
        }
    }
    /**
     * Get manifest template
     */
    getManifestTemplate(resourceType) {
        const templates = {
            deployment: `apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"`,
            service: `apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP`,
            ingress: `apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
spec:
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: my-app-service
            port:
              number: 80`,
            configmap: `apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
data:
  key1: value1
  key2: value2`,
            secret: `apiVersion: v1
kind: Secret
metadata:
  name: my-app-secret
type: Opaque
data:
  username: <base64-encoded-username>
  password: <base64-encoded-password>`
        };
        return templates[resourceType] || null;
    }
    /**
     * Dispose Kubernetes integration
     */
    dispose() {
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.KubernetesIntegration = KubernetesIntegration;
//# sourceMappingURL=kubernetesIntegration.js.map