import { Command } from 'commander';
import chalk from 'chalk';
import { spawn } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

/**
 * Noodle Improvement Pipeline CLI Commands
 * 
 * This module provides CLI commands for managing the Noodle Improvement Pipeline (NIP),
 * including task creation, execution, candidate management, and promotion.
 */

// Paths
const NOODLE_CORE_PATH = path.join(__dirname, '../../noodle-core/src');
const IMPROVE_MODULE_PATH = path.join(NOODLE_CORE_PATH, 'noodlecore/improve');
const DEFAULT_ROOT_DIR = '.noodle/improve';

/**
 * Execute a Python script from the noodle-core module
 */
function executePythonScript(scriptName: string, args: string[]): Promise<{ stdout: string; stderr: string; exitCode: number }> {
    return new Promise((resolve, reject) => {
        const scriptPath = path.join(IMPROVE_MODULE_PATH, scriptName);
        const pythonArgs = ['-c', `
import sys
sys.path.insert(0, '${IMPROVE_MODULE_PATH.replace(/\\/g, '\\\\')}')
from ${scriptName.replace('.py', '')} import main
sys.argv = ['${scriptName}', ${args.map(a => `'${a}'`).join(', ')}]
main()
        `];

        const python = spawn('python', pythonArgs, {
            cwd: process.cwd(),
            env: { ...process.env, PYTHONPATH: NOODLE_CORE_PATH }
        });

        let stdout = '';
        let stderr = '';

        python.stdout.on('data', (data) => {
            stdout += data.toString();
        });

        python.stderr.on('data', (data) => {
            stderr += data.toString();
        });

        python.on('close', (code) => {
            resolve({ stdout, stderr, exitCode: code || 0 });
        });

        python.on('error', (error) => {
            reject(new Error(`Failed to execute Python script: ${error.message}`));
        });
    });
}

/**
 * Load NIP configuration from noodle.json
 */
function loadNipConfig(): any {
    const configPath = path.join(process.cwd(), 'noodle.json');
    
    if (!fs.existsSync(configPath)) {
        return {
            rootDir: DEFAULT_ROOT_DIR,
            snapshotDir: path.join(DEFAULT_ROOT_DIR, 'snapshots'),
            allowedCommands: ['make test', 'make lint', 'make bench:parser'],
            networkEnabled: false,
            maxLocChangedDefault: 200
        };
    }

    try {
        const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
        return config.improve || {
            rootDir: DEFAULT_ROOT_DIR,
            snapshotDir: path.join(DEFAULT_ROOT_DIR, 'snapshots'),
            allowedCommands: ['make test', 'make lint', 'make bench:parser'],
            networkEnabled: false,
            maxLocChangedDefault: 200
        };
    } catch (error) {
        console.warn(chalk.yellow('Warning: Failed to parse noodle.json, using defaults'));
        return {
            rootDir: DEFAULT_ROOT_DIR,
            snapshotDir: path.join(DEFAULT_ROOT_DIR, 'snapshots'),
            allowedCommands: ['make test', 'make lint', 'make bench:parser'],
            networkEnabled: false,
            maxLocChangedDefault: 200
        };
    }
}

/**
 * Get task store path
 */
function getTaskStorePath(): string {
    const config = loadNipConfig();
    return path.join(process.cwd(), config.rootDir, 'tasks');
}

/**
 * Get candidate store path
 */
function getCandidateStorePath(): string {
    const config = loadNipConfig();
    return path.join(process.cwd(), config.rootDir, 'candidates');
}

/**
 * Create improve command group
 */
