/**
 * Syntax Highlighting Engine
 * Provides syntax highlighting for Noodle and other languages
 * Implements language-agnostic highlighting patterns
 */

class SyntaxHighlighter {
    constructor(language = 'noodle') {
        this.language = language;
        this.highlightRules = this.initializeHighlightRules();
    }

    /**
     * Initialize highlighting rules for different languages
     */
    initializeHighlightRules() {
        return {
            noodle: {
                keywords: [
                    'import', 'from', 'class', 'def', 'if', 'else', 'elif', 'for',
                    'while', 'try', 'except', 'finally', 'with', 'as', 'return',
                    'yield', 'break', 'continue', 'pass', 'and', 'or', 'not',
                    'in', 'is', 'lambda', 'async', 'await', 'None', 'True', 'False'
                ],
                builtins: [
                    'print', 'len', 'range', 'str', 'int', 'float', 'list',
                    'dict', 'set', 'tuple', 'bool', 'type', 'isinstance'
                ],
                types: ['int', 'float', 'str', 'bool', 'list', 'dict', 'tuple', 'set', 'Optional', 'Any', 'Dict', 'List'],
                decorators: ['@property', '@staticmethod', '@classmethod'],
                comments: '#',
                strings: ['"', "'", '"""', "'''"],
                operators: ['=', '==', '!=', '<', '>', '<=', '>=', '+', '-', '*', '/', '//', '%', '**', '|', '&', '^', '~', '<<', '>>'],
                delimiters: ['(', ')', '[', ']', '{', '}', ',', ':', ';', '.', '...']
            },
            python: {
                keywords: [
                    'import', 'from', 'class', 'def', 'if', 'else', 'elif', 'for',
                    'while', 'try', 'except', 'finally', 'with', 'as', 'return',
                    'yield', 'break', 'continue', 'pass', 'and', 'or', 'not',
                    'in', 'is', 'lambda', 'async', 'await', 'None', 'True', 'False'
                ],
                builtins: [
                    'print', 'len', 'range', 'str', 'int', 'float', 'list',
                    'dict', 'set', 'tuple', 'bool', 'type', 'isinstance'
                ],
                types: ['int', 'float', 'str', 'bool', 'list', 'dict', 'tuple', 'set'],
                decorators: ['@property', '@staticmethod', '@classmethod'],
                comments: '#',
                strings: ['"', "'", '"""', "'''"],
                operators: ['=', '==', '!=', '<', '>', '<=', '>=', '+', '-', '*', '/', '//', '%', '**'],
                delimiters: ['(', ')', '[', ']', '{', '}', ',', ':', ';', '.', '...']
            },
            javascript: {
                keywords: [
                    'function', 'var', 'let', 'const', 'if', 'else', 'else if', 'for',
                    'while', 'do', 'try', 'catch', 'finally', 'return', 'break',
                    'continue', 'switch', 'case', 'default', 'new', 'class',
                    'extends', 'super', 'this', 'null', 'undefined', 'true', 'false'
                ],
                builtins: [
                    'console', 'setTimeout', 'setInterval', 'clearTimeout', 'clearInterval',
                    'Array', 'Object', 'String', 'Number', 'Boolean', 'Date', 'Math'
                ],
                types: ['function', 'object', 'string', 'number', 'boolean', 'undefined', 'null'],
                comments: '//',
                strings: ['"', "'"],
                operators: ['=', '==', '===', '!=', '!==', '<', '>', '<=', '>=', '+', '-', '*', '/', '%', '++', '--', '!', '&&', '||'],
                delimiters: ['(', ')', '[', ']', '{', '}', ',', ';', '.', '!', '?']
            },
            html: {
                keywords: [],
                builtins: [],
                types: [],
                decorators: [],
                comments: '<!--',
                strings: ['"', "'"],
                operators: [],
                delimiters: [],
                tags: [
                    'html', 'head', 'title', 'body', 'div', 'span', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
                    'a', 'img', 'ul', 'ol', 'li', 'table', 'tr', 'td', 'th', 'form', 'input', 'button',
                    'script', 'style', 'link', 'meta', 'doctype', 'br', 'hr'
                ],
                attributes: [
                    'class', 'id', 'src', 'href', 'style', 'type', 'name', 'value', 'placeholder',
                    'required', 'disabled', 'checked', 'selected', 'onclick', 'onload', 'onerror'
                ]
            },
            css: {
                keywords: [],
                builtins: [],
                types: [],
                decorators: [],
                comments: '/*',
                strings: ['"', "'"],
                operators: [],
                delimiters: [],
                properties: [
                    'color', 'background-color', 'font-size', 'font-family', 'font-weight',
                    'margin', 'padding', 'border', 'width', 'height', 'display', 'position',
                    'top', 'right', 'bottom', 'left', 'z-index', 'opacity', 'visibility',
                    'text-align', 'text-decoration', 'text-transform', 'line-height'
                ],
                values: [
                    'block', 'inline', 'inline-block', 'none', 'relative', 'absolute',
                    'fixed', 'static', 'center', 'left', 'right', 'top', 'bottom',
                    'bold', 'normal', 'italic', 'underline', 'none', 'visible', 'hidden'
                ]
            }
        };
    }

