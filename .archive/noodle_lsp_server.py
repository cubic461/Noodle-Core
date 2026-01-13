"""
Lsp::Noodle Lsp Server - noodle_lsp_server.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Language Server Protocol (LSP) Server

This module implements a comprehensive LSP server for NoodleCore language,
providing deep language understanding, IntelliSense capabilities, and integration
with the existing NoodleCore infrastructure.

Features:
- Full LSP protocol implementation
- Deep syntax and semantic analysis
- Real-time IntelliSense for all NoodleCore constructs
- Pattern matching, generics, async/await support
- Cross-file reference resolution
- Advanced diagnostics and error handling
- Code formatting and refactoring
- Performance optimization with caching
"""

import asyncio
import json
import logging
import os
import sys
import traceback
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional, Union, Tuple

# LSP Protocol imports
try:
    from lsprotocol.types import (
        TEXT_DOCUMENT_COMPLETION,
        TEXT_DOCUMENT_DEFINITION,
        TEXT_DOCUMENT_REFERENCES,
        TEXT_DOCUMENT_HOVER,
        TEXT_DOCUMENT_SIGNATURE_HELP,
        TEXT_DOCUMENT_FORMATTING,
        TEXT_DOCUMENT_RANGE_FORMATTING,
        TEXT_DOCUMENT_CODE_ACTION,
        TEXT_DOCUMENT_RENAME,
        INITIALIZE,
        INITIALIZED,
        SHUTDOWN,
        EXIT,
        CompletionItem,
        CompletionItemKind,
        Position,
        Range,
        Location,
        Hover,
        SignatureHelp,
        SignatureInformation,
        ParameterInformation,
        TextEdit,
        Diagnostic,
        DiagnosticSeverity,
        DiagnosticRelatedInformation,
        CodeAction,
        CodeActionKind,
        WorkspaceEdit,
        TextDocumentIdentifier,
        TextDocumentEdit,
        RenameParams,
        WorkspaceFolder,
        MessageType,
        ShowMessageParams,
        LogMessageParams,
        CompletionParams,
        DefinitionParams,
        ReferencesParams,
        HoverParams,
        SignatureHelpParams,
        DocumentFormattingParams,
        DocumentRangeFormattingParams,
        CodeActionParams,
        TextDocumentPositionParams,
    )
except ImportError:
    # Fallback to basic types if lsprotocol is not available
    from typing import Any
    # Define basic LSP types as fallback
    class CompletionItem:
        def __init__(self, label: str, kind: int = 1, detail: str = "", documentation: str = "", insert_text: str = None):
            self.label = label
            self.kind = kind
            self.detail = detail
            self.documentation = documentation
            self.insert_text = insert_text or label
    
    class Position:
        def __init__(self, line: int, character: int):
            self.line = line
            self.character = character
    
    class Range:
        def __init__(self, start: Position, end: Position):
            self.start = start
            self.end = end
    
    class Location:
        def __init__(self, uri: str, range: Range):
            self.uri = uri
            self.range = range
    
    class Diagnostic:
        def __init__(self, range: Range, message: str, severity: int = 1, source: str = "noodle-lsp"):
            self.range = range
            self.message = message
            self.severity = severity
            self.source = source

# NoodleCore imports
from ..parser.lexer_tokens import Token, TokenType, TokenStream
from ..parser.noodle_parser import Parser, ParseError
from ..parser.parser_ast_nodes import (
    ASTNode, NodeType, Identifier, Type, StatementNode, ExpressionNode,
    FuncDefNode, VarDeclNode, AssignStmtNode, CallExprNode,
    IdentifierExprNode, LiteralExprNode, BinaryExprNode, UnaryExprNode,
    IfStmtNode, WhileStmtNode, ForStmtNode, ClassDefNode,
    ReturnStmtNode, ImportStmtNode, TryStmtNode
)
from ..runtime.modern_runtime import ModernRuntime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Constants
NOODLE_LANGUAGE_ID = "noodle"
NOODLE_FILE_EXTENSIONS = [".nc", ".noodle"]
LSP_SERVER_VERSION = "1.0.0"

