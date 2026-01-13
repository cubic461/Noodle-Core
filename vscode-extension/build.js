#!/usr/bin/env node

/**
 * Build script for Noodle VSCode Extension
 * 
 * This script handles:
 * - TypeScript compilation
 * - Copying necessary resource files
 * - Validating the build output
 * - Providing clear error reporting
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const PROJECT_ROOT = __dirname;
const SRC_DIR = path.join(PROJECT_ROOT, 'src');
const OUT_DIR = path.join(PROJECT_ROOT, 'out');
const RESOURCES_DIR = path.join(PROJECT_ROOT, 'resources');
const SYNTAXES_DIR = path.join(PROJECT_ROOT, 'syntaxes');
const THEMES_DIR = path.join(PROJECT_ROOT, 'themes');
const SNIPPETS_DIR = path.join(PROJECT_ROOT, 'snippets');
const LANGUAGE_CONFIG = path.join(PROJECT_ROOT, 'language-configuration.json');

// Resource files to copy to output directory
const RESOURCE_FILES = [
    { src: RESOURCES_DIR, dest: path.join(OUT_DIR, 'resources') },
    { src: SYNTAXES_DIR, dest: path.join(OUT_DIR, 'syntaxes') },
    { src: THEMES_DIR, dest: path.join(OUT_DIR, 'themes') },
    { src: SNIPPETS_DIR, dest: path.join(OUT_DIR, 'snippets') },
    { src: LANGUAGE_CONFIG, dest: path.join(OUT_DIR, 'language-configuration.json') },
    { src: path.join(PROJECT_ROOT, 'package.json'), dest: path.join(OUT_DIR, 'package.json') },
    { src: path.join(PROJECT_ROOT, 'README.md'), dest: path.join(OUT_DIR, 'README.md') }
];

// ANSI color codes for console output
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m'
};

/**
 * Log a message with color
 */
function log(message, color = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

/**
 * Log an error message
 */
function logError(message) {
    log(`❌ Error: ${message}`, 'red');
}

/**
 * Log a success message
 */
function logSuccess(message) {
    log(`✅ ${message}`, 'green');
}

/**
 * Log an info message
 */
function logInfo(message) {
    log(`ℹ️  ${message}`, 'blue');
}

/**
 * Log a warning message
 */
function logWarning(message) {
    log(`⚠️  ${message}`, 'yellow');
}

/**
 * Execute a command and handle errors
 */
function execCommand(command, description) {
    try {
        logInfo(`${description}...`);
        execSync(command, { stdio: 'inherit', cwd: PROJECT_ROOT });
        logSuccess(`${description} completed`);
        return true;
    } catch (error) {
        logError(`${description} failed`);
        logError(error.message);
        return false;
    }
}

/**
 * Create directory if it doesn't exist
 */
function ensureDir(dirPath) {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
}

/**
 * Copy a file or directory recursively
 */
function copyRecursive(src, dest) {
    if (!fs.existsSync(src)) {
        logWarning(`Source path does not exist: ${src}`);
        return false;
    }

    ensureDir(path.dirname(dest));

    const stat = fs.statSync(src);
    if (stat.isDirectory()) {
        if (!fs.existsSync(dest)) {
            fs.mkdirSync(dest, { recursive: true });
        }
        
        const files = fs.readdirSync(src);
        for (const file of files) {
            copyRecursive(path.join(src, file), path.join(dest, file));
        }
    } else {
        fs.copyFileSync(src, dest);
    }
    return true;
}

/**
 * Validate that the build output is correct
 */
function validateBuild() {
    logInfo('Validating build output...');
    
    // Check that main entry point exists
    const mainFile = path.join(OUT_DIR, 'extension.js');
    if (!fs.existsSync(mainFile)) {
        logError(`Main entry point not found: ${mainFile}`);
        return false;
    }
    
    // Check that package.json exists in output
    const packageJson = path.join(OUT_DIR, 'package.json');
    if (!fs.existsSync(packageJson)) {
        logError(`package.json not found in output: ${packageJson}`);
        return false;
    }
    
    // Check that resource directories exist
    const requiredDirs = ['resources', 'syntaxes', 'themes'];
    for (const dir of requiredDirs) {
        const dirPath = path.join(OUT_DIR, dir);
        if (!fs.existsSync(dirPath)) {
            logError(`Required directory not found: ${dirPath}`);
            return false;
        }
    }
    
    logSuccess('Build validation passed');
    return true;
}

/**
 * Clean the output directory
 */
function cleanOutput() {
    logInfo('Cleaning output directory...');
    if (fs.existsSync(OUT_DIR)) {
        fs.rmSync(OUT_DIR, { recursive: true, force: true });
    }
    ensureDir(OUT_DIR);
    logSuccess('Output directory cleaned');
}

/**
 * Copy resource files to output directory
 */
function copyResources() {
    logInfo('Copying resource files...');
    for (const resource of RESOURCE_FILES) {
        if (!copyRecursive(resource.src, resource.dest)) {
            logError(`Failed to copy resource: ${resource.src}`);
            return false;
        }
    }
    logSuccess('Resource files copied');
    return true;
}

/**
 * Main build function
 */
function build(mode = 'production') {
    log('🍜 Building Noodle VSCode Extension', 'bright');
    log(`Build mode: ${mode}`, 'cyan');
    
    // Clean output directory
    cleanOutput();
    
    // Run TypeScript compilation via webpack
    const webpackMode = mode === 'development' ? 'development' : 'production';
    if (!execCommand(`npx webpack --mode ${webpackMode}`, 'TypeScript compilation')) {
        return false;
    }
    
    // Copy resource files
    if (!copyResources()) {
        return false;
    }
    
    // Validate build
    if (!validateBuild()) {
        return false;
    }
    
    logSuccess('Build completed successfully!');
    return true;
}

/**
 * Parse command line arguments
 */
function parseArgs() {
    const args = process.argv.slice(2);
    const options = {
        mode: 'production',
        watch: false,
        clean: false
    };
    
    for (const arg of args) {
        switch (arg) {
            case '--development':
            case '--dev':
                options.mode = 'development';
                break;
            case '--production':
            case '--prod':
                options.mode = 'production';
                break;
            case '--watch':
            case '-w':
                options.watch = true;
                break;
            case '--clean':
            case '-c':
                options.clean = true;
                break;
            case '--help':
            case '-h':
                console.log(`
Usage: node build.js [options]

Options:
  --development, --dev   Build in development mode
  --production, --prod   Build in production mode (default)
  --watch, -w            Watch for changes and rebuild
  --clean, -c            Clean output directory before building
  --help, -h             Show this help message
                `);
                process.exit(0);
        }
    }
    
    return options;
}

/**
 * Main execution
 */
function main() {
    const options = parseArgs();
    
    if (options.clean) {
        cleanOutput();
        if (options.watch) {
            logInfo('Starting webpack in watch mode...');
            execCommand(`npx webpack --mode ${options.mode} --watch`, 'Webpack watch');
        }
        return;
    }
    
    if (options.watch) {
        logInfo('Starting webpack in watch mode...');
        execCommand(`npx webpack --mode ${options.mode} --watch`, 'Webpack watch');
        return;
    }
    
    const success = build(options.mode);
    process.exit(success ? 0 : 1);
}

// Run the build if this file is executed directly
if (require.main === module) {
    main();
}

module.exports = { build, cleanOutput, copyResources, validateBuild };