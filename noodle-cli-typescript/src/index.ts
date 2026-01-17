#!/usr/bin/env node

import chalk from 'chalk';
import { Command } from 'commander';

// Import improve commands
import { createImproveCommand } from './improve';

// Initialize CLI program
const program = new Command();

// Set program metadata
program
    .name('noodle')
    .description('A comprehensive CLI tool for development workflows')
    .version('1.0.0');

// Add NIP improve command group
program.addCommand(createImproveCommand());

// Core Commands
program
    .command('run <file>')
    .description('Run a file or script')
    .option('-w, --watch', 'Watch for changes')
    .option('-v, --verbose', 'Verbose output')
    .action(async (file, options) => {
        try {
            console.log(chalk.green(`Running ${file}...`));
            console.log(chalk.blue('Options:'), options);
            console.log(chalk.yellow('Note: This is a simplified implementation for testing'));
        } catch (error: any) {
            console.error(chalk.red(`Error running ${file}:`, error.message));
            process.exit(1);
        }
    });

program
    .command('build [target]')
    .description('Build the project')
    .option('-p, --production', 'Production build')
    .option('-m, --minify', 'Minify output')
    .option('-c, --config <file>', 'Use custom config')
    .action(async (target, options) => {
        try {
            console.log(chalk.green(`Building ${target || 'project'}...`));
            console.log(chalk.blue('Options:'), options);
            console.log(chalk.yellow('Note: This is a simplified implementation for testing'));
        } catch (error: any) {
            console.error(chalk.red('Build failed:', error.message));
            process.exit(1);
        }
    });

// Handle run with code command
program
    .command('run-code <code>')
    .description('Run noodle code directly')
    .action(async (code, options) => {
        try {
            console.log(chalk.green('Running Noodle code...'));
            console.log(chalk.blue('Code:'), code);
            console.log(chalk.yellow('Note: This is a simplified implementation for testing'));
        } catch (error: any) {
            console.error(chalk.red('Code execution failed:', error.message));
            process.exit(1);
        }
    });

// Parse command line arguments
program.parse();
