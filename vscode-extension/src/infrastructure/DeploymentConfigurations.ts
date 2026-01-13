/**
 * NoodleCore Deployment Configurations
 * 
 * Provides deployment configurations for different environments
 * including development, production, and containerized deployments.
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

export interface EnvironmentConfig {
    name: string;
    debug: boolean;
    logLevel: 'debug' | 'info' | 'warning' | 'error';
    apiTimeout: number;
    maxRetries: number;
    cacheEnabled: boolean;
    monitoringEnabled: boolean;
}

export interface DatabaseConfig {
    host: string;
    port: number;
    database: string;
    ssl: boolean;
    connectionPool: {
        min: number;
        max: number;
        timeout: number;
    };
}

export interface ServerConfig {
    host: string;
    port: number;
    ssl: boolean;
    workers: number;
    keepAlive: boolean;
    timeout: number;
}

export interface AIConfig {
    provider: string;
    model: string;
    apiKey: string;
    endpoint: string;
    timeout: number;
    maxTokens: number;
    temperature: number;
}

export interface LSPConfig {
    enabled: boolean;
    serverMode: 'python' | 'node';
    serverPath: string;
    pythonPath: string;
    nodePath: string;
    logLevel: string;
    enableAnalysis: boolean;
}

export interface PerformanceConfig {
    monitoring: boolean;
    profiling: boolean;
    metricsInterval: number;
    memoryThreshold: number;
    cpuThreshold: number;
    cacheSize: number;
}

export interface SecurityConfig {
    enableEncryption: boolean;
    jwtExpiration: number;
    allowedOrigins: string[];
    rateLimiting: {
        enabled: boolean;
        windowMs: number;
        maxRequests: number;
    };
}

export interface DeploymentConfig {
    environment: EnvironmentConfig;
    database: DatabaseConfig;
    server: ServerConfig;
    ai: AIConfig;
    lsp: LSPConfig;
    performance: PerformanceConfig;
    security: SecurityConfig;
}

export interface DockerConfig {
    image: string;
    tag: string;
    ports: {
        api: number;
        web: number;
        database: number;
    };
    volumes: {
        data: string;
        logs: string;
        config: string;
    };
    environment: {
        [key: string]: string;
    };
    networks: string[];
    depends_on?: string[];
}

export interface KubernetesConfig {
    namespace: string;
    replicas: number;
    image: {
        repository: string;
        tag: string;
        pullPolicy: 'Always' | 'IfNotPresent';
    };
    resources: {
        requests: {
            cpu: string;
            memory: string;
        };
        limits: {
            cpu: string;
            memory: string;
        };
    };
    ports: {
        api: number;
        web: number;
    };
    volumes: {
        data: string;
        logs: string;
        config: string;
    };
    env: {
        [key: string]: string;
    };
    secrets: {
        [key: string]: string;
        secretKeyRef: string;
    };
}

export interface DeploymentTemplate {
    name: string;
    description: string;
    config: DeploymentConfig;
    docker?: DockerConfig;
    kubernetes?: KubernetesConfig;
}

/**
 * Deployment Configuration Manager
 */
export class DeploymentConfigurationManager {
    private configs: Map<string, DeploymentTemplate> = new Map();
    private currentEnvironment: string = 'development';

    constructor(private workspaceRoot: string) {
        this.initializeDefaultTemplates();
    }

    /**
     * Initialize configuration manager
     */
    public async initialize(): Promise<void> {
        // Load custom configurations from workspace
        await this.loadCustomConfigurations();
    }

    /**
     * Get current environment
     */
    public getCurrentEnvironment(): string {
        return this.currentEnvironment;
    }

    /**
     * Set current environment
     */
    public setEnvironment(environment: string): void {
        this.currentEnvironment = environment;
        vscode.window.showInformationMessage(`Environment switched to: ${environment}`);
    }

    /**
     * Get deployment template by name
     */
    public getTemplate(name: string): DeploymentTemplate | undefined {
        return this.configs.get(name);
    }

    /**
     * Register a deployment template
     */
    public registerTemplate(template: DeploymentTemplate): void {
        this.configs.set(template.name, template);
    }

    /**
     * Get all registered templates
     */
    public getTemplates(): DeploymentTemplate[] {
        return Array.from(this.configs.values());
    }