    /**
     * Highlight code based on language rules
     */
    highlight(code) {
        const rules = this.highlightRules[this.language] || this.highlightRules.noodle;
        let highlighted = code;

        // Apply highlighting rules
        highlighted = this.highlightComments(highlighted, rules.comments);
        highlighted = this.highlightStrings(highlighted, rules.strings);
        highlighted = this.highlightKeywords(highlighted, rules.keywords);
        highlighted = this.highlightBuiltins(highlighted, rules.builtins);
        highlighted = this.highlightNumbers(highlighted);
        highlighted = this.highlightOperators(highlighted, rules.operators);
        highlighted = this.highlightDelimiters(highlighted, rules.delimiters);

        // Language-specific highlighting
        if (this.language === 'html') {
            highlighted = this.highlightHTMLTags(highlighted, rules.tags, rules.attributes);
        } else if (this.language === 'css') {
            highlighted = this.highlightCSSProperties(highlighted, rules.properties, rules.values);
        }

        return highlighted;
    }

    /**
     * Highlight comments
     */
    highlightComments(code, commentStart) {
        if (!commentStart) return code;

        const commentRegex = commentStart === '<!--'
            ? /<!--[\s\S]*?-->/g
            : new RegExp(commentStart + '.*$', 'gm');

        return code.replace(commentRegex, match =>
            `<span class="syntax-comment">${this.escapeHtml(match)}</span>`
        );
    }

    /**
     * Highlight strings
     */
    highlightStrings(code, stringDelimiters) {
        if (!stringDelimiters || stringDelimiters.length === 0) return code;

        let result = code;

        stringDelimiters.forEach(delimiter => {
            const regex = new RegExp(`${delimiter}(?:[^${delimiter}\\\\]|\\\\.)*${delimiter}`, 'g');
            result = result.replace(regex, match =>
                `<span class="syntax-string">${this.escapeHtml(match)}</span>`
            );
        });

        return result;
    }

    /**
     * Highlight keywords
     */
    highlightKeywords(code, keywords) {
        if (!keywords || keywords.length === 0) return code;

        keywords.forEach(keyword => {
            const regex = new RegExp(`\\b${keyword}\\b`, 'g');
            code = code.replace(regex, match =>
                `<span class="syntax-keyword">${match}</span>`
            );
        });

        return code;
    }

    /**
     * Highlight built-in functions and types
     */
    highlightBuiltins(code, builtins) {
        if (!builtins || builtins.length === 0) return code;

        builtins.forEach(builtin => {
            const regex = new RegExp(`\\b${builtin}\\b`, 'g');
            code = code.replace(regex, match =>
                `<span class="syntax-builtin">${match}</span>`
            );
        });

        return code;
    }

    /**
     * Highlight numbers
     */
    highlightNumbers(code) {
        // Match integers and floats
        const numberRegex = /\b\d+(?:\.\d+)?\b/g;
        return code.replace(numberRegex, match =>
            `<span class="syntax-number">${match}</span>`
        );
    }

