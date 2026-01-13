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
exports.NoodleHoverProvider = void 0;
const vscode = __importStar(require("vscode"));
/**
 * NoodleCore Hover Provider
 *
 * Provides hover information for NoodleCore language constructs,
 * including keywords, functions, types, and AI-specific elements.
 */
class NoodleHoverProvider {
    /**
     * Provide hover information for the given position
     */
    provideHover(document, position, token) {
        const range = document.getWordRangeAtPosition(position);
        if (!range) {
            return undefined;
        }
        const word = document.getText(range);
        const line = document.lineAt(position).text;
        // Check for different types of hover information
        const keywordHover = this.getKeywordHover(word);
        if (keywordHover) {
            return keywordHover;
        }
        const functionHover = this.getFunctionHover(word, line);
        if (functionHover) {
            return functionHover;
        }
        const typeHover = this.getTypeHover(word);
        if (typeHover) {
            return typeHover;
        }
        const aiHover = this.getAIHover(word, line);
        if (aiHover) {
            return aiHover;
        }
        return undefined;
    }
    /**
     * Get hover information for keywords
     */
    getKeywordHover(word) {
        const keywordInfo = {
            // Control flow
            'if': 'Conditional statement\n\n```noodle\nif (condition) {\n    // code to execute if condition is true\n}\n```',
            'else': 'Else clause for conditional statement\n\n```noodle\nif (condition) {\n    // code if condition is true\n} else {\n    // code if condition is false\n}\n```',
            'for': 'For loop\n\n```noodle\nfor (i = 0; i < 10; i++) {\n    // code to repeat\n}\n```',
            'while': 'While loop\n\n```noodle\nwhile (condition) {\n    // code to repeat while condition is true\n}\n```',
            'return': 'Return value from function\n\n```noodle\nreturn value;\n```',
            'func': 'Function definition\n\n```noodle\nfunc functionName(param1, param2) {\n    // function body\n    return result;\n}\n```',
            'class': 'Class definition\n\n```noodle\nclass ClassName {\n    // class properties and methods\n}\n```',
            'import': 'Import module\n\n```noodle\nimport "module_name";\n```',
            'export': 'Export module\n\n```noodle\nexport function_name;\n```',
            // Types
            'int': 'Integer type - whole numbers',
            'float': 'Float type - decimal numbers',
            'string': 'String type - text data',
            'bool': 'Boolean type - true or false',
            'array': 'Array type - ordered collection',
            'map': 'Map type - key-value pairs',
            'set': 'Set type - unique values',
            // Modifiers
            'public': 'Public access modifier - accessible from anywhere',
            'private': 'Private access modifier - accessible only within class',
            'protected': 'Protected access modifier - accessible within class and subclasses',
            'static': 'Static modifier - belongs to class, not instance',
            'async': 'Async modifier - function returns a Promise',
            'await': 'Await operator - wait for Promise to resolve',
        };
        const info = keywordInfo[word];
        if (info) {
            const content = new vscode.MarkdownString(info);
            return new vscode.Hover(content);
        }
        return undefined;
    }
    /**
     * Get hover information for functions
     */
    getFunctionHover(word, line) {
        const functionInfo = {
            'print': 'Print output to console\n\n```noodle\nprint("Hello, World!");\n```',
            'println': 'Print output to console with newline\n\n```noodle\nprintln("Hello, World!");\n```',
            'len': 'Get length of array, string, or collection\n\n```noodle\nlen(array_name)\n```',
            'size': 'Get size of collection\n\n```noodle\nsize(collection_name)\n```',
            'append': 'Add element to end of array\n\n```noodle\narray_name.append(element)\n```',
            'push': 'Add element to end of array\n\n```noodle\narray_name.push(element)\n```',
            'pop': 'Remove and return last element of array\n\n```noodle\narray_name.pop()\n```',
            'sort': 'Sort array elements\n\n```noodle\narray_name.sort()\n```',
            'filter': 'Filter array elements based on condition\n\n```noodle\narray_name.filter(function(element) {\n    return condition;\n})\n```',
            'map': 'Transform array elements\n\n```noodle\narray_name.map(function(element) {\n    return transformed_element;\n})\n```',
            'read': 'Read data from file or input\n\n```noodle\nread("filename")\n```',
            'write': 'Write data to file\n\n```noodle\nwrite("filename", data)\n```',
            'open': 'Open file for reading or writing\n\n```noodle\nopen("filename", "mode")\n```',
            'close': 'Close file\n\n```noodle\nfile_handle.close()\n```',
        };
        const info = functionInfo[word];
        if (info) {
            const content = new vscode.MarkdownString(info);
            return new vscode.Hover(content);
        }
        return undefined;
    }
    /**
     * Get hover information for types
     */
    getTypeHover(word) {
        const typeInfo = {
            'String': 'String class for text manipulation\n\n```noodle\nlet text = "Hello, World!";\nlet length = text.len();\n```',
            'Array': 'Array class for ordered collections\n\n```noodle\nlet arr = [1, 2, 3, 4, 5];\narr.push(6);\n```',
            'Map': 'Map class for key-value pairs\n\n```noodle\nlet map = {"key1": "value1", "key2": "value2"};\nmap.set("key3", "value3");\n```',
            'Set': 'Set class for unique values\n\n```noodle\nlet set = {1, 2, 3, 4, 5};\nset.add(6);\n```',
            'List': 'List class for dynamic arrays\n\n```noodle\nlet list = List([1, 2, 3]);\nlist.append(4);\n```',
            'Dictionary': 'Dictionary class for key-value mappings\n\n```noodle\nlet dict = Dictionary();\ndict.set("key", "value");\n```',
            'Function': 'Function class for function objects\n\n```noodle\nlet func = Function(param1, param2) {\n    return param1 + param2;\n};\n```',
            'Promise': 'Promise class for async operations\n\n```noodle\nlet promise = Promise(resolve => {\n    // async operation\n    resolve(result);\n});\n```',
            'Stream': 'Stream class for data streams\n\n```noodle\nlet stream = Stream();\nstream.write(data);\n```',
            'Buffer': 'Buffer class for binary data\n\n```noodle\nlet buffer = Buffer(size);\nbuffer.write(data);\n```',
        };
        const info = typeInfo[word];
        if (info) {
            const content = new vscode.MarkdownString(info);
            return new vscode.Hover(content);
        }
        return undefined;
    }
    /**
     * Get hover information for AI-specific elements
     */
    getAIHover(word, line) {
        const aiInfo = {
            // AI keywords
            'ai': 'AI namespace for artificial intelligence functionality\n\n```noodle\nai model modelName {\n    // model configuration\n}\n```',
            'agent': 'AI agent definition\n\n```noodle\nagent agentName {\n    role: "developer";\n    capabilities: ["code_analysis", "debugging"];\n}\n```',
            'model': 'AI model configuration\n\n```noodle\nai model modelName {\n    type: "neural_network";\n    layers: [input, hidden, output];\n}\n```',
            'train': 'Train AI model\n\n```noodle\nmodel.train(dataset, epochs);\n```',
            'predict': 'Make predictions with AI model\n\n```noodle\nlet result = model.predict(input_data);\n```',
            'transform': 'Transform data using AI\n\n```noodle\nlet transformed = ai.transform(data, transformation_type);\n```',
            'validate': 'Validate AI model or data\n\n```noodle\nlet accuracy = model.validate(test_data);\n```',
            'compile': 'Compile AI model\n\n```noodle\nmodel.compile(optimizer, loss_function);\n```',
            'run': 'Run AI model or agent\n\n```noodle\nlet result = model.run(input);\n```',
            'debug': 'Debug AI model or agent\n\n```noodle\nmodel.debug(input, expected_output);\n```',
            'test': 'Test AI model or agent\n\n```noodle\nlet results = model.test(test_dataset);\n```',
            'optimize': 'Optimize AI model performance\n\n```noodle\nmodel.optimize(hyperparameters);\n```',
            'refactor': 'Refactor code using AI\n\n```noodle\nai.refactor(code, improvement_type);\n```',
            'learn': 'AI learning functionality\n\n```noodle\nagent.learn(experience_data);\n```',
            'dataset': 'Dataset for AI training\n\n```noodle\nlet data = dataset.load("path/to/data");\n```',
            'pipeline': 'AI pipeline definition\n\n```noodle\npipeline pipelineName {\n    input: dataset;\n    steps: [preprocess, train, evaluate];\n}\n```',
            'neural': 'Neural network functionality\n\n```noodle\nneural network modelName {\n    layers: [input, hidden, output];\n}\n```',
            'network': 'Neural network definition\n\n```noodle\nnetwork modelName {\n    type: "feedforward";\n    layers: [input, hidden, output];\n}\n```',
            'tensor': 'Tensor data structure for AI\n\n```noodle\nlet tensor = Tensor(shape, data);\n```',
            'matrix': 'Matrix operations for AI\n\n```noodle\nlet matrix = Matrix(rows, cols, data);\n```',
            'vector': 'Vector operations for AI\n\n```noodle\nlet vector = Vector(data);\n```',
            // AI types
            'AIModel': 'AI Model class for machine learning models\n\n```noodle\nlet model = AIModel();\nmodel.load("path/to/model");\n```',
            'NeuralNetwork': 'Neural Network class for deep learning\n\n```noodle\nlet nn = NeuralNetwork();\nnn.addLayer("input", 784);\n```',
            'Dataset': 'Dataset class for AI training data\n\n```noodle\nlet dataset = Dataset();\ndataset.load("path/to/data");\n```',
            'Pipeline': 'Pipeline class for AI workflows\n\n```noodle\nlet pipeline = Pipeline();\npipeline.addStep("preprocess", preprocess_function);\n```',
            'Agent': 'AI Agent class for intelligent agents\n\n```noodle\nlet agent = Agent();\nagent.setRole("developer");\n```',
            'Workspace': 'Workspace class for AI development\n\n```noodle\nlet workspace = Workspace();\nworkspace.addProject("project_name");\n```',
        };
        const info = aiInfo[word];
        if (info) {
            const content = new vscode.MarkdownString(info);
            return new vscode.Hover(content);
        }
        return undefined;
    }
}
exports.NoodleHoverProvider = NoodleHoverProvider;
//# sourceMappingURL=noodleHoverProvider.js.map