    /**
     * Generate deployment configuration for environment
     */
    public generateConfig(environment: string): DeploymentConfig | null {
        const template = this.configs.get(environment);
        if (!template) {
            throw new Error(`No template found for environment: ${environment}`);
        }

        return this.interpolateConfig(template.config, environment);
    }

    /**
     * Generate Docker configuration
     */
    public generateDockerConfig(template: DeploymentTemplate): DockerConfig {
        const baseConfig = template.config;
        
        return {
            image: 'noodle/noodle-core:' + (template.docker?.tag || 'latest'),
            tag: template.docker?.tag || 'latest',
            ports: {
                api: 8080,
                web: 3000,
                database: 5432
            },
            volumes: {
                data: '/app/data',
                logs: '/app/logs',
                config: '/app/config'
            },
            environment: {
                ...template.docker?.environment,
                NODE_ENV: environment,
                NOODLE_ENV: environment,
                NOODLE_PORT: '8080',
                NOODLE_LOG_LEVEL: baseConfig.environment?.logLevel || 'info'
            },
            networks: template.docker?.networks || ['noodle-network'],
            depends_on: template.docker?.depends_on
        };
    }

    /**
     * Generate Kubernetes configuration
     */
    public generateKubernetesConfig(template: DeploymentTemplate): KubernetesConfig {
        const baseConfig = template.config;
        
        return {
            namespace: 'noodle',
            replicas: template.kubernetes?.replicas || 3,
            image: {
                repository: 'noodle/noodle-core',
                tag: template.kubernetes?.tag || 'latest',
                pullPolicy: template.kubernetes?.pullPolicy || 'Always'
            },
            resources: {
                requests: {
                    cpu: template.kubernetes?.resources?.requests?.cpu || '100m',
                    memory: template.kubernetes?.resources?.requests?.memory || '256Mi'
                },
                limits: {
                    cpu: template.kubernetes?.resources?.limits?.cpu || '500m',
                    memory: template.kubernetes?.resources?.limits?.memory || '512Mi'
                }
            },
            ports: {
                api: 8080,
                web: 3000
            },
            volumes: [
                {
                    name: 'data-volume',
                    persistentVolumeClaim: {
                        claimName: 'noodle-data-pvc'
                    },
                    mountPath: '/app/data'
                },
                {
                    name: 'logs-volume',
                    persistentVolumeClaim: {
                        claimName: 'noodle-logs-pvc'
                    },
                    mountPath: '/app/logs'
                },
                {
                    name: 'config-volume',
                    configMap: {
                        name: 'noodle-config'
                    },
                    mountPath: '/app/config'
                }
            ],
            env: [
                ...template.kubernetes?.env,
                { name: 'NODE_ENV', value: 'production' },
                { name: 'NOODLE_ENV', value: 'production' },
                { name: 'NOODLE_PORT', value: '8080' },
                { name: 'NOODLE_LOG_LEVEL', value: baseConfig.environment?.logLevel || 'info' }
            ],
            secrets: template.kubernetes?.secrets || []
        };
    }

    /**
     * Save deployment configuration to file
     */
    public async saveConfig(environment: string, config: DeploymentConfig): Promise<void> {
        const configPath = this.getConfigPath(environment);
        const configDir = path.dirname(configPath);
        
        // Ensure config directory exists
        if (!fs.existsSync(configDir)) {
            await fs.promises.mkdir(configDir, { recursive: true });
        }

        // Save main configuration
        await fs.promises.writeFile(
            configPath,
            JSON.stringify(config, null, 2),
            'utf8'
        );

        // Save Docker configuration if present
        if (config.docker) {
            const dockerConfig = this.generateDockerConfig({ name: environment, config });
            const dockerPath = path.join(configDir, 'docker-compose.yml');
            await fs.promises.writeFile(
                dockerPath,
                this.generateDockerCompose(dockerConfig),
                'utf8'
            );
        }

        // Save Kubernetes configuration if present
        if (config.kubernetes) {
            const k8sConfig = this.generateKubernetesConfig({ name: environment, config });
            const k8sPath = path.join(configDir, 'k8s-deployment.yml');
            await fs.promises.writeFile(
                k8sPath,
                this.generateKubernetesDeployment(k8sConfig),
                'utf8'
            );
        }

        vscode.window.showInformationMessage(`Configuration saved for ${environment}`);
    }

    /**
     * Load deployment configuration from file
     */
    public async loadConfig(environment: string): Promise<DeploymentConfig | null> {
        const configPath = this.getConfigPath(environment);
        
        if (!fs.existsSync(configPath)) {
            return null;
        }

        const configData = await fs.promises.readFile(configPath, 'utf8');
        return JSON.parse(configData);
    }