export function createImproveCommand(): Command {
    const improve = new Command('improve')
        .description('Noodle Improvement Pipeline (NIP) - Manage self-improvement tasks');

    // Task create command
    improve
        .command('task create')
        .description('Create a new improvement task')
        .option('-f, --file <path>', 'Path to task specification JSON file')
        .option('--title <title>', 'Task title')
        .option('--goal <goal>', 'Task goal description')
        .option('--risk <level>', 'Risk level: low, medium, high', 'medium')
        .action(async (options) => {
            try {
                let taskSpec: any;

                if (options.file) {
                    // Load from file
                    const filePath = path.resolve(options.file);
                    if (!fs.existsSync(filePath)) {
                        console.error(chalk.red(`Error: Task file not found: ${filePath}`));
                        process.exit(1);
                    }

                    const content = fs.readFileSync(filePath, 'utf-8');
                    taskSpec = JSON.parse(content);

                    // Override with command-line options if provided
                    if (options.title) taskSpec.title = options.title;
                    if (options.goal) taskSpec.goal = options.goal;
                    if (options.risk) taskSpec.risk = options.risk;
                } else {
                    // Create from command-line options
                    if (!options.title || !options.goal) {
                        console.error(chalk.red('Error: --title and --goal are required when not using --file'));
                        process.exit(1);
                    }

                    taskSpec = {
                        id: `task-${Date.now()}`,
                        title: options.title,
                        goal: {
                            type: 'improvement',
                            description: options.goal
                        },
                        scope: {
                            repo_paths: ['.']
                        },
                        constraints: {
                            max_loc_changed: 200
                        },
                        verification: {
                            commands: ['make test'],
                            required_green: true
                        },
                        risk: options.risk,
                        mode: 'shadow',
                        created_at: new Date().toISOString()
                    };
                }

                // Validate task spec
                if (!taskSpec.title || !taskSpec.goal) {
                    console.error(chalk.red('Error: Task specification must include title and goal'));
                    process.exit(1);
                }

                // Ensure task has an ID
                if (!taskSpec.id) {
                    taskSpec.id = `task-${Date.now()}`;
                }

                // Save task to store
                const taskStorePath = getTaskStorePath();
                if (!fs.existsSync(taskStorePath)) {
                    fs.mkdirSync(taskStorePath, { recursive: true });
                }

                const taskFilePath = path.join(taskStorePath, `${taskSpec.id}.json`);
                fs.writeFileSync(taskFilePath, JSON.stringify(taskSpec, null, 2));

                console.log(chalk.green('✓ Task created successfully'));
                console.log(chalk.gray('  Task ID:'), chalk.cyan(taskSpec.id));
                console.log(chalk.gray('  Title:'), taskSpec.title);
                console.log(chalk.gray('  File:'), taskFilePath);

            } catch (error: any) {
                console.error(chalk.red('Error creating task:'), error.message);
                process.exit(1);
            }
        });

    // Task list command
    improve
        .command('task list')
        .description('List all improvement tasks')
        .option('--status <status>', 'Filter by status (queued, running, completed, failed)')
        .action(async (options) => {
            try {
                const taskStorePath = getTaskStorePath();

                if (!fs.existsSync(taskStorePath)) {
                    console.log(chalk.yellow('No tasks found. Create your first task with: noodle improve task create'));
                    return;
                }

                const files = fs.readdirSync(taskStorePath).filter(f => f.endsWith('.json'));

                if (files.length === 0) {
                    console.log(chalk.yellow('No tasks found. Create your first task with: noodle improve task create'));
                    return;
                }

                console.log(chalk.bold('\nImprovement Tasks:\n'));

                for (const file of files) {
                    const filePath = path.join(taskStorePath, file);
                    const task = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

                    // Filter by status if specified
                    if (options.status && task.status !== options.status) {
                        continue;
                    }

                    // Status indicator
                    let statusIcon = '○';
                    let statusColor = 'gray';
                    if (task.status === 'completed') {
                        statusIcon = '✓';
                        statusColor = 'green';
                    } else if (task.status === 'running') {
                        statusIcon = '●';
                        statusColor = 'yellow';
                    } else if (task.status === 'failed') {
                        statusIcon = '✗';
                        statusColor = 'red';
                    }

                    console.log(chalk[statusColor](statusIcon) + ' ' + chalk.cyan(task.id));
                    console.log(chalk.gray('  Title:'), task.title);
                    console.log(chalk.gray('  Status:'), task.status || 'queued');
                    if (task.created_at) {
                        console.log(chalk.gray('  Created:'), new Date(task.created_at).toLocaleString());
                    }
                    if (task.outcome) {
                        console.log(chalk.gray('  Outcome:'), task.outcome);
                    }
                    console.log();
                }

            } catch (error: any) {
                console.error(chalk.red('Error listing tasks:'), error.message);
                process.exit(1);
            }
        });

    // Run command
    improve
        .command('run')
        .description('Run an improvement task')
        .requiredOption('-t, --task <id>', 'Task ID to run')
        .option('--dry-run', 'Show what would be done without executing')
        .action(async (options) => {
            try {
                const taskStorePath = getTaskStorePath();
                const taskFilePath = path.join(taskStorePath, `${options.task}.json`);

                if (!fs.existsSync(taskFilePath)) {
                    console.error(chalk.red(`Error: Task not found: ${options.task}`));
                    process.exit(1);
                }

                const task = JSON.parse(fs.readFileSync(taskFilePath, 'utf-8'));

                console.log(chalk.bold('\nRunning Task:'), chalk.cyan(task.title));
                console.log(chalk.gray('Task ID:'), task.id);
                console.log(chalk.gray('Goal:'), task.goal.description || task.goal.type);
                console.log();

                if (options.dryRun) {
                    console.log(chalk.yellow('Dry run mode - no changes will be made'));
                    console.log(chalk.gray('Would execute verification commands:'));
                    task.verification.commands.forEach((cmd: string) => {
                        console.log(chalk.gray('  -'), cmd);
                    });
                    return;
                }

                // Create snapshot
                console.log(chalk.blue('Creating workspace snapshot...'));
                const snapshotId = `snapshot-${Date.now()}`;
                console.log(chalk.gray('  Snapshot ID:'), snapshotId);

                // Create candidate
                console.log(chalk.blue('Creating candidate...'));
                const candidateId = `candidate-${Date.now()}`;
                const candidate = {
                    id: candidateId,
                    task_id: task.id,
                    base_snapshot_id: snapshotId,
                    patch: task.patch || null,
                    metadata: {
                        created_at: new Date().toISOString(),
                        agent: 'cli'
                    },
                    status: 'CREATED'
                };

                const candidateStorePath = getCandidateStorePath();
                if (!fs.existsSync(candidateStorePath)) {
                    fs.mkdirSync(candidateStorePath, { recursive: true });
                }

                const candidateFilePath = path.join(candidateStorePath, `${candidateId}.json`);
                fs.writeFileSync(candidateFilePath, JSON.stringify(candidate, null, 2));

                // Apply patch if provided
                if (task.patchFile) {
                    console.log(chalk.blue('Applying patch...'));
                    // TODO: Implement patch application via Python core
                }

                // Run verification commands
                console.log(chalk.blue('Running verification commands...\n'));
                const evidence = {
                    candidate_id: candidateId,
                    commands: [],
                    timestamp: new Date().toISOString()
                };

                for (const cmd of task.verification.commands) {
                    console.log(chalk.gray('$'), cmd);
                    // TODO: Execute command via sandbox runner
                    evidence.commands.push({
                        command: cmd,
                        exit_code: 0,
                        stdout: 'Not yet implemented',
                        stderr: '',
                        duration_ms: 0
                    });
                }

                // Save evidence
                const evidenceDir = path.join(process.cwd(), loadNipConfig().rootDir, 'evidence', candidateId);
                if (!fs.existsSync(evidenceDir)) {
                    fs.mkdirSync(evidenceDir, { recursive: true });
                }
                fs.writeFileSync(path.join(evidenceDir, 'evidence.json'), JSON.stringify(evidence, null, 2));

                // Update candidate status
                candidate.status = 'VERIFIED';
                fs.writeFileSync(candidateFilePath, JSON.stringify(candidate, null, 2));

                // Update task status
                task.status = 'completed';
                task.outcome = 'ACCEPTED';
                task.updated_at = new Date().toISOString();
                fs.writeFileSync(taskFilePath, JSON.stringify(task, null, 2));

                console.log();
                console.log(chalk.green('✓ Task completed successfully'));
                console.log(chalk.gray('  Candidate ID:'), candidateId);
                console.log(chalk.gray('  Evidence:'), evidenceDir);

            } catch (error: any) {
                console.error(chalk.red('Error running task:'), error.message);
                process.exit(1);
            }
        });

    // Candidate list command
    improve
        .command('candidate list')
        .description('List candidates for a task')
        .requiredOption('-t, --task <id>', 'Task ID')
        .action(async (options) => {
            try {
                const candidateStorePath = getCandidateStorePath();

                if (!fs.existsSync(candidateStorePath)) {
                    console.log(chalk.yellow('No candidates found'));
                    return;
                }

                const files = fs.readdirSync(candidateStorePath).filter(f => f.endsWith('.json'));
                const taskCandidates = [];

                for (const file of files) {
                    const filePath = path.join(candidateStorePath, file);
                    const candidate = JSON.parse(fs.readFileSync(filePath, 'utf-8'));

                    if (candidate.task_id === options.task) {
                        taskCandidates.push(candidate);
                    }
                }

                if (taskCandidates.length === 0) {
                    console.log(chalk.yellow(`No candidates found for task: ${options.task}`));
                    return;
                }

                console.log(chalk.bold(`\nCandidates for Task ${options.task}:\n`));

                for (const candidate of taskCandidates) {
                    console.log(chalk.cyan(candidate.id));
                    console.log(chalk.gray('  Status:'), candidate.status);
                    console.log(chalk.gray('  Created:'), new Date(candidate.metadata?.created_at).toLocaleString());
                    console.log();
                }

            } catch (error: any) {
                console.error(chalk.red('Error listing candidates:'), error.message);
                process.exit(1);
            }
        });

    // Candidate show command
    improve
        .command('candidate show')
        .description('Show detailed candidate information')
        .requiredOption('-i, --id <candidateId>', 'Candidate ID')
        .action(async (options) => {
            try {
                const candidateFilePath = path.join(getCandidateStorePath(), `${options.id}.json`);

                if (!fs.existsSync(candidateFilePath)) {
                    console.error(chalk.red(`Error: Candidate not found: ${options.id}`));
                    process.exit(1);
                }

                const candidate = JSON.parse(fs.readFileSync(candidateFilePath, 'utf-8'));

                console.log(chalk.bold('\nCandidate Details:\n'));
                console.log(chalk.gray('ID:'), candidate.id);
                console.log(chalk.gray('Task ID:'), candidate.task_id);
                console.log(chalk.gray('Status:'), candidate.status);
                console.log(chalk.gray('Created:'), new Date(candidate.metadata?.created_at).toLocaleString());
                console.log();

                if (candidate.patch) {
                    console.log(chalk.bold('Patch:'));
                    console.log(candidate.patch);
                    console.log();
                }

                if (candidate.metadata?.rationale) {
                    console.log(chalk.bold('Rationale:'));
                    console.log(candidate.metadata.rationale);
                    console.log();
                }

            } catch (error: any) {
                console.error(chalk.red('Error showing candidate:'), error.message);
                process.exit(1);
            }
        });

    // Candidate evidence command
    improve
        .command('candidate evidence')
        .description('Show evidence for a candidate')
        .requiredOption('-i, --id <candidateId>', 'Candidate ID')
        .action(async (options) => {
            try {
                const evidenceDir = path.join(process.cwd(), loadNipConfig().rootDir, 'evidence', options.id);
                const evidenceFilePath = path.join(evidenceDir, 'evidence.json');

                if (!fs.existsSync(evidenceFilePath)) {
                    console.error(chalk.red(`Error: Evidence not found for candidate: ${options.id}`));
                    process.exit(1);
                }

                const evidence = JSON.parse(fs.readFileSync(evidenceFilePath, 'utf-8'));

                console.log(chalk.bold(`\nEvidence for ${options.id}:\n`));
                console.log(chalk.gray('Timestamp:'), new Date(evidence.timestamp).toLocaleString());
                console.log();

                console.log(chalk.bold('Command Results:'));
                for (const cmd of evidence.commands) {
                    const icon = cmd.exit_code === 0 ? chalk.green('✓') : chalk.red('✗');
                    console.log(icon + ' ' + chalk.cyan(cmd.command));
                    if (cmd.exit_code !== 0) {
                        console.log(chalk.gray('  Exit code:'), cmd.exit_code);
                    }
                    if (cmd.duration_ms) {
                        console.log(chalk.gray('  Duration:'), `${cmd.duration_ms}ms`);
                    }
                    console.log();
                }

            } catch (error: any) {
                console.error(chalk.red('Error showing evidence:'), error.message);
                process.exit(1);
            }
        });

    // Candidate promote command
    improve
        .command('candidate promote')
        .description('Promote a verified candidate (manual promotion)')
        .requiredOption('-i, --id <candidateId>', 'Candidate ID')
        .option('--reason <reason>', 'Reason for promotion')
        .action(async (options) => {
            try {
                const candidateFilePath = path.join(getCandidateStorePath(), `${options.id}.json`);

                if (!fs.existsSync(candidateFilePath)) {
                    console.error(chalk.red(`Error: Candidate not found: ${options.id}`));
                    process.exit(1);
                }

                const candidate = JSON.parse(fs.readFileSync(candidateFilePath, 'utf-8'));

                if (candidate.status !== 'VERIFIED') {
                    console.error(chalk.red('Error: Candidate must be VERIFIED before promotion'));
                    console.error(chalk.gray('Current status:'), candidate.status);
                    process.exit(1);
                }

                // Create promotion record
                const promotion = {
                    candidate_id: options.id,
                    decision: 'accepted',
                    reason_codes: [options.reason || 'manual_promotion'],
                    timestamp: new Date().toISOString(),
                    promoted_by: 'cli'
                };

                const promotionDir = path.join(process.cwd(), loadNipConfig().rootDir, 'promotions');
                if (!fs.existsSync(promotionDir)) {
                    fs.mkdirSync(promotionDir, { recursive: true });
                }

                const promotionFilePath = path.join(promotionDir, `${options.id}.json`);
                fs.writeFileSync(promotionFilePath, JSON.stringify(promotion, null, 2));

                console.log(chalk.green('✓ Candidate promoted successfully'));
                console.log(chalk.gray('  Candidate ID:'), options.id);
                console.log(chalk.gray('  Promotion record:'), promotionFilePath);
                console.log(chalk.yellow('\nNote: v1 only logs promotion. No automatic deployment is performed.'));

            } catch (error: any) {
                console.error(chalk.red('Error promoting candidate:'), error.message);
                process.exit(1);
            }
        });

    // Config show command
    improve
        .command('config show')
        .description('Show current NIP configuration')
        .action(async () => {
            try {
                const config = loadNipConfig();

                console.log(chalk.bold('\nNoodle Improvement Pipeline Configuration:\n'));
                console.log(chalk.gray('Root Directory:'), config.rootDir);
                console.log(chalk.gray('Snapshot Directory:'), config.snapshotDir);
                console.log(chalk.gray('Network Enabled:'), config.networkEnabled ? 'Yes' : 'No');
                console.log(chalk.gray('Max LOC Changed (default):'), config.maxLocChangedDefault);
                console.log();

                console.log(chalk.bold('Allowed Commands:'));
                config.allowedCommands.forEach((cmd: string) => {
                    console.log(chalk.gray('  -'), cmd);
                });
                console.log();

                const taskStorePath = getTaskStorePath();
                if (fs.existsSync(taskStorePath)) {
                    const taskCount = fs.readdirSync(taskStorePath).filter(f => f.endsWith('.json')).length;
                    console.log(chalk.gray('Total Tasks:'), taskCount);
                }

                const candidateStorePath = getCandidateStorePath();
                if (fs.existsSync(candidateStorePath)) {
                    const candidateCount = fs.readdirSync(candidateStorePath).filter(f => f.endsWith('.json')).length;
                    console.log(chalk.gray('Total Candidates:'), candidateCount);
                }

                console.log();

            } catch (error: any) {
                console.error(chalk.red('Error showing config:'), error.message);
                process.exit(1);
            }
        });

    return improve;
}