    /**
     * Highlight operators
     */
    highlightOperators(code, operators) {
        if (!operators || operators.length === 0) return code;

        operators.forEach(operator => {
            const escaped = operator.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp(escaped, 'g');
            code = code.replace(regex, match =>
                `<span class="syntax-operator">${match}</span>`
            );
        });

        return code;
    }

    /**
     * Highlight delimiters
     */
    highlightDelimiters(code, delimiters) {
        if (!delimiters || delimiters.length === 0) return code;

        delimiters.forEach(delimiter => {
            const escaped = delimiter.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            const regex = new RegExp(escaped, 'g');
            code = code.replace(regex, match =>
                `<span class="syntax-delimiter">${match}</span>`
            );
        });

        return code;
    }

    /**
     * Highlight HTML tags
     */
    highlightHTMLTags(code, tags = [], attributes = []) {
        let result = code;

        // Highlight tags
        tags.forEach(tag => {
            const regex = new RegExp(`</?${tag}\\b`, 'gi');
            result = result.replace(regex, match =>
                `<span class="syntax-tag">${match}</span>`
            );
        });

        // Highlight attributes
        attributes.forEach(attr => {
            const regex = new RegExp(`\\b${attr}\\b`, 'g');
            result = result.replace(regex, match =>
                `<span class="syntax-attribute">${match}</span>`
            );
        });

        return result;
    }

    /**
     * Highlight CSS properties and values
     */
    highlightCSSProperties(code, properties = [], values = []) {
        let result = code;

        // Highlight properties
        properties.forEach(prop => {
            const regex = new RegExp(`\\b${prop}\\b`, 'g');
            result = result.replace(regex, match =>
                `<span class="syntax-property">${match}</span>`
            );
        });

        // Highlight values
        values.forEach(value => {
            const regex = new RegExp(`\\b${value}\\b`, 'g');
            result = result.replace(regex, match =>
                `<span class="syntax-value">${match}</span>`
            );
        });

        return result;
    }

    /**
     * Escape HTML special characters
     */
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Set programming language
     */
    setLanguage(language) {
        this.language = language;
    }

    /**
     * Get current language
     */
    getLanguage() {
        return this.language;
    }

    /**
     * Add custom highlighting rules
     */
    addRules(language, rules) {
        this.highlightRules[language] = {
            ...this.highlightRules[language],
            ...rules
        };
    }

    /**
     * Get available languages
     */
    getLanguages() {
        return Object.keys(this.highlightRules);
    }
}

/**
 * Code Completer
 * Provides intelligent code completion suggestions
 */
class CodeCompleter {
    constructor() {
        this.completions = this.initializeCompletions();
        this.maxCompletions = 20;
    }