    /**
     * Get configuration file path
     */
    private getConfigPath(environment: string): string {
        return path.join(this.workspaceRoot, '.noodle', `${environment}.json`);
    }

    /**
     * Interpolate configuration with environment-specific values
     */
    private interpolateConfig(config: DeploymentConfig, environment: string): DeploymentConfig {
        const envConfig = config.environment;
        
        return {
            environment: {
                ...envConfig,
                name: environment
            },
            database: {
                ...config.database,
                host: this.interpolateValue(config.database.host, environment),
                port: this.interpolateValue(config.database.port, environment)
            },
            server: {
                ...config.server,
                host: this.interpolateValue(config.server.host, environment),
                port: this.interpolateValue(config.server.port, environment)
            },
            ai: {
                ...config.ai,
                apiKey: this.interpolateValue(config.ai.apiKey, environment),
                endpoint: this.interpolateValue(config.ai.endpoint, environment)
            },
            lsp: {
                ...config.lsp,
                serverPath: this.interpolateValue(config.lsp.serverPath, environment)
            },
            performance: {
                ...config.performance,
                monitoring: this.interpolateValue(config.performance.monitoring, environment)
            },
            security: {
                ...config.security,
                allowedOrigins: this.interpolateValue(config.security.allowedOrigins, environment)
            }
        };
    }

    /**
     * Interpolate a configuration value
     */
    private interpolateValue(value: any, environment: string): any {
        if (typeof value === 'string' && value.startsWith('${') && value.endsWith('}')) {
            // Simple template interpolation
            const template = value.slice(2, -2);
            return template.replace(/\${ENV}/g, environment);
        }
        
        return value;
    }

    /**
     * Generate Docker Compose configuration
     */
    private generateDockerCompose(config: DockerConfig): string {
        return `version: '3.8'

services:
  noodle-api:
    image: ${config.image}
    ports:
      - "${config.ports.api}:${config.ports.api}"
      - "${config.ports.web}:${config.ports.web}"
      - "${config.ports.database}:${config.ports.database}"
    environment:
${Object.entries(config.environment || {})
    .map(([key, value]) => `      - ${key}: ${value}`)
    .join('\n')}
    volumes:
${config.volumes ? Object.entries(config.volumes)
    .map(([name, volume]) => `      - ${name}: ${volume}`)
    .join('\n') : ''}
${config.networks ? config.networks.map(network => `    networks:
      - ${network}`).join('\n') : ''}
${config.depends_on ? config.depends_on.map(service => `    depends_on:
      - ${service}`).join('\n') : ''}

  noodle-web:
    image: noodle/noodle-web:${config.tag}
    ports:
      - "${config.ports.web}:80"
    volumes:
      - ./web:/app
      - noodle-data:/app/data
    depends_on:
      - noodle-api
`;
    }

    /**
     * Generate Kubernetes deployment configuration
     */
    private generateKubernetesDeployment(config: KubernetesConfig): string {
        return `apiVersion: apps/v1
kind: Deployment
metadata:
  name: noodle-${config.namespace}
  labels:
    app: noodle
spec:
  replicas: ${config.replicas}
  selector:
    matchLabels:
      app: noodle
  template:
    metadata:
      labels:
        app: noodle
    spec:
      containers:
      - name: noodle-api
        image: ${config.image.repository}:${config.image.tag}
        ports:
        - containerPort: 8080
          protocol: TCP
        env:
${config.env.map(([key, value]) => `        - name: ${key}
          value: "${value}"`).join('\n')}
        resources:
          requests:
            cpu: ${config.resources.requests.cpu}
            memory: ${config.resources.requests.memory}
          limits:
            cpu: ${config.resources.limits.cpu}
            memory: ${config.resources.limits.memory}
        volumeMounts:
        - name: data-volume
          mountPath: /app/data
        - name: logs-volume
          mountPath: /app/logs
        - name: config-volume
          mountPath: /app/config
---
apiVersion: v1
kind: Service
metadata:
  name: noodle-${config.namespace}-service
  labels:
    app: noodle
spec:
  selector:
    app: noodle
  ports:
  - name: api
    port: 8080
    protocol: TCP
  - name: web
    port: 3000
    protocol: TCP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${config.volumes?.find(v => v.name === 'data-volume')?.persistentVolumeClaim?.claimName || 'noodle-data-pvc'}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${config.volumes?.find(v => v.name === 'logs-volume')?.persistentVolumeClaim?.claimName || 'noodle-logs-pvc'}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: noodle-config
data:
${config.env ? Object.entries(config.env)
    .filter(([key]) => !key.startsWith('NOODLE_'))
    .map(([key, value]) => `  ${key}: "${value}"`).join('\n') : ''}`;
    }

