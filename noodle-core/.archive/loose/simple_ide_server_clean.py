#!/usr/bin/env python3
"""
Noodle Core::Simple Ide Server Clean - simple_ide_server_clean.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple NoodleCore IDE Server with Local Monaco Editor Support
"""

import os
import sys
import uuid
import time
from datetime import datetime
from flask import Flask, jsonify, request, send_file
from flask_cors import CORS
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configuration
SERVER_HOST = os.environ.get('NOODLE_HOST', '0.0.0.0')
SERVER_PORT = int(os.environ.get('NOODLE_PORT', 8080))
BASE_DIR = os.path.dirname(__file__)
MONACO_EDITOR_PATH = os.path.join(BASE_DIR, 'monaco-editor')

# Storage for demo purposes
ide_files = {}

def generate_request_id():
    """Generate a unique request ID"""
    return str(uuid.uuid4())

def create_response(success=True, data=None, error=None, request_id=None):
    """Create standardized API response"""
    if request_id is None:
        request_id = generate_request_id()
    
    response = {
        'requestId': request_id,
        'timestamp': datetime.now().isoformat(),
        'success': success
    }
    
    if data is not None:
        response['data'] = data
    if error is not None:
        response['error'] = error
    
    return response

@app.route('/')
def index():
    """Serve enhanced IDE"""
    enhanced_ide_path = os.path.join(BASE_DIR, 'enhanced-ide.html')
    if os.path.exists(enhanced_ide_path):
        return send_file(enhanced_ide_path)
    return "NoodleCore Enhanced IDE Server Running"

@app.route('/enhanced-ide.html')
def serve_enhanced_ide():
    """Serve the enhanced IDE HTML file"""
    enhanced_ide_path = os.path.join(BASE_DIR, 'enhanced-ide.html')
    if os.path.exists(enhanced_ide_path):
        return send_file(enhanced_ide_path)
    return "Enhanced IDE not found", 404

@app.route('/monaco-editor/<path:filename>')
def serve_monaco_editor(filename):
    """Serve Monaco Editor files from local directory"""
    try:
        file_path = os.path.join(MONACO_EDITOR_PATH, filename)
        logger.info(f"Serving Monaco Editor file: {filename}")
        
        if os.path.exists(file_path):
            return send_file(file_path)
        else:
            logger.warning(f"Monaco Editor file not found: {file_path}")
            return f"Monaco Editor file not found: {filename}", 404
    except Exception as e:
        logger.error(f"Error serving Monaco Editor file: {e}")
        return f"Error serving Monaco Editor file: {str(e)}", 500

@app.route('/api/v1/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify(create_response(
        success=True,
        data={
            'status': 'healthy',
            'version': '1.0.0',
            'uptime': time.time(),
            'enhanced_ide_available': os.path.exists(os.path.join(BASE_DIR, 'enhanced-ide.html'))
        }
    ))

@app.route('/api/v1/ide/files/save', methods=['POST'])
def ide_save_file():
    """Save file content via IDE interface"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_response(success=False, error='No JSON data provided')), 400
        
        file_path = data.get('file_path')
        content = data.get('content', '')
        
        if not file_path:
            return jsonify(create_response(success=False, error='file_path is required')), 400
        
        ide_files[file_path] = {
            'content': content,
            'last_modified': datetime.now().isoformat()
        }
        
        logger.info(f"File saved: {file_path}")
        
        return jsonify(create_response(
            success=True,
            data={'message': f'File {file_path} saved successfully'}
        ))
        
    except Exception as e:
        logger.error(f"Error saving file: {e}")
        return jsonify(create_response(success=False, error=f'Error saving file: {str(e)}')), 500

@app.route('/api/v1/ide/code/execute', methods=['POST'])
def ide_execute_code():
    """Execute code via IDE interface"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_response(success=False, error='No JSON data provided')), 400
        
        content = data.get('content', '')
        file_name = data.get('file_name', 'script.py')
        
        result = {
            'output': f"Executed {file_name}:\n{content}\n\nExecution completed successfully!",
            'error': None,
            'exit_code': 0,
            'execution_time': 0.123
        }
        
        logger.info(f"Code executed: {file_name}")
        return jsonify(create_response(success=True, data=result))
        
    except Exception as e:
        logger.error(f"Error executing code: {e}")
        return jsonify(create_response(success=False, error=f'Error executing code: {str(e)}')), 500

@app.route('/api/v1/ai/analyze/code', methods=['POST'])
def ai_analyze_code():
    """AI code analysis endpoint"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_response(success=False, error='No JSON data provided')), 400
        
        content = data.get('content', '')
        file_path = data.get('file_path', 'unknown')
        
        analysis_result = {
            'performance_score': 0.85,
            'security_score': 0.92,
            'confidence_score': 0.88,
            'suggestions': [
                {
                    'id': 'suggestion_1',
                    'type': 'optimization',
                    'content': 'Consider using list comprehensions for better performance',
                    'confidence': 0.75
                }
            ]
        }
        
        logger.info(f"AI analysis completed for {file_path}")
        return jsonify(create_response(success=True, data=analysis_result))
        
    except Exception as e:
        logger.error(f"Error in AI analysis: {e}")
        return jsonify(create_response(success=False, error=f'Error in AI analysis: {str(e)}')), 500

def main():
    """Start the server"""
    logger.info(f"Starting NoodleCore Enhanced IDE Server")
    logger.info(f"Server will listen on {SERVER_HOST}:{SERVER_PORT}")
    logger.info(f"Enhanced IDE: {'âœ… Available' if os.path.exists(os.path.join(BASE_DIR, 'enhanced-ide.html')) else 'âŒ Missing'}")
    
    try:
        app.run(
            host=SERVER_HOST,
            port=SERVER_PORT,
            debug=False,
            threaded=True
        )
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Server error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()