    /**
     * Initialize completion data for different languages
     */
    initializeCompletions() {
        return {
            noodle: {
                keywords: [
                    { text: 'import', type: 'keyword', description: 'Import module', snippet: 'import ${1:module}' },
                    { text: 'from', type: 'keyword', description: 'Import from module', snippet: 'from ${1:module} import ${2:name}' },
                    { text: 'class', type: 'keyword', description: 'Define class', snippet: 'class ${1:ClassName}:\n    ${2:pass}' },
                    { text: 'def', type: 'keyword', description: 'Define function', snippet: 'def ${1:function_name}(${2:args}):\n    ${3:pass}' },
                    { text: 'if', type: 'keyword', description: 'If statement', snippet: 'if ${1:condition}:\n    ${2:pass}' },
                    { text: 'else', type: 'keyword', description: 'Else statement', snippet: 'else:\n    ${1:pass}' },
                    { text: 'elif', type: 'keyword', description: 'Else if statement', snippet: 'elif ${1:condition}:\n    ${2:pass}' },
                    { text: 'for', type: 'keyword', description: 'For loop', snippet: 'for ${1:item} in ${2:items}:\n    ${3:pass}' },
                    { text: 'while', type: 'keyword', description: 'While loop', snippet: 'while ${1:condition}:\n    ${2:pass}' },
                    { text: 'try', type: 'keyword', description: 'Try block', snippet: 'try:\n    ${1:pass}\nexcept ${2:Exception}:\n    ${3:pass}' },
                    { text: 'async', type: 'keyword', description: 'Async function', snippet: 'async def ${1:function_name}(${2:args}):\n    ${3:pass}' },
                    { text: 'await', type: 'keyword', description: 'Await expression', snippet: 'await ${1:expression}' },
                    { text: 'return', type: 'keyword', description: 'Return statement', snippet: 'return ${1:value}' },
                    { text: 'None', type: 'keyword', description: 'Null value', snippet: 'None' },
                    { text: 'True', type: 'keyword', description: 'Boolean true', snippet: 'True' },
                    { text: 'False', type: 'keyword', description: 'Boolean false', snippet: 'False' }
                ],
                builtins: [
                    { text: 'print', type: 'function', description: 'Print function', snippet: 'print(${1:value})' },
                    { text: 'len', type: 'function', description: 'Get length', snippet: 'len(${1:object})' },
                    { text: 'range', type: 'function', description: 'Generate range', snippet: 'range(${1:start}, ${2:stop}, ${3:step})' },
                    { text: 'str', type: 'function', description: 'Convert to string', snippet: 'str(${1:object})' },
                    { text: 'int', type: 'function', description: 'Convert to integer', snippet: 'int(${1:object})' },
                    { text: 'float', type: 'function', description: 'Convert to float', snippet: 'float(${1:object})' },
                    { text: 'list', type: 'function', description: 'Create list', snippet: 'list(${1:iterable})' },
                    { text: 'dict', type: 'function', description: 'Create dictionary', snippet: 'dict(${1:mapping})' },
                    { text: 'set', type: 'function', description: 'Create set', snippet: 'set(${1:iterable})' },
                    { text: 'tuple', type: 'function', description: 'Create tuple', snippet: 'tuple(${1:iterable})' },
                    { text: 'type', type: 'function', description: 'Get type', snippet: 'type(${1:object})' },
                    { text: 'isinstance', type: 'function', description: 'Check instance', snippet: 'isinstance(${1:object}, ${2:type})' },
                    { text: 'open', type: 'function', description: 'Open file', snippet: 'open(${1:filename}, ${2:mode})' },
                    { text: 'input', type: 'function', description: 'Get user input', snippet: 'input(${1:prompt})' },
                    { text: 'sum', type: 'function', description: 'Sum elements', snippet: 'sum(${1:iterable})' },
                    { text: 'max', type: 'function', description: 'Maximum value', snippet: 'max(${1:iterable})' },
                    { text: 'min', type: 'function', description: 'Minimum value', snippet: 'min(${1:iterable})' },
                    { text: 'sorted', type: 'function', description: 'Sort list', snippet: 'sorted(${1:iterable})' },
                    { text: 'filter', type: 'function', description: 'Filter elements', snippet: 'filter(${1:function}, ${2:iterable})' },
                    { text: 'map', type: 'function', description: 'Map function', snippet: 'map(${1:function}, ${2:iterable})' },
                    { text: 'zip', type: 'function', description: 'Zip iterables', snippet: 'zip(${1:iterable1}, ${2:iterable2})' }
                ],
                types: [
                    { text: 'str', type: 'type', description: 'String type', snippet: 'str' },
                    { text: 'int', type: 'type', description: 'Integer type', snippet: 'int' },
                    { text: 'float', type: 'type', description: 'Float type', snippet: 'float' },
                    { text: 'bool', type: 'type', description: 'Boolean type', snippet: 'bool' },
                    { text: 'list', type: 'type', description: 'List type', snippet: 'list' },
                    { text: 'dict', type: 'type', description: 'Dictionary type', snippet: 'dict' },
                    { text: 'tuple', type: 'type', description: 'Tuple type', snippet: 'tuple' },
                    { text: 'set', type: 'type', description: 'Set type', snippet: 'set' },
                    { text: 'Optional', type: 'type', description: 'Optional type', snippet: 'Optional[${1:Type}]' },
                    { text: 'Any', type: 'type', description: 'Any type', snippet: 'Any' },
                    { text: 'Dict', type: 'type', description: 'Dictionary type', snippet: 'Dict[${1:Key}, ${2:Value}]' },
                    { text: 'List', type: 'type', description: 'List type', snippet: 'List[${1:Type}]' }
                ]
            },
            python: {
                keywords: [
                    { text: 'import', type: 'keyword', description: 'Import module', snippet: 'import ${1:module}' },
                    { text: 'from', type: 'keyword', description: 'Import from module', snippet: 'from ${1:module} import ${2:name}' },
                    { text: 'class', type: 'keyword', description: 'Define class', snippet: 'class ${1:ClassName}:\n    ${2:pass}' },
                    { text: 'def', type: 'keyword', description: 'Define function', snippet: 'def ${1:function_name}(${2:args}):\n    ${3:pass}' },
                    { text: 'if', type: 'keyword', description: 'If statement', snippet: 'if ${1:condition}:\n    ${2:pass}' },
                    { text: 'else', type: 'keyword', description: 'Else statement', snippet: 'else:\n    ${1:pass}' },
                    { text: 'elif', type: 'keyword', description: 'Else if statement', snippet: 'elif ${1:condition}:\n    ${2:pass}' },
                    { text: 'for', type: 'keyword', description: 'For loop', snippet: 'for ${1:item} in ${2:items}:\n    ${3:pass}' },
                    { text: 'while', type: 'keyword', description: 'While loop', snippet: 'while ${1:condition}:\n    ${2:pass}' },
                    { text: 'try', type: 'keyword', description: 'Try block', snippet: 'try:\n    ${1:pass}\nexcept ${2:Exception}:\n    ${3:pass}' },
                    { text: 'with', type: 'keyword', description: 'With statement', snippet: 'with ${1:expression} as ${2:target}:\n    ${3:pass}' },
                    { text: 'lambda', type: 'keyword', description: 'Lambda function', snippet: 'lambda ${1:args}: ${2:expression}' },
                    { text: 'return', type: 'keyword', description: 'Return statement', snippet: 'return ${1:value}' },
                    { text: 'yield', type: 'keyword', description: 'Yield statement', snippet: 'yield ${1:value}' }
                ],
                builtins: [
                    { text: 'print', type: 'function', description: 'Print function', snippet: 'print(${1:value})' },
                    { text: 'len', type: 'function', description: 'Get length', snippet: 'len(${1:object})' },
                    { text: 'range', type: 'function', description: 'Generate range', snippet: 'range(${1:start}, ${2:stop}, ${3:step})' },
                    { text: 'enumerate', type: 'function', description: 'Enumerate iterable', snippet: 'enumerate(${1:iterable})' },
                    { text: 'zip', type: 'function', description: 'Zip iterables', snippet: 'zip(${1:iterable1}, ${2:iterable2})' },
                    { text: 'map', type: 'function', description: 'Map function', snippet: 'map(${1:function}, ${2:iterable})' },
                    { text: 'filter', type: 'function', description: 'Filter elements', snippet: 'filter(${1:function}, ${2:iterable})' },
                    { text: 'sorted', type: 'function', description: 'Sort list', snippet: 'sorted(${1:iterable})' },
                    { text: 'reversed', type: 'function', description: 'Reverse iterable', snippet: 'reversed(${1:iterable})' },
                    { text: 'all', type: 'function', description: 'All true', snippet: 'all(${1:iterable})' },
                    { text: 'any', type: 'function', description: 'Any true', snippet: 'any(${1:iterable})' },
                    { text: 'sum', type: 'function', description: 'Sum elements', snippet: 'sum(${1:iterable})' },
                    { text: 'max', type: 'function', description: 'Maximum value', snippet: 'max(${1:iterable})' },
                    { text: 'min', type: 'function', description: 'Minimum value', snippet: 'min(${1:iterable})' },
                    { text: 'abs', type: 'function', description: 'Absolute value', snippet: 'abs(${1:number})' },
                    { text: 'round', type: 'function', description: 'Round number', snippet: 'round(${1:number}, ${2:ndigits})' },
                    { text: 'pow', type: 'function', description: 'Power', snippet: 'pow(${1:base}, ${2:exp})' },
                    { text: 'divmod', type: 'function', description: 'Div and mod', snippet: 'divmod(${1:dividend}, ${2:divisor})' }
                ],
                types: [
                    { text: 'str', type: 'type', description: 'String type', snippet: 'str' },
                    { text: 'int', type: 'type', description: 'Integer type', snippet: 'int' },
                    { text: 'float', type: 'type', description: 'Float type', snippet: 'float' },
                    { text: 'bool', type: 'type', description: 'Boolean type', snippet: 'bool' },
                    { text: 'list', type: 'type', description: 'List type', snippet: 'list' },
                    { text: 'dict', type: 'type', description: 'Dictionary type', snippet: 'dict' },
                    { text: 'tuple', type: 'type', description: 'Tuple type', snippet: 'tuple' },
                    { text: 'set', type: 'type', description: 'Set type', snippet: 'set' },
                    { text: 'frozenset', type: 'type', description: 'Frozen set type', snippet: 'frozenset' },
                    { text: 'bytes', type: 'type', description: 'Bytes type', snippet: 'bytes' },
                    { text: 'bytearray', type: 'type', description: 'Byte array type', snippet: 'bytearray' },
                    { text: 'memoryview', type: 'type', description: 'Memory view type', snippet: 'memoryview' }
                ]
            },
            javascript: {
                keywords: [
                    { text: 'function', type: 'keyword', description: 'Function declaration', snippet: 'function ${1:name}(${2:params}) {\n    ${3:// body}\n}' },
                    { text: 'var', type: 'keyword', description: 'Variable declaration', snippet: 'var ${1:name} = ${2:value}' },
                    { text: 'let', type: 'keyword', description: 'Block variable', snippet: 'let ${1:name} = ${2:value}' },
                    { text: 'const', type: 'keyword', description: 'Constant declaration', snippet: 'const ${1:name} = ${2:value}' },
                    { text: 'if', type: 'keyword', description: 'If statement', snippet: 'if (${1:condition}) {\n    ${2:// body}\n}' },
                    { text: 'else', type: 'keyword', description: 'Else statement', snippet: 'else {\n    ${1:// body}\n}' },
                    { text: 'else if', type: 'keyword', description: 'Else if statement', snippet: 'else if (${1:condition}) {\n    ${2:// body}\n}' },
                    { text: 'for', type: 'keyword', description: 'For loop', snippet: 'for (${1:var i = 0; i < ${2:length}; i++) {\n    ${3:// body}\n}' },
                    { text: 'while', type: 'keyword', description: 'While loop', snippet: 'while (${1:condition}) {\n    ${2:// body}\n}' },
                    { text: 'do', type: 'keyword', description: 'Do while loop', snippet: 'do {\n    ${1:// body}\n} while (${2:condition});' },
                    { text: 'try', type: 'keyword', description: 'Try catch', snippet: 'try {\n    ${1:// body}\n} catch (${2:error}) {\n    ${3:// handle error}\n}' },
                    { text: 'switch', type: 'keyword', description: 'Switch statement', snippet: 'switch (${1:expression}) {\n    case ${2:value}:\n        ${3:// code}\n        break;\n    default:\n        ${4:// default code}\n}' },
                    { text: 'class', type: 'keyword', description: 'Class declaration', snippet: 'class ${1:Name} {\n    constructor(${2:params}) {\n        ${3:// constructor}\n    }\n}' },
                    { text: 'return', type: 'keyword', description: 'Return statement', snippet: 'return ${1:value}' },
                    { text: 'throw', type: 'keyword', description: 'Throw error', snippet: 'throw new Error(${1:message})' }
                ],
                builtins: [
                    { text: 'console.log', type: 'function', description: 'Log to console', snippet: 'console.log(${1:message})' },
                    { text: 'console.error', type: 'function', description: 'Log error', snippet: 'console.error(${1:error})' },
                    { text: 'console.warn', type: 'function', description: 'Log warning', snippet: 'console.warn(${1:warning})' },
                    { text: 'console.info', type: 'function', description: 'Log info', snippet: 'console.info(${1:info})' },
                    { text: 'alert', type: 'function', description: 'Show alert', snippet: 'alert(${1:message})' },
                    { text: 'confirm', type: 'function', description: 'Show confirmation', snippet: 'confirm(${1:message})' },
                    { text: 'prompt', type: 'function', description: 'Show prompt', snippet: 'prompt(${1:message}, ${2:default})' },
                    { text: 'setTimeout', type: 'function', description: 'Set timeout', snippet: 'setTimeout(() => {\n    ${1:// code}\n}, ${2:delay})' },
                    { text: 'setInterval', type: 'function', description: 'Set interval', snippet: 'setInterval(() => {\n    ${1:// code}\n}, ${2:interval})' },
                    { text: 'clearTimeout', type: 'function', description: 'Clear timeout', snippet: 'clearTimeout(${1:id})' },
                    { text: 'clearInterval', type: 'function', description: 'Clear interval', snippet: 'clearInterval(${1:id})' },
                    { text: 'parseInt', type: 'function', description: 'Parse integer', snippet: 'parseInt(${1:string}, ${2:radix})' },
                    { text: 'parseFloat', type: 'function', description: 'Parse float', snippet: 'parseFloat(${1:string})' },
                    { text: 'isNaN', type: 'function', description: 'Check NaN', snippet: 'isNaN(${1:value})' },
                    { text: 'JSON.parse', type: 'function', description: 'Parse JSON', snippet: 'JSON.parse(${1:string})' },
                    { text: 'JSON.stringify', type: 'function', description: 'Stringify JSON', snippet: 'JSON.stringify(${1:value}, ${2:replacer}, ${3:space})' }
                ],
                types: [
                    { text: 'String', type: 'type', description: 'String type', snippet: 'String' },
                    { text: 'Number', type: 'type', description: 'Number type', snippet: 'Number' },
                    { text: 'Boolean', type: 'type', description: 'Boolean type', snippet: 'Boolean' },
                    { text: 'Array', type: 'type', description: 'Array type', snippet: 'Array' },
                    { text: 'Object', type: 'type', description: 'Object type', snippet: 'Object' },
                    { text: 'Function', type: 'type', description: 'Function type', snippet: 'Function' },
                    { text: 'undefined', type: 'type', description: 'Undefined type', snippet: 'undefined' },
                    { text: 'null', type: 'type', description: 'Null type', snippet: 'null' }
                ]
            }
        };
    }

