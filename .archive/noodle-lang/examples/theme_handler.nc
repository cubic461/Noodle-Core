# """
# Theme Handler for NoodleCore Web Server
# 
# This module handles theme-related requests including dark and light theme CSS.
# """

import typing
import logging
import time
import uuid
import json
from .. import ThemeError


class ThemeHandler:
    # """
    # Handler for theme operations.
    # """
    
    def __init__(self):
        # """Initialize the theme handler."""
        self.logger = logging.getLogger(__name__)
        self.themes = {
            "dark": self._generate_dark_theme(),
            "light": self._generate_light_theme()
        }
        
    def get_theme(self, theme_name: str) -> "HTTPResponse":
        # """
        # Get theme CSS.
        
        Args:
            theme_name: Name of theme
            
        Returns:
            HTTP response with theme CSS
        """
        try:
            if theme_name in self.themes:
                css_content = self.themes[theme_name]
                return self._create_css_response(200, css_content)
            else:
                return self._create_error_response(404, f"Theme '{theme_name}' not found")
                
        except Exception as e:
            self.logger.error(f"Error getting theme {theme_name}: {str(e)}")
            return self._create_error_response(500, f"Theme error: {str(e)}")
    
    def handle_request(self, request) -> "HTTPResponse":
        # """
        # Handle theme request.
        
        Args:
            request: HTTP request
            
        Returns:
            HTTP response
        """
        try:
            # Extract theme name from path
            theme_name = self._extract_theme_name(request.path)
            return self.get_theme(theme_name)
            
        except Exception as e:
            self.logger.error(f"Error handling theme request: {str(e)}")
            return self._create_error_response(500, f"Theme request error: {str(e)}")
    
    def _extract_theme_name(self, path: str) -> str:
        # """
        # Extract theme name from request path.
        
        Args:
            path: Request path
            
        Returns:
            Theme name
        """
        if "dark.css" in path:
            return "dark"
        elif "light.css" in path:
            return "light"
        else:
            # Default to dark theme
            return "dark"
    
    def _generate_dark_theme(self) -> str:
        # """Generate dark theme CSS."""
        return """/* NoodleCore Dark Theme */
:root {
    --primary-bg: #1e1e1e;
    --secondary-bg: #252526;
    --tertiary-bg: #2d2d30;
    --border-color: #3e3e42;
    --text-primary: #d4d4d4;
    --text-secondary: #cccccc;
    --text-muted: #999999;
    --accent-color: #007acc;
    --success-color: #4ec9b0;
    --warning-color: #ffcc02;
    --error-color: #f48771;
    
    --sidebar-width: 250px;
    --status-bar-height: 24px;
}

