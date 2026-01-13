# Noodle API Client for IDE operations
# Handles all communication with NoodleCore API
# Provides language-independent interface for IDE functionality

import asyncio
import json
import aiohttp
import logging
from dataclasses import dataclass
from enum import Enum
from typing import Dict, List, Optional, Any, Union

@dataclass
class APIResponse
    """Standard API response structure"""
    success: bool
    data: Any = None
    error: str = None
    status_code: int = 200
    timestamp: str = None
    
    def __post_init__(self):
        if self.timestamp is None:
            import datetime
            self.timestamp = datetime.datetime.now().isoformat()

@dataclass
class FileInfo
    """File information structure"""
    path: str
    name: str
    size: int
    modified: str
    is_directory: bool = False
    content: str = None
    language: str = "unknown"

@dataclass
class ProjectInfo
    """Project information structure"""
    name: str
    path: str
    description: str
    files: List[FileInfo]
    config: Dict[str, Any]

class APIEndpoint(Enum)
    """NoodleCore API endpoints"""
    # Core endpoints
    ROOT = "/"
    HEALTH = "/api/v1/health"
    DATABASE_STATUS = "/api/v1/database/status"
    RUNTIME_STATUS = "/api/v1/runtime/status"
    
    # IDE-specific endpoints
    IDE_STATUS = "/api/v1/ide/status"
    IDE_OPEN_FILE = "/api/v1/ide/file/open"
    IDE_SAVE_FILE = "/api/v1/ide/file/save"
    IDE_LIST_FILES = "/api/v1/ide/file/list"
    IDE_CREATE_FILE = "/api/v1/ide/file/create"
    IDE_DELETE_FILE = "/api/v1/ide/file/delete"
    IDE_EXECUTE = "/api/v1/ide/execute"
    IDE_SYNTAX_HIGHLIGHT = "/api/v1/ide/syntax/highlight"
    IDE_COMPLETIONS = "/api/v1/ide/completions"
    IDE_PROJECT_CREATE = "/api/v1/ide/project/create"
    IDE_PROJECT_OPEN = "/api/v1/ide/project/open"
    IDE_PROJECT_CLOSE = "/api/v1/ide/project/close"