    /**
     * Get code completions for a given position
     */
    getCompletions(content, position, language = 'noodle') {
        const langCompletions = this.completions[language] || this.completions.noodle;
        const allCompletions = [
            ...langCompletions.keywords || [],
            ...langCompletions.builtins || [],
            ...langCompletions.types || []
        ];

        // Get text before cursor
        const textBefore = content.substring(0, position);
        const wordMatch = textBefore.match(/(\w+)$/);

        if (!wordMatch) return [];

        const currentWord = wordMatch[1];
        const suggestions = allCompletions.filter(item =>
            item.text.startsWith(currentWord) &&
            item.text !== currentWord
        );

        // Sort by relevance (exact matches first, then alphabetical)
        suggestions.sort((a, b) => {
            if (a.text === currentWord) return -1;
            if (b.text === currentWord) return 1;
            return a.text.localeCompare(b.text);
        });

        return suggestions.slice(0, this.maxCompletions);
    }

    /**
     * Add custom completion for a language
     */
    addCompletions(language, category, completions) {
        if (!this.completions[language]) {
            this.completions[language] = { keywords: [], builtins: [], types: [] };
        }

        if (!this.completions[language][category]) {
            this.completions[language][category] = [];
        }

        this.completions[language][category].push(...completions);
    }

    /**
     * Get available languages
     */
    getLanguages() {
        return Object.keys(this.completions);
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { SyntaxHighlighter, CodeCompleter };
} else if (typeof window !== 'undefined') {
    window.SyntaxHighlighter = SyntaxHighlighter;
    window.CodeCompleter = CodeCompleter;
}