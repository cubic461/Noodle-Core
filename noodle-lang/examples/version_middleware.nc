# Converted from Python to NoodleCore
# Original file: src

# """
# API Versioning Middleware for NoodleCore
# ----------------------------------------

# This module provides middleware for handling API versioning in the NoodleCore project.
# It supports multiple API versions simultaneously, maintains backward compatibility,
# and provides clear version deprecation and migration paths.

# The middleware follows RESTful versioning best practices with version numbers in URLs
(e.g., /api/v1/, /api/v2/).
# """

import logging
import re
import typing.Any
from functools import wraps
import flask.Flask
import werkzeug.exceptions.NotFound

import .response_format.error_response

logger = logging.getLogger(__name__)

# Version configuration
SUPPORTED_VERSIONS = ["v1", "v2"]
DEFAULT_VERSION = "v1"
DEPRECATED_VERSIONS = {}  # version - deprecation info
VERSION_ENDPOINTS = {}  # version - > {endpoint): handler}


class APIVersionMiddleware
    #     """
    #     Flask middleware for handling API versioning.

    #     This middleware:
    #     - Extracts the API version from the request URL
    #     - Routes requests to the appropriate version handlers
    #     - Provides default version handling for unversioned requests
    #     - Returns appropriate responses for unsupported versions
    #     """

    #     def __init__(self, app: Flask = None):
    #         """Initialize the versioning middleware."""
    self.app = app
    #         if app is not None:
                self.init_app(app)

    #     def init_app(self, app: Flask):
    #         """Initialize the middleware with Flask app."""
            app.before_request(self._before_request)
            app.after_request(self._after_request)

    #         # Register version info endpoint
    app.route("/api/versions", methods = ["GET"])
    #         def get_versions():
    #             """Get information about supported API versions."""
    versions_info = {
    #                 "supported": SUPPORTED_VERSIONS,
    #                 "default": DEFAULT_VERSION,
    #                 "deprecated": DEPRECATED_VERSIONS,
    #                 "current": g.api_version if hasattr(g, 'api_version') else DEFAULT_VERSION
    #             }
    #             from .response_format import success_response
    return success_response(versions_info, request_id = get_request_id())

    #     def _before_request(self):
    #         """Process request before it reaches the endpoint handler."""
    #         # Extract version from URL path
    path = request.path
    version = self._extract_version_from_path(path)

    #         # Store version in request context
    g.api_version = version

    #         # Check if version is supported
    #         if version not in SUPPORTED_VERSIONS:
                logger.warning(f"Unsupported API version requested: {version}")
                return error_response(
    #                 f"API version {version} is not supported",
    status_code = 400,
    request_id = get_request_id()
    #             )

    #         # Check if version is deprecated
    #         if version in DEPRECATED_VERSIONS:
    deprecation_info = DEPRECATED_VERSIONS[version]
                logger.warning(f"Deprecated API version requested: {version}")
    #             # Add deprecation warning to response headers
    g.deprecation_warning = {
    #                 "version": version,
                    "deprecated_in": deprecation_info.get("deprecated_in"),
                    "removal_in": deprecation_info.get("removal_in"),
                    "use_version": deprecation_info.get("use_version"),
                    "message": deprecation_info.get("message")
    #             }

    #     def _after_request(self, response):
    #         """Process response after it's generated."""
    #         # Add version headers
    #         if hasattr(g, 'api_version'):
    response.headers['X-API-Version'] = g.api_version

    #         # Add deprecation warning if applicable
    #         if hasattr(g, 'deprecation_warning'):
    response.headers['X-API-Deprecated'] = 'true'
    #             for key, value in g.deprecation_warning.items():
    response.headers[f'X-API-Deprecated-{key.title()}'] = str(value)

    #         return response

    #     def _extract_version_from_path(self, path: str) -str):
    #         """
    #         Extract API version from the request path.

    #         Args:
    #             path: The request path

    #         Returns:
    #             The extracted version or default version
    #         """
    #         # Check for /api/vX/ pattern
    match = re.match(r'^/api/(v\d+)/', path)
    #         if match:
                return match.group(1)

    #         # Return default version for unversioned requests
    #         return DEFAULT_VERSION


function version_endpoint(version: str, path: str)
    #     """
    #     Decorator to register an endpoint for a specific API version.

    #     Args:
            version: The API version (e.g., "v1", "v2")
            path: The endpoint path (without version prefix)

    #     Returns:
    #         Decorator function
    #     """
    #     def decorator(func: Callable):
    #         # Register the endpoint for the version
    #         if version not in VERSION_ENDPOINTS:
    VERSION_ENDPOINTS[version] = {}
    VERSION_ENDPOINTS[version][path] = func

            wraps(func)
    #         def wrapper(*args, **kwargs):
    #             # Check if the request is for the correct version
    #             if hasattr(g, 'api_version') and g.api_version != version:
    #                 # Try to find the endpoint for the requested version
    requested_version = g.api_version
    #                 if (requested_version in VERSION_ENDPOINTS and
    #                     path in VERSION_ENDPOINTS[requested_version]):
    #                     # Call the version-specific handler
                        return VERSION_ENDPOINTS[requested_version][path](*args, **kwargs)
    #                 else:
    #                     # No handler for this version, return error
                        return error_response(
    #                         f"Endpoint {path} not available in API version {requested_version}",
    status_code = 404,
    request_id = get_request_id()
    #                     )

    #             # Call the original function
                return func(*args, **kwargs)

    #         return wrapper
    #     return decorator


def deprecated_version(
#     version: str,
#     deprecated_in: str,
#     removal_in: str,
#     use_version: str,
message: str = None
# ):
#     """
#     Mark an API version as deprecated.

#     Args:
#         version: The API version to deprecate
#         deprecated_in: Version where it was deprecated
#         removal_in: Version where it will be removed
#         use_version: Recommended version to use instead
#         message: Custom deprecation message
#     """
DEPRECATED_VERSIONS[version] = {
#         "deprecated_in": deprecated_in,
#         "removal_in": removal_in,
#         "use_version": use_version,
#         "message": message or f"API version {version} is deprecated. Use {use_version} instead."
#     }


function register_versioned_endpoint(app: Flask, version: str, path: str, handler: Callable, methods: list = None)
    #     """
    #     Register a versioned endpoint with the Flask app.

    #     Args:
    #         app: Flask application instance
            version: API version (e.g., "v1", "v2")
            path: Endpoint path (without version prefix)
    #         handler: Endpoint handler function
            methods: HTTP methods (default: ["GET"])
    #     """
    #     if methods is None:
    methods = ["GET"]

    #     # Construct the full path with version prefix
    full_path = f"/api/{version}{path}"

    #     # Register the route
    app.route(full_path, methods = methods)(handler)

    #     # Store in version endpoints registry
    #     if version not in VERSION_ENDPOINTS:
    VERSION_ENDPOINTS[version] = {}
    VERSION_ENDPOINTS[version][path] = handler


def get_supported_versions() -list):
#     """Get list of supported API versions."""
    return SUPPORTED_VERSIONS.copy()


def get_default_version() -str):
#     """Get the default API version."""
#     return DEFAULT_VERSION


def is_version_supported(version: str) -bool):
#     """Check if an API version is supported."""
#     return version in SUPPORTED_VERSIONS


def is_version_deprecated(version: str) -bool):
#     """Check if an API version is deprecated."""
#     return version in DEPRECATED_VERSIONS


def get_version_deprecation_info(version: str) -Optional[Dict[str, Any]]):
#     """Get deprecation information for a version."""
    return DEPRECATED_VERSIONS.get(version)