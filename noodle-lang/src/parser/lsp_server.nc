# Converted from Python to NoodleCore
# Original file: src

# """
# LSP Server Module

# This module implements the Language Server Protocol (LSP) server for NoodleCore IDE integration.
# """

import asyncio
import json
import logging
import os
import uuid
import typing.Dict
import datetime.datetime
import pathlib.Path

# Import logging
import ..logs.get_logger

# Error codes for LSP operations
LSP_ERROR_CODES = {
#     "PARSE_ERROR": -32700,
#     "INVALID_REQUEST": -32600,
#     "METHOD_NOT_FOUND": -32601,
#     "INVALID_PARAMS": -32602,
#     "INTERNAL_ERROR": -32603,
#     "SERVER_NOT_INITIALIZED": -32002,
#     "UNKNOWN_ERROR_CODE": -32001,
#     "REQUEST_CANCELLED": -32800,
#     "CONTENT_MODIFIED": -32801,
# }

# NoodleCore specific error codes (6001-6999)
NOODLE_LSP_ERROR_CODES = {
#     "SYNTAX_ERROR": 6001,
#     "SEMANTIC_ERROR": 6002,
#     "TYPE_ERROR": 6003,
#     "IMPORT_ERROR": 6004,
#     "DEFINITION_NOT_FOUND": 6005,
#     "COMPLETION_FAILED": 6006,
#     "VALIDATION_FAILED": 6007,
#     "FORMATTING_FAILED": 6008,
#     "NAVIGATION_ERROR": 6009,
#     "SYMBOL_RESOLUTION_ERROR": 6010,
# }


class LspError(Exception)
    #     """Custom exception for LSP errors with error codes."""

    #     def __init__(self, code: int, message: str, data: Optional[Dict[str, Any]] = None):
    self.code = code
    self.message = message
    self.data = data
            super().__init__(message)


class LspServer
    #     """Language Server Protocol (LSP) server for NoodleCore."""

    #     def __init__(self, host: str = 'localhost', port: int = 8080):""
    #         Initialize the LSP server.

    #         Args:
    #             host: Host to bind the server to
    #             port: Port to bind the server to
    #         """
    self.name = "LspServer"
    self.host = host
    self.port = port
    self.running = False
    self.server = None
    self.clients = []
    self.initialized = False
    self.workspace_root = None

    #         # Initialize logger
    self.logger = get_logger(f"{__name__}.{self.name}")

    #         # NoodleCore language features
    self.language_features = {
    #             'completion': True,
    #             'diagnostics': True,
    #             'hover': True,
    #             'signature_help': True,
    #             'declaration': True,
    #             'definition': True,
    #             'type_definition': True,
    #             'implementation': True,
    #             'references': True,
    #             'document_highlight': True,
    #             'document_symbol': True,
    #             'workspace_symbol': True,
    #             'code_action': True,
    #             'code_lens': True,
    #             'document_link': True,
    #             'document_color': True,
    #             'document_formatting': True,
    #             'document_range_formatting': True,
    #             'rename': True,
    #             'prepare_rename': True,
    #             'execute_command': True,
    #             'workspace_configuration': True,
    #             'workspace_apply_edit': True,
    #         }

    #         # Supported file types
    self.supported_file_types = ['.nc', '.noodle', '.config']

    #         # Document cache
    self.documents = {}

    #         # Performance tracking
    self.request_times = {}
    self.performance_stats = {
    #             'total_requests': 0,
    #             'average_response_time': 0,
    #             'error_count': 0,
                'last_reset': datetime.now()
    #         }

    #     async def start(self) -Dict[str, Any]):
    #         """
    #         Start the LSP server.

    #         Returns:
    #             Dictionary containing start result
    #         """
    #         try:
                self.logger.info(f"Starting LSP server on {self.host}:{self.port}")

    #             # Create server socket
    self.server = await asyncio.start_server(
    #                 self._handle_client,
    #                 self.host,
    #                 self.port
    #             )

    self.running = True
                self.logger.info(f"LSP server started successfully on {self.host}:{self.port}")

    #             return {
    #                 'success': True,
    #                 'message': f"LSP server started on {self.host}:{self.port}",
    #                 'host': self.host,
    #                 'port': self.port,
    #                 'language_features': self.language_features,
    #                 'supported_file_types': self.supported_file_types,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Failed to start LSP server: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to start LSP server: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def stop(self) -Dict[str, Any]):
    #         """
    #         Stop the LSP server.

    #         Returns:
    #             Dictionary containing stop result
    #         """
    #         try:
                self.logger.info("Stopping LSP server")

    #             if self.server:
                    self.server.close()
                    await self.server.wait_closed()

    self.running = False
    self.initialized = False

                self.logger.info("LSP server stopped successfully")

    #             return {
    #                 'success': True,
    #                 'message': "LSP server stopped successfully",
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Failed to stop LSP server: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to stop LSP server: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def _handle_client(self, reader, writer):
    #         """Handle incoming client connections."""
    client_addr = writer.get_extra_info('peername')
            self.logger.info(f"Client connected: {client_addr}")

    #         try:
    #             while self.running:
                    # Read message length (Content-Length header)
    line = await reader.readline()
    #                 if not line:
    #                     break

    line = line.decode('utf-8').strip()
    #                 if line.startswith('Content-Length:'):
    content_length = int(line.split(':')[1].strip())

    #                     # Read empty line
                        await reader.readline()

    #                     # Read JSON content
    content = await reader.readexactly(content_length)
    request = json.loads(content.decode('utf-8'))

    #                     # Process request
    response = await self.handle_request(request)

    #                     # Send response
    response_json = json.dumps(response)
    response_bytes = response_json.encode('utf-8')

                        writer.write(f'Content-Length: {len(response_bytes)}\r\n\r\n'.encode('utf-8'))
                        writer.write(response_bytes)
                        await writer.drain()

    #         except Exception as e:
    self.logger.error(f"Error handling client {client_addr}: {str(e)}", exc_info = True)

    #         finally:
                writer.close()
                await writer.wait_closed()
                self.logger.info(f"Client disconnected: {client_addr}")

    #     async def handle_request(self, request: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Handle an LSP request.

    #         Args:
    #             request: LSP request

    #         Returns:
    #             Dictionary containing LSP response
    #         """
    start_time = datetime.now()
    request_id = request.get('id', str(uuid.uuid4()))

    #         try:
    method = request.get('method')
    params = request.get('params', {})
    id = request.get('id')

    #             # Update performance stats
    self.performance_stats['total_requests'] + = 1

    response = {
    #                 'jsonrpc': '2.0',
    #                 'id': id
    #             }

    #             # Handle different LSP methods
    #             if method == 'initialize':
    response['result'] = await self._handle_initialize(params)
    #             elif method == 'initialized':
    response['result'] = await self._handle_initialized(params)
    #             elif method == 'shutdown':
    response['result'] = await self._handle_shutdown(params)
    #             elif method == 'exit':
                    await self._handle_exit(params)
    #                 # No response for exit notification
    #                 return None
    #             elif method == 'textDocument/didOpen':
                    await self._handle_did_open(params)
    #                 # No response for notification
    #                 return None
    #             elif method == 'textDocument/didChange':
                    await self._handle_did_change(params)
    #                 # No response for notification
    #                 return None
    #             elif method == 'textDocument/didClose':
                    await self._handle_did_close(params)
    #                 # No response for notification
    #                 return None
    #             elif method == 'textDocument/didSave':
                    await self._handle_did_save(params)
    #                 # No response for notification
    #                 return None
    #             elif method == 'textDocument/completion':
    response['result'] = await self._handle_completion(params)
    #             elif method == 'completionItem/resolve':
    response['result'] = await self._handle_completion_resolve(params)
    #             elif method == 'textDocument/hover':
    response['result'] = await self._handle_hover(params)
    #             elif method == 'textDocument/signatureHelp':
    response['result'] = await self._handle_signature_help(params)
    #             elif method == 'textDocument/declaration':
    response['result'] = await self._handle_declaration(params)
    #             elif method == 'textDocument/definition':
    response['result'] = await self._handle_definition(params)
    #             elif method == 'textDocument/typeDefinition':
    response['result'] = await self._handle_type_definition(params)
    #             elif method == 'textDocument/implementation':
    response['result'] = await self._handle_implementation(params)
    #             elif method == 'textDocument/references':
    response['result'] = await self._handle_references(params)
    #             elif method == 'textDocument/documentHighlight':
    response['result'] = await self._handle_document_highlight(params)
    #             elif method == 'textDocument/documentSymbol':
    response['result'] = await self._handle_document_symbol(params)
    #             elif method == 'workspace/symbol':
    response['result'] = await self._handle_workspace_symbol(params)
    #             elif method == 'textDocument/codeAction':
    response['result'] = await self._handle_code_action(params)
    #             elif method == 'textDocument/codeLens':
    response['result'] = await self._handle_code_lens(params)
    #             elif method == 'codeLens/resolve':
    response['result'] = await self._handle_code_lens_resolve(params)
    #             elif method == 'textDocument/documentLink':
    response['result'] = await self._handle_document_link(params)
    #             elif method == 'documentLink/resolve':
    response['result'] = await self._handle_document_link_resolve(params)
    #             elif method == 'textDocument/documentColor':
    response['result'] = await self._handle_document_color(params)
    #             elif method == 'textDocument/colorPresentation':
    response['result'] = await self._handle_color_presentation(params)
    #             elif method == 'textDocument/formatting':
    response['result'] = await self._handle_formatting(params)
    #             elif method == 'textDocument/rangeFormatting':
    response['result'] = await self._handle_range_formatting(params)
    #             elif method == 'textDocument/onTypeFormatting':
    response['result'] = await self._handle_on_type_formatting(params)
    #             elif method == 'textDocument/rename':
    response['result'] = await self._handle_rename(params)
    #             elif method == 'textDocument/prepareRename':
    response['result'] = await self._handle_prepare_rename(params)
    #             elif method == 'workspace/executeCommand':
    response['result'] = await self._handle_execute_command(params)
    #             elif method == 'workspace/configuration':
    response['result'] = await self._handle_workspace_configuration(params)
    #             elif method == 'workspace/applyEdit':
    response['result'] = await self._handle_workspace_apply_edit(params)
    #             else:
    response['error'] = {
    #                     'code': LSP_ERROR_CODES["METHOD_NOT_FOUND"],
    #                     'message': f"Method not found: {method}"
    #                 }

    #                 # Update error stats
    self.performance_stats['error_count'] + = 1

    #             # Update performance tracking
    end_time = datetime.now()
    response_time = (end_time - start_time.total_seconds())
    self.request_times[request_id] = response_time

    #             # Update average response time
    total_time = sum(self.request_times.values())
    self.performance_stats['average_response_time'] = math.divide(total_time, len(self.request_times))

    #             # Log slow requests
    #             if response_time 0.1):  # 100ms threshold
                    self.logger.warning(f"Slow LSP request: {method} took {response_time:.3f}s")

    #             return response

    #         except LspError as e:
                self.logger.error(f"LSP error in request {request_id}: {e.message}")
    self.performance_stats['error_count'] + = 1

    #             return {
    #                 'jsonrpc': '2.0',
                    'id': request.get('id'),
    #                 'error': {
    #                     'code': e.code,
    #                     'message': e.message,
    #                     'data': e.data
    #                 }
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Unexpected error in request {request_id}: {str(e)}", exc_info = True)
    self.performance_stats['error_count'] + = 1

    #             return {
    #                 'jsonrpc': '2.0',
                    'id': request.get('id'),
    #                 'error': {
    #                     'code': error_code,
                        'message': f"Internal error: {str(e)}"
    #                 }
    #             }

    #     async def _handle_initialize(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Handle LSP initialize request.

    #         Args:
    #             params: Initialize parameters

    #         Returns:
    #             Initialize result
    #         """
    #         try:
    #             # Set workspace root
    #             if 'rootUri' in params and params['rootUri']:
    self.workspace_root = params['rootUri']
    #             elif 'rootPath' in params and params['rootPath']:
    self.workspace_root = params['rootPath']

    #             # Get client capabilities
    client_capabilities = params.get('capabilities', {})

    #             # Determine server capabilities based on client support
    server_capabilities = {
    #                 'textDocumentSync': {
    #                     'openClose': True,
    #                     'change': 2,  # Incremental
    #                     'save': {
    #                         'includeText': True
    #                     }
    #                 },
    #                 'completionProvider': {
    #                     'resolveProvider': True,
                        'triggerCharacters': ['.', ':', '(', '[', ' ', '"', "'"]
    #                 },
    #                 'hoverProvider': True,
    #                 'signatureHelpProvider': {
                        'triggerCharacters': ['(', ',']
    #                 },
    #                 'declarationProvider': True,
    #                 'definitionProvider': True,
    #                 'typeDefinitionProvider': True,
    #                 'implementationProvider': True,
    #                 'referencesProvider': True,
    #                 'documentHighlightProvider': True,
    #                 'documentSymbolProvider': True,
    #                 'workspaceSymbolProvider': True,
    #                 'codeActionProvider': {
    #                     'codeActionKinds': ['quickfix', 'refactor', 'refactor.extract', 'refactor.inline']
    #                 },
    #                 'codeLensProvider': {
    #                     'resolveProvider': True
    #                 },
    #                 'documentLinkProvider': {
    #                     'resolveProvider': True
    #                 },
    #                 'colorProvider': True,
    #                 'documentFormattingProvider': True,
    #                 'documentRangeFormattingProvider': True,
    #                 'documentOnTypeFormattingProvider': {
    #                     'firstTriggerCharacter': '}',
    #                     'moreTriggerCharacter': [';', '\n']
    #                 },
    #                 'renameProvider': {
    #                     'prepareProvider': True
    #                 },
    #                 'executeCommandProvider': {
    #                     'commands': [
    #                         'noodlecore.format',
    #                         'noodlecore.validate',
    #                         'noodlecore.optimize',
    #                         'noodlecore.refactor'
    #                     ]
    #                 },
    #                 'workspace': {
    #                     'workspaceFolders': {
    #                         'supported': True,
    #                         'changeNotifications': True
    #                     },
    #                     'configuration': True,
    #                     'applyEdit': True
    #                 }
    #             }

    #             # Mark as initialized
    self.initialized = True

    #             self.logger.info(f"LSP server initialized for workspace: {self.workspace_root}")

    #             return {
    #                 'capabilities': server_capabilities,
    #                 'serverInfo': {
    #                     'name': 'NoodleCore LSP Server',
    #                     'version': '1.0.0'
    #                 }
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in initialize: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to initialize: {str(e)}")

    #     async def _handle_initialized(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle initialized notification."""
    #         try:
                self.logger.info("LSP server fully initialized")
    #             return {}

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in initialized: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to handle initialized: {str(e)}")

    #     async def _handle_shutdown(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle shutdown request."""
    #         try:
                self.logger.info("LSP server shutting down")
    self.initialized = False
    #             return {}

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in shutdown: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to shutdown: {str(e)}")

    #     async def _handle_exit(self, params: Dict[str, Any]) -None):
    #         """Handle exit notification."""
    #         try:
                self.logger.info("LSP server exiting")
                await self.stop()

    #         except Exception as e:
    self.logger.error(f"Error in exit: {str(e)}", exc_info = True)

    #     async def _handle_did_open(self, params: Dict[str, Any]) -None):
    #         """Handle textDocument/didOpen notification."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']
    language_id = text_document['languageId']
    version = text_document['version']
    text = text_document['text']

    #             # Store document
    self.documents[uri] = {
    #                 'uri': uri,
    #                 'language_id': language_id,
    #                 'version': version,
    #                 'text': text,
                    'last_modified': datetime.now()
    #             }

                self.logger.debug(f"Document opened: {uri}")

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in did_open: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to handle did_open: {str(e)}")

    #     async def _handle_did_change(self, params: Dict[str, Any]) -None):
    #         """Handle textDocument/didChange notification."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']
    version = text_document['version']
    content_changes = params['contentChanges']

    #             # Update document
    #             if uri in self.documents:
    doc = self.documents[uri]

    #                 # Apply changes
    #                 for change in content_changes:
    #                     if 'range' in change:
    #                         # Incremental change
    start = change['range']['start']
    end = change['range']['end']
    text = change['text']

                            # Apply range change (simplified)
    lines = doc['text'].split('\n')
    start_line = start['line']
    start_char = start['character']
    end_line = end['line']
    end_char = end['character']

    #                         # Replace text in range
    #                         if start_line == end_line:
    lines[start_line] = (
    #                                 lines[start_line][:start_char] +
    #                                 text +
    #                                 lines[start_line][end_char:]
    #                             )
    #                         else:
                                # Multi-line change (simplified)
    lines[start_line] = (
    #                                 lines[start_line][:start_char] +
    #                                 text +
    #                                 lines[end_line][end_char:]
    #                             )
    #                             del lines[start_line+1:end_line+1]

    doc['text'] = '\n'.join(lines)
    #                     else:
    #                         # Full text change
    doc['text'] = change['text']

    doc['version'] = version
    doc['last_modified'] = datetime.now()

                    self.logger.debug(f"Document changed: {uri}")

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in did_change: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to handle did_change: {str(e)}")

    #     async def _handle_did_close(self, params: Dict[str, Any]) -None):
    #         """Handle textDocument/didClose notification."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']

    #             # Remove document
    #             if uri in self.documents:
    #                 del self.documents[uri]

                self.logger.debug(f"Document closed: {uri}")

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in did_close: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to handle did_close: {str(e)}")

    #     async def _handle_did_save(self, params: Dict[str, Any]) -None):
    #         """Handle textDocument/didSave notification."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']
    text = params.get('text')

    #             # Update document if text provided
    #             if text and uri in self.documents:
    self.documents[uri]['text'] = text
    self.documents[uri]['last_modified'] = datetime.now()

                self.logger.debug(f"Document saved: {uri}")

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in did_save: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to handle did_save: {str(e)}")

    #     async def _handle_completion(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Handle textDocument/completion request.

    #         Args:
    #             params: Completion parameters

    #         Returns:
    #             Completion result
    #         """
    #         try:
    text_document = params['textDocument']
    position = params['position']
    context = params.get('context', {})

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
                    raise LspError(
    #                     NOODLE_LSP_ERROR_CODES["COMPLETION_FAILED"],
    #                     f"Document not found: {uri}"
    #                 )

    doc = self.documents[uri]
    text = doc['text']
    line = position['line']
    character = position['character']

    #             # Get line text
    lines = text.split('\n')
    #             if line >= len(lines):
    #                 return {'isIncomplete': True, 'items': []}

    line_text = lines[line]
    prefix = line_text[:character]

    #             # Generate completions based on context
    completions = await self._generate_completions(prefix, context, line, character)

    #             return {
    #                 'isIncomplete': False,
    #                 'items': completions
    #             }

    #         except LspError:
    #             raise
    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["COMPLETION_FAILED"]
    self.logger.error(f"Error in completion: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get completions: {str(e)}")

    #     async def _generate_completions(self, prefix: str, context: Dict[str, Any], line: int, character: int) -List[Dict[str, Any]]):
    #         """Generate completion items based on context."""
    completions = []

    #         # Basic keyword completions
    keywords = [
    #             'func', 'var', 'const', 'if', 'else', 'for', 'while', 'return',
    #             'import', 'export', 'class', 'interface', 'type', 'enum',
    #             'try', 'catch', 'finally', 'throw', 'async', 'await'
    #         ]

    #         for keyword in keywords:
    #             if keyword.startswith(prefix):
                    completions.append({
    #                     'label': keyword,
    #                     'kind': 14,  # Keyword
    #                     'detail': f'NoodleCore keyword: {keyword}',
    #                     'documentation': f'NoodleCore {keyword} keyword',
    #                     'insertText': keyword,
    #                     'sortText': f'0{keyword}'
    #                 })

    #         # Function completions
    #         if prefix.endswith('(') or '(' in prefix:
                completions.append({
    #                 'label': 'function',
    #                 'kind': 15,  # Function
    #                 'detail': 'Define a function',
    #                 'documentation': 'Defines a new function in NoodleCore',
                    'insertText': 'func ${1:name}(${2:params}) {\n\t${3:// body}\n}',
    #                 'insertTextFormat': 2,  # Snippet
    #                 'sortText': '1function'
    #             })

    #         # Variable completions
    #         if prefix.endswith(' ') or prefix == '':
                completions.append({
    #                 'label': 'variable',
    #                 'kind': 6,  # Variable
    #                 'detail': 'Declare a variable',
    #                 'documentation': 'Declares a new variable in NoodleCore',
    'insertText': 'var ${1:name} = ${2:value};',
    #                 'insertTextFormat': 2,  # Snippet
    #                 'sortText': '2variable'
    #             })

    #         # Import completions
    #         if 'import' in prefix:
                completions.append({
    #                 'label': 'import module',
    #                 'kind': 9,  # Module
    #                 'detail': 'Import a module',
    #                 'documentation': 'Imports a module in NoodleCore',
    #                 'insertText': 'import ${1:module};',
    #                 'insertTextFormat': 2,  # Snippet
    #                 'sortText': '3import'
    #             })

    #         return completions

    #     async def _handle_completion_resolve(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle completionItem/resolve request."""
    #         try:
    #             # Resolve additional details for completion item
    item = params

    #             # Add additional documentation if needed
    #             if 'documentation' not in item:
    #                 item['documentation'] = f"Documentation for {item['label']}"

    #             return item

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["COMPLETION_FAILED"]
    self.logger.error(f"Error in completion_resolve: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to resolve completion: {str(e)}")

    #     async def _handle_hover(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Handle textDocument/hover request.

    #         Args:
    #             params: Hover parameters

    #         Returns:
    #             Hover result
    #         """
    #         try:
    text_document = params['textDocument']
    position = params['position']

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return {'contents': []}

    doc = self.documents[uri]
    text = doc['text']
    line = position['line']
    character = position['character']

    #             # Get word at position
    lines = text.split('\n')
    #             if line >= len(lines):
    #                 return {'contents': []}

    line_text = lines[line]

    #             # Find word boundaries
    start = character
    #             while start 0 and (line_text[start-1].isalnum() or line_text[start-1] == '_')):
    start - = 1

    end = character
    #             while end < len(line_text) and (line_text[end].isalnum() or line_text[end] == '_'):
    end + = 1

    word = line_text[start:end]

    #             # Generate hover content
    hover_content = await self._generate_hover_content(word)

    #             return {
    #                 'contents': {
    #                     'kind': 'markdown',
    #                     'value': hover_content
    #                 },
    #                 'range': {
    #                     'start': {'line': line, 'character': start},
    #                     'end': {'line': line, 'character': end}
    #                 }
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in hover: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get hover: {str(e)}")

    #     async def _generate_hover_content(self, word: str) -str):
    #         """Generate hover content for a word."""
    #         # Check if it's a keyword
    keywords = ['func', 'var', 'const', 'if', 'else', 'for', 'while', 'return']
    #         if word in keywords:
    #             return f"**{word}**\n\nNoodleCore keyword: `{word}`"

    #         # Default hover content
    #         return f"**{word}**\n\nSymbol: `{word}`\n\n*No additional information available*"

    #     async def _handle_signature_help(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/signatureHelp request."""
    #         try:
    #             # TODO: Implement signature help
    #             return {
    #                 'signatures': [
    #                     {
                            'label': 'function(param1, param2)',
    #                         'documentation': 'Function documentation',
    #                         'parameters': [
    #                             {
    #                                 'label': 'param1',
    #                                 'documentation': 'First parameter'
    #                             },
    #                             {
    #                                 'label': 'param2',
    #                                 'documentation': 'Second parameter'
    #                             }
    #                         ]
    #                     }
    #                 ],
    #                 'activeSignature': 0,
    #                 'activeParameter': 0
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in signature_help: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get signature help: {str(e)}")

    #     async def _handle_declaration(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/declaration request."""
    #         try:
    #             # TODO: Implement declaration lookup
    text_document = params['textDocument']
    position = params['position']

    #             return {
    #                 'uri': text_document['uri'],
    #                 'range': {
    #                     'start': {'line': position['line'], 'character': 0},
    #                     'end': {'line': position['line'], 'character': 10}
    #                 }
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["DEFINITION_NOT_FOUND"]
    self.logger.error(f"Error in declaration: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to find declaration: {str(e)}")

    #     async def _handle_definition(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/definition request."""
    #         try:
    text_document = params['textDocument']
    position = params['position']

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    line = position['line']
    character = position['character']

    #             # Get word at position
    lines = text.split('\n')
    #             if line >= len(lines):
    #                 return []

    line_text = lines[line]

    #             # Find word boundaries
    start = character
    #             while start 0 and (line_text[start-1].isalnum() or line_text[start-1] == '_')):
    start - = 1

    end = character
    #             while end < len(line_text) and (line_text[end].isalnum() or line_text[end] == '_'):
    end + = 1

    word = line_text[start:end]

    #             # Find definition in document
    definition_line = None
    #             for i, doc_line in enumerate(lines):
    #                 if f"func {word}" in doc_line or f"var {word}" in doc_line or f"const {word}" in doc_line:
    definition_line = i
    #                     break

    #             if definition_line is not None:
    #                 return [{
    #                     'uri': uri,
    #                     'range': {
    #                         'start': {'line': definition_line, 'character': 0},
                            'end': {'line': definition_line, 'character': len(lines[definition_line])}
    #                     }
    #                 }]
    #             else:
    #                 return []

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["DEFINITION_NOT_FOUND"]
    self.logger.error(f"Error in definition: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to find definition: {str(e)}")

    #     async def _handle_type_definition(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/typeDefinition request."""
    #         try:
    #             # TODO: Implement type definition lookup
    text_document = params['textDocument']
    position = params['position']

    #             return {
    #                 'uri': text_document['uri'],
    #                 'range': {
    #                     'start': {'line': position['line'], 'character': 0},
    #                     'end': {'line': position['line'], 'character': 10}
    #                 }
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["DEFINITION_NOT_FOUND"]
    self.logger.error(f"Error in type_definition: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to find type definition: {str(e)}")

    #     async def _handle_implementation(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/implementation request."""
    #         try:
    #             # TODO: Implement implementation lookup
    text_document = params['textDocument']
    position = params['position']

    #             return {
    #                 'uri': text_document['uri'],
    #                 'range': {
    #                     'start': {'line': position['line'], 'character': 0},
    #                     'end': {'line': position['line'], 'character': 10}
    #                 }
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["DEFINITION_NOT_FOUND"]
    self.logger.error(f"Error in implementation: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to find implementation: {str(e)}")

    #     async def _handle_references(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/references request."""
    #         try:
    text_document = params['textDocument']
    position = params['position']
    context = params.get('context', {'includeDeclaration': True})

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    line = position['line']
    character = position['character']

    #             # Get word at position
    lines = text.split('\n')
    #             if line >= len(lines):
    #                 return []

    line_text = lines[line]

    #             # Find word boundaries
    start = character
    #             while start 0 and (line_text[start-1].isalnum() or line_text[start-1] == '_')):
    start - = 1

    end = character
    #             while end < len(line_text) and (line_text[end].isalnum() or line_text[end] == '_'):
    end + = 1

    word = line_text[start:end]

    #             # Find all references in document
    references = []
    #             for i, doc_line in enumerate(lines):
    #                 if word in doc_line:
    #                     # Find all occurrences in this line
    start_idx = 0
    #                     while True:
    idx = doc_line.find(word, start_idx)
    #                         if idx == -1:
    #                             break

                            references.append({
    #                             'uri': uri,
    #                             'range': {
    #                                 'start': {'line': i, 'character': idx},
                                    'end': {'line': i, 'character': idx + len(word)}
    #                             }
    #                         })

    start_idx = idx + 1

    #             return references

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["NAVIGATION_ERROR"]
    self.logger.error(f"Error in references: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to find references: {str(e)}")

    #     async def _handle_document_highlight(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/documentHighlight request."""
    #         try:
    text_document = params['textDocument']
    position = params['position']

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    line = position['line']
    character = position['character']

    #             # Get word at position
    lines = text.split('\n')
    #             if line >= len(lines):
    #                 return []

    line_text = lines[line]

    #             # Find word boundaries
    start = character
    #             while start 0 and (line_text[start-1].isalnum() or line_text[start-1] == '_')):
    start - = 1

    end = character
    #             while end < len(line_text) and (line_text[end].isalnum() or line_text[end] == '_'):
    end + = 1

    word = line_text[start:end]

    #             # Find all occurrences in document
    highlights = []
    #             for i, doc_line in enumerate(lines):
    #                 if word in doc_line:
    #                     # Find all occurrences in this line
    start_idx = 0
    #                     while True:
    idx = doc_line.find(word, start_idx)
    #                         if idx == -1:
    #                             break

                            highlights.append({
    #                             'range': {
    #                                 'start': {'line': i, 'character': idx},
                                    'end': {'line': i, 'character': idx + len(word)}
    #                             },
    #                             'kind': 1  # Text
    #                         })

    start_idx = idx + 1

    #             return highlights

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in document_highlight: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to highlight document: {str(e)}")

    #     async def _handle_document_symbol(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/documentSymbol request."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    lines = text.split('\n')

    symbols = []

    #             # Find functions
    #             for i, line in enumerate(lines):
    stripped = line.strip()
    #                 if stripped.startswith('func '):
    parts = stripped.split('(')[0].split()
    #                     if len(parts) >= 2:
    func_name = parts[1]
                            symbols.append({
    #                             'name': func_name,
    #                             'kind': 12,  # Function
    #                             'location': {
    #                                 'uri': uri,
    #                                 'range': {
    #                                     'start': {'line': i, 'character': 0},
                                        'end': {'line': i, 'character': len(line)}
    #                                 }
    #                             },
    #                             'detail': f"Function: {func_name}"
    #                         })

    #                 # Find variables
    #                 elif stripped.startswith('var ') or stripped.startswith('const '):
    parts = stripped.split('=')
    #                     if len(parts) >= 1:
    var_decl = parts[0].strip()
    var_name = var_decl.split()[ - 1]
                            symbols.append({
    #                             'name': var_name,
    #                             'kind': 13,  # Variable
    #                             'location': {
    #                                 'uri': uri,
    #                                 'range': {
    #                                     'start': {'line': i, 'character': 0},
                                        'end': {'line': i, 'character': len(line)}
    #                                 }
    #                             },
    #                             'detail': f"Variable: {var_name}"
    #                         })

    #                 # Find classes
    #                 elif stripped.startswith('class '):
    parts = stripped.split()
    #                     if len(parts) >= 2:
    class_name = parts[1].split('{')[0]
                            symbols.append({
    #                             'name': class_name,
    #                             'kind': 5,  # Class
    #                             'location': {
    #                                 'uri': uri,
    #                                 'range': {
    #                                     'start': {'line': i, 'character': 0},
                                        'end': {'line': i, 'character': len(line)}
    #                                 }
    #                             },
    #                             'detail': f"Class: {class_name}"
    #                         })

    #             return symbols

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["SYMBOL_RESOLUTION_ERROR"]
    self.logger.error(f"Error in document_symbol: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get document symbols: {str(e)}")

    #     async def _handle_workspace_symbol(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle workspace/symbol request."""
    #         try:
    query = params.get('query', '')

    #             # Search in all documents
    symbols = []

    #             for uri, doc in self.documents.items():
    text = doc['text']
    lines = text.split('\n')

    #                 for i, line in enumerate(lines):
    stripped = line.strip()

    #                     # Find functions
    #                     if stripped.startswith('func ') and query in line:
    parts = stripped.split('(')[0].split()
    #                         if len(parts) >= 2:
    func_name = parts[1]
                                symbols.append({
    #                                 'name': func_name,
    #                                 'kind': 12,  # Function
    #                                 'location': {
    #                                     'uri': uri,
    #                                     'range': {
    #                                         'start': {'line': i, 'character': 0},
                                            'end': {'line': i, 'character': len(line)}
    #                                     }
    #                                 },
                                    'containerName': f"Document: {Path(uri).stem}"
    #                             })

    #                     # Find variables
    #                     elif (stripped.startswith('var ') or stripped.startswith('const ')) and query in line:
    parts = stripped.split('=')
    #                         if len(parts) >= 1:
    var_decl = parts[0].strip()
    var_name = var_decl.split()[ - 1]
                                symbols.append({
    #                                 'name': var_name,
    #                                 'kind': 13,  # Variable
    #                                 'location': {
    #                                     'uri': uri,
    #                                     'range': {
    #                                         'start': {'line': i, 'character': 0},
                                            'end': {'line': i, 'character': len(line)}
    #                                     }
    #                                 },
                                    'containerName': f"Document: {Path(uri).stem}"
    #                             })

    #             return symbols

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["SYMBOL_RESOLUTION_ERROR"]
    self.logger.error(f"Error in workspace_symbol: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to search workspace symbols: {str(e)}")

    #     async def _handle_code_action(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/codeAction request."""
    #         try:
    text_document = params['textDocument']
    range = params['range']
    context = params.get('context', {})

    uri = text_document['uri']

    #             # Generate code actions
    actions = []

    #             # Quick fix actions
    #             if context.get('diagnostics'):
    #                 for diagnostic in context['diagnostics']:
    #                     if diagnostic.get('source') == 'noodlecore':
                            actions.append({
    #                             'title': f"Fix: {diagnostic['message']}",
    #                             'kind': 'quickfix',
    #                             'diagnostics': [diagnostic],
    #                             'edit': {
    #                                 'documentChanges': [
    #                                     {
    #                                         'textDocument': {'uri': uri, 'version': 1},
    #                                         'edits': [
    #                                             {
    #                                                 'range': diagnostic['range'],
    #                                                 'newText': 'fixed code'
    #                                             }
    #                                         ]
    #                                     }
    #                                 ]
    #                             }
    #                         })

    #             # Refactor actions
                actions.append({
    #                 'title': 'Extract to function',
    #                 'kind': 'refactor.extract',
    #                 'diagnostics': [],
    #                 'edit': {
    #                     'documentChanges': [
    #                         {
    #                             'textDocument': {'uri': uri, 'version': 1},
    #                             'edits': [
    #                                 {
    #                                     'range': range,
                                        'newText': 'extracted_function()'
    #                                 }
    #                             ]
    #                         }
    #                     ]
    #                 }
    #             })

    #             return actions

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in code_action: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get code actions: {str(e)}")

    #     async def _handle_code_lens(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/codeLens request."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    lines = text.split('\n')

    lenses = []

    #             # Add code lenses for functions
    #             for i, line in enumerate(lines):
    stripped = line.strip()
    #                 if stripped.startswith('func '):
    parts = stripped.split('(')[0].split()
    #                     if len(parts) >= 2:
    func_name = parts[1]
                            lenses.append({
    #                             'range': {
    #                                 'start': {'line': i, 'character': 0},
                                    'end': {'line': i, 'character': len(line)}
    #                             },
    #                             'command': {
    #                                 'title': 'Run function',
    #                                 'command': 'noodlecore.run_function',
    #                                 'arguments': [func_name]
    #                             }
    #                         })

    #             return lenses

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in code_lens: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get code lenses: {str(e)}")

    #     async def _handle_code_lens_resolve(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle codeLens/resolve request."""
    #         try:
    #             # Resolve additional details for code lens
    lens = params

    #             # Add additional data if needed
    #             if 'data' not in lens:
    lens['data'] = {'resolved': True}

    #             return lens

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in code_lens_resolve: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to resolve code lens: {str(e)}")

    #     async def _handle_document_link(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/documentLink request."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    lines = text.split('\n')

    links = []

    #             # Find import statements
    #             for i, line in enumerate(lines):
    #                 if 'import ' in line:
    #                     # Extract module path
    import_match = line.find('import ')
    #                     if import_match >= 0:
    import_part = line[import_match + 7:].strip().rstrip(';')
    #                         if import_part.startswith('"') and import_part.endswith('"'):
    module_path = import_part[1: - 1]

                                links.append({
    #                                 'range': {
    #                                     'start': {'line': i, 'character': import_match + 7},
                                        'end': {'line': i, 'character': import_match + 7 + len(import_part)}
    #                                 },
    #                                 'target': f'file://{module_path}'
    #                             })

    #             return links

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in document_link: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get document links: {str(e)}")

    #     async def _handle_document_link_resolve(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle documentLink/resolve request."""
    #         try:
    #             # Resolve additional details for document link
    link = params

    #             # Add tooltip if needed
    #             if 'tooltip' not in link:
    link['tooltip'] = f"Go to {link['target']}"

    #             return link

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in document_link_resolve: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to resolve document link: {str(e)}")

    #     async def _handle_document_color(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/documentColor request."""
    #         try:
    text_document = params['textDocument']
    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    lines = text.split('\n')

    colors = []

    #             # Find color definitions
    #             for i, line in enumerate(lines):
    #                 # Look for color patterns
    #                 import re
    color_patterns = [
                        r'#([0-9a-fA-F]{6})',  # #RRGGBB
                        r'#([0-9a-fA-F]{3})',  # #RGB
                        r'rgb\((\d+),\s*(\d+),\s*(\d+)\)',  # rgb(r, g, b)
                        r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([0-9.]+)\)',  # rgba(r, g, b, a)
    #                 ]

    #                 for pattern in color_patterns:
    matches = re.finditer(pattern, line)
    #                     for match in matches:
                            colors.append({
    #                             'range': {
                                    'start': {'line': i, 'character': match.start()},
                                    'end': {'line': i, 'character': match.end()}
    #                             },
    #                             'color': {
    #                                 'red': 0.5,  # Default color
    #                                 'green': 0.5,
    #                                 'blue': 0.5,
    #                                 'alpha': 1.0
    #                             }
    #                         })

    #             return colors

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in document_color: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get document colors: {str(e)}")

    #     async def _handle_color_presentation(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/colorPresentation request."""
    #         try:
    text_document = params['textDocument']
    color = params['color']
    range = params['range']

    #             # Generate color presentations
    presentations = []

    #             # Hex format
    r = int(color['red'] * 255)
    g = int(color['green'] * 255)
    b = int(color['blue'] * 255)

                presentations.append({
    #                 'label': f'#{r:02x}{g:02x}{b:02x}',
    #                 'textEdit': {
    #                     'range': range,
    #                     'newText': f'#{r:02x}{g:02x}{b:02x}'
    #                 }
    #             })

    #             # RGB format
                presentations.append({
                    'label': f'rgb({r}, {g}, {b})',
    #                 'textEdit': {
    #                     'range': range,
                        'newText': f'rgb({r}, {g}, {b})'
    #                 }
    #             })

    #             return presentations

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in color_presentation: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get color presentations: {str(e)}")

    #     async def _handle_formatting(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/formatting request."""
    #         try:
    text_document = params['textDocument']
    options = params.get('options', {})

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']

    #             # Format the document
    tab_size = options.get('tabSize', 4)
    insert_spaces = options.get('insertSpaces', True)

    #             # Simple formatting
    lines = text.split('\n')
    formatted_lines = []

    #             for line in lines:
    #                 # Basic indentation
    stripped = line.lstrip()
    #                 if stripped:
    #                     # Calculate indentation level
    #                     indent_level = (len(line) - len(stripped)) // (4 if insert_spaces else 1)

    #                     # Apply new indentation
    #                     if insert_spaces:
    new_indent = ' ' * (indent_level * tab_size)
    #                     else:
    new_indent = '\t' * indent_level

                        formatted_lines.append(new_indent + stripped)
    #                 else:
                        formatted_lines.append('')

    formatted_text = '\n'.join(formatted_lines)

    #             # Generate text edit
    #             return [{
    #                 'range': {
    #                     'start': {'line': 0, 'character': 0},
                        'end': {'line': len(lines) - 1, 'character': len(lines[-1])}
    #                 },
    #                 'newText': formatted_text
    #             }]

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["FORMATTING_FAILED"]
    self.logger.error(f"Error in formatting: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to format document: {str(e)}")

    #     async def _handle_range_formatting(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/rangeFormatting request."""
    #         try:
    text_document = params['textDocument']
    range = params['range']
    options = params.get('options', {})

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    lines = text.split('\n')

    #             # Extract range
    start_line = range['start']['line']
    end_line = range['end']['line']

    #             # Format the range
    tab_size = options.get('tabSize', 4)
    insert_spaces = options.get('insertSpaces', True)

    formatted_lines = []

    #             for i in range(start_line, end_line + 1):
    #                 if i < len(lines):
    line = lines[i]

    #                     # Basic indentation
    stripped = line.lstrip()
    #                     if stripped:
    #                         # Calculate indentation level
    #                         indent_level = (len(line) - len(stripped)) // (4 if insert_spaces else 1)

    #                         # Apply new indentation
    #                         if insert_spaces:
    new_indent = ' ' * (indent_level * tab_size)
    #                         else:
    new_indent = '\t' * indent_level

                            formatted_lines.append(new_indent + stripped)
    #                     else:
                            formatted_lines.append('')

    formatted_text = '\n'.join(formatted_lines)

    #             # Generate text edit
    #             return [{
    #                 'range': range,
    #                 'newText': formatted_text
    #             }]

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["FORMATTING_FAILED"]
    self.logger.error(f"Error in range_formatting: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to format range: {str(e)}")

    #     async def _handle_on_type_formatting(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/onTypeFormatting request."""
    #         try:
    text_document = params['textDocument']
    position = params['position']
    ch = params['ch']
    options = params.get('options', {})

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return []

    doc = self.documents[uri]
    text = doc['text']
    lines = text.split('\n')

    #             # Handle different trigger characters
    #             if ch == '}':
    #                 # Auto-close braces
    line = lines[position['line']]

    #                 # Find opening brace
    brace_count = 1
    #                 for i in range(position['line'], -1, -1):
    #                     for j in range(len(lines[i]) - 1, -1, -1):
    #                         if i == position['line'] and j >= position['character']:
    #                             continue

    #                         if lines[i][j] == '}':
    brace_count + = 1
    #                         elif lines[i][j] == '{':
    brace_count - = 1
    #                             if brace_count = 0:
    #                                 # Found matching opening brace
    #                                 return [{
    #                                     'range': {
    #                                         'start': {'line': position['line'], 'character': position['character']},
    #                                         'end': {'line': position['line'], 'character': position['character']}
    #                                     },
                                        'newText': '\n' + ' ' * (j + 1) + '\n'
    #                                 }]

    #             return []

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["FORMATTING_FAILED"]
    self.logger.error(f"Error in on_type_formatting: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to format on type: {str(e)}")

    #     async def _handle_rename(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/rename request."""
    #         try:
    text_document = params['textDocument']
    position = params['position']
    new_name = params['newName']

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return {}

    doc = self.documents[uri]
    text = doc['text']
    line = position['line']
    character = position['character']

    #             # Get word at position
    lines = text.split('\n')
    #             if line >= len(lines):
    #                 return {}

    line_text = lines[line]

    #             # Find word boundaries
    start = character
    #             while start 0 and (line_text[start-1].isalnum() or line_text[start-1] == '_')):
    start - = 1

    end = character
    #             while end < len(line_text) and (line_text[end].isalnum() or line_text[end] == '_'):
    end + = 1

    word = line_text[start:end]

    #             # Find all occurrences in document
    changes = {}
    #             for i, doc_line in enumerate(lines):
    #                 if word in doc_line:
    #                     # Find all occurrences in this line
    start_idx = 0
    #                     while True:
    idx = doc_line.find(word, start_idx)
    #                         if idx == -1:
    #                             break

    #                         # Check if it's a whole word
    is_word_start = (idx = 0 or not (doc_line[idx-1].isalnum() or doc_line[idx-1] == '_'))
    is_word_end = (idx + len(word) == len(doc_line) or not (doc_line[idx + len(word)].isalnum() or doc_line[idx + len(word)] == '_'))

    #                         if is_word_start and is_word_end:
    #                             if uri not in changes:
    changes[uri] = []

                                changes[uri].append({
    #                                 'range': {
    #                                     'start': {'line': i, 'character': idx},
                                        'end': {'line': i, 'character': idx + len(word)}
    #                                 },
    #                                 'newText': new_name
    #                             })

    start_idx = idx + 1

    #             return {
    #                 'documentChanges': [
    #                     {
    #                         'textDocument': {'uri': uri, 'version': doc['version']},
                            'edits': changes.get(uri, [])
    #                     }
    #                 ]
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in rename: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to rename: {str(e)}")

    #     async def _handle_prepare_rename(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle textDocument/prepareRename request."""
    #         try:
    text_document = params['textDocument']
    position = params['position']

    uri = text_document['uri']

    #             # Check if document exists
    #             if uri not in self.documents:
    #                 return None

    doc = self.documents[uri]
    text = doc['text']
    line = position['line']
    character = position['character']

    #             # Get word at position
    lines = text.split('\n')
    #             if line >= len(lines):
    #                 return None

    line_text = lines[line]

    #             # Find word boundaries
    start = character
    #             while start 0 and (line_text[start-1].isalnum() or line_text[start-1] == '_')):
    start - = 1

    end = character
    #             while end < len(line_text) and (line_text[end].isalnum() or line_text[end] == '_'):
    end + = 1

    #             # Check if we found a word
    #             if start < end:
    #                 return {
    #                     'range': {
    #                         'start': {'line': line, 'character': start},
    #                         'end': {'line': line, 'character': end}
    #                     },
    #                     'placeholder': line_text[start:end]
    #                 }
    #             else:
    #                 return None

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in prepare_rename: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to prepare rename: {str(e)}")

    #     async def _handle_execute_command(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle workspace/executeCommand request."""
    #         try:
    command = params['command']
    arguments = params.get('arguments', [])

    #             if command == 'noodlecore.format':
    #                 # Format document
    #                 return {'success': True, 'message': 'Document formatted'}
    #             elif command == 'noodlecore.validate':
    #                 # Validate document
    #                 return {'success': True, 'message': 'Document validated'}
    #             elif command == 'noodlecore.optimize':
    #                 # Optimize document
    #                 return {'success': True, 'message': 'Document optimized'}
    #             elif command == 'noodlecore.refactor':
    #                 # Refactor document
    #                 return {'success': True, 'message': 'Document refactored'}
    #             else:
                    raise LspError(
    #                     LSP_ERROR_CODES["UNKNOWN_ERROR_CODE"],
    #                     f"Unknown command: {command}"
    #                 )

    #         except LspError:
    #             raise
    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in execute_command: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to execute command: {str(e)}")

    #     async def _handle_workspace_configuration(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle workspace/configuration request."""
    #         try:
    items = params['items']

    #             # Get configuration for each item
    configurations = []

    #             for item in items:
    section = item.get('section', '')
    scope_uri = item.get('scopeUri', '')

    #                 # Get configuration based on section
    config = {}

    #                 if section == 'noodlecore':
    config = {
    #                         'lsp_port': 8080,
    #                         'auto_start': True,
    #                         'real_time_validation': True,
    #                         'ai_assistant': {
    #                             'enabled': True,
    #                             'inline_suggestions': True,
    #                             'model': 'zai_glm'
    #                         },
    #                         'completion': {
    #                             'enabled': True,
    #                             'ai_powered': True,
    #                             'max_suggestions': 10
    #                         },
    #                         'validation': {
    #                             'real_time': True,
    #                             'semantic': True,
    #                             'security_scan': True
    #                         },
    #                         'sandbox': {
    #                             'preview_enabled': True,
    #                             'auto_approve_safe': False,
    #                             'execution_timeout': 30
    #                         }
    #                     }

                    configurations.append(config)

    #             return configurations

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in workspace_configuration: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to get workspace configuration: {str(e)}")

    #     async def _handle_workspace_apply_edit(self, params: Dict[str, Any]) -Dict[str, Any]):
    #         """Handle workspace/applyEdit request."""
    #         try:
    edit = params['edit']

    #             # Apply edit to documents
    #             for document_change in edit.get('documentChanges', []):
    text_document = document_change['textDocument']
    uri = text_document['uri']
    version = text_document.get('version')

    #                 if uri in self.documents:
    doc = self.documents[uri]

    #                     # Apply edits
    #                     for edit_item in document_change.get('edits', []):
    range = edit_item['range']
    new_text = edit_item['newText']

    #                         # Apply edit to document text
    lines = doc['text'].split('\n')

    start_line = range['start']['line']
    start_char = range['start']['character']
    end_line = range['end']['line']
    end_char = range['end']['character']

    #                         if start_line == end_line:
    #                             # Single line edit
    line = lines[start_line]
    lines[start_line] = (
    #                                 line[:start_char] +
    #                                 new_text +
    #                                 line[end_char:]
    #                             )
    #                         else:
                                # Multi-line edit (simplified)
    lines[start_line] = (
    #                                 lines[start_line][:start_char] +
    #                                 new_text +
    #                                 lines[end_line][end_char:]
    #                             )
    #                             del lines[start_line+1:end_line+1]

    doc['text'] = '\n'.join(lines)
    doc['version'] = version + 1
    doc['last_modified'] = datetime.now()

    #             return {
    #                 'applied': True,
    #                 'failureReason': ''
    #             }

    #         except Exception as e:
    error_code = NOODLE_LSP_ERROR_CODES["INTERNAL_ERROR"]
    self.logger.error(f"Error in workspace_apply_edit: {str(e)}", exc_info = True)
                raise LspError(error_code, f"Failed to apply workspace edit: {str(e)}")

    #     async def get_server_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the LSP server.

    #         Returns:
    #             Dictionary containing LSP server information
    #         """
    #         return {
    #             'name': self.name,
    #             'version': '1.0.0',
    #             'host': self.host,
    #             'port': self.port,
    #             'running': self.running,
    #             'initialized': self.initialized,
    #             'language': 'NoodleCore',
    #             'language_features': self.language_features,
    #             'supported_file_types': self.supported_file_types,
    #             'workspace_root': self.workspace_root,
                'open_documents': len(self.documents),
    #             'performance_stats': self.performance_stats,
    #             'features': [
    #                 'code_completion',
    #                 'diagnostics',
    #                 'hover_information',
    #                 'go_to_definition',
    #                 'find_references',
    #                 'document_symbols',
    #                 'workspace_symbols',
    #                 'code_actions',
    #                 'document_formatting',
    #                 'rename_symbol',
    #                 'signature_help',
    #                 'declaration',
    #                 'type_definition',
    #                 'implementation',
    #                 'document_highlight',
    #                 'code_lens',
    #                 'document_link',
    #                 'document_color',
    #                 'execute_command',
    #                 'workspace_configuration',
    #                 'workspace_apply_edit'
    #             ],
                'request_id': str(uuid.uuid4())
    #         }