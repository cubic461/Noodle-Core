/**
 * Code Editor Component
 * Advanced code editing functionality for the Noodle IDE
 * Implements syntax highlighting, code completion, and real-time editing
 */

class CodeEditor {
    constructor(container, options = {}) {
        this.container = container;
        this.options = {
            language: 'noodle',
            theme: 'dark',
            fontSize: 14,
            tabSize: 4,
            lineNumbers: true,
            autoIndent: true,
            autoComplete: true,
            autoSave: true,
            ...options
        };

        // Editor state
        this.isDirty = false;
        this.hasFocus = false;
        this.cursorPosition = { line: 1, column: 1 };
        this.scrollPosition = { top: 0, left: 0 };
        this.selectedText = '';

        // Code analysis state
        this.syntaxErrors = [];
        this.codeMetrics = {
            lines: 0,
            characters: 0,
            functions: 0,
            classes: 0,
            comments: 0
        };

        // Auto-completion state
        this.completionCache = new Map();
        this.showingCompletions = false;
        this.currentCompletions = [];

        // Event listeners
        this.onChange = [];
        this.onSave = [];
        this.onError = [];
        this.onCompletion = [];
        this.onCursorChange = [];

        // Initialize editor
        this.init();
    }

    /**
     * Initialize the code editor
     */
    init() {
        console.log('Initializing Code Editor...');

        // Create editor structure
        this.createEditorStructure();

        // Setup event listeners
        this.setupEventListeners();

        // Initialize syntax highlighting
        this.initSyntaxHighlighting();

        // Initialize code completion
        this.initCodeCompletion();

        // Initialize auto-save
        if (this.options.autoSave) {
            this.initAutoSave();
        }

        console.log('Code Editor initialized successfully');
    }

    /**
     * Create the editor DOM structure
     */
    createEditorStructure() {
        // Clear container
        this.container.innerHTML = '';

        // Create editor wrapper
        const wrapper = document.createElement('div');
        wrapper.className = 'code-editor-wrapper';
        wrapper.style.position = 'relative';
        wrapper.style.height = '100%';
        wrapper.style.width = '100%';

        // Create line numbers
        if (this.options.lineNumbers) {
            this.lineNumbersEl = document.createElement('div');
            this.lineNumbersEl.className = 'line-numbers';
            this.lineNumbersEl.style.position = 'absolute';
            this.lineNumbersEl.style.left = '0';
            this.lineNumbersEl.style.top = '0';
            this.lineNumbersEl.style.width = '60px';
            this.lineNumbersEl.style.height = '100%';
            this.lineNumbersEl.style.backgroundColor = 'var(--bg-secondary)';
            this.lineNumbersEl.style.borderRight = '1px solid var(--border-color)';
            this.lineNumbersEl.style.overflow = 'hidden';
            wrapper.appendChild(this.lineNumbersEl);
        }

        // Create code textarea
        this.textarea = document.createElement('textarea');
        this.textarea.className = 'code-editor-textarea';
        this.textarea.style.position = 'absolute';
        this.textarea.style.left = this.options.lineNumbers ? '70px' : '0';
        this.textarea.style.top = '0';
        this.textarea.style.width = 'calc(100% - ' + (this.options.lineNumbers ? '70px' : '0') + ')';
        this.textarea.style.height = '100%';
        this.textarea.style.border = 'none';
        this.textarea.style.outline = 'none';
        this.textarea.style.resize = 'none';
        this.textarea.style.backgroundColor = 'var(--bg-primary)';
        this.textarea.style.color = 'var(--text-primary)';
        this.textarea.style.fontFamily = 'var(--font-family)';
        this.textarea.style.fontSize = this.options.fontSize + 'px';
        this.textarea.style.lineHeight = '1.6';
        this.textarea.style.padding = 'var(--spacing-lg)';
        this.textarea.style.whiteSpace = 'pre';
        this.textarea.style.overflow = 'auto';
        this.textarea.style.tabSize = this.options.tabSize;

        wrapper.appendChild(this.textarea);

        // Create syntax highlighting overlay
        this.highlightOverlay = document.createElement('div');
        this.highlightOverlay.className = 'syntax-highlight-overlay';
        this.highlightOverlay.style.position = 'absolute';
        this.highlightOverlay.style.left = this.textarea.style.left;
        this.highlightOverlay.style.top = '0';
        this.highlightOverlay.style.width = this.textarea.style.width;
        this.highlightOverlay.style.height = '100%';
        this.highlightOverlay.style.pointerEvents = 'none';
        this.highlightOverlay.style.whiteSpace = 'pre';
        this.highlightOverlay.style.overflow = 'hidden';
        this.highlightOverlay.style.fontFamily = 'var(--font-family)';
        this.highlightOverlay.style.fontSize = this.options.fontSize + 'px';
        this.highlightOverlay.style.lineHeight = '1.6';
        this.highlightOverlay.style.padding = 'var(--spacing-lg)';

        wrapper.appendChild(this.highlightOverlay);

        // Create completion popup
        this.completionPopup = document.createElement('div');
        this.completionPopup.className = 'completion-popup';
        this.completionPopup.style.position = 'absolute';
        this.completionPopup.style.display = 'none';
        this.completionPopup.style.backgroundColor = 'var(--bg-secondary)';
        this.completionPopup.style.border = '1px solid var(--border-color)';
        this.completionPopup.style.borderRadius = '4px';
        this.completionPopup.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.15)';
        this.completionPopup.style.maxHeight = '200px';
        this.completionPopup.style.overflowY = 'auto';
        this.completionPopup.style.zIndex = '1000';
        this.completionPopup.style.minWidth = '200px';

