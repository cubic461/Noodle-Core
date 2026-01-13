#!/usr/bin/env python3
"""
Noodle Core::Start Noodlecore Web Server - start_noodlecore_web_server.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Web Server Launcher

This script launches the NoodleCore web server to replace the Python
enhanced_file_server.py and provide web compatibility for the IDE.
"""

import sys
import os
import logging
import time
import signal
import threading
from pathlib import Path

# Add NoodleCore to Python path
sys.path.insert(0, str(Path(__file__).parent / "src"))

try:
    from noodlecore.web.web_server import NoodleCoreWebServer
    from noodlecore.web import WebServerError
except ImportError as e:
    print(f"Failed to import NoodleCore modules: {e}")
    print("Make sure NoodleCore is properly installed and accessible.")
    sys.exit(1)


def setup_logging():
    """Setup logging configuration."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('noodlecore-web.log')
        ]
    )


def signal_handler(signum, frame):
    """Handle shutdown signals."""
    print(f"\nReceived signal {signum}, shutting down...")
    global server
    if server:
        server.stop()
    sys.exit(0)


def main():
    """Main entry point for NoodleCore web server."""
    global server
    
    # Setup logging
    setup_logging()
    logger = logging.getLogger(__name__)
    
    # Register signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    print("ðŸš€ Starting NoodleCore Web Server...")
    print("=" * 50)
    
    try:
        # Create and start the web server
        server = NoodleCoreWebServer(port=8080, host="0.0.0.0")
        
        logger.info("Initializing NoodleCore web server...")
        
        if not server.start():
            logger.error("Failed to start NoodleCore web server")
            return 1
        
        print("âœ… NoodleCore Web Server started successfully!")
        print(f"ðŸŒ Server URL: http://localhost:8080")
        print(f"ðŸ“ Web Interface: http://localhost:8080/enhanced-ide.html")
        print(f"ðŸ”§ API Health: http://localhost:8080/api/v1/health")
        print("=" * 50)
        print("ðŸ“Š Available endpoints:")
        print("  â€¢ GET  /enhanced-ide.html")
        print("  â€¢ GET  /working-file-browser-ide.html")
        print("  â€¢ GET  /api/v1/health")
        print("  â€¢ GET  /api/v1/ide/files/list")
        print("  â€¢ POST /api/v1/ai/analyze")
        print("  â€¢ GET  /api/v1/search/files")
        print("  â€¢ GET  /api/v1/search/content")
        print("  â€¢ GET  /themes/dark.css")
        print("  â€¢ GET  /themes/light.css")
        print("  â€¢ GET  /demo/full-demo")
        print("  â€¢ GET  /demo/quick-demo")
        print("  â€¢ GET  /demo/performance-demo")
        print("  â€¢ GET  /monaco-editor/min/vs/*")
        print("=" * 50)
        print("ðŸ›‘ Press Ctrl+C to stop the server")
        print()
        
        # Keep server running
        while server.is_running:
            time.sleep(1)
            # Print server stats every 30 seconds
            if int(time.time()) % 30 == 0:
                stats = server.get_stats()
                print(f"ðŸ“ˆ Requests handled: {stats['requests_handled']}, "
                      f"Avg response: {stats['avg_response_time']:.3f}s, "
                      f"Uptime: {stats['uptime_seconds']:.0f}s")
        
        return 0
        
    except WebServerError as e:
        logger.error(f"NoodleCore Web Server error: {e}")
        print(f"âŒ NoodleCore Web Server error: {e}")
        return 1
        
    except KeyboardInterrupt:
        print("\nðŸ›‘ Shutting down NoodleCore Web Server...")
        return 0
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        print(f"âŒ Unexpected error: {e}")
        return 1
        
    finally:
        if 'server' in globals() and server:
            server.stop()
            print("âœ… NoodleCore Web Server stopped")


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

