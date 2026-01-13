"use strict";
/**
 * NoodleCore Testing Framework
 *
 * Comprehensive testing framework with unit, integration,
 * and E2E testing capabilities.
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
exports.PerformanceTestRunner = exports.E2ETestRunner = exports.IntegrationTestRunner = exports.UnitTestRunner = exports.BaseTestRunner = exports.TestingFramework = exports.TestStatus = exports.TestType = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
var TestType;
(function (TestType) {
    TestType["Unit"] = "unit";
    TestType["Integration"] = "integration";
    TestType["E2E"] = "e2e";
    TestType["Performance"] = "performance";
    TestType["Load"] = "load";
})(TestType = exports.TestType || (exports.TestType = {}));
var TestStatus;
(function (TestStatus) {
    TestStatus["Pending"] = "pending";
    TestStatus["Running"] = "running";
    TestStatus["Passed"] = "passed";
    TestStatus["Failed"] = "failed";
    TestStatus["Skipped"] = "skipped";
    TestStatus["Timeout"] = "timeout";
})(TestStatus = exports.TestStatus || (exports.TestStatus = {}));
class TestingFramework extends events_1.EventEmitter {
    constructor(config = {}) {
        super();
        this.testSuites = new Map();
        this.testResults = [];
        this.runners = new Map();
        this.currentSuite = null;
        this.outputChannel = vscode.window.createOutputChannel('NoodleCore Test Framework');
        this.config = this.initializeConfig(config);
        this.setupTestRunners();
    }
    /**
     * Register a test suite
     */
    registerSuite(suite) {
        this.testSuites.set(suite.id, suite);
        this.emit('suiteRegistered', suite);
    }
    /**
     * Get a test suite by ID
     */
    getSuite(suiteId) {
        return this.testSuites.get(suiteId);
    }
    /**
     * Get all test suites
     */
    getSuites() {
        return Array.from(this.testSuites.values());
    }
    /**
     * Run a specific test suite
     */
    async runSuite(suiteId) {
        const suite = this.testSuites.get(suiteId);
        if (!suite) {
            throw new Error(`Test suite ${suiteId} not found`);
        }
        this.currentSuite = suite;
        this.emit('suiteStarted', suite);
        this.outputChannel.appendLine(`Running test suite: ${suite.name}`);
        try {
            // Run setup
            if (suite.setup) {
                await suite.setup();
            }
            // Run tests
            const results = [];
            if (suite.parallel) {
                // Run tests in parallel
                const testPromises = suite.tests.map(test => this.runTest(test));
                const testResults = await Promise.allSettled(testPromises);
                for (const result of testResults) {
                    if (result.status === 'fulfilled') {
                        results.push(result.value);
                    }
                    else {
                        results.push(this.createErrorResult(test, result.reason));
                    }
                }
            }
            else {
                // Run tests sequentially
                for (const test of suite.tests) {
                    results.push(await this.runTest(test));
                }
            }
            // Run teardown
            if (suite.teardown) {
                await suite.teardown();
            }
            this.currentSuite = null;
            this.emit('suiteCompleted', { suite, results });
            this.outputChannel.appendLine(`Test suite completed: ${suite.name}`);
            return results;
        }
        catch (error) {
            this.currentSuite = null;
            const errorResult = this.createErrorResult({ id: 'suite-error', name: suite.name, type: TestType.Unit, tests: [] }, error instanceof Error ? error.message : String(error));
            this.emit('suiteError', { suite, error: errorResult });
            return [errorResult];
        }
    }
    /**
     * Run all test suites
     */
    async runAllSuites() {
        const results = {};
        for (const [suiteId, suite] of this.testSuites.entries()) {
            results[suiteId] = await this.runSuite(suiteId);
        }
        this.emit('allSuitesCompleted', results);
        return results;
    }
    /**
     * Run a single test
     */
    async runTest(test) {
        const startTime = Date.now();
        const result = {
            ...test,
            startTime: new Date(startTime).toISOString(),
            status: TestStatus.Running
        };
        this.emit('testStarted', result);
        this.outputChannel.appendLine(`Running test: ${test.name}`);
        try {
            // Set timeout
            const timeout = setTimeout(() => {
                result.status = TestStatus.Timeout;
                result.endTime = new Date().toISOString();
                result.duration = Date.now() - startTime;
                result.error = `Test timed out after ${this.config.timeout}ms`;
                this.emit('testCompleted', result);
                this.outputChannel.appendLine(`Test timed out: ${test.name}`);
            }, this.config.timeout);
            // Execute test (this would be implemented by specific test runners)
            await this.executeTest(test);
            // Clear timeout if test completed
            clearTimeout(timeout);
            result.status = TestStatus.Passed;
            result.endTime = new Date().toISOString();
            result.duration = Date.now() - startTime;
            this.emit('testCompleted', result);
            this.outputChannel.appendLine(`Test passed: ${test.name}`);
        }
        catch (error) {
            clearTimeout(timeout);
            result.status = TestStatus.Failed;
            result.endTime = new Date().toISOString();
            result.duration = Date.now() - startTime;
            result.error = error instanceof Error ? error.message : String(error);
            result.stack = error instanceof Error ? error.stack : undefined;
            this.emit('testCompleted', result);
            this.outputChannel.appendLine(`Test failed: ${test.name} - ${result.error}`);
        }
        return result;
    }
    /**
     * Get test results
     */
    getResults(filter) {
        let results = [...this.testResults];
        if (filter) {
            if (filter.suiteId) {
                const suite = this.testSuites.get(filter.suiteId);
                if (suite) {
                    results = results.filter(result => suite.tests.some(test => test.id === result.id));
                }
            }
            if (filter.type) {
                results = results.filter(result => result.type === filter.type);
            }
            if (filter.status) {
                results = results.filter(result => result.status === filter.status);
            }
            if (filter.since) {
                const since = new Date(filter.since);
                results = results.filter(result => new Date(result.startTime) >= since);
            }
        }
        return results;
    }
    /**
     * Get test statistics
     */
    getStatistics() {
        const stats = {
            total: this.testResults.length,
            byType: {
                [TestType.Unit]: 0,
                [TestType.Integration]: 0,
                [TestType.E2E]: 0,
                [TestType.Performance]: 0,
                [TestType.Load]: 0
            },
            byStatus: {
                [TestStatus.Pending]: 0,
                [TestStatus.Running]: 0,
                [TestStatus.Passed]: 0,
                [TestStatus.Failed]: 0,
                [TestStatus.Skipped]: 0,
                [TestStatus.Timeout]: 0
            },
            averageDuration: 0,
            passRate: 0
        };
        // Calculate statistics
        let totalDuration = 0;
        let passedCount = 0;
        for (const result of this.testResults) {
            stats.byType[result.type]++;
            stats.byStatus[result.status]++;
            if (result.status === TestStatus.Passed) {
                passedCount++;
            }
            totalDuration += result.duration;
        }
        if (this.testResults.length > 0) {
            stats.averageDuration = totalDuration / this.testResults.length;
            stats.passRate = (passedCount / this.testResults.length) * 100;
        }
        return stats;
    }
    /**
     * Generate test report
     */
    generateReport(format = 'json') {
        const statistics = this.getStatistics();
        const report = {
            generatedAt: new Date().toISOString(),
            framework: {
                name: 'NoodleCore Testing Framework',
                version: '1.0.0'
            },
            statistics,
            suites: Array.from(this.testSuites.values()).map(suite => ({
                id: suite.id,
                name: suite.name,
                description: suite.description,
                tests: suite.tests,
                results: this.testResults.filter(result => suite.tests.some(test => test.id === result.id))
            })),
            results: this.testResults
        };
        switch (format) {
            case 'json':
                return JSON.stringify(report, null, 2);
            case 'junit':
                return this.generateJunitReport(report);
            case 'html':
                return this.generateHtmlReport(report);
            default:
                throw new Error(`Unsupported report format: ${format}`);
        }
    }
    /**
     * Clear test results
     */
    clearResults() {
        this.testResults = [];
        this.emit('resultsCleared');
    }
    /**
     * Register a test runner
     */
    registerRunner(name, runner) {
        this.runners.set(name, runner);
        this.emit('runnerRegistered', { name, runner });
    }
    /**
     * Get a test runner
     */
    getRunner(name) {
        return this.runners.get(name);
    }
    /**
     * Execute test using appropriate runner
     */
    async executeTest(test) {
        // Find appropriate runner based on test type
        const runner = this.findRunner(test.type);
        if (!runner) {
            throw new Error(`No test runner found for type: ${test.type}`);
        }
        return runner.execute(test);
    }
    /**
     * Find appropriate test runner
     */
    findRunner(type) {
        for (const runner of this.runners.values()) {
            if (runner.capabilities.includes(type.toString())) {
                return runner;
            }
        }
        return undefined;
    }
    /**
     * Create error test result
     */
    createErrorResult(test, error) {
        return {
            id: test.id,
            name: test.name,
            type: test.type,
            status: TestStatus.Failed,
            duration: 0,
            startTime: new Date().toISOString(),
            error,
            assertions: [],
            metadata: test.metadata
        };
    }
    /**
     * Initialize configuration
     */
    initializeConfig(config) {
        return {
            timeout: 30000,
            retries: 3,
            parallel: false,
            coverage: true,
            reporting: {
                format: 'json',
                output: './test-results'
            },
            performance: {
                enabled: false,
                profiling: false,
                thresholds: {
                    memory: 80,
                    cpu: 80,
                    latency: 1000
                }
            },
            ...config
        };
    }
    /**
     * Setup test runners
     */
    setupTestRunners() {
        // Register built-in runners
        this.registerRunner('unit', new UnitTestRunner());
        this.registerRunner('integration', new IntegrationTestRunner());
        this.registerRunner('e2e', new E2ETestRunner());
        this.registerRunner('performance', new PerformanceTestRunner());
    }
    /**
     * Generate JUnit XML report
     */
    generateJunitReport(report) {
        // Simplified JUnit XML generation
        let xml = '<?xml version="1.0" encoding="UTF-8"?>\n';
        xml += '<testsuites>\n';
        for (const suite of report.suites) {
            xml += `  <testsuite name="${suite.name}" tests="${suite.tests.length}">\n`;
            for (const result of suite.results) {
                xml += `    <testcase classname="${suite.name}" name="${result.name}" time="${result.duration / 1000}">\n`;
                if (result.status === TestStatus.Failed) {
                    xml += `      <failure message="${result.error || 'Unknown error'}"></failure>\n`;
                }
                else if (result.status === TestStatus.Skipped) {
                    xml += `      <skipped message="${result.error || 'Skipped'}"></skipped>\n`;
                }
                xml += '    </testcase>\n';
            }
            xml += '  </testsuite>\n';
        }
        xml += '</testsuites>';
        return xml;
    }
    /**
     * Generate HTML report
     */
    generateHtmlReport(report) {
        return `
<!DOCTYPE html>
<html>
<head>
    <title>NoodleCore Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .summary { display: flex; gap: 20px; margin-bottom: 20px; }
        .metric { text-align: center; padding: 10px; border: 1px solid #ddd; border-radius: 3px; }
        .metric-value { font-size: 24px; font-weight: bold; color: #2c3e50; }
        .metric-label { font-size: 12px; color: #666; }
        .suite { margin-bottom: 30px; }
        .test-result { padding: 10px; margin: 5px 0; border-radius: 3px; }
        .passed { background: #d4edda; }
        .failed { background: #f8d7da; }
        .skipped { background: #fff3cd; }
        .timeout { background: #ffc107; }
    </style>
</head>
<body>
    <div class="header">
        <h1>NoodleCore Test Report</h1>
        <p>Generated: ${report.generatedAt}</p>
    </div>
    
    <div class="summary">
        <div class="metric">
            <div class="metric-value">${report.statistics.total}</div>
            <div class="metric-label">Total Tests</div>
        </div>
        <div class="metric">
            <div class="metric-value">${report.statistics.passRate.toFixed(1)}%</div>
            <div class="metric-label">Pass Rate</div>
        </div>
        <div class="metric">
            <div class="metric-value">${report.statistics.averageDuration.toFixed(0)}ms</div>
            <div class="metric-label">Avg Duration</div>
        </div>
    </div>
    
    ${report.suites.map(suite => `
    <div class="suite">
        <h2>${suite.name}</h2>
        <p>${suite.description}</p>
        ${suite.results.map(result => `
            <div class="test-result ${result.status}">
                <strong>${result.name}</strong>
                ${result.status === TestStatus.Failed ? `- ${result.error}` : ''}
                <span style="float: right;">${result.duration}ms</span>
            </div>
        `).join('')}
    </div>
    `).join('')}
</body>
</html>`;
    }
    /**
     * Dispose testing framework
     */
    dispose() {
        this.testSuites.clear();
        this.testResults = [];
        this.runners.clear();
        this.currentSuite = null;
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.TestingFramework = TestingFramework;
// Test Runner Base Class
class BaseTestRunner {
}
exports.BaseTestRunner = BaseTestRunner;
// Unit Test Runner
class UnitTestRunner extends BaseTestRunner {
    constructor() {
        super(...arguments);
        this.name = 'Unit Test Runner';
        this.version = '1.0.0';
        this.capabilities = [TestType.Unit];
    }
    async execute(test) {
        // Unit test execution logic would go here
        // This is a placeholder for demonstration
        console.log(`Executing unit test: ${test.name}`);
    }
}
exports.UnitTestRunner = UnitTestRunner;
// Integration Test Runner
class IntegrationTestRunner extends BaseTestRunner {
    constructor() {
        super(...arguments);
        this.name = 'Integration Test Runner';
        this.version = '1.0.0';
        this.capabilities = [TestType.Integration];
    }
    async execute(test) {
        // Integration test execution logic would go here
        console.log(`Executing integration test: ${test.name}`);
    }
}
exports.IntegrationTestRunner = IntegrationTestRunner;
// E2E Test Runner
class E2ETestRunner extends BaseTestRunner {
    constructor() {
        super(...arguments);
        this.name = 'E2E Test Runner';
        this.version = '1.0.0';
        this.capabilities = [TestType.E2E];
    }
    async execute(test) {
        // E2E test execution logic would go here
        console.log(`Executing E2E test: ${test.name}`);
    }
}
exports.E2ETestRunner = E2ETestRunner;
// Performance Test Runner
class PerformanceTestRunner extends BaseTestRunner {
    constructor() {
        super(...arguments);
        this.name = 'Performance Test Runner';
        this.version = '1.0.0';
        this.capabilities = [TestType.Performance];
    }
    async execute(test) {
        // Performance test execution logic would go here
        console.log(`Executing performance test: ${test.name}`);
    }
}
exports.PerformanceTestRunner = PerformanceTestRunner;
//# sourceMappingURL=TestingFramework.js.map