        wrapper.appendChild(this.completionPopup);

        // Create error indicators
        this.errorIndicators = document.createElement('div');
        this.errorIndicators.className = 'error-indicators';
        this.errorIndicators.style.position = 'absolute';
        this.errorIndicators.style.right = '10px';
        this.errorIndicators.style.top = '10px';
        this.errorIndicators.style.maxHeight = 'calc(100% - 20px)';
        this.errorIndicators.style.overflowY = 'auto';
        this.errorIndicators.style.zIndex = '500';

        wrapper.appendChild(this.errorIndicators);

        this.container.appendChild(wrapper);

        // Store references
        this.wrapper = wrapper;
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Text change events
        this.textarea.addEventListener('input', () => this.onTextChange());
        this.textarea.addEventListener('keydown', (e) => this.onKeyDown(e));
        this.textarea.addEventListener('click', () => this.onCursorChange());
        this.textarea.addEventListener('scroll', () => this.onScroll());
        this.textarea.addEventListener('focus', () => this.onFocus());
        this.textarea.addEventListener('blur', () => this.onBlur());

        // Mouse events for completion
        this.textarea.addEventListener('mouseup', () => this.onCursorChange());

        // Context menu
        this.textarea.addEventListener('contextmenu', (e) => this.onContextMenu(e));
    }

    /**
     * Handle text changes
     */
    onTextChange() {
        this.isDirty = true;

        // Update syntax highlighting
        this.updateSyntaxHighlighting();

        // Update code metrics
        this.updateCodeMetrics();

        // Update line numbers
        this.updateLineNumbers();

        // Trigger change events
        this.triggerChange();

        // Trigger auto-completion if enabled
        if (this.options.autoComplete) {
            this.debounce(() => this.checkForCompletions(), 300);
        }
    }

    /**
     * Handle key down events
     */
    onKeyDown(e) {
        // Handle tab key
        if (e.key === 'Tab') {
            e.preventDefault();
            this.insertText('    '.repeat(this.options.tabSize));
            return;
        }

        // Handle Enter key with auto-indent
        if (e.key === 'Enter' && this.options.autoIndent) {
            e.preventDefault();
            this.insertTextWithAutoIndent();
            return;
        }

        // Handle Ctrl+S for save
        if (e.ctrlKey && e.key === 's') {
            e.preventDefault();
            this.triggerSave();
            return;
        }

        // Handle Ctrl+Space for completion
        if (e.ctrlKey && e.key === ' ') {
            e.preventDefault();
            this.showCompletions();
            return;
        }

        // Handle Escape to hide completions
        if (e.key === 'Escape' && this.showingCompletions) {
            this.hideCompletions();
            return;
        }

        // Handle arrow keys for navigation
        if (this.showingCompletions && ['ArrowUp', 'ArrowDown', 'Enter'].includes(e.key)) {
            this.navigateCompletions(e);
            return;
        }
    }

    /**
     * Handle cursor position changes
     */
    onCursorChange() {
        this.updateCursorPosition();
        this.updateCursorDisplay();
        this.triggerCursorChange();
    }

    /**
     * Handle scroll events
     */
    onScroll() {
        this.updateScrollPosition();
        this.updateScrollDisplay();
        this.updateScrollSynchronization();
    }

    /**
     * Handle focus events
     */
    onFocus() {
        this.hasFocus = true;
    }

    /**
     * Handle blur events
     */
    onBlur() {
        this.hasFocus = false;
        this.hideCompletions();
    }

    /**
     * Handle context menu
     */
    onContextMenu(e) {
        e.preventDefault();
        // Context menu functionality can be added here
    }

    /**
     * Initialize syntax highlighting
     */
    initSyntaxHighlighting() {
        this.highlighter = new SyntaxHighlighter(this.options.language);
        this.updateSyntaxHighlighting();
    }

    /**
     * Update syntax highlighting
     */
    updateSyntaxHighlighting() {
        if (!this.textarea) return;

        const content = this.textarea.value;
        const highlighted = this.highlighter.highlight(content);

        this.highlightOverlay.innerHTML = highlighted;
        this.highlightOverlay.scrollTop = this.textarea.scrollTop;
        this.highlightOverlay.scrollLeft = this.textarea.scrollLeft;
    }

    /**
     * Initialize code completion
     */
    initCodeCompletion() {
        this.completer = new CodeCompleter();
    }

    /**
     * Check for code completions
     */
    checkForCompletions() {
        if (!this.options.autoComplete) return;

        const content = this.textarea.value;
        const position = this.getCursorPosition();
        const completions = this.completer.getCompletions(content, position, this.options.language);

        if (completions.length > 0) {
            this.showCompletions(completions);
        } else {
            this.hideCompletions();
        }
    }

    /**
     * Show code completions
     */
    showCompletions(completions = []) {
        this.currentCompletions = completions;
        this.showingCompletions = true;

        this.completionPopup.innerHTML = '';

        completions.forEach((completion, index) => {
            const item = document.createElement('div');
            item.className = 'completion-item';
            item.style.padding = '8px 12px';
            item.style.cursor = 'pointer';
            item.style.borderBottom = '1px solid var(--border-color)';

            const text = document.createElement('div');
            text.textContent = completion.text;
            text.style.fontWeight = 'bold';
            text.style.color = 'var(--text-primary)';

            const description = document.createElement('div');
            description.textContent = completion.description;
            description.style.fontSize = '12px';
            description.style.color = 'var(--text-secondary)';
            description.style.marginTop = '2px';

            item.appendChild(text);
            item.appendChild(description);

            item.addEventListener('click', () => {
                this.insertCompletion(completion);
            });

            item.addEventListener('mouseenter', () => {
                item.style.backgroundColor = 'var(--bg-hover)';
            });

            item.addEventListener('mouseleave', () => {
                item.style.backgroundColor = 'transparent';
            });

            this.completionPopup.appendChild(item);
        });

        // Position popup
        const rect = this.textarea.getBoundingClientRect();
        const scrollTop = this.textarea.scrollTop;
        const lineHeight = this.getLineHeight();
        const line = this.getCurrentLineNumber();

        this.completionPopup.style.top = (rect.top + (line * lineHeight) - scrollTop - 200) + 'px';
        this.completionPopup.style.left = (rect.left + 70) + 'px';
        this.completionPopup.style.display = 'block';
    }

    /**
     * Hide code completions
     */
    hideCompletions() {
        this.showingCompletions = false;
        this.completionPopup.style.display = 'none';
    }

    /**
     * Navigate completions with keyboard
     */
    navigateCompletions(e) {
        if (!this.showingCompletions || this.currentCompletions.length === 0) return;

        const items = this.completionPopup.querySelectorAll('.completion-item');
        let selectedIndex = Array.from(items).findIndex(item =>
            item.classList.contains('selected'));

        if (e.key === 'ArrowDown') {
            e.preventDefault();
            selectedIndex = (selectedIndex + 1) % items.length;
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            selectedIndex = selectedIndex <= 0 ? items.length - 1 : selectedIndex - 1;
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (selectedIndex >= 0 && selectedIndex < this.currentCompletions.length) {
                this.insertCompletion(this.currentCompletions[selectedIndex]);
            }
            return;
        }

        items.forEach(item => item.classList.remove('selected'));
        if (selectedIndex >= 0 && selectedIndex < items.length) {
            items[selectedIndex].classList.add('selected');
        }
    }

    /**
     * Insert a completion
     */
    insertCompletion(completion) {
        const position = this.getCursorPosition();
        const content = this.textarea.value;

        // Find word boundaries
        const beforeCursor = content.substring(0, position);
        const afterCursor = content.substring(position);

        // Find start of current word
        const wordStart = beforeCursor.search(/\w+$/);
        if (wordStart === -1) return;

        // Replace current word with completion
        const newBeforeCursor = beforeCursor.substring(0, wordStart);
        const newAfterCursor = afterCursor;

        const newContent = newBeforeCursor + completion.text + newAfterCursor;
        this.textarea.value = newContent;

        // Set cursor position
        const newPosition = wordStart + completion.text.length;
        this.setCursorPosition(newPosition);

        this.hideCompletions();
        this.onTextChange();
    }

    /**
     * Initialize auto-save
     */
    initAutoSave() {
        this.autoSaveTimer = null;
        this.autoSaveInterval = 30000; // 30 seconds

        this.onChange(() => {
            if (this.autoSaveTimer) {
                clearTimeout(this.autoSaveTimer);
            }
            this.autoSaveTimer = setTimeout(() => {
                this.autoSave();
            }, this.autoSaveInterval);
        });
    }

    /**
     * Auto-save current content
     */
    autoSave() {
        if (!this.isDirty) return;

        console.log('Auto-saving...');
        this.triggerSave();
    }

    /**
     * Update line numbers
     */
    updateLineNumbers() {
        if (!this.lineNumbersEl) return;

        const lines = this.textarea.value.split('\n').length;
        let lineNumbers = '';

        for (let i = 1; i <= lines; i++) {
            lineNumbers += i + '\n';
        }

        this.lineNumbersEl.textContent = lineNumbers;
        this.lineNumbersEl.scrollTop = this.textarea.scrollTop;
    }

    /**
     * Update cursor position
     */
    updateCursorPosition() {
        const position = this.textarea.selectionStart;
        const lines = this.textarea.value.substring(0, position).split('\n');

        this.cursorPosition = {
            line: lines.length,
            column: lines[lines.length - 1].length + 1
        };
    }

    /**
     * Get cursor position
     */
    getCursorPosition() {
        return this.textarea.selectionStart;
    }

    /**
     * Set cursor position
     */
    setCursorPosition(position) {
        this.textarea.setSelectionRange(position, position);
        this.updateCursorPosition();
        this.updateCursorDisplay();
    }

    /**
     * Update cursor display
     */
    updateCursorDisplay() {
        // Update status bar with cursor position
        const statusElement = document.getElementById('cursor-position');
        if (statusElement) {
            statusElement.textContent = `Line ${this.cursorPosition.line}, Col ${this.cursorPosition.column}`;
        }
    }

    /**
     * Update scroll position
     */
    updateScrollPosition() {
        this.scrollPosition = {
            top: this.textarea.scrollTop,
            left: this.textarea.scrollLeft
        };
    }

    /**
     * Update scroll display
     */
    updateScrollDisplay() {
        // Update syntax highlighting overlay scroll
        if (this.highlightOverlay) {
            this.highlightOverlay.scrollTop = this.textarea.scrollTop;
            this.highlightOverlay.scrollLeft = this.textarea.scrollLeft;
        }

        // Update line numbers scroll
        if (this.lineNumbersEl) {
            this.lineNumbersEl.scrollTop = this.textarea.scrollTop;
        }
    }

    /**
     * Update scroll synchronization
     */
    updateScrollSynchronization() {
        // Ensure all elements stay in sync
        this.updateScrollDisplay();
    }

    /**
     * Update code metrics
     */
    updateCodeMetrics() {
        const content = this.textarea.value;
        const lines = content.split('\n');

        this.codeMetrics = {
            lines: lines.length,
            characters: content.length,
            functions: this.countPatterns(content, /\bdef\b/g),
            classes: this.countPatterns(content, /\bclass\b/g),
            comments: this.countPatterns(content, /#.*$/gm)
        };
    }

    /**
     * Count patterns in text
     */
    countPatterns(text, pattern) {
        const matches = text.match(pattern);
        return matches ? matches.length : 0;
    }

    /**
     * Get current line number
     */
    getCurrentLineNumber() {
        return this.cursorPosition.line - 1;
    }

    /**
     * Get line height
     */
    getLineHeight() {
        const computed = window.getComputedStyle(this.textarea);
        const lineHeight = parseFloat(computed.lineHeight);
        return isNaN(lineHeight) ? 20 : lineHeight;
    }

    /**
     * Insert text with auto-indentation
     */
    insertTextWithAutoIndent() {
        const position = this.getCursorPosition();
        const content = this.textarea.value;
        const lines = content.substring(0, position).split('\n');
        const currentLine = lines[lines.length - 1];

        // Calculate indentation level
        const indentMatch = currentLine.match(/^\s*/);
        const currentIndent = indentMatch ? indentMatch[0].length : 0;

        // Check if current line ends with colon (indicating block)
        const hasBlock = currentLine.trim().endsWith(':');
        const newIndent = hasBlock ? currentIndent + 4 : currentIndent;

        // Insert new line with proper indentation
        const newLine = '\n' + ' '.repeat(newIndent);
        this.insertText(newLine);
    }

    /**
     * Insert text at cursor position
     */
    insertText(text) {
        const position = this.getCursorPosition();
        const content = this.textarea.value;

        const newContent = content.substring(0, position) + text + content.substring(position);
        this.textarea.value = newContent;

        const newPosition = position + text.length;
        this.setCursorPosition(newPosition);

        this.onTextChange();
    }

    /**
     * Get editor content
     */
    getContent() {
        return this.textarea ? this.textarea.value : '';
    }

    /**
     * Set editor content
     */
    setContent(content) {
        if (this.textarea) {
            this.textarea.value = content;
            this.isDirty = false;
            this.updateSyntaxHighlighting();
            this.updateLineNumbers();
            this.updateCodeMetrics();
            this.onTextChange();
        }
    }

    /**
     * Set language
     */
    setLanguage(language) {
        this.options.language = language;
        this.highlighter.setLanguage(language);
        this.updateSyntaxHighlighting();
    }

    /**
     * Set theme
     */
    setTheme(theme) {
        this.options.theme = theme;
        // Theme changes can be applied here
    }

    /**
     * Focus the editor
     */
    focus() {
        if (this.textarea) {
            this.textarea.focus();
        }
    }

    /**
     * Save the current file
     */
    save() {
        this.triggerSave();
    }

    /**
     * Event trigger methods
     */
    triggerChange() {
        this.onChange.forEach(callback => callback(this.getContent(), this));
    }

    triggerSave() {
        const content = this.getContent();
        this.isDirty = false;
        this.onSave.forEach(callback => callback(content, this));
    }

    triggerCursorChange() {
        this.onCursorChange.forEach(callback => callback(this.cursorPosition, this));
    }

    /**
     * Add event listeners
     */
    onChange(callback) {
        this.onChange.push(callback);
    }

    onSave(callback) {
        this.onSave.push(callback);
    }

    onError(callback) {
        this.onError.push(callback);
    }

    onCompletion(callback) {
        this.onCompletion.push(callback);
    }

    onCursorChange(callback) {
        this.onCursorChange.push(callback);
    }

    /**
     * Utility method for debouncing
     */
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    /**
     * Get editor statistics
     */
    getStatistics() {
        return {
            ...this.codeMetrics,
            cursorPosition: this.cursorPosition,
            isDirty: this.isDirty,
            hasFocus: this.hasFocus
        };
    }

    /**
     * Cleanup
     */
    destroy() {
        if (this.autoSaveTimer) {
            clearTimeout(this.autoSaveTimer);
        }

        this.onChange = [];
        this.onSave = [];
        this.onError = [];
        this.onCompletion = [];
        this.onCursorChange = [];

        if (this.container) {
            this.container.innerHTML = '';
        }
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CodeEditor;
} else if (typeof window !== 'undefined') {
    window.CodeEditor = CodeEditor;
}