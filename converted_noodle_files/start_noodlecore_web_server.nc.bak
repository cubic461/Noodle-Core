# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# NoodleCore Web Server Launcher

# This script launches the NoodleCore web server to replace the Python
# enhanced_file_server.py and provide web compatibility for the IDE.
# """

import sys
import os
import logging
import time
import signal
import threading
import pathlib.Path

# Add NoodleCore to Python path
sys.path.insert(0, str(Path(__file__).parent / "src"))

try
    #     from noodlecore.web.web_server import NoodleCoreWebServer
    #     from noodlecore.web import WebServerError
except ImportError as e
        print(f"Failed to import NoodleCore modules: {e}")
        print("Make sure NoodleCore is properly installed and accessible.")
        sys.exit(1)


function setup_logging()
    #     """Setup logging configuration."""
        logging.basicConfig(
    level = logging.INFO,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers = [
                logging.StreamHandler(),
                logging.FileHandler('noodlecore-web.log')
    #         ]
    #     )


function signal_handler(signum, frame)
    #     """Handle shutdown signals."""
        print(f"\nReceived signal {signum}, shutting down...")
    #     global server
    #     if server:
            server.stop()
        sys.exit(0)


function main()
    #     """Main entry point for NoodleCore web server."""
    #     global server

    #     # Setup logging
        setup_logging()
    logger = logging.getLogger(__name__)

    #     # Register signal handlers
        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)

        print("🚀 Starting NoodleCore Web Server...")
    print(" = " * 50)

    #     try:
    #         # Create and start the web server
    server = NoodleCoreWebServer(port=8080, host="0.0.0.0")

            logger.info("Initializing NoodleCore web server...")

    #         if not server.start():
                logger.error("Failed to start NoodleCore web server")
    #             return 1

            print("✅ NoodleCore Web Server started successfully!")
            print(f"🌐 Server URL: http://localhost:8080")
            print(f"📁 Web Interface: http://localhost:8080/enhanced-ide.html")
            print(f"🔧 API Health: http://localhost:8080/api/v1/health")
    print(" = " * 50)
            print("📊 Available endpoints:")
            print("  • GET  /enhanced-ide.html")
            print("  • GET  /working-file-browser-ide.html")
            print("  • GET  /api/v1/health")
            print("  • GET  /api/v1/ide/files/list")
            print("  • POST /api/v1/ai/analyze")
            print("  • GET  /api/v1/search/files")
            print("  • GET  /api/v1/search/content")
            print("  • GET  /themes/dark.css")
            print("  • GET  /themes/light.css")
            print("  • GET  /demo/full-demo")
            print("  • GET  /demo/quick-demo")
            print("  • GET  /demo/performance-demo")
            print("  • GET  /monaco-editor/min/vs/*")
    print(" = " * 50)
            print("🛑 Press Ctrl+C to stop the server")
            print()

    #         # Keep server running
    #         while server.is_running:
                time.sleep(1)
    #             # Print server stats every 30 seconds
    #             if int(time.time()) % 30 == 0:
    stats = server.get_stats()
                    print(f"📈 Requests handled: {stats['requests_handled']}, "
    #                       f"Avg response: {stats['avg_response_time']:.3f}s, "
    #                       f"Uptime: {stats['uptime_seconds']:.0f}s")

    #         return 0

    #     except WebServerError as e:
            logger.error(f"NoodleCore Web Server error: {e}")
            print(f"❌ NoodleCore Web Server error: {e}")
    #         return 1

    #     except KeyboardInterrupt:
            print("\n🛑 Shutting down NoodleCore Web Server...")
    #         return 0

    #     except Exception as e:
            logger.error(f"Unexpected error: {e}")
            print(f"❌ Unexpected error: {e}")
    #         return 1

    #     finally:
    #         if 'server' in globals() and server:
                server.stop()
                print("✅ NoodleCore Web Server stopped")


if __name__ == "__main__"
    exit_code = main()
        sys.exit(exit_code)