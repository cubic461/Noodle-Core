//@ts-check
'use strict';

const path = require('path');

/**@type {import('webpack').Configuration}*/
const config = {
    target: 'node', // vscode extensions run in a Node.js-context 📖 -> https://webpack.js.org/configuration/node/
    mode: 'none', // this leaves the source code as close as possible to the original (when packaging we set this to 'production')

    entry: './src/extension.ts', // the entry point of this extension, 📖 -> https://webpack.js.org/configuration/entry-context/
    output: {
        // the bundle is stored in the 'out' folder (check package.json), 📖 -> https://webpack.js.org/configuration/output/
        path: path.resolve(__dirname, 'out'),
        filename: 'extension.js',
        chunkFilename: '[name].js',
        libraryTarget: 'commonjs2',
        devtoolModuleFilenameTemplate: '../[resource-path]'
    },
    externals: {
        vscode: 'commonjs vscode', // the vscode-module is created on-the-fly and must be excluded. Add other modules that cannot be webpack'ed, 📖 -> https://webpack.js.org/configuration/externals/
        // Add other external dependencies that should not be bundled
        'axios': 'commonjs axios',
        'uuid': 'commonjs uuid',
        'semver': 'commonjs semver',
        'monaco-editor': 'commonjs monaco-editor'
    },
    resolve: {
        // support reading TypeScript and JavaScript in 📖 -> https://github.com/TypeStrong/ts-loader
        extensions: ['.ts', '.js']
    },
    module: {
        rules: [
            {
                test: /\.ts$/,
                exclude: /node_modules/,
                use: [
                    {
                        loader: 'ts-loader',
                        options: {
                            // Use the project's tsconfig.json
                            configFile: 'tsconfig.json',
                            // Ensure transpileOnly is set for faster builds
                            transpileOnly: true
                        }
                    }
                ]
            },
            // Handle CSS files for any UI components
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
            },
            // Handle JSON files
            {
                test: /\.json$/,
                type: 'json'
            },
            // Handle SVG and other image files
            {
                test: /\.(svg|png|jpg|jpeg|gif)$/,
                type: 'asset/resource'
            }
        ]
    },
    // Source map configuration for debugging
    devtool: process.env.NODE_ENV === 'production' ? 'source-map' : 'nosources-source-map',
    // Optimization settings
    optimization: {
        minimize: false, // Don't minimize for better debugging
        // Disable code splitting to avoid chunk naming conflicts
        splitChunks: false
    },
    // Performance hints
    performance: {
        hints: false, // Disable performance hints for now
        maxEntrypointSize: 512000,
        maxAssetSize: 512000
    },
    // Node.js configuration for webpack
    node: {
        __dirname: false,
        __filename: false
    },
    // Stats configuration for better build output
    stats: {
        colors: true,
        modules: false,
        children: false,
        chunks: false,
        chunkModules: false
    }
};

// Export a function to allow environment-specific configuration
/** @param {any} env @param {any} argv */
module.exports = (env, argv) => {
    // Set mode based on webpack's mode argument
    config.mode = argv.mode || 'none';

    // Adjust source maps based on mode
    if (config.mode === 'production') {
        config.devtool = 'source-map';
        // Enable minimization in production
        if (config.optimization) {
            config.optimization.minimize = true;
        }
    } else {
        config.devtool = 'nosources-source-map';
        if (config.optimization) {
            config.optimization.minimize = false;
        }
    }

    return config;
};