    /**
     * Initialize default deployment templates
     */
    private initializeDefaultTemplates(): void {
        // Development environment
        this.registerTemplate({
            name: 'development',
            description: 'Development environment configuration',
            config: {
                environment: {
                    name: 'development',
                    debug: true,
                    logLevel: 'debug',
                    apiTimeout: 30000,
                    maxRetries: 3,
                    cacheEnabled: true,
                    monitoringEnabled: true
                },
                database: {
                    host: 'localhost',
                    port: 5432,
                    database: 'noodle_dev',
                    ssl: false,
                    connectionPool: {
                        min: 2,
                        max: 5,
                        timeout: 30000
                    }
                },
                server: {
                    host: '0.0.0.0',
                    port: 8080,
                    ssl: false,
                    workers: 1,
                    keepAlive: true,
                    timeout: 30000
                },
                ai: {
                    provider: 'openai',
                    model: 'gpt-4',
                    apiKey: '${OPENAI_API_KEY}',
                    endpoint: 'https://api.openai.com/v1',
                    timeout: 30000,
                    maxTokens: 1000,
                    temperature: 0.7
                },
                lsp: {
                    enabled: true,
                    serverMode: 'python',
                    serverPath: './src/lsp/noodleLspServer.py',
                    pythonPath: 'python',
                    logLevel: 'debug',
                    enableAnalysis: true
                },
                performance: {
                    monitoring: true,
                    profiling: false,
                    metricsInterval: 5000,
                    memoryThreshold: 80,
                    cpuThreshold: 80,
                    cacheSize: 100 * 1024 * 1024
                },
                security: {
                    enableEncryption: false,
                    jwtExpiration: 7200,
                    allowedOrigins: ['http://localhost:3000', 'http://localhost:8080'],
                    rateLimiting: {
                        enabled: false,
                        windowMs: 900000,
                        maxRequests: 100
                    }
                },
                docker: {
                    image: 'noodle/noodle-core:dev',
                    tag: 'latest',
                    ports: {
                        api: 8080,
                        web: 3000,
                        database: 5432
                    },
                    volumes: {
                        data: './data',
                        logs: './logs',
                        config: './config'
                    },
                    environment: {
                        NODE_ENV: 'development',
                        NOODLE_ENV: 'development',
                        NOODLE_PORT: '8080'
                    }
                }
            }
        });

        // Production environment
        this.registerTemplate({
            name: 'production',
            description: 'Production environment configuration',
            config: {
                environment: {
                    name: 'production',
                    debug: false,
                    logLevel: 'error',
                    apiTimeout: 30000,
                    maxRetries: 3,
                    cacheEnabled: true,
                    monitoringEnabled: true
                },
                database: {
                    host: '${DB_HOST}',
                    port: 5432,
                    database: 'noodle_prod',
                    ssl: true,
                    connectionPool: {
                        min: 5,
                        max: 20,
                        timeout: 30000
                    }
                },
                server: {
                    host: '0.0.0.0',
                    port: 8080,
                    ssl: true,
                    workers: 4,
                    keepAlive: true,
                    timeout: 30000
                },
                ai: {
                    provider: 'openai',
                    model: 'gpt-4',
                    apiKey: '${OPENAI_API_KEY}',
                    endpoint: 'https://api.openai.com/v1',
                    timeout: 30000,
                    maxTokens: 1000,
                    temperature: 0.7
                },
                lsp: {
                    enabled: true,
                    serverMode: 'python',
                    serverPath: './src/lsp/noodleLspServer.py',
                    pythonPath: 'python3',
                    logLevel: 'info',
                    enableAnalysis: true
                },
                performance: {
                    monitoring: true,
                    profiling: true,
                    metricsInterval: 10000,
                    memoryThreshold: 85,
                    cpuThreshold: 85,
                    cacheSize: 200 * 1024 * 1024
                },
                security: {
                    enableEncryption: true,
                    jwtExpiration: 7200,
                    allowedOrigins: ['https://api.noodle.com', 'https://app.noodle.com'],
                    rateLimiting: {
                        enabled: true,
                        windowMs: 900000,
                        maxRequests: 1000
                    }
                },
                docker: {
                    image: 'noodle/noodle-core:prod',
                    tag: 'latest',
                    ports: {
                        api: 8080,
                        web: 3000,
                        database: 5432
                    },
                    volumes: {
                        data: '/app/data',
                        logs: '/app/logs',
                        config: '/app/config'
                    },
                    environment: {
                        NODE_ENV: 'production',
                        NOODLE_ENV: 'production',
                        NOODLE_PORT: '8080'
                    }
                },
                kubernetes: {
                    namespace: 'noodle-prod',
                    replicas: 5,
                    image: {
                        repository: 'noodle/noodle-core',
                        tag: 'latest',
                        pullPolicy: 'Always'
                    },
                    resources: {
                        requests: {
                            cpu: '200m',
                            memory: '512Mi'
                        },
                        limits: {
                            cpu: '1000m',
                            memory: '1Gi'
                        }
                    },
                    env: {
                        NODE_ENV: 'production',
                        NOODLE_ENV: 'production',
                        NOODLE_PORT: '8080'
                    },
                    secrets: [
                        {
                            name: 'OPENAI_API_KEY',
                            secretKeyRef: 'openai-api-key'
                        }
                    ]
                }
            }
        });

        // Test environment
        this.registerTemplate({
            name: 'test',
            description: 'Test environment configuration',
            config: {
                environment: {
                    name: 'test',
                    debug: false,
                    logLevel: 'warning',
                    apiTimeout: 10000,
                    maxRetries: 1,
                    cacheEnabled: false,
                    monitoringEnabled: false
                },
                database: {
                    host: 'localhost',
                    port: 5432,
                    database: 'noodle_test',
                    ssl: false,
                    connectionPool: {
                        min: 1,
                        max: 3,
                        timeout: 10000
                    }
                },
                server: {
                    host: '0.0.0.0',
                    port: 8080,
                    ssl: false,
                    workers: 1,
                    keepAlive: false,
                    timeout: 10000
                },
                ai: {
                    provider: 'mock',
                    model: 'test-model',
                    apiKey: 'test-key',
                    endpoint: 'http://localhost:8081',
                    timeout: 5000,
                    maxTokens: 500,
                    temperature: 0.5
                },
                lsp: {
                    enabled: true,
                    serverMode: 'python',
                    serverPath: './src/lsp/noodleLspServer.py',
                    pythonPath: 'python3',
                    logLevel: 'debug',
                    enableAnalysis: true
                },
                performance: {
                    monitoring: false,
                    profiling: false,
                    metricsInterval: 30000,
                    memoryThreshold: 90,
                    cpuThreshold: 90,
                    cacheSize: 50 * 1024 * 1024
                },
                security: {
                    enableEncryption: false,
                    jwtExpiration: 3600,
                    allowedOrigins: ['http://localhost:3000'],
                    rateLimiting: {
                        enabled: false,
                        windowMs: 300000,
                        maxRequests: 50
                    }
                },
                docker: {
                    image: 'noodle/noodle-core:test',
                    tag: 'latest',
                    ports: {
                        api: 8080,
                        web: 3000,
                        database: 5432
                    },
                    volumes: {
                        data: './test-data',
                        logs: './test-logs',
                        config: './test-config'
                    },
                    environment: {
                        NODE_ENV: 'test',
                        NOODLE_ENV: 'test',
                        NOODLE_PORT: '8080'
                    }
                }
            }
        });
    }

    /**
     * Load custom configurations from workspace
     */
    private async loadCustomConfigurations(): Promise<void> {
        const configDir = path.join(this.workspaceRoot, '.noodle');
        
        if (!fs.existsSync(configDir)) {
            return;
        }

        const files = await fs.promises.readdir(configDir);
        
        for (const file of files) {
            if (file.endsWith('.json')) {
                try {
                    const filePath = path.join(configDir, file);
                    const content = await fs.promises.readFile(filePath, 'utf8');
                    const config = JSON.parse(content);
                    
                    if (config.name && config.config) {
                        this.registerTemplate({
                            name: config.name,
                            description: `Custom configuration: ${config.name}`,
                            config: config.config
                        });
                    }
                } catch (error) {
                    console.error(`Failed to load custom configuration from ${file}:`, error);
                }
            }
        }
    }
}