class NoodleAPIClient
    """NoodleCore API client for IDE operations
    
    This client provides a complete interface to all NoodleCore API endpoints
    used by the IDE, ensuring language independence and version compatibility.
    """

    def __init__(self, base_url: str = "http://localhost:8080", timeout: int = 30):
        """Initialize the API client
        
        Args:
            base_url: Base URL for NoodleCore API
            timeout: Request timeout in seconds
        """
        self.base_url = base_url.rstrip('/')
        self.timeout = timeout
        self.session = None
        
        # Connection management
        self._connection_pool = None
        self._is_connected = False
        
        # Performance metrics
        self.request_count = 0
        self.error_count = 0
        self.average_response_time = 0.0
        
        # Setup logging
        self.logger = logging.getLogger(__name__)

    async def __aenter__(self):
        """Async context manager entry"""
        await self.connect()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit"""
        await self.disconnect()

    async def connect(self):
        """Establish connection to NoodleCore"""
        try:
            # Create aiohttp session with connection pooling
            timeout = aiohttp.ClientTimeout(total=self.timeout)
            self.session = aiohttp.ClientSession(
                timeout=timeout,
                headers={
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'User-Agent': 'NoodleIDE/1.0'
                }
            )
            
            # Test connection
            await self.health_check()
            
            self._is_connected = True
            self.logger.info(f"Connected to NoodleCore at {self.base_url}")
            
        except Exception as e:
            self.logger.error(f"Failed to connect to NoodleCore: {e}")
            raise ConnectionError(f"Cannot connect to NoodleCore: {e}")

    async def disconnect(self):
        """Close connection to NoodleCore"""
        if self.session:
            await self.session.close()
            self.session = None
        
        self._is_connected = False
        self.logger.info("Disconnected from NoodleCore")

    async def health_check(self) -> APIResponse:
        """Check NoodleCore health status"""
        return await self._make_request("GET", APIEndpoint.HEALTH)

    async def get_status(self) -> APIResponse:
        """Get IDE status"""
        return await self._make_request("GET", APIEndpoint.IDE_STATUS)

    # File Operations
    async def open_file(self, file_path: str) -> APIResponse:
        """Open a file"""
        data = {"file_path": file_path}
        return await self._make_request("POST", APIEndpoint.IDE_OPEN_FILE, data)

    async def save_file(self, file_path: str, content: str, language: str = "noodle") -> APIResponse:
        """Save a file"""
        data = {
            "file_path": file_path,
            "content": content,
            "language": language
        }
        return await self._make_request("POST", APIEndpoint.IDE_SAVE_FILE, data)

    async def create_file(self, file_path: str, content: str = "", language: str = "noodle") -> APIResponse:
        """Create a new file"""
        data = {
            "file_path": file_path,
            "content": content,
            "language": language
        }
        return await self._make_request("POST", APIEndpoint.IDE_CREATE_FILE, data)

    async def delete_file(self, file_path: str) -> APIResponse:
        """Delete a file"""
        data = {"file_path": file_path}
        return await self._make_request("POST", APIEndpoint.IDE_DELETE_FILE, data)

    async def list_files(self, directory: str = "") -> APIResponse:
        """List files in directory"""
        data = {"directory": directory} if directory else {}
        return await self._make_request("POST", APIEndpoint.IDE_LIST_FILES, data)

    async def close_file(self, file_path: str) -> APIResponse:
        """Close an open file"""
        data = {"file_path": file_path}
        return await self._make_request("POST", APIEndpoint.IDE_OPEN_FILE, data)

    # Code Execution
    async def execute_code(self, code: str, language: str = "noodle") -> APIResponse:
        """Execute code"""
        data = {
            "code": code,
            "language": language
        }
        return await self._make_request("POST", APIEndpoint.IDE_EXECUTE, data)

    async def debug_code(self, code: str, language: str = "noodle", breakpoint_lines: List[int] = None) -> APIResponse:
        """Debug code with optional breakpoints"""
        data = {
            "code": code,
            "language": language,
            "breakpoint_lines": breakpoint_lines or []
        }
        return await self._make_request("POST", APIEndpoint.IDE_EXECUTE, data)

    # Syntax and Editing
    async def get_syntax_highlight(self, code: str, language: str = "noodle") -> APIResponse:
        """Get syntax highlighting for code"""
        data = {
            "code": code,
            "language": language
        }
        return await self._make_request("POST", APIEndpoint.IDE_SYNTAX_HIGHLIGHT, data)

    async def get_code_completions(self, code: str, position: Dict[str, int], language: str = "noodle") -> APIResponse:
        """Get code completions at position"""
        data = {
            "code": code,
            "position": position,
            "language": language
        }
        return await self._make_request("POST", APIEndpoint.IDE_COMPLETIONS, data)

    async def analyze_code(self, code: str, language: str = "noodle") -> APIResponse:
        """Analyze code for errors and suggestions"""
        data = {
            "code": code,
            "language": language
        }
        return await self._make_request("POST", APIEndpoint.IDE_SYNTAX_HIGHLIGHT, data)

    # Project Management
    async def create_project(self, project_name: str, project_path: str, description: str = "") -> APIResponse:
        """Create a new project"""
        data = {
            "project_name": project_name,
            "project_path": project_path,
            "description": description
        }
        return await self._make_request("POST", APIEndpoint.IDE_PROJECT_CREATE, data)

    async def open_project(self, project_path: str) -> APIResponse:
        """Open a project"""
        data = {"project_path": project_path}
        return await self._make_request("POST", APIEndpoint.IDE_PROJECT_OPEN, data)

    async def close_project(self, project_path: str) -> APIResponse:
        """Close a project"""
        data = {"project_path": project_path}
        return await self._make_request("POST", APIEndpoint.IDE_PROJECT_CLOSE, data)

    async def get_project_info(self, project_path: str) -> APIResponse:
        """Get project information"""
        # This would be implemented with a dedicated endpoint
        return await self.list_files(project_path)

    # Configuration
    async def save_configuration(self, config_key: str, config_data: Dict[str, Any]) -> APIResponse:
        """Save configuration data"""
        data = {
            "config_key": config_key,
            "config_data": config_data
        }
        return await self._make_request("POST", APIEndpoint.IDE_STATUS, data)

    async def load_configuration(self, config_key: str) -> APIResponse:
        """Load configuration data"""
        data = {"config_key": config_key}
        return await self._make_request("POST", APIEndpoint.IDE_STATUS, data)

    # IDE State
    async def save_ide_state(self, state_data: Dict[str, Any]) -> APIResponse:
        """Save current IDE state"""
        return await self.save_configuration("ide_state", state_data)

    async def load_ide_state(self) -> APIResponse:
        """Load saved IDE state"""
        return await self.load_configuration("ide_state")

    # Utility Methods
    async def test_connection(self) -> bool:
        """Test if API connection is working"""
        try:
            response = await self.health_check()
            return response.success
        except Exception:
            return False

    async def get_api_info(self) -> APIResponse:
        """Get API server information"""
        return await self._make_request("GET", APIEndpoint.ROOT)

    async def get_runtime_info(self) -> APIResponse:
        """Get runtime system information"""
        return await self._make_request("GET", APIEndpoint.RUNTIME_STATUS)

    async def get_database_info(self) -> APIResponse:
        """Get database status information"""
        return await self._make_request("GET", APIEndpoint.DATABASE_STATUS)

    # Internal Methods
    async def _make_request(self, method: str, endpoint: APIEndpoint, data: Dict[str, Any] = None) -> APIResponse:
        """Make HTTP request to NoodleCore API"""
        if not self._is_connected:
            await self.connect()
        
        url = self.base_url + endpoint.value
        start_time = asyncio.get_event_loop().time()
        
        try:
            self.request_count += 1
            
            if method.upper() == "GET":
                async with self.session.get(url) as response:
                    result = await self._process_response(response)
            else:
                json_data = json.dumps(data) if data else None
                async with self.session.request(method, url, data=json_data) as response:
                    result = await self._process_response(response)
            
            # Update performance metrics
            response_time = asyncio.get_event_loop().time() - start_time
            self._update_performance_metrics(response_time, True)
            
            return result
            
        except aiohttp.ClientError as e:
            self.error_count += 1
            response_time = asyncio.get_event_loop().time() - start_time
            self._update_performance_metrics(response_time, False)
            
            self.logger.error(f"API request failed: {e}")
            return APIResponse(
                success=False,
                error=f"Network error: {str(e)}",
                status_code=503
            )
        except Exception as e:
            self.error_count += 1
            response_time = asyncio.get_event_loop().time() - start_time
            self._update_performance_metrics(response_time, False)
            
            self.logger.error(f"Unexpected error: {e}")
            return APIResponse(
                success=False,
                error=f"Unexpected error: {str(e)}",
                status_code=500
            )

    async def _process_response(self, response) -> APIResponse:
        """Process HTTP response"""
        try:
            content_type = response.headers.get('content-type', '')
            
            if 'application/json' in content_type:
                data = await response.json()
            else:
                # Handle non-JSON responses
                text = await response.text()
                try:
                    data = json.loads(text)
                except json.JSONDecodeError:
                    data = {"raw_response": text}
            
            # Standardize response format
            if isinstance(data, dict):
                if 'success' in data:
                    return APIResponse(
                        success=data.get('success', False),
                        data=data.get('data'),
                        error=data.get('error'),
                        status_code=response.status,
                        timestamp=data.get('timestamp')
                    )
                else:
                    # Assume it's data if not in standard format
                    return APIResponse(
                        success=True,
                        data=data,
                        status_code=response.status
                    )
            else:
                return APIResponse(
                    success=True,
                    data=data,
                    status_code=response.status
                )
                
        except json.JSONDecodeError as e:
            return APIResponse(
                success=False,
                error=f"Invalid JSON response: {str(e)}",
                status_code=500
            )
        except Exception as e:
            return APIResponse(
                success=False,
                error=f"Error processing response: {str(e)}",
                status_code=500
            )

    def _update_performance_metrics(self, response_time: float, success: bool):
        """Update performance metrics"""
        # Update average response time
        if success:
            if self.average_response_time == 0:
                self.average_response_time = response_time
            else:
                # Exponential moving average
                alpha = 0.1
                self.average_response_time = (alpha * response_time + 
                                           (1 - alpha) * self.average_response_time)

    def get_performance_stats(self) -> Dict[str, Any]:
        """Get API client performance statistics"""
        return {
            "total_requests": self.request_count,
            "error_count": self.error_count,
            "success_rate": (self.request_count - self.error_count) / max(1, self.request_count),
            "average_response_time_ms": self.average_response_time * 1000,
            "is_connected": self._is_connected,
            "base_url": self.base_url
        }

    def __str__(self):
        return f"NoodleAPIClient(url={self.base_url}, connected={self._is_connected})"

    def __repr__(self):
        return f"NoodleAPIClient(requests={self.request_count}, errors={self.error_count})"

# Utility Functions
async def create_api_client(base_url: str = "http://localhost:8080", timeout: int = 30) -> NoodleAPIClient:
    """Factory function to create and connect API client"""
    client = NoodleAPIClient(base_url, timeout)
    await client.connect()
    return client

async def test_noodle_core_connection(base_url: str = "http://localhost:8080") -> Dict[str, Any]:
    """Test NoodleCore connection and return status"""
    try:
        async with NoodleAPIClient(base_url) as client:
            # Test multiple endpoints
            health_response = await client.health_check()
            api_response = await client.get_api_info()
            
            return {
                "connected": health_response.success,
                "health_status": health_response,
                "api_info": api_response,
                "performance_stats": client.get_performance_stats()
            }
    except Exception as e:
        return {
            "connected": False,
            "error": str(e)
        }