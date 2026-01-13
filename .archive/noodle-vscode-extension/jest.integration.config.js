module.exports = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    roots: ['<rootDir>/test/integration'],
    testMatch: ['**/*.integration.ts', '**/*.test.ts'],
    transform: {
        '^.+\\.ts$': 'ts-jest',
    },
    collectCoverageFrom: [
        'src/**/*.ts',
        '!src/**/*.d.ts',
        '!src/**/*.test.ts',
        '!src/**/*.spec.ts',
    ],
    coverageDirectory: 'coverage/integration',
    coverageReporters: ['text', 'lcov', 'html'],
    setupFilesAfterEnv: ['<rootDir>/test/integration/setup.ts'],
    moduleNameMapping: {
        '^@/(.*)$': '<rootDir>/src/$1',
    },
    testTimeout: 30000,
    verbose: true,
    forceExit: true,
    clearMocks: true,
    resetMocks: true,
    restoreMocks: true,
    maxWorkers: 1, // Run integration tests sequentially to avoid port conflicts
};