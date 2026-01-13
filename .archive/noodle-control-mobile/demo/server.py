#!/usr/bin/env python3
"""
Demo::Server - server.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import http.server
import socketserver
import os
import logging
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

PORT = 8081
HOST = "0.0.0.0"  # Explicitly bind to all interfaces

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()
    
    def log_message(self, format, *args):
        """Override log_message to use our logging system"""
        logging.info(f"{self.address_string()} - {format % args}")
    
    def do_get(self):
        """Handle GET requests with detailed logging"""
        file_path = os.path.join(os.getcwd(), self.path.lstrip('/'))
        if os.path.exists(file_path):
            logging.info(f"Serving file: {file_path}")
        else:
            logging.warning(f"File not found: {file_path}")
        super().do_GET()
    
    def do_GET(self):
        """Override GET to add more detailed logging"""
        self.do_get()

if __name__ == "__main__":
    # Change to the directory containing this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    logging.info(f"Changed working directory to: {script_dir}")
    
    # List files in the directory for debugging
    logging.info("Files in directory:")
    for file in os.listdir(script_dir):
        logging.info(f"  - {file}")
    
    try:
        with socketserver.TCPServer((HOST, PORT), MyHTTPRequestHandler) as httpd:
            logging.info(f"Starting frontend server on {HOST}:{PORT}")
            logging.info(f"Server accessible at: http://localhost:{PORT}")
            logging.info("Press Ctrl+C to stop the server")
            
            try:
                httpd.serve_forever()
            except KeyboardInterrupt:
                logging.info("\nServer stopped by user")
    except OSError as e:
        logging.error(f"Failed to start server: {e}")
        logging.error(f"Port {PORT} might be in use by another application")
        sys.exit(1)