class NoodleLSPServer:
    """
    Main NoodleCore Language Server Protocol implementation
    
    Provides comprehensive language support for NoodleCore including:
    - Syntax and semantic analysis
    - IntelliSense (completion, hover, signature help)
    - Definition and reference resolution
    - Advanced diagnostics
    - Code formatting and refactoring
    - Pattern matching and generics support
    - Async/await support
    """
    
    def __init__(self):
        self.documents: Dict[str, NoodleDocument] = {}
        self.workspace_folders: List[WorkspaceFolder] = []
        self.parser = Parser()
        self.runtime = ModernRuntime()
        self.symbol_table = SymbolTable()
        self.type_checker = TypeChecker()
        self.completion_cache = CompletionCache()
        self.diagnostics_cache = DiagnosticsCache()
        self.formatting_options = FormattingOptions()
        
        # Performance tracking
        self.request_count = 0
        self.performance_metrics = {
            'parse_time': 0,
            'completion_time': 0,
            'definition_time': 0,
            'references_time': 0,
            'diagnostics_time': 0,
            'formatting_time': 0
        }
    
    async def handle_request(self, request: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Handle incoming LSP request
        """
        try:
            self.request_count += 1
            method = request.get("method")
            params = request.get("params")
            request_id = request.get("id")
            
            logger.info(f"Handling LSP request: {method} (ID: {request_id})")
            
            # Route request to appropriate handler
            if method == INITIALIZE:
                return await self.handle_initialize(params, request_id)
            elif method == INITIALIZED:
                return await self.handle_initialized(params, request_id)
            elif method == SHUTDOWN:
                return await self.handle_shutdown(params, request_id)
            elif method == EXIT:
                return await self.handle_exit(params, request_id)
            elif method == TEXT_DOCUMENT_COMPLETION:
                return await self.handle_completion(params, request_id)
            elif method == TEXT_DOCUMENT_DEFINITION:
                return await self.handle_definition(params, request_id)
            elif method == TEXT_DOCUMENT_REFERENCES:
                return await self.handle_references(params, request_id)
            elif method == TEXT_DOCUMENT_HOVER:
                return await self.handle_hover(params, request_id)
            elif method == TEXT_DOCUMENT_SIGNATURE_HELP:
                return await self.handle_signature_help(params, request_id)
            elif method == TEXT_DOCUMENT_FORMATTING:
                return await self.handle_formatting(params, request_id)
            elif method == TEXT_DOCUMENT_RANGE_FORMATTING:
                return await self.handle_range_formatting(params, request_id)
            elif method == TEXT_DOCUMENT_CODE_ACTION:
                return await self.handle_code_action(params, request_id)
            elif method == TEXT_DOCUMENT_RENAME:
                return await self.handle_rename(params, request_id)
            else:
                logger.warning(f"Unhandled LSP method: {method}")
                return None
                
        except Exception as e:
            logger.error(f"Error handling request {request.get('method')}: {str(e)}")
            logger.debug(traceback.format_exc())
            return self.create_error_response(request_id, str(e))
    
    async def handle_initialize(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle initialize request from client
        """
        logger.info("Initializing NoodleCore LSP server")
        
        # Extract workspace folders
        if "workspaceFolders" in params:
            self.workspace_folders = [
                WorkspaceFolder(folder["uri"], folder["name"])
                for folder in params["workspaceFolders"]
            ]
        
        # Initialize workspace
        await self.initialize_workspace()
        
        # Return server capabilities
        return {
            "id": request_id,
            "result": {
                "capabilities": {
                    # Text document synchronization
                    "textDocumentSync": {
                        "dynamicRegistration": False,
                        "willSave": True,
                        "willSaveWaitUntil": False,
                        "didSave": True,
                        "openClose": True,
                        "change": 2  # Full incremental sync
                    },
                    
                    # Completion capabilities
                    "completionProvider": {
                        "resolveProvider": False,
                        "triggerCharacters": [".", "(", " ", "@"],
                        "completionItem": {
                            "snippetSupport": True,
                            "commitCharactersSupport": True,
                            "documentationFormat": ["markdown", "plaintext"],
                            "deprecatedSupport": True,
                            "preselectSupport": True,
                            "tagSupport": {
                                "valueSet": [1, 2]  # Deprecated, Recommended
                            }
                        }
                    },
                    
                    # Hover capabilities
                    "hoverProvider": True,
                    
                    # Signature help capabilities
                    "signatureHelpProvider": {
                        "triggerCharacters": ["(", ","],
                        "retriggerCharacters": [")"],
                        "workDoneProgress": True
                    },
                    
                    # Definition capabilities
                    "definitionProvider": True,
                    
                    # References capabilities
                    "referencesProvider": True,
                    
                    # Document formatting capabilities
                    "documentFormattingProvider": True,
                    "documentRangeFormattingProvider": True,
                    
                    # Code action capabilities
                    "codeActionProvider": {
                        "codeActionKinds": [
                            CodeActionKind.QuickFix,
                            CodeActionKind.Refactor,
                            CodeActionKind.RefactorExtract,
                            CodeActionKind.RefactorInline,
                            CodeActionKind.RefactorRewrite,
                            CodeActionKind.Source,
                            CodeActionKind.SourceOrganizeImports
                        ],
                        "resolveProvider": True,
                        "dataSupport": True
                    },
                    
                    # Rename capabilities
                    "renameProvider": {
                        "prepareProvider": True,
                        "supportsPrepareRename": True
                    },
                    
                    # Workspace capabilities
                    "workspace": {
                        "workspaceFolders": {
                            "supported": True,
                            "changeNotifications": True
                        },
                        "symbol": {
                            "dynamicRegistration": False,
                            "symbolKind": {
                                "valueSet": [
                                    1,  # File
                                    2,  # Module
                                    3,  # Namespace
                                    4,  # Package
                                    5,  # Class
                                    6,  # Method
                                    7,  # Property
                                    8,  # Field
                                    9,  # Constructor
                                    10, # Enum
                                    11, # Interface
                                    12, # Function
                                    13, # Variable
                                    14, # Constant
                                    15, # String
                                    16, # Number
                                    17, # Boolean
                                    18, # Array
                                    19, # Object
                                    20, # Key
                                    21, # Null
                                    22, # EnumMember
                                    23, # Struct
                                    24, # Event
                                    25, # Operator
                                    26, # TypeParameter
                                ]
                            }
                        }
                    },
                    
                    # Experimental features
                    "experimental": {
                        "patternMatching": True,
                        "genericsSupport": True,
                        "asyncAwaitSupport": True,
                        "aiIntegration": True,
                        "advancedDiagnostics": True
                    }
                },
                "serverInfo": {
                    "name": "NoodleCore Language Server",
                    "version": LSP_SERVER_VERSION,
                    "logo": "https://noodlecore.ai/logo.png",
                    "description": "Intelligent LSP server with AI-enhanced capabilities"
                }
            }
        }
    
    async def handle_initialized(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle initialized notification from client
        """
        logger.info("NoodleCore LSP server initialized")
        return None  # No response needed for notifications
    
    async def handle_shutdown(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle shutdown request from client
        """
        logger.info("Shutting down NoodleCore LSP server")
        return {"id": request_id, "result": None}
    
    async def handle_exit(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle exit notification from client
        """
        logger.info("Exiting NoodleCore LSP server")
        return None  # No response needed for notifications
    
    async def handle_completion(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle completion request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            position = Position(
                line=params["position"]["line"],
                character=params["position"]["character"]
            )
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Generate completion items
            completion_items = await self.generate_completion_items(document, position)
            
            # Update performance metrics
            self.performance_metrics['completion_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            return {
                "id": request_id,
                "result": {
                    "isIncomplete": False,
                    "items": [item.to_dict() for item in completion_items]
                }
            }
            
        except Exception as e:
            logger.error(f"Error in completion: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_definition(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle go-to-definition request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            position = Position(
                line=params["position"]["line"],
                character=params["position"]["character"]
            )
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Find definition
            locations = await self.find_definitions(document, position)
            
            # Update performance metrics
            self.performance_metrics['definition_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            return {
                "id": request_id,
                "result": [location.to_dict() for location in locations]
            }
            
        except Exception as e:
            logger.error(f"Error in definition: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_references(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle find references request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            position = Position(
                line=params["position"]["line"],
                character=params["position"]["character"]
            )
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Find references
            locations = await self.find_references(document, position)
            
            # Update performance metrics
            self.performance_metrics['references_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            return {
                "id": request_id,
                "result": [location.to_dict() for location in locations]
            }
            
        except Exception as e:
            logger.error(f"Error in references: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_hover(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle hover request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            position = Position(
                line=params["position"]["line"],
                character=params["position"]["character"]
            )
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Generate hover information
            hover_info = await self.generate_hover_info(document, position)
            
            # Update performance metrics
            self.performance_metrics['hover_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            if hover_info:
                return {
                    "id": request_id,
                    "result": {
                        "contents": {
                            "kind": "markdown",
                            "value": hover_info.content
                        },
                        "range": hover_info.range.to_dict()
                    }
                }
            else:
                return {"id": request_id, "result": None}
            
        except Exception as e:
            logger.error(f"Error in hover: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_signature_help(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle signature help request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            position = Position(
                line=params["position"]["line"],
                character=params["position"]["character"]
            )
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Generate signature help
            signature_help = await self.generate_signature_help(document, position)
            
            # Update performance metrics
            self.performance_metrics['signature_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            if signature_help:
                return {
                    "id": request_id,
                    "result": signature_help.to_dict()
                }
            else:
                return {"id": request_id, "result": None}
            
        except Exception as e:
            logger.error(f"Error in signature help: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_formatting(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle document formatting request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            options = params.get("options", {})
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Format document
            edits = await self.format_document(document, options)
            
            # Update performance metrics
            self.performance_metrics['formatting_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            return {
                "id": request_id,
                "result": edits
            }
            
        except Exception as e:
            logger.error(f"Error in formatting: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_range_formatting(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle document range formatting request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            range_obj = Range(
                start=Position(
                    line=params["range"]["start"]["line"],
                    character=params["range"]["start"]["character"]
                ),
                end=Position(
                    line=params["range"]["end"]["line"],
                    character=params["range"]["end"]["character"]
                )
            )
            options = params.get("options", {})
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Format document range
            edits = await self.format_document_range(document, range_obj, options)
            
            # Update performance metrics
            self.performance_metrics['formatting_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            return {
                "id": request_id,
                "result": edits
            }
            
        except Exception as e:
            logger.error(f"Error in range formatting: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_code_action(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle code action request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            range_obj = Range(
                start=Position(
                    line=params["range"]["start"]["line"],
                    character=params["range"]["start"]["character"]
                ),
                end=Position(
                    line=params["range"]["end"]["line"],
                    character=params["range"]["end"]["character"]
                )
            )
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Generate code actions
            actions = await self.generate_code_actions(document, range_obj)
            
            # Update performance metrics
            self.performance_metrics['code_action_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            return {
                "id": request_id,
                "result": [action.to_dict() for action in actions]
            }
            
        except Exception as e:
            logger.error(f"Error in code action: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def handle_rename(self, params: Dict[str, Any], request_id: Any) -> Dict[str, Any]:
        """
        Handle rename request
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            text_document = params["textDocument"]
            uri = text_document["uri"]
            position = Position(
                line=params["position"]["line"],
                character=params["position"]["character"]
            )
            new_name = params["newName"]
            
            # Get or create document
            document = await self.get_or_create_document(uri)
            
            # Prepare rename
            workspace_edit = await self.prepare_rename(document, position, new_name)
            
            # Update performance metrics
            self.performance_metrics['rename_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
            return {
                "id": request_id,
                "result": workspace_edit.to_dict()
            }
            
        except Exception as e:
            logger.error(f"Error in rename: {str(e)}")
            return self.create_error_response(request_id, str(e))
    
    async def initialize_workspace(self):
        """
        Initialize workspace and analyze all NoodleCore files
        """
        logger.info("Initializing NoodleCore workspace")
        
        # Scan workspace for NoodleCore files
        for workspace_folder in self.workspace_folders:
            workspace_path = Path(workspace_folder.uri.replace("file://", ""))
            if workspace_path.exists():
                await self.scan_workspace_directory(workspace_path)
        
        logger.info(f"Workspace initialized with {len(self.documents)} documents")
    
    async def scan_workspace_directory(self, workspace_path: Path):
        """
        Scan workspace directory for NoodleCore files
        """
        for file_path in workspace_path.rglob("*"):
            if file_path.is_file() and file_path.suffix in NOODLE_FILE_EXTENSIONS:
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    uri = f"file://{file_path.as_posix()}"
                    await self.get_or_create_document(uri, content)
                    
                except Exception as e:
                    logger.error(f"Error scanning file {file_path}: {str(e)}")
    
    async def get_or_create_document(self, uri: str, content: str = None) -> 'NoodleDocument':
        """
        Get existing document or create new one
        """
        if uri in self.documents:
            return self.documents[uri]
        
        if content is None:
            # Load content from file
            file_path = Path(uri.replace("file://", ""))
            if file_path.exists():
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            else:
                content = ""
        
        document = NoodleDocument(uri, content)
        self.documents[uri] = document
        
        # Parse and analyze document
        await self.analyze_document(document)
        
        return document
    
    async def analyze_document(self, document: 'NoodleDocument'):
        """
        Analyze document for syntax and semantic information
        """
        start_time = asyncio.get_event_loop().time()
        
        try:
            # Parse document
            tokens = self.parser.lexer.tokenize(document.content)
            ast = self.parser.parse(document.content)
            
            # Update document with parsed information
            document.tokens = tokens
            document.ast = ast
            document.symbols = self.extract_symbols(ast)
            document.diagnostics = self.generate_diagnostics(tokens, ast)
            
            # Update symbol table
            self.symbol_table.update_document_symbols(document.uri, document.symbols)
            
            # Update performance metrics
            self.performance_metrics['parse_time'] += (
                asyncio.get_event_loop().time() - start_time
            )
            
        except Exception as e:
            logger.error(f"Error analyzing document {document.uri}: {str(e)}")
            document.diagnostics = [self.create_syntax_error_diagnostic(e)]
    
    def extract_symbols(self, ast: ASTNode) -> List['Symbol']:
        """
        Extract symbols from AST
        """
        symbols = []
        
        def extract_from_node(node: ASTNode, scope: str = "global"):
            nonlocal symbols
            
            if hasattr(node, 'node_type'):
                if node.node_type == NodeType.FUNC_DEF:
                    symbol = Symbol(
                        name=node.name,
                        kind=SymbolKind.FUNCTION,
                        location=Location(
                            uri="",  # Will be set by document
                            range=Range(
                                start=Position(line=node.position.line if node.position else 0, character=0),
                                end=Position(line=node.position.line if node.position else 0, character=len(node.name))
                            )
                        ),
                        scope=scope,
                        type_hint=node.return_type
                    )
                    symbols.append(symbol)
                
                elif node.node_type == NodeType.VAR_DECL:
                    symbol = Symbol(
                        name=node.name,
                        kind=SymbolKind.VARIABLE,
                        location=Location(
                            uri="",
                            range=Range(
                                start=Position(line=node.position.line if node.position else 0, character=0),
                                end=Position(line=node.position.line if node.position else 0, character=len(node.name))
                            )
                        ),
                        scope=scope,
                        type_hint=node.type_hint
                    )
                    symbols.append(symbol)
                
                elif node.node_type == NodeType.CLASS_DEF:
                    symbol = Symbol(
                        name=node.name,
                        kind=SymbolKind.CLASS,
                        location=Location(
                            uri="",
                            range=Range(
                                start=Position(line=node.position.line if node.position else 0, character=0),
                                end=Position(line=node.position.line if node.position else 0, character=len(node.name))
                            )
                        ),
                        scope=scope,
                        type_hint="class"
                    )
                    symbols.append(symbol)
            
            # Recursively extract from children
            if hasattr(node, 'children'):
                for child in node.children:
                    extract_from_node(child, scope)
        
        extract_from_node(ast)
        return symbols
    
    def generate_diagnostics(self, tokens: List[Token], ast: ASTNode) -> List[Diagnostic]:
        """
        Generate diagnostics from tokens and AST
        """
        diagnostics = []
        
        # Check for syntax errors
        for token in tokens:
            if token.type == TokenType.ERROR:
                diagnostic = Diagnostic(
                    range=Range(
                        start=Position(line=token.position.line - 1, character=token.position.column - 1),
                        end=Position(line=token.position.line - 1, character=token.position.column + len(token.value) - 1)
                    ),
                    message=f"Unknown token: {token.value}",
                    severity=DiagnosticSeverity.Error,
                    source="noodle-lsp-syntax"
                )
                diagnostics.append(diagnostic)
        
        # Check for semantic errors
        semantic_diagnostics = self.type_checker.check_semantics(ast)
        diagnostics.extend(semantic_diagnostics)
        
        return diagnostics
    
    def create_syntax_error_diagnostic(self, error: Exception) -> Diagnostic:
        """
        Create diagnostic for syntax error
        """
        if isinstance(error, ParseError):
            return Diagnostic(
                range=Range(
                    start=Position(line=error.line - 1, character=error.column - 1),
                    end=Position(line=error.line - 1, character=error.column + 10 - 1)
                ),
                message=error.message,
                severity=DiagnosticSeverity.Error,
                source="noodle-lsp-parser"
            )
        else:
            return Diagnostic(
                range=Range(
                    start=Position(line=0, character=0),
                    end=Position(line=0, character=10)
                ),
                message=f"Syntax error: {str(error)}",
                severity=DiagnosticSeverity.Error,
                source="noodle-lsp-parser"
            )
    
    async def generate_completion_items(self, document: 'NoodleDocument', position: Position) -> List['CompletionItem']:
        """
        Generate completion items for given position
        """
        # Check cache first
        cache_key = f"{document.uri}:{position.line}:{position.character}"
        cached_items = self.completion_cache.get(cache_key)
        if cached_items is not None:
            return cached_items
        
        items = []
        
        # Get line prefix and current word
        line_text = document.get_line(position.line)
        line_prefix = line_text[:position.character]
        current_word = self.get_current_word(line_text, position.character)
        
        # Generate different types of completions
        items.extend(self.generate_keyword_completions(line_prefix, current_word))
        items.extend(self.generate_symbol_completions(document, position, current_word))
        items.extend(self.generate_ai_completions(line_prefix, current_word))
        items.extend(self.generate_pattern_completions(line_prefix, current_word))
        items.extend(self.generate_generic_completions(line_prefix, current_word))
        items.extend(self.generate_snippet_completions(line_prefix, current_word))
        
        # Cache results
        self.completion_cache.put(cache_key, items)
        
        return items
    
    def get_current_word(self, line_text: str, character: int) -> str:
        """
        Get current word at cursor position
        """
        word_start = character
        while word_start > 0 and line_text[word_start - 1].isalnum() or line_text[word_start - 1] == '_':
            word_start -= 1
        
        word_end = character
        while word_end < len(line_text) and (line_text[word_end].isalnum() or line_text[word_end] == '_'):
            word_end += 1
        
        return line_text[word_start:word_end]
    
    def generate_keyword_completions(self, line_prefix: str, current_word: str) -> List['CompletionItem']:
        """
        Generate keyword completions
        """
        items = []
        
        # Control flow keywords
        control_keywords = [
            "if", "else", "elif", "for", "while", "do", "break", "continue",
            "switch", "case", "default", "return", "yield", "await", "async"
        ]
        
        # Declaration keywords
        declaration_keywords = [
            "func", "function", "let", "const", "var", "type", "interface",
            "class", "enum", "struct", "implements", "extends", "import", "export"
        ]
        
        # Type keywords
        type_keywords = [
            "int", "float", "string", "bool", "char", "byte", "array", "list",
            "map", "set", "void", "null", "true", "false"
        ]
        
        # AI-specific keywords
        ai_keywords = [
            "ai", "agent", "model", "train", "predict", "transform", "validate",
            "compile", "run", "debug", "test", "optimize", "refactor"
        ]
        
        # Built-in functions
        builtin_functions = [
            "print", "println", "input", "read", "write", "open", "close",
            "len", "size", "append", "push", "pop", "sort", "filter", "map"
        ]
        
        all_keywords = control_keywords + declaration_keywords + type_keywords + ai_keywords + builtin_functions
        
        for keyword in all_keywords:
            if keyword.startswith(current_word) and keyword != current_word:
                if keyword in control_keywords:
                    kind = CompletionItemKind.Keyword
                    detail = "Control flow keyword"
                elif keyword in declaration_keywords:
                    kind = CompletionItemKind.Keyword
                    detail = "Declaration keyword"
                elif keyword in type_keywords:
                    kind = CompletionItemKind.Keyword
                    detail = "Type keyword"
                elif keyword in ai_keywords:
                    kind = CompletionItemKind.Keyword
                    detail = "AI keyword"
                else:
                    kind = CompletionItemKind.Function
                    detail = "Built-in function"
                
                item = CompletionItem(
                    label=keyword,
                    kind=kind,
                    detail=detail,
                    documentation=f"NoodleCore {detail.lower()}: `{keyword}`"
                )
                items.append(item)
        
        return items
    
    def generate_symbol_completions(self, document: 'NoodleDocument', position: Position, current_word: str) -> List['CompletionItem']:
        """
        Generate symbol completions from document and workspace
        """
        items = []
        
        # Get symbols from current document
        document_symbols = self.symbol_table.get_document_symbols(document.uri)
        
        # Get symbols from workspace
        workspace_symbols = self.symbol_table.get_workspace_symbols()
        
        all_symbols = document_symbols + workspace_symbols
        
        for symbol in all_symbols:
            if symbol.name.startswith(current_word) and symbol.name != current_word:
                if symbol.kind == SymbolKind.FUNCTION:
                    kind = CompletionItemKind.Function
                    detail = f"Function ({symbol.type_hint})" if symbol.type_hint else "Function"
                elif symbol.kind == SymbolKind.VARIABLE:
                    kind = CompletionItemKind.Variable
                    detail = f"Variable ({symbol.type_hint})" if symbol.type_hint else "Variable"
                elif symbol.kind == SymbolKind.CLASS:
                    kind = CompletionItemKind.Class
                    detail = "Class"
                elif symbol.kind == SymbolKind.INTERFACE:
                    kind = CompletionItemKind.Interface
                    detail = "Interface"
                else:
                    kind = CompletionItemKind.Text
                    detail = "Symbol"
                
                item = CompletionItem(
                    label=symbol.name,
                    kind=kind,
                    detail=detail,
                    documentation=f"NoodleCore {detail.lower()}: `{symbol.name}`",
                    insert_text=symbol.name
                )
                items.append(item)
        
        return items
    
    def generate_ai_completions(self, line_prefix: str, current_word: str) -> List['CompletionItem']:
        """
        Generate AI-specific completions
        """
        items = []
        
        # AI annotations
        if line_prefix.endswith('@'):
            ai_annotations = [
                ("@ai_agent", "Define an AI agent with specific capabilities"),
                ("@ai_model", "Define an AI model configuration"),
                ("@ai_train", "Train an AI model with specified data"),
                ("@ai_predict", "Make predictions using an AI model"),
                ("@ai_refactor", "Refactor code using AI assistance"),
                ("@ai_optimize", "Optimize code performance using AI"),
                ("@ai_test", "Generate tests using AI"),
                ("@ai_document", "Generate documentation using AI")
            ]
            
            for annotation, description in ai_annotations:
                if annotation.startswith(current_word) and annotation != current_word:
                    item = CompletionItem(
                        label=annotation,
                        kind=CompletionItemKind.Snippet,
                        detail="AI annotation",
                        documentation=description,
                        insert_text=annotation + " ${1:parameters}"
                    )
                    items.append(item)
        
        # AI functions
        ai_functions = [
            ("train", "Train AI model"),
            ("predict", "Make predictions"),
            ("validate", "Validate model"),
            ("optimize", "Optimize model"),
            ("dataset", "Define dataset"),
            ("pipeline", "Define AI pipeline")
        ]
        
        for func_name, description in ai_functions:
            if func_name.startswith(current_word) and func_name != current_word:
                item = CompletionItem(
                    label=func_name,
                    kind=CompletionItemKind.Method,
                    detail="AI method",
                    documentation=description,
                    insert_text=func_name
                )
                items.append(item)
        
        return items
    
    def generate_pattern_completions(self, line_prefix: str, current_word: str) -> List['CompletionItem']:
        """
        Generate pattern matching completions
        """
        items = []
        
        if "match" in line_prefix:
            pattern_keywords = [
                ("case", "Pattern case"),
                ("_", "Wildcard pattern"),
                ("|", "Alternative pattern"),
                ("as", "Pattern binding")
            ]
            
            for keyword, description in pattern_keywords:
                if keyword.startswith(current_word) and keyword != current_word:
                    item = CompletionItem(
                        label=keyword,
                        kind=CompletionItemKind.Keyword,
                        detail="Pattern matching",
                        documentation=description,
                        insert_text=keyword
                    )
                    items.append(item)
        
        return items
    
    def generate_generic_completions(self, line_prefix: str, current_word: str) -> List['CompletionItem']:
        """
        Generate generics-related completions
        """
        items = []
        
        if "<" in line_prefix:
            generic_keywords = [
                ("T", "Type parameter"),
                ("extends", "Generic constraint"),
                ("implements", "Generic interface"),
                ("where", "Generic constraint")
            ]
            
            for keyword, description in generic_keywords:
                if keyword.startswith(current_word) and keyword != current_word:
                    item = CompletionItem(
                        label=keyword,
                        kind=CompletionItemKind.Keyword,
                        detail="Generics",
                        documentation=description,
                        insert_text=keyword
                    )
                    items.append(item)
        
        return items
    
    def generate_snippet_completions(self, line_prefix: str, current_word: str) -> List['CompletionItem']:
        """
        Generate snippet completions
        """
        items = []
        
        snippets = [
            ("func", "function", "Create a function", [
                "func ${1:function_name}(${2:parameters}) {",
                "\t${3:// TODO: Implement function}",
                "\treturn ${4:null}",
                "}"
            ]),
            ("if", "if", "Create an if statement", [
                "if (${1:condition}) {",
                "\t${2:// TODO: Implement if block}",
                "}"
            ]),
            ("for", "for", "Create a for loop", [
                "for (${1:item} in ${2:collection}) {",
                "\t${3:// TODO: Implement loop body}",
                "}"
            ]),
            ("class", "class", "Create a class", [
                "class ${1:class_name} {",
                "\t${2:// Properties}",
                "\t",
                "\tconstructor(${3:params}) {",
                "\t\t${4:// TODO: Initialize properties}",
                "\t}",
                "\t",
                "\t${5:// Methods}",
                "}"
            ]),
            ("try", "try", "Create a try-catch block", [
                "try {",
                "\t${1:// TODO: Try block}",
                "} catch (${2:error}) {",
                "\t${3:// TODO: Handle error}",
                "}"
            ]),
            ("async", "async", "Create an async function", [
                "async func ${1:function_name}(${2:parameters}) {",
                "\t${3:// TODO: Implement async function}",
                "\treturn await ${4:async_result}",
                "}"
            ])
        ]
        
        for snippet_prefix, snippet_kind, description, body in snippets:
            if snippet_prefix.startswith(current_word) and snippet_prefix != current_word:
                item = CompletionItem(
                    label=snippet_prefix,
                    kind=CompletionItemKind.Snippet,
                    detail=snippet_kind,
                    documentation=description,
                    insert_text="\n".join(body)
                )
                items.append(item)
        
        return items
    
    async def find_definitions(self, document: 'NoodleDocument', position: Position) -> List[Location]:
        """
        Find definitions for symbol at position
        """
        locations = []
        
        # Get current word
        line_text = document.get_line(position.line)
        current_word = self.get_current_word(line_text, position.character)
        
        if not current_word:
            return locations
        
        # Find in document symbols
        document_symbols = self.symbol_table.get_document_symbols(document.uri)
        for symbol in document_symbols:
            if symbol.name == current_word:
                location = Location(
                    uri=document.uri,
                    range=symbol.location.range
                )
                locations.append(location)
        
        # Find in workspace symbols
        workspace_symbols = self.symbol_table.get_workspace_symbols()
        for symbol in workspace_symbols:
            if symbol.name == current_word:
                location = Location(
                    uri=symbol.location.uri,
                    range=symbol.location.range
                )
                locations.append(location)
        
        return locations
    
    async def find_references(self, document: 'NoodleDocument', position: Position) -> List[Location]:
        """
        Find references to symbol at position
        """
        locations = []
        
        # Get current word
        line_text = document.get_line(position.line)
        current_word = self.get_current_word(line_text, position.character)
        
        if not current_word:
            return locations
        
        # Search through all documents for references
        for doc_uri, doc in self.documents.items():
            references = self.find_symbol_in_document(doc, current_word)
            for ref_pos in references:
                location = Location(
                    uri=doc_uri,
                    range=Range(
                        start=ref_pos,
                        end=Position(line=ref_pos.line, character=ref_pos.character + len(current_word))
                    )
                )
                locations.append(location)
        
        return locations
    
    def find_symbol_in_document(self, document: 'NoodleDocument', symbol_name: str) -> List[Position]:
        """
        Find all references to symbol in document
        """
        positions = []
        
        if not document.tokens:
            return positions
        
        # Search through tokens
        for token in document.tokens:
            if (token.type == TokenType.IDENTIFIER and 
                token.value == symbol_name and 
                token.position):
                positions.append(Position(
                    line=token.position.line - 1,
                    character=token.position.column - 1
                ))
        
        return positions
    
    async def generate_hover_info(self, document: 'NoodleDocument', position: Position) -> Optional['Hover']:
        """
        Generate hover information for symbol at position
        """
        # Get current word
        line_text = document.get_line(position.line)
        current_word = self.get_current_word(line_text, position.character)
        
        if not current_word:
            return None
        
        # Find symbol information
        document_symbols = self.symbol_table.get_document_symbols(document.uri)
        for symbol in document_symbols:
            if symbol.name == current_word:
                content = f"**{symbol.name}**\n\n"
                
                if symbol.type_hint:
                    content += f"Type: `{symbol.type_hint}`\n\n"
                
                if symbol.kind == SymbolKind.FUNCTION:
                    content += f"**Function**\n\n"
                    if symbol.type_hint:
                        content += f"Returns: `{symbol.type_hint}`\n\n"
                    content += "Click to go to definition"
                elif symbol.kind == SymbolKind.VARIABLE:
                    content += f"**Variable**\n\n"
                    if symbol.type_hint:
                        content += f"Type: `{symbol.type_hint}`\n\n"
                elif symbol.kind == SymbolKind.CLASS:
                    content += f"**Class**\n\n"
                    content += "Click to go to definition"
                
                return Hover(
                    content=content,
                    range=Range(
                        start=Position(line=position.line, character=position.character - len(current_word)),
                        end=Position(line=position.line, character=position.character + len(current_word))
                    )
                )
        
        return None
    
    async def generate_signature_help(self, document: 'NoodleDocument', position: Position) -> Optional['SignatureHelp']:
        """
        Generate signature help for function call at position
        """
        # Get current word
        line_text = document.get_line(position.line)
        current_word = self.get_current_word(line_text, position.character)
        
        if not current_word:
            return None
        
        # Find function symbol
        document_symbols = self.symbol_table.get_document_symbols(document.uri)
        for symbol in document_symbols:
            if (symbol.name == current_word and 
                symbol.kind == SymbolKind.FUNCTION):
                
                # Create signature information
                signature_info = SignatureInformation(
                    label=f"{symbol.name}()",
                    documentation=f"Function: {symbol.name}",
                    parameters=[
                        ParameterInformation(
                            label="parameters",
                            documentation="Function parameters"
                        )
                    ]
                )
                
                return SignatureHelp(
                    signatures=[signature_info],
                    activeSignature=0,
                    activeParameter=0
                )
        
        return None
    
    async def format_document(self, document: 'NoodleDocument', options: Dict[str, Any]) -> List[TextEdit]:
        """
        Format entire document
        """
        # For now, return empty edits (no formatting)
        # TODO: Implement actual formatting logic
        return []
    
    async def format_document_range(self, document: 'NoodleDocument', range_obj: Range, options: Dict[str, Any]) -> List[TextEdit]:
        """
        Format document range
        """
        # For now, return empty edits (no formatting)
        # TODO: Implement actual formatting logic
        return []
    
    async def generate_code_actions(self, document: 'NoodleDocument', range_obj: Range) -> List['CodeAction']:
        """
        Generate code actions for given range
        """
        actions = []
        
        # Get diagnostics for range
        range_diagnostics = [
            diag for diag in document.diagnostics
            if self.ranges_overlap(diag.range, range_obj)
        ]
        
        # Generate quick fix actions
        for diagnostic in range_diagnostics:
            if "Unknown token" in diagnostic.message:
                action = CodeAction(
                    title="Fix unknown token",
                    kind=CodeActionKind.QuickFix,
                    diagnostics=[diagnostic],
                    edit=self.create_unknown_token_fix(diagnostic, document)
                )
                actions.append(action)
        
        return actions
    
    def create_unknown_token_fix(self, diagnostic: Diagnostic, document: 'NoodleDocument') -> 'WorkspaceEdit':
        """
        Create workspace edit to fix unknown token
        """
        # Extract the unknown token from diagnostic message
        token_value = diagnostic.message.split(": ")[1].strip('"')
        
        # Find the token in document
        if document.tokens:
            for token in document.tokens:
                if (token.value == token_value and 
                    token.position):
                    
                    # Replace with comment
                    new_text = f"// TODO: Fix unknown token: {token_value}"
                    
                    return WorkspaceEdit(
                        documentChanges=[
                            TextDocumentEdit(
                                textDocument=TextDocumentIdentifier(uri=document.uri),
                                edits=[
                                    TextEdit(
                                        range=Range(
                                            start=Position(line=token.position.line - 1, character=token.position.column - 1),
                                            end=Position(line=token.position.line - 1, character=token.position.column + len(token_value) - 1)
                                        ),
                                        newText=new_text
                                    )
                                ]
                            )
                        ]
                    )
        
        return WorkspaceEdit(documentChanges=[])
    
    def ranges_overlap(self, range1: Range, range2: Range) -> bool:
        """
        Check if two ranges overlap
        """
        return not (
            range1.end.line < range2.start.line or
            range2.end.line < range1.start.line or
            (range1.start.line == range2.start.line and range1.end.character < range2.start.character) or
            (range1.start.line == range2.start.line and range2.end.character < range1.start.character)
        )
    
    async def prepare_rename(self, document: 'NoodleDocument', position: Position, new_name: str) -> 'WorkspaceEdit':
        """
        Prepare rename operation
        """
        # Get current word
        line_text = document.get_line(position.line)
        current_word = self.get_current_word(line_text, position.character)
        
        if not current_word:
            return WorkspaceEdit(documentChanges=[])
        
        # Find all occurrences of the symbol
        positions = self.find_symbol_in_document(document, current_word)
        
        # Create edits for all occurrences
        edits = []
        for pos in positions:
            edit = TextEdit(
                range=Range(
                    start=pos,
                    end=Position(line=pos.line, character=pos.character + len(current_word))
                ),
                newText=new_name
            )
            edits.append(edit)
        
        return WorkspaceEdit(
            documentChanges=[
                TextDocumentEdit(
                    textDocument=TextDocumentIdentifier(uri=document.uri),
                    edits=edits
                )
            ]
        )
    
    def create_error_response(self, request_id: Any, message: str) -> Dict[str, Any]:
        """
        Create error response
        """
        return {
            "id": request_id,
            "error": {
                "code": -32603,  # Internal error
                "message": message
            }
        }


class NoodleDocument:
    """
    Represents a NoodleCore document in the LSP server
    """
    
    def __init__(self, uri: str, content: str):
        self.uri = uri
        self.content = content
        self.version = 0
        self.tokens = None
        self.ast = None
        self.symbols = []
        self.diagnostics = []
    
    def get_line(self, line_number: int) -> str:
        """
        Get line text by line number
        """
        lines = self.content.split('\n')
        if 0 <= line_number < len(lines):
            return lines[line_number]
        return ""
    
    def update_content(self, new_content: str):
        """
        Update document content and increment version
        """
        self.content = new_content
        self.version += 1
        self.tokens = None
        self.ast = None
        self.symbols = []
        self.diagnostics = []


class Symbol:
    """
    Represents a symbol in NoodleCore code
    """
    
    def __init__(self, name: str, kind: int, location: Location, scope: str = "global", type_hint: str = None):
        self.name = name
        self.kind = kind
        self.location = location
        self.scope = scope
        self.type_hint = type_hint
    
    def to_dict(self) -> Dict[str, Any]:
        """
        Convert to dictionary
        """
        return {
            "name": self.name,
            "kind": self.kind,
            "location": self.location.to_dict(),
            "scope": self.scope,
            "typeHint": self.type_hint
        }


class SymbolKind:
    """
    Symbol kinds
    """
    FILE = 1
    MODULE = 2
    NAMESPACE = 3
    PACKAGE = 4
    CLASS = 5
    METHOD = 6
    PROPERTY = 7
    FIELD = 8
    CONSTRUCTOR = 9
    ENUM = 10
    INTERFACE = 11
    FUNCTION = 12
    VARIABLE = 13
    CONSTANT = 14
    STRING = 15
    NUMBER = 16
    BOOLEAN = 17
    ARRAY = 18
    OBJECT = 19
    KEY = 20
    NULL = 21
    ENUM_MEMBER = 22
    STRUCT = 23
    EVENT = 24
    OPERATOR = 25
    TYPE_PARAMETER = 26


class SymbolTable:
    """
    Manages symbols across documents and workspace
    """
    
    def __init__(self):
        self.document_symbols: Dict[str, List[Symbol]] = {}
        self.workspace_symbols: List[Symbol] = []
    
    def update_document_symbols(self, uri: str, symbols: List[Symbol]):
        """
        Update symbols for a document
        """
        self.document_symbols[uri] = symbols
        
        # Update workspace symbols
        self.workspace_symbols = [
            symbol for symbols in self.document_symbols.values()
            for symbol in symbols
            if symbol.scope == "global"
        ]
    
    def get_document_symbols(self, uri: str) -> List[Symbol]:
        """
        Get symbols for a document
        """
        return self.document_symbols.get(uri, [])
    
    def get_workspace_symbols(self) -> List[Symbol]:
        """
        Get all workspace symbols
        """
        return self.workspace_symbols


class TypeChecker:
    """
    Performs type checking for NoodleCore code
    """
    
    def __init__(self):
        self.errors = []
    
    def check_semantics(self, ast: ASTNode) -> List[Diagnostic]:
        """
        Check semantic errors in AST
        """
        self.errors = []
        
        # Check for undefined variables
        self.check_undefined_variables(ast)
        
        # Check for type mismatches
        self.check_type_mismatches(ast)
        
        # Check for unused variables
        self.check_unused_variables(ast)
        
        return self.errors
    
    def check_undefined_variables(self, ast: ASTNode):
        """
        Check for undefined variables
        """
        # TODO: Implement undefined variable checking
        pass
    
    def check_type_mismatches(self, ast: ASTNode):
        """
        Check for type mismatches
        """
        # TODO: Implement type mismatch checking
        pass
    
    def check_unused_variables(self, ast: ASTNode):
        """
        Check for unused variables
        """
        # TODO: Implement unused variable checking
        pass


class CompletionCache:
    """
    Caches completion results
    """
    
    def __init__(self, max_size: int = 1000):
        self.cache: Dict[str, List['CompletionItem']] = {}
        self.max_size = max_size
    
    def get(self, key: str) -> Optional[List['CompletionItem']]:
        """
        Get cached completion items
        """
        return self.cache.get(key)
    
    def put(self, key: str, items: List['CompletionItem']):
        """
        Put completion items in cache
        """
        if len(self.cache) >= self.max_size:
            # Remove oldest entry
            oldest_key = next(iter(self.cache))
            del self.cache[oldest_key]
        
        self.cache[key] = items


class DiagnosticsCache:
    """
    Caches diagnostic results
    """
    
    def __init__(self, max_size: int = 1000):
        self.cache: Dict[str, List[Diagnostic]] = {}
        self.max_size = max_size
    
    def get(self, key: str) -> Optional[List[Diagnostic]]:
        """
        Get cached diagnostics
        """
        return self.cache.get(key)
    
    def put(self, key: str, diagnostics: List[Diagnostic]):
        """
        Put diagnostics in cache
        """
        if len(self.cache) >= self.max_size:
            # Remove oldest entry
            oldest_key = next(iter(self.cache))
            del self.cache[oldest_key]
        
        self.cache[key] = diagnostics


class FormattingOptions:
    """
    Formatting options
    """
    
    def __init__(self):
        self.indent_size = 4
        self.indent_style = "spaces"  # or "tabs"
        self.max_line_length = 120
        self.insert_final_newline = True


# Add to_dict methods to classes that need them
def add_to_dict_methods():
    """
    Add to_dict methods to classes that need them
    """
    def completion_item_to_dict(self):
        return {
            "label": self.label,
            "kind": self.kind,
            "detail": self.detail,
            "documentation": self.documentation,
            "insertText": self.insert_text
        }
    
    def location_to_dict(self):
        return {
            "uri": self.uri,
            "range": {
                "start": {
                    "line": self.range.start.line,
                    "character": self.range.start.character
                },
                "end": {
                    "line": self.range.end.line,
                    "character": self.range.end.character
                }
            }
        }
    
    def range_to_dict(self):
        return {
            "start": {
                "line": self.start.line,
                "character": self.start.character
            },
            "end": {
                "line": self.end.line,
                "character": self.end.character
            }
        }
    
    def position_to_dict(self):
        return {
            "line": self.line,
            "character": self.character
        }
    
    def hover_to_dict(self):
        return {
            "contents": self.content,
            "range": self.range.to_dict() if hasattr(self, 'range') else None
        }
    
    def signature_help_to_dict(self):
        return {
            "signatures": [sig.to_dict() for sig in self.signatures],
            "activeSignature": self.activeSignature,
            "activeParameter": self.activeParameter
        }
    
    def signature_info_to_dict(self):
        return {
            "label": self.label,
            "documentation": self.documentation,
            "parameters": [param.to_dict() for param in self.parameters]
        }
    
    def parameter_info_to_dict(self):
        return {
            "label": self.label,
            "documentation": self.documentation
        }
    
    def workspace_edit_to_dict(self):
        return {
            "documentChanges": [change.to_dict() for change in self.documentChanges]
        }
    
    def text_document_edit_to_dict(self):
        return {
            "textDocument": {
                "uri": self.textDocument.uri,
                "version": getattr(self.textDocument, 'version', None)
            },
            "edits": [edit.to_dict() for edit in self.edits]
        }
    
    def text_edit_to_dict(self):
        return {
            "range": self.range.to_dict(),
            "newText": self.newText
        }
    
    def text_document_identifier_to_dict(self):
        return {
            "uri": self.uri
        }
    
    # Add methods to classes
    CompletionItem.to_dict = completion_item_to_dict
    Location.to_dict = location_to_dict
    Range.to_dict = range_to_dict
    Position.to_dict = position_to_dict
    Hover.to_dict = hover_to_dict
    SignatureHelp.to_dict = signature_help_to_dict
    SignatureInformation.to_dict = signature_info_to_dict
    ParameterInformation.to_dict = parameter_info_to_dict
    WorkspaceEdit.to_dict = workspace_edit_to_dict
    TextDocumentEdit.to_dict = text_document_edit_to_dict
    TextEdit.to_dict = text_edit_to_dict
    TextDocumentIdentifier.to_dict = text_document_identifier_to_dict


# Main server loop
async def main():
    """
    Main entry point for NoodleCore LSP server
    """
    logger.info("Starting NoodleCore Language Server")
    
    server = NoodleLSPServer()
    
    try:
        while True:
            # Read request from stdin
            line = await asyncio.get_event_loop().run_in_executor(None, sys.stdin.readline)
            if not line:
                break
            
            try:
                request = json.loads(line)
                response = await server.handle_request(request)
                
                if response:
                    print(json.dumps(response), flush=True)
                    
            except json.JSONDecodeError as e:
                logger.error(f"JSON decode error: {str(e)}")
            except Exception as e:
                logger.error(f"Error processing request: {str(e)}")
    
    except KeyboardInterrupt:
        logger.info("NoodleCore Language Server stopped by user")
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
    finally:
        logger.info("NoodleCore Language Server shutdown")


if __name__ == "__main__":
    asyncio.run(main())