body {
    background-color: var(--primary-bg);
    color: var(--text-primary);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.ide-container {
    background-color: var(--primary-bg);
}

.file-explorer {
    background-color: var(--secondary-bg);
    border-right: 1px solid var(--border-color);
}

.explorer-header {
    background-color: var(--tertiary-bg);
    border-bottom: 1px solid var(--border-color);
}

.file-tree {
    background-color: var(--secondary-bg);
}

.file-item {
    color: var(--text-secondary);
}

.file-item:hover {
    background-color: var(--tertiary-bg);
}

.file-item.selected {
    background-color: var(--accent-color);
}

.editor-area {
    background-color: var(--primary-bg);
}

.editor-header {
    background-color: var(--tertiary-bg);
    border-bottom: 1px solid var(--border-color);
}

.editor-tab {
    background-color: var(--secondary-bg);
    border-right: 1px solid var(--border-color);
    color: var(--text-secondary);
}

.editor-tab.active {
    background-color: var(--primary-bg);
    color: var(--text-primary);
}

.status-bar {
    background-color: var(--accent-color);
    color: white;
}

.control-btn {
    color: var(--text-secondary);
}

.control-btn:hover {
    background-color: var(--tertiary-bg);
    color: var(--text-primary);
}

.search-input {
    background-color: var(--tertiary-bg);
    border: 1px solid var(--border-color);
    color: var(--text-primary);
}

.search-input:focus {
    border-color: var(--accent-color);
    box-shadow: 0 0 0 1px var(--accent-color);
}

.toast {
    background-color: var(--secondary-bg);
    color: var(--text-primary);
    border: 1px solid var(--border-color);
}

.toast.success {
    border-left: 4px solid var(--success-color);
}

.toast.error {
    border-left: 4px solid var(--error-color);
}

.toast.warning {
    border-left: 4px solid var(--warning-color);
}

.toast.info {
    border-left: 4px solid var(--accent-color);
}

/* Monaco Editor Dark Theme */
.monaco-editor {
    background-color: var(--primary-bg) !important;
}

.monaco-editor .monaco-editor-background {
    background-color: var(--primary-bg) !important;
}

.monaco-editor .view-lines {
    color: var(--text-primary) !important;
}

.monaco-editor .current-line {
    background-color: rgba(255, 255, 255, 0.02) !important;
}

/* Code syntax highlighting for dark theme */
.monaco-editor .mtk1 { color: #d4d4d4; }
.monaco-editor .mtk2 { color: #569cd6; }
.monaco-editor .mtk3 { color: #ce9178; }
.monaco-editor .mtk4 { color: #b5cea8; }
.monaco-editor .mtk5 { color: #dcdcaa; }
.monaco-editor .mtk6 { color: #9cdcfe; }
.monaco-editor .mtk7 { color: #c586c0; }
.monaco-editor .mtk8 { color: #f44747; }
.monaco-editor .mtk9 { color: #4ec9b0; }
"""
    
    def _generate_light_theme(self) -> str:
        # """Generate light theme CSS."""
        return """/* NoodleCore Light Theme */
:root {
    --primary-bg: #ffffff;
    --secondary-bg: #f8f9fa;
    --tertiary-bg: #f1f3f4;
    --border-color: #dadce0;
    --text-primary: #202124;
    --text-secondary: #5f6368;
    --text-muted: #9aa0a6;
    --accent-color: #1976d2;
    --success-color: #2e7d32;
    --warning-color: #f57c00;
    --error-color: #d32f2f;
    
    --sidebar-width: 250px;
    --status-bar-height: 24px;
}

body {
    background-color: var(--primary-bg);
    color: var(--text-primary);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.ide-container {
    background-color: var(--primary-bg);
}

.file-explorer {
    background-color: var(--secondary-bg);
    border-right: 1px solid var(--border-color);
}

.explorer-header {
    background-color: var(--tertiary-bg);
    border-bottom: 1px solid var(--border-color);
}

.file-tree {
    background-color: var(--secondary-bg);
}

.file-item {
    color: var(--text-secondary);
}

.file-item:hover {
    background-color: var(--tertiary-bg);
}

.file-item.selected {
    background-color: var(--accent-color);
    color: white;
}

.editor-area {
    background-color: var(--primary-bg);
}

.editor-header {
    background-color: var(--tertiary-bg);
    border-bottom: 1px solid var(--border-color);
}

.editor-tab {
    background-color: var(--secondary-bg);
    border-right: 1px solid var(--border-color);
    color: var(--text-secondary);
}

.editor-tab.active {
    background-color: var(--primary-bg);
    color: var(--text-primary);
}

.status-bar {
    background-color: var(--accent-color);
    color: white;
}

.control-btn {
    color: var(--text-secondary);
}

.control-btn:hover {
    background-color: var(--tertiary-bg);
    color: var(--text-primary);
}

.search-input {
    background-color: var(--tertiary-bg);
    border: 1px solid var(--border-color);
    color: var(--text-primary);
}

.search-input:focus {
    border-color: var(--accent-color);
    box-shadow: 0 0 0 1px var(--accent-color);
}

.toast {
    background-color: var(--secondary-bg);
    color: var(--text-primary);
    border: 1px solid var(--border-color);
}

.toast.success {
    border-left: 4px solid var(--success-color);
}

.toast.error {
    border-left: 4px solid var(--error-color);
}

.toast.warning {
    border-left: 4px solid var(--warning-color);
}

.toast.info {
    border-left: 4px solid var(--accent-color);
}

/* Monaco Editor Light Theme */
.monaco-editor {
    background-color: var(--primary-bg) !important;
}

.monaco-editor .monaco-editor-background {
    background-color: var(--primary-bg) !important;
}

.monaco-editor .view-lines {
    color: var(--text-primary) !important;
}

.monaco-editor .current-line {
    background-color: rgba(0, 0, 0, 0.02) !important;
}

/* Code syntax highlighting for light theme */
.monaco-editor .mtk1 { color: #24292e; }
.monaco-editor .mtk2 { color: #005cc5; }
.monaco-editor .mtk3 { color: #d73a49; }
.monaco-editor .mtk4 { color: #032f62; }
.monaco-editor .mtk5 { color: #6f42c1; }
.monaco-editor .mtk6 { color: #005cc5; }
.monaco-editor .mtk7 { color: #e36209; }
.monaco-editor .mtk8 { color: #6a737d; }
.monaco-editor .mtk9 { color: #22863a; }
"""
    
    def _create_css_response(self, status_code: int, css_content: str) -> "HTTPResponse":
        # """
        # Create CSS response.
        
        Args:
            status_code: HTTP status code
            css_content: CSS content
            
        Returns:
            HTTP response
        """
        # Import here to avoid circular dependency
        from ..web_server import HTTPResponse
        
        return HTTPResponse(
            status_code=status_code,
            headers={
                "Content-Type": "text/css",
                "Cache-Control": "max-age=3600"
            },
            body=css_content
        )
    
    def _create_error_response(self, status_code: int, message: str) -> "HTTPResponse":
        # """
        # Create error response.
        
        Args:
            status_code: HTTP status code
            message: Error message
            
        Returns:
            HTTP response
        """
        # Import here to avoid circular dependency
        from ..web_server import HTTPResponse
        
        return HTTPResponse(
            status_code=status_code,
            headers={"Content-Type": "text/html"},
            body=f"<html><body><h1>{status_code}</h1><p>{message}</p></body></html>"
        )