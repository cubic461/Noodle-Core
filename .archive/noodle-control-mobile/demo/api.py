"""
Demo::Api - api.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

# NoodleControl Demo API

import os
import uuid
import time
import threading
from datetime import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_socketio import SocketIO, emit, join_room, leave_room

# Initialize Flask app
app = Flask(__name__)
# Configure CORS with specific settings
CORS(app,
     resources={r"/*": {"origins": "*"}},
     methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
     allow_headers=["Content-Type", "Authorization", "X-Requested-With"])

# Initialize SocketIO
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

# Configuration
NOODLE_ENV = os.getenv('NOODLE_ENV', 'development')
DEBUG = NOODLE_ENV == 'development'
NOODLE_PORT = int(os.getenv('NOODLE_PORT', 8082))

# In-memory storage for demo purposes
nodes = [
    {
        'id': 'node-01',
        'name': 'Node-01',
        'status': 'running',
        'ip_address': '192.168.1.101',
        'cpu_usage': 45,
        'memory_usage': 1.2,
        'last_updated': datetime.now().isoformat()
    },
    {
        'id': 'node-02',
        'name': 'Node-02',
        'status': 'running',
        'ip_address': '192.168.1.102',
        'cpu_usage': 67,
        'memory_usage': 2.1,
        'last_updated': datetime.now().isoformat()
    },
    {
        'id': 'node-03',
        'name': 'Node-03',
        'status': 'stopped',
        'ip_address': '192.168.1.103',
        'cpu_usage': 0,
        'memory_usage': 0,
        'last_updated': datetime.now().isoformat()
    },
    {
        'id': 'node-04',
        'name': 'Node-04',
        'status': 'error',
        'ip_address': '192.168.1.104',
        'cpu_usage': 0,
        'memory_usage': 0,
        'last_updated': datetime.now().isoformat()
    }
]

# Performance metrics
metrics = {
    'active_nodes': 2,
    'total_nodes': 4,
    'running_tasks': 12,
    'cpu_usage': 67,
    'memory_usage': 4.2,
    'network_traffic': 125,
    'disk_io': 45,
    'last_updated': datetime.now().isoformat()
}

# Helper function to create API response with requestId
def create_response(data, status_code=200):
    response = {
        'requestId': str(uuid.uuid4()),
        'data': data,
        'timestamp': datetime.now().isoformat(),
        'status': 'success' if status_code < 400 else 'error'
    }
    return jsonify(response), status_code

# Error handler
@app.errorhandler(404)
def not_found(error):
    return create_response({'error': 'Endpoint not found', 'code': 404}, 404)

@app.errorhandler(500)
def internal_error(error):
    return create_response({'error': 'Internal server error', 'code': 500}, 500)

@app.errorhandler(400)
def bad_request(error):
    return create_response({'error': 'Bad request', 'code': 400}, 400)

@app.errorhandler(405)
def method_not_allowed(error):
    return create_response({'error': 'Method not allowed', 'code': 405}, 405)

# API Routes

# Root endpoint
@app.route('/', methods=['GET'])
def root():
    """API root endpoint with basic information"""
    api_info = {
        'name': 'NoodleControl Demo API',
        'version': '1.0.0',
        'description': 'Demo API for NoodleControl mobile application',
        'endpoints': {
            'nodes': '/api/nodes',
            'node_actions': '/api/nodes/<node_id>/start|stop|restart',
            'metrics': '/api/metrics',
            'health': '/api/health'
        },
        'status': 'running'
    }
    return create_response(api_info)

@app.route('/api/nodes', methods=['GET'])
def get_nodes():
    """Get all nodes"""
    return create_response(nodes)

@app.route('/api/nodes/<node_id>/start', methods=['POST'])
def start_node(node_id):
    """Start a node"""
    for node in nodes:
        if node['id'] == node_id:
            node['status'] = 'running'
            node['last_updated'] = datetime.now().isoformat()
            # Simulate some resource usage
            node['cpu_usage'] = 30 + (hash(node_id) % 40)
            node['memory_usage'] = 1.0 + (hash(node_id) % 10) / 5.0
            
            # Update metrics
            metrics['active_nodes'] = sum(1 for n in nodes if n['status'] == 'running')
            metrics['last_updated'] = datetime.now().isoformat()
            
            # Emit WebSocket event for node status change
            socketio.emit('node_status_change', {
                'node': node,
                'action': 'started'
            }, room='noodle_control')
            
            # Emit updated metrics
            socketio.emit('metrics_update', metrics, room='noodle_control')
            
            return create_response({'message': f'Node {node_id} started successfully'})
    
    return create_response({'error': 'Node not found'}, 404)

@app.route('/api/nodes/<node_id>/stop', methods=['POST'])
def stop_node(node_id):
    """Stop a node"""
    for node in nodes:
        if node['id'] == node_id:
            node['status'] = 'stopped'
            node['cpu_usage'] = 0
            node['memory_usage'] = 0
            node['last_updated'] = datetime.now().isoformat()
            
            # Update metrics
            metrics['active_nodes'] = sum(1 for n in nodes if n['status'] == 'running')
            metrics['last_updated'] = datetime.now().isoformat()
            
            # Emit WebSocket event for node status change
            socketio.emit('node_status_change', {
                'node': node,
                'action': 'stopped'
            }, room='noodle_control')
            
            # Emit updated metrics
            socketio.emit('metrics_update', metrics, room='noodle_control')
            
            return create_response({'message': f'Node {node_id} stopped successfully'})
    
    return create_response({'error': 'Node not found'}, 404)

@app.route('/api/nodes/<node_id>/restart', methods=['POST'])
def restart_node(node_id):
    """Restart a node"""
    for node in nodes:
        if node['id'] == node_id:
            # First set to restarting
            node['status'] = 'restarting'
            node['last_updated'] = datetime.now().isoformat()
            
            # Emit WebSocket event for restart start
            socketio.emit('node_status_change', {
                'node': node,
                'action': 'restarting'
            }, room='noodle_control')
            
            # Simulate restart delay
            def complete_restart():
                time.sleep(2)  # Simulate 2 second restart
                node['status'] = 'running'
                node['cpu_usage'] = 30 + (hash(node_id) % 40)
                node['memory_usage'] = 1.0 + (hash(node_id) % 10) / 5.0
                node['last_updated'] = datetime.now().isoformat()
                
                # Update metrics
                metrics['active_nodes'] = sum(1 for n in nodes if n['status'] == 'running')
                metrics['last_updated'] = datetime.now().isoformat()
                
                # Emit WebSocket event for restart completion
                socketio.emit('node_status_change', {
                    'node': node,
                    'action': 'restarted'
                }, room='noodle_control')
                
                # Emit updated metrics
                socketio.emit('metrics_update', metrics, room='noodle_control')
            
            # Run restart in background thread
            thread = threading.Thread(target=complete_restart)
            thread.daemon = True
            thread.start()
            
            return create_response({'message': f'Node {node_id} restart initiated'})
    
    return create_response({'error': 'Node not found'}, 404)

@app.route('/api/metrics', methods=['GET'])
def get_metrics():
    """Get performance metrics"""
    # Simulate some fluctuation in metrics
    metrics['cpu_usage'] = max(20, min(90, metrics['cpu_usage'] + (hash(time.time()) % 10) - 5))
    metrics['memory_usage'] = max(1.0, min(8.0, metrics['memory_usage'] + (hash(time.time()) % 5) / 10.0 - 0.25))
    metrics['network_traffic'] = max(50, min(200, metrics['network_traffic'] + (hash(time.time()) % 20) - 10))
    metrics['disk_io'] = max(20, min(100, metrics['disk_io'] + (hash(time.time()) % 15) - 7))
    metrics['last_updated'] = datetime.now().isoformat()
    
    return create_response(metrics)

# Health check endpoint
@app.route('/api/health', methods=['GET'])
def health_check():
    """API health check"""
    return create_response({'status': 'healthy'})

# WebSocket event handlers
@socketio.on('connect')
def handle_connect():
    """Handle client connection"""
    print(f"Client connected: {request.sid}")
    join_room('noodle_control')
    
    # Send initial data to the newly connected client
    emit('initial_data', {
        'nodes': nodes,
        'metrics': metrics
    })
    
    # Broadcast notification to all clients
    emit('notification', {
        'type': 'info',
        'message': 'New client connected to the system',
        'timestamp': datetime.now().isoformat()
    }, room='noodle_control', include_self=False)

@socketio.on('disconnect')
def handle_disconnect():
    """Handle client disconnection"""
    print(f"Client disconnected: {request.sid}")
    leave_room('noodle_control')
    
    # Broadcast notification to remaining clients
    emit('notification', {
        'type': 'info',
        'message': 'A client disconnected from the system',
        'timestamp': datetime.now().isoformat()
    }, room='noodle_control', include_self=False)

@socketio.on('request_nodes')
def handle_request_nodes():
    """Handle request for nodes data"""
    emit('nodes_data', nodes)

@socketio.on('request_metrics')
def handle_request_metrics():
    """Handle request for metrics data"""
    emit('metrics_data', metrics)

# Background thread to periodically update metrics and broadcast changes
def broadcast_metrics():
    """Periodically update and broadcast metrics"""
    while True:
        time.sleep(5)  # Update every 5 seconds
        
        # Simulate metrics changes
        metrics['cpu_usage'] = max(20, min(90, metrics['cpu_usage'] + (hash(time.time()) % 10) - 5))
        metrics['memory_usage'] = max(1.0, min(8.0, metrics['memory_usage'] + (hash(time.time()) % 5) / 10.0 - 0.25))
        metrics['network_traffic'] = max(50, min(200, metrics['network_traffic'] + (hash(time.time()) % 20) - 10))
        metrics['disk_io'] = max(20, min(100, metrics['disk_io'] + (hash(time.time()) % 15) - 7))
        metrics['last_updated'] = datetime.now().isoformat()
        
        # Broadcast updated metrics to all connected clients
        socketio.emit('metrics_update', metrics, room='noodle_control')
        
        # Occasionally simulate node status changes
        if time.time() % 30 < 5:  # Approximately every 30 seconds
            import random
            if random.random() < 0.3:  # 30% chance
                node = random.choice(nodes)
                if node['status'] == 'running':
                    # Simulate resource usage changes
                    node['cpu_usage'] = max(10, min(95, node['cpu_usage'] + (hash(time.time()) % 20) - 10))
                    node['memory_usage'] = max(0.5, min(7.0, node['memory_usage'] + (hash(time.time()) % 10) / 10.0 - 0.5))
                    node['last_updated'] = datetime.now().isoformat()
                    
                    socketio.emit('node_status_change', {
                        'node': node,
                        'action': 'performance_update'
                    }, room='noodle_control')

# Start the background thread
metrics_thread = threading.Thread(target=broadcast_metrics)
metrics_thread.daemon = True
metrics_thread.start()

if __name__ == '__main__':
    print(f"Starting NoodleControl Demo API with WebSocket support on port {NOODLE_PORT}")
    print(f"Environment: {NOODLE_ENV}")
    print(f"Debug mode: {DEBUG}")
    
    # Run the Flask app with SocketIO
    socketio.run(app, host='0.0.0.0', port=NOODLE_PORT, debug=DEBUG, allow_unsafe_werkzeug=True)

