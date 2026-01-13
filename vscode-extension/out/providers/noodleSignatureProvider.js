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
exports.NoodleSignatureProvider = void 0;
const vscode = __importStar(require("vscode"));
/**
 * NoodleCore Signature Help Provider
 *
 * Provides parameter information for function calls and AI operations
 * in NoodleCore files.
 */
class NoodleSignatureProvider {
    /**
     * Provide signature help for the given position
     */
    provideSignatureHelp(document, position, token, context) {
        const line = document.lineAt(position).text;
        const textBefore = line.substring(0, position.character);
        // Check if we're in a function call
        const functionMatch = this.matchFunctionCall(textBefore);
        if (functionMatch) {
            return this.getFunctionSignature(functionMatch);
        }
        // Check if we're in an AI operation
        const aiMatch = this.matchAIOperation(textBefore);
        if (aiMatch) {
            return this.getAIOperationSignature(aiMatch);
        }
        return undefined;
    }
    /**
     * Match function call pattern
     */
    matchFunctionCall(text) {
        // Match pattern: functionName(param1, param2, ...)
        const match = text.match(/(\w+)\s*\(([^)]*)$/);
        if (match) {
            const name = match[1];
            const paramsString = match[2];
            const params = paramsString.split(',').map(p => p.trim()).filter(p => p.length > 0);
            return { name, params };
        }
        return undefined;
    }
    /**
     * Match AI operation pattern
     */
    matchAIOperation(text) {
        // Match AI patterns like: ai.train(...), model.predict(...), agent.learn(...)
        const aiMatch = text.match(/(?:ai|model|agent|pipeline)\.(\w+)\s*\(([^)]*)$/);
        if (aiMatch) {
            const name = aiMatch[1];
            const paramsString = aiMatch[2];
            const params = paramsString.split(',').map(p => p.trim()).filter(p => p.length > 0);
            return { name, params };
        }
        return undefined;
    }
    /**
     * Get function signature
     */
    getFunctionSignature(match) {
        const signatures = this.getFunctionSignatures();
        const signature = signatures.find(sig => sig.label.startsWith(match.name + '('));
        if (signature) {
            const activeParameter = Math.max(0, match.params.length - 1);
            return {
                signatures: [signature],
                activeSignature: 0,
                activeParameter
            };
        }
        // Default signature for unknown functions
        const defaultSignature = new vscode.SignatureInformation(`${match.name}(...)`, `Function ${match.name}`);
        defaultSignature.parameters = [
            new vscode.ParameterInformation('...', 'Parameters')
        ];
        return {
            signatures: [defaultSignature],
            activeSignature: 0,
            activeParameter: Math.max(0, match.params.length - 1)
        };
    }
    /**
     * Get AI operation signature
     */
    getAIOperationSignature(match) {
        const signatures = this.getAIOperationSignatures();
        const signature = signatures.find(sig => sig.label.startsWith(match.name + '('));
        if (signature) {
            const activeParameter = Math.max(0, match.params.length - 1);
            return {
                signatures: [signature],
                activeSignature: 0,
                activeParameter
            };
        }
        // Default signature for unknown AI operations
        const defaultSignature = new vscode.SignatureInformation(`${match.name}(...)`, `AI operation ${match.name}`);
        defaultSignature.parameters = [
            new vscode.ParameterInformation('...', 'Parameters')
        ];
        return {
            signatures: [defaultSignature],
            activeSignature: 0,
            activeParameter: Math.max(0, match.params.length - 1)
        };
    }
    /**
     * Get predefined function signatures
     */
    getFunctionSignatures() {
        return [
            // Basic functions
            new vscode.SignatureInformation('print(message)', 'Print message to console'),
            new vscode.SignatureInformation('println(message)', 'Print message to console with newline'),
            new vscode.SignatureInformation('len(collection)', 'Get length of collection'),
            new vscode.SignatureInformation('size(collection)', 'Get size of collection'),
            new vscode.SignatureInformation('append(collection, element)', 'Add element to collection'),
            new vscode.SignatureInformation('push(collection, element)', 'Add element to collection'),
            new vscode.SignatureInformation('pop(collection)', 'Remove and return last element'),
            new vscode.SignatureInformation('sort(collection, comparator?)', 'Sort collection'),
            new vscode.SignatureInformation('filter(collection, predicate)', 'Filter collection elements'),
            new vscode.SignatureInformation('map(collection, transform)', 'Transform collection elements'),
            new vscode.SignatureInformation('read(filename, mode?)', 'Read from file'),
            new vscode.SignatureInformation('write(filename, data, mode?)', 'Write to file'),
            new vscode.SignatureInformation('open(filename, mode)', 'Open file'),
            new vscode.SignatureInformation('close(fileHandle)', 'Close file'),
            // Array functions
            new vscode.SignatureInformation('Array(size?, fillValue?)', 'Create new array'),
            new vscode.SignatureInformation('List(size?, fillValue?)', 'Create new list'),
            // String functions
            new vscode.SignatureInformation('String(value)', 'Convert to string'),
            new vscode.SignatureInformation('substring(string, start, end?)', 'Get substring'),
            // Math functions
            new vscode.SignatureInformation('Math.abs(value)', 'Absolute value'),
            new vscode.SignatureInformation('Math.sqrt(value)', 'Square root'),
            new vscode.SignatureInformation('Math.pow(base, exponent)', 'Power'),
            new vscode.SignatureInformation('Math.random(max?)', 'Random number'),
            // Promise functions
            new vscode.SignatureInformation('Promise(executor)', 'Create new promise'),
            new vscode.SignatureInformation('Promise.resolve(value)', 'Create resolved promise'),
            new vscode.SignatureInformation('Promise.reject(reason)', 'Create rejected promise'),
        ];
    }
    /**
     * Get predefined AI operation signatures
     */
    getAIOperationSignatures() {
        return [
            // AI model operations
            new vscode.SignatureInformation('train(dataset, epochs?, batchSize?, validationData?)', 'Train AI model'),
            new vscode.SignatureInformation('predict(input, batchSize?)', 'Make predictions with AI model'),
            new vscode.SignatureInformation('validate(testData, metrics?)', 'Validate AI model'),
            new vscode.SignatureInformation('compile(optimizer, loss, metrics?)', 'Compile AI model'),
            new vscode.SignatureInformation('fit(dataset, epochs?, callbacks?)', 'Fit AI model to data'),
            new vscode.SignatureInformation('evaluate(testData, metrics?)', 'Evaluate AI model'),
            new vscode.SignatureInformation('save(filepath, format?)', 'Save AI model'),
            new vscode.SignatureInformation('load(filepath, format?)', 'Load AI model'),
            // AI agent operations
            new vscode.SignatureInformation('learn(experience, reward?)', 'Learn from experience'),
            new vscode.SignatureInformation('act(state, explorationRate?)', 'Take action based on state'),
            new vscode.SignatureInformation('observe(state, action, reward, nextState)', 'Observe environment feedback'),
            new vscode.SignatureInformation('reset()', 'Reset agent state'),
            // AI pipeline operations
            new vscode.SignatureInformation('run(inputData, config?)', 'Run AI pipeline'),
            new vscode.SignatureInformation('addStep(name, function, config?)', 'Add step to pipeline'),
            new vscode.SignatureInformation('removeStep(name)', 'Remove step from pipeline'),
            new vscode.SignatureInformation('getStep(name)', 'Get pipeline step'),
            // AI dataset operations
            new vscode.SignatureInformation('load(filepath, format?, preprocessing?)', 'Load dataset'),
            new vscode.SignatureInformation('split(ratio, shuffle?)', 'Split dataset'),
            new vscode.SignatureInformation('batch(batchSize, shuffle?)', 'Create batches from dataset'),
            new vscode.SignatureInformation('preprocess(function)', 'Apply preprocessing to dataset'),
            // AI tensor operations
            new vscode.SignatureInformation('reshape(shape)', 'Reshape tensor'),
            new vscode.SignatureInformation('transpose(axes?)', 'Transpose tensor'),
            new vscode.SignatureInformation('concat(other, axis?)', 'Concatenate tensors'),
            new vscode.SignatureInformation('slice(start, end?, step?)', 'Slice tensor'),
            // AI general operations
            new vscode.SignatureInformation('transform(data, type, config?)', 'Transform data using AI'),
            new vscode.SignatureInformation('optimize(hyperparameters, objective?)', 'Optimize AI model'),
            new vscode.SignatureInformation('refactor(code, type, config?)', 'Refactor code using AI'),
            new vscode.SignatureInformation('generate(prompt, config?)', 'Generate content using AI'),
            new vscode.SignatureInformation('analyze(data, type, config?)', 'Analyze data using AI'),
        ];
    }
}
exports.NoodleSignatureProvider = NoodleSignatureProvider;
//# sourceMappingURL=noodleSignatureProvider.js.map