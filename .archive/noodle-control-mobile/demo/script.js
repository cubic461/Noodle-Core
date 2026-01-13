// NoodleControl Mobile App Demo JavaScript

// API base URL - configurable for Docker environment
const API_BASE_URL = window.location.hostname === 'localhost'
    ? 'http://localhost:8082/api'
    : `http://${window.location.hostname}:8082/api`;

// WebSocket URL - configurable for Docker environment
const SOCKET_IO_URL = window.location.hostname === 'localhost'
    ? 'http://localhost:8082'
    : `http://${window.location.hostname}:8082`;

// Global variables to store data
let nodesData = [];
let metricsData = {};
let socket = null;
let reconnectAttempts = 0;
const MAX_RECONNECT_ATTEMPTS = 5;

document.addEventListener('DOMContentLoaded', function() {
    // Initialize all functionality
    initNavigation();
    initSearchBar();
    initFilterChips();
    initNodeActions();
    initFloatingActionButton();
    
    // Initialize WebSocket connection
    initWebSocket();
    
    // Load initial data from API
    loadNodesData();
    loadMetricsData();
    
    // Note: We no longer need periodic refresh since WebSocket will handle real-time updates
});

// Load nodes data from API
async function loadNodesData() {
    try {
        const response = await fetch(`${API_BASE_URL}/nodes`);
        const result = await response.json();
        
        if (response.ok) {
            nodesData = result.data;
            updateNodesUI();
        } else {
            console.error('Error loading nodes:', result.error);
        }
    } catch (error) {
        console.error('Error fetching nodes:', error);
        // Fallback to static data if API is not available
        nodesData = [
            {
                'id': 'node-01',
                'name': 'Node-01',
                'status': 'running',
                'ip_address': '192.168.1.101',
                'cpu_usage': 45,
                'memory_usage': 1.2
            },
            {
                'id': 'node-02',
                'name': 'Node-02',
                'status': 'running',
                'ip_address': '192.168.1.102',
                'cpu_usage': 67,
                'memory_usage': 2.1
            },
            {
                'id': 'node-03',
                'name': 'Node-03',
                'status': 'stopped',
                'ip_address': '192.168.1.103',
                'cpu_usage': 0,
                'memory_usage': 0
            },
            {
                'id': 'node-04',
                'name': 'Node-04',
                'status': 'error',
                'ip_address': '192.168.1.104',
                'cpu_usage': 0,
                'memory_usage': 0
            }
        ];
        updateNodesUI();
    }
}

// Load metrics data from API
async function loadMetricsData() {
    try {
        const response = await fetch(`${API_BASE_URL}/metrics`);
        const result = await response.json();
        
        if (response.ok) {
            metricsData = result.data;
            updateMetricsUI();
        } else {
            console.error('Error loading metrics:', result.error);
        }
    } catch (error) {
        console.error('Error fetching metrics:', error);
        // Fallback to static data if API is not available
        metricsData = {
            'active_nodes': 2,
            'total_nodes': 4,
            'running_tasks': 12,
            'cpu_usage': 67,
            'memory_usage': 4.2,
            'network_traffic': 125,
            'disk_io': 45
        };
        updateMetricsUI();
    }
}

// Initialize WebSocket connection
function initWebSocket() {
    try {
        // Load socket.io client library
        const script = document.createElement('script');
        script.src = 'https://cdn.socket.io/4.5.4/socket.io.min.js';
        script.onload = function() {
            connectWebSocket();
        };
        document.head.appendChild(script);
    } catch (error) {
        console.error('Error loading socket.io library:', error);
        showNotification('WebSocket library failed to load', 'error');
    }
}

// Connect to WebSocket
function connectWebSocket() {
    try {
        socket = io(SOCKET_IO_URL);
        
        // Connection events
        socket.on('connect', function() {
            console.log('Connected to WebSocket server');
            reconnectAttempts = 0;
            updateConnectionStatus(true);
            showNotification('Connected to real-time updates', 'success');
        });
        
        socket.on('disconnect', function() {
            console.log('Disconnected from WebSocket server');
            updateConnectionStatus(false);
            showNotification('Disconnected from real-time updates', 'error');
            // Attempt to reconnect
            attemptReconnect();
        });
        
        socket.on('connect_error', function(error) {
            console.error('WebSocket connection error:', error);
            updateConnectionStatus(false);
            showNotification('Failed to connect to real-time updates', 'error');
            attemptReconnect();
        });
        
        // Data events
        socket.on('initial_data', function(data) {
            console.log('Received initial data:', data);
            nodesData = data.nodes;
            metricsData = data.metrics;
            updateNodesUI();
            updateMetricsUI();
        });
        
        socket.on('nodes_data', function(data) {
            console.log('Received nodes data:', data);
            nodesData = data;
            updateNodesUI();
        });
        
        socket.on('metrics_data', function(data) {
            console.log('Received metrics data:', data);
            metricsData = data;
            updateMetricsUI();
        });
        
        socket.on('node_status_change', function(data) {
            console.log('Node status change:', data);
            handleNodeStatusChange(data);
        });
        
        socket.on('metrics_update', function(data) {
            console.log('Metrics update:', data);
            metricsData = data;
            updateMetricsUI();
        });
        
        socket.on('notification', function(data) {
            console.log('Notification:', data);
            showRealtimeNotification(data);
        });
        
    } catch (error) {
        console.error('Error initializing WebSocket:', error);
        showNotification('WebSocket initialization failed', 'error');
    }
}

// Attempt to reconnect WebSocket
function attemptReconnect() {
    if (reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
        reconnectAttempts++;
        console.log(`Attempting to reconnect (${reconnectAttempts}/${MAX_RECONNECT_ATTEMPTS})...`);
        
        setTimeout(() => {
            connectWebSocket();
        }, 2000 * reconnectAttempts); // Exponential backoff
    } else {
        showNotification('Failed to reconnect to real-time updates', 'error');
        // Fall back to periodic polling
        setInterval(loadMetricsData, 5000);
    }
}

// Handle node status change from WebSocket
function handleNodeStatusChange(data) {
    const { node, action } = data;
    
    // Update local nodes data
    const nodeIndex = nodesData.findIndex(n => n.id === node.id);
    if (nodeIndex !== -1) {
        nodesData[nodeIndex] = { ...nodesData[nodeIndex], ...node };
        updateNodesUI();
    }
    
    // Show notification based on action
    let message = '';
    let type = 'info';
    
    switch (action) {
        case 'started':
            message = `Node ${node.name} started successfully`;
            type = 'success';
            break;
        case 'stopped':
            message = `Node ${node.name} stopped`;
            type = 'warning';
            break;
        case 'restarting':
            message = `Node ${node.name} is restarting...`;
            type = 'info';
            break;
        case 'restarted':
            message = `Node ${node.name} restarted successfully`;
            type = 'success';
            break;
        case 'performance_update':
            // Don't show notification for performance updates
            return;
        default:
            message = `Node ${node.name} status changed to ${node.status}`;
    }
    
    showRealtimeNotification({
        type: type,
        message: message,
        timestamp: new Date().toISOString()
    });
}

// Show real-time notification
function showRealtimeNotification(data) {
    const { type, message, timestamp } = data;
    
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'realtime-notification';
    
    // Set color based on type
    let bgColor = '#1976D2'; // Default blue for info
    if (type === 'success') bgColor = '#4CAF50';
    else if (type === 'warning') bgColor = '#FF9800';
    else if (type === 'error') bgColor = '#F44336';
    
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background-color: ${bgColor};
        color: white;
        padding: 16px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        z-index: 1000;
        max-width: 300px;
        animation: slideInRight 0.3s ease-out;
    `;
    
    // Format timestamp
    const time = new Date(timestamp).toLocaleTimeString();
    
    notification.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <div>${message}</div>
            <button onclick="this.parentElement.parentElement.remove()" style="background: none; border: none; color: white; cursor: pointer; margin-left: 10px;">✕</button>
        </div>
        <div style="font-size: 12px; opacity: 0.8; margin-top: 5px;">${time}</div>
    `;
    
    document.body.appendChild(notification);
    
    // Remove notification after 5 seconds
    setTimeout(() => {
        if (notification.parentElement) {
            notification.style.animation = 'slideOutRight 0.3s ease-out';
            setTimeout(() => {
                if (notification.parentElement) {
                    document.body.removeChild(notification);
                }
            }, 300);
        }
    }, 5000);
}

// Update nodes UI with data from API
function updateNodesUI() {
    // Update dashboard nodes count
    const activeNodesElement = document.querySelector('.status-card-value');
    if (activeNodesElement) {
        activeNodesElement.textContent = metricsData.active_nodes || nodesData.filter(n => n.status === 'running').length;
    }
    
    // Update nodes list if we're on the Nodes tab
    const nodesList = document.querySelector('.node-list');
    if (nodesList && document.querySelector('.nav-item.active span').textContent === 'Nodes') {
        let nodesHTML = '';
        
        nodesData.forEach(node => {
            const statusClass = `status-${node.status}`;
            const statusText = node.status.charAt(0).toUpperCase() + node.status.slice(1);
            
            // Determine which buttons to show based on status
            let actionButtons = '';
            if (node.status === 'running') {
                actionButtons = `
                    <button class="btn btn-secondary" onclick="stopNode('${node.id}')">Stop</button>
                    <button class="btn btn-secondary" onclick="restartNode('${node.id}')">Restart</button>
                `;
            } else if (node.status === 'stopped') {
                actionButtons = `
                    <button class="btn btn-primary" onclick="startNode('${node.id}')">Start</button>
                    <button class="btn btn-secondary" onclick="restartNode('${node.id}')">Restart</button>
                `;
            } else if (node.status === 'error') {
                actionButtons = `
                    <button class="btn btn-secondary" onclick="stopNode('${node.id}')">Stop</button>
                    <button class="btn btn-primary" onclick="restartNode('${node.id}')">Restart</button>
                `;
            }
            
            nodesHTML += `
                <div class="node-item" data-status="${node.status}" data-node-id="${node.id}">
                    <div class="node-info">
                        <div class="node-name">${node.name}</div>
                        <div class="node-status">
                            <span class="status-indicator ${statusClass}"></span>
                            ${statusText} • ${node.ip_address}
                        </div>
                    </div>
                    <div class="action-buttons">
                        ${actionButtons}
                    </div>
                </div>
            `;
        });
        
        nodesList.innerHTML = nodesHTML;
        initNodeActions(); // Reinitialize event listeners
    }
}

// Update metrics UI with data from API
function updateMetricsUI() {
    // Update dashboard metrics
    const activeNodesElement = document.querySelector('.status-card-value');
    if (activeNodesElement) {
        activeNodesElement.textContent = metricsData.active_nodes || nodesData.filter(n => n.status === 'running').length;
    }
    
    // Find and update all metric cards
    const statusCards = document.querySelectorAll('.status-card');
    statusCards.forEach(card => {
        const title = card.querySelector('.status-card-title');
        if (!title) return;
        
        const titleText = title.textContent;
        const valueElement = card.querySelector('.status-card-value');
        
        if (titleText === 'Active Nodes') {
            valueElement.textContent = metricsData.active_nodes || nodesData.filter(n => n.status === 'running').length;
        } else if (titleText === 'Running Tasks') {
            valueElement.textContent = metricsData.running_tasks || 12;
        } else if (titleText === 'CPU Usage') {
            valueElement.textContent = `${metricsData.cpu_usage || 67}%`;
        } else if (titleText === 'Memory Usage') {
            valueElement.textContent = `${metricsData.memory_usage || 4.2}GB`;
        }
    });
    
    // Update monitor section metrics if visible
    const monitorCards = document.querySelectorAll('#monitor-content .status-card');
    monitorCards.forEach(card => {
        const title = card.querySelector('.status-card-title');
        if (!title) return;
        
        const titleText = title.textContent;
        const valueElement = card.querySelector('.status-card-value');
        
        if (titleText === 'Network Traffic') {
            valueElement.textContent = `${metricsData.network_traffic || 125} MB/s`;
        } else if (titleText === 'Disk I/O') {
            valueElement.textContent = `${metricsData.disk_io || 45} MB/s`;
        }
    });
}

// API functions for node actions
async function startNode(nodeId) {
    try {
        const response = await fetch(`${API_BASE_URL}/nodes/${nodeId}/start`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const result = await response.json();
        
        if (response.ok) {
            // Refresh nodes data
            await loadNodesData();
            showNotification('Node started successfully', 'success');
        } else {
            showNotification(`Error: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error('Error starting node:', error);
        showNotification('Failed to start node', 'error');
    }
}

async function stopNode(nodeId) {
    try {
        const response = await fetch(`${API_BASE_URL}/nodes/${nodeId}/stop`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const result = await response.json();
        
        if (response.ok) {
            // Refresh nodes data
            await loadNodesData();
            showNotification('Node stopped successfully', 'success');
        } else {
            showNotification(`Error: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error('Error stopping node:', error);
        showNotification('Failed to stop node', 'error');
    }
}

async function restartNode(nodeId) {
    try {
        const response = await fetch(`${API_BASE_URL}/nodes/${nodeId}/restart`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const result = await response.json();
        
        if (response.ok) {
            // Show restarting status immediately
            const nodeElement = document.querySelector(`[data-node-id="${nodeId}"]`);
            if (nodeElement) {
                updateNodeStatus(nodeElement, 'restarting');
            }
            
            // Refresh nodes data after a delay
            setTimeout(async () => {
                await loadNodesData();
                showNotification('Node restarted successfully', 'success');
            }, 2000);
        } else {
            showNotification(`Error: ${result.error}`, 'error');
        }
    } catch (error) {
        console.error('Error restarting node:', error);
        showNotification('Failed to restart node', 'error');
    }
}

// Show notification
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        background-color: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#F44336' : '#1976D2'};
        color: white;
        padding: 16px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        z-index: 1000;
        animation: slideDown 0.3s ease-out;
    `;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Remove notification after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideUp 0.3s ease-out';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Navigation functionality
function initNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    const contentSections = {
        'Dashboard': createDashboardContent(),
        'IDE Control': createIDEContent(),
        'Nodes': createNodesContent(),
        'Tasks': createTasksContent(),
        'Monitor': createMonitorContent()
    };
    
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            // Remove active class from all nav items
            navItems.forEach(navItem => {
                navItem.classList.remove('active');
            });
            
            // Add active class to clicked item
            this.classList.add('active');
            
            // Get the section name
            const sectionName = this.querySelector('span').textContent;
            
            // Update content based on selected tab
            updateContent(sectionName, contentSections[sectionName]);
        });
    });
}

// Search bar functionality
function initSearchBar() {
    const searchInput = document.querySelector('.search-input');
    
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            filterNodes(searchTerm);
        });
    }
}

// Filter chips functionality
function initFilterChips() {
    const filterChips = document.querySelectorAll('.filter-chip');
    
    filterChips.forEach(chip => {
        chip.addEventListener('click', function() {
            // Remove active class from all chips
            filterChips.forEach(c => {
                c.classList.remove('active');
            });
            
            // Add active class to clicked chip
            this.classList.add('active');
            
            // Filter nodes based on selected filter
            const filterValue = this.textContent;
            filterNodesByStatus(filterValue);
        });
    });
}

// Node action buttons functionality
function initNodeActions() {
    const actionButtons = document.querySelectorAll('.action-buttons .btn');
    
    actionButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.stopPropagation();
            
            const action = this.textContent;
            const nodeItem = this.closest('.node-item');
            const nodeName = nodeItem.querySelector('.node-name').textContent;
            
            // Show visual feedback
            showActionFeedback(this, action);
            
            // Simulate action
            performNodeAction(nodeName, action, nodeItem);
        });
    });
}

// Floating action button functionality
function initFloatingActionButton() {
    const fab = document.querySelector('.floating-action-btn');
    
    if (fab) {
        fab.addEventListener('click', function() {
            // Add rotation animation
            this.style.transform = 'rotate(45deg) scale(1.1)';
            
            // Show add node dialog (simplified)
            showAddNodeDialog();
            
            // Reset animation after delay
            setTimeout(() => {
                this.style.transform = '';
            }, 300);
        });
        
        // Add pulse animation on hover
        fab.addEventListener('mouseenter', function() {
            this.classList.add('pulse');
        });
        
        fab.addEventListener('mouseleave', function() {
            this.classList.remove('pulse');
        });
    }
}

// Update content based on selected navigation tab
function updateContent(sectionName, content) {
    const contentDiv = document.querySelector('.content');
    
    // Fade out effect
    contentDiv.style.opacity = '0';
    
    setTimeout(() => {
        contentDiv.innerHTML = content;
        
        // Re-initialize functionality for the new content
        if (sectionName === 'Nodes') {
            initSearchBar();
            initFilterChips();
            initNodeActions();
            // Load nodes data when switching to Nodes tab
            loadNodesData();
        } else if (sectionName === 'Monitor') {
            // Load metrics data when switching to Monitor tab
            loadMetricsData();
        } else if (sectionName === 'Dashboard') {
            // Load both nodes and metrics data for Dashboard
            loadNodesData();
            loadMetricsData();
        }
        
        // Fade in effect
        contentDiv.style.opacity = '1';
    }, 200);
}

// Create content for Dashboard section
function createDashboardContent() {
    return `
        <div class="dashboard-grid">
            <div class="status-card">
                <div class="status-card-title">Active Nodes</div>
                <div class="status-card-value">4</div>
                <div class="status-card-trend trend-up">
                    <i class="material-icons" style="font-size: 14px;">arrow_upward</i>
                    <span>12% from last week</span>
                </div>
            </div>
            <div class="status-card">
                <div class="status-card-title">Running Tasks</div>
                <div class="status-card-value">12</div>
                <div class="status-card-trend trend-up">
                    <i class="material-icons" style="font-size: 14px;">arrow_upward</i>
                    <span>8% from last week</span>
                </div>
            </div>
            <div class="status-card">
                <div class="status-card-title">CPU Usage</div>
                <div class="status-card-value">67%</div>
                <div class="status-card-trend trend-down">
                    <i class="material-icons" style="font-size: 14px;">arrow_downward</i>
                    <span>5% from last hour</span>
                </div>
            </div>
            <div class="status-card">
                <div class="status-card-title">Memory Usage</div>
                <div class="status-card-value">4.2GB</div>
                <div class="status-card-trend trend-up">
                    <i class="material-icons" style="font-size: 14px;">arrow_upward</i>
                    <span>2% from last hour</span>
                </div>
            </div>
        </div>
        
        <h2 class="section-title">Recent Activity</h2>
        <div class="node-list">
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Node-01 restarted</div>
                    <div class="node-status">2 minutes ago</div>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Task #142 completed</div>
                    <div class="node-status">15 minutes ago</div>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Node-03 joined network</div>
                    <div class="node-status">1 hour ago</div>
                </div>
            </div>
        </div>
        
        <h2 class="section-title">Performance Monitoring</h2>
        <div class="performance-chart">
            Performance chart would be displayed here
        </div>
    `;
}

// Create content for IDE Control section
function createIDEContent() {
    return `
        <h2 class="section-title">IDE Control</h2>
        <div class="node-list">
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Python IDE</div>
                    <div class="node-status">
                        <span class="status-indicator status-running"></span>
                        Running • Version 3.9
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-secondary">Configure</button>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">JavaScript IDE</div>
                    <div class="node-status">
                        <span class="status-indicator status-stopped"></span>
                        Stopped • Version 18.0
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-primary">Start</button>
                </div>
            </div>
        </div>
        
        <h2 class="section-title">Available Extensions</h2>
        <div class="node-list">
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Code Formatter</div>
                    <div class="node-status">Installed</div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-secondary">Configure</button>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Debugger</div>
                    <div class="node-status">Not Installed</div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-primary">Install</button>
                </div>
            </div>
        </div>
    `;
}

// Create content for Nodes section
function createNodesContent() {
    return `
        <h2 class="section-title">Node Management</h2>
        
        <div class="search-bar">
            <i class="material-icons">search</i>
            <input type="text" class="search-input" placeholder="Search nodes...">
        </div>
        
        <div class="filter-chips">
            <div class="filter-chip active">All</div>
            <div class="filter-chip">Running</div>
            <div class="filter-chip">Stopped</div>
            <div class="filter-chip">Error</div>
        </div>
        
        <div class="node-list" id="nodes-list">
            <!-- Nodes will be populated by API -->
            <div class="loading-indicator">Loading nodes...</div>
        </div>
    `;
}

// Create content for Tasks section
function createTasksContent() {
    return `
        <h2 class="section-title">Task Management</h2>
        <div class="node-list">
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Data Processing</div>
                    <div class="node-status">
                        <span class="status-indicator status-running"></span>
                        Running • 75% complete
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-secondary">Pause</button>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Model Training</div>
                    <div class="node-status">
                        <span class="status-indicator status-running"></span>
                        Running • 42% complete
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-secondary">Pause</button>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Report Generation</div>
                    <div class="node-status">
                        <span class="status-indicator status-stopped"></span>
                        Queued • Waiting for resources
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-primary">Start</button>
                </div>
            </div>
        </div>
        
        <h2 class="section-title">Completed Tasks</h2>
        <div class="node-list">
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">Database Backup</div>
                    <div class="node-status">
                        <span class="status-indicator status-running"></span>
                        Completed • 2 hours ago
                    </div>
                </div>
                <div class="action-buttons">
                    <button class="btn btn-secondary">View Log</button>
                </div>
            </div>
        </div>
    `;
}

// Create content for Monitor section
function createMonitorContent() {
    return `
        <h2 class="section-title">System Monitoring</h2>
        
        <div class="dashboard-grid" id="monitor-content">
            <div class="status-card">
                <div class="status-card-title">Network Traffic</div>
                <div class="status-card-value">125 MB/s</div>
                <div class="status-card-trend trend-up">
                    <i class="material-icons" style="font-size: 14px;">arrow_upward</i>
                    <span>15% from last hour</span>
                </div>
            </div>
            <div class="status-card">
                <div class="status-card-title">Disk I/O</div>
                <div class="status-card-value">45 MB/s</div>
                <div class="status-card-trend trend-down">
                    <i class="material-icons" style="font-size: 14px;">arrow_downward</i>
                    <span>8% from last hour</span>
                </div>
            </div>
        </div>
        
        <h2 class="section-title">Performance Metrics</h2>
        <div class="performance-chart">
            Performance metrics chart would be displayed here
        </div>
        
        <h2 class="section-title">System Logs</h2>
        <div class="node-list">
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">INFO</div>
                    <div class="node-status">Node-01 connected successfully</div>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">WARNING</div>
                    <div class="node-status">High memory usage on Node-02</div>
                </div>
            </div>
            <div class="node-item">
                <div class="node-info">
                    <div class="node-name">ERROR</div>
                    <div class="node-status">Connection timeout to Node-04</div>
                </div>
            </div>
        </div>
    `;
}

// Filter nodes based on search term
function filterNodes(searchTerm) {
    const nodeItems = document.querySelectorAll('.node-item');
    
    nodeItems.forEach(item => {
        const nodeName = item.querySelector('.node-name').textContent.toLowerCase();
        const nodeStatus = item.querySelector('.node-status').textContent.toLowerCase();
        
        if (nodeName.includes(searchTerm) || nodeStatus.includes(searchTerm)) {
            item.style.display = 'flex';
        } else {
            item.style.display = 'none';
        }
    });
}

// Filter nodes by status
function filterNodesByStatus(filterValue) {
    const nodeItems = document.querySelectorAll('.node-item');
    
    if (filterValue === 'All') {
        nodeItems.forEach(item => {
            item.style.display = 'flex';
        });
        return;
    }
    
    nodeItems.forEach(item => {
        const nodeStatus = item.dataset.status || getStatusFromText(item.querySelector('.node-status').textContent);
        
        if (nodeStatus === filterValue.toLowerCase()) {
            item.style.display = 'flex';
        } else {
            item.style.display = 'none';
        }
    });
}

// Get status from text
function getStatusFromText(statusText) {
    if (statusText.includes('Running')) return 'running';
    if (statusText.includes('Stopped')) return 'stopped';
    if (statusText.includes('Error')) return 'error';
    return 'unknown';
}

// Show visual feedback for action buttons
function showActionFeedback(button, action) {
    const originalText = button.textContent;
    const originalClass = button.className;
    
    // Change button appearance to show processing
    button.textContent = 'Processing...';
    button.disabled = true;
    button.style.opacity = '0.7';
    
    // Reset after a delay
    setTimeout(() => {
        button.textContent = originalText;
        button.disabled = false;
        button.style.opacity = '1';
        
        // Show success feedback briefly
        button.style.backgroundColor = '#4CAF50';
        button.style.color = 'white';
        
        setTimeout(() => {
            button.className = originalClass;
            button.style.backgroundColor = '';
            button.style.color = '';
        }, 1000);
    }, 1500);
}

// Perform node action (now handled by API functions)
function performNodeAction(nodeName, action, nodeItem) {
    // This function is now replaced by the API functions
    // Keeping it for backward compatibility
    console.log(`Node action ${action} on ${nodeName} is now handled by API functions`);
}

// Update node status in the UI
function updateNodeStatus(nodeItem, newStatus) {
    const statusElement = nodeItem.querySelector('.node-status');
    const statusIndicator = nodeItem.querySelector('.status-indicator');
    const actionButtons = nodeItem.querySelector('.action-buttons');
    
    // Update status indicator
    statusIndicator.className = 'status-indicator';
    
    if (newStatus === 'running') {
        statusIndicator.classList.add('status-running');
        statusElement.innerHTML = `<span class="status-indicator status-running"></span>Running • ${statusElement.textContent.split('•')[1] || '192.168.1.101'}`;
        
        // Update action buttons
        actionButtons.innerHTML = `
            <button class="btn btn-secondary">Stop</button>
            <button class="btn btn-secondary">Restart</button>
        `;
    } else if (newStatus === 'stopped') {
        statusIndicator.classList.add('status-stopped');
        statusElement.innerHTML = `<span class="status-indicator status-stopped"></span>Stopped • ${statusElement.textContent.split('•')[1] || '192.168.1.101'}`;
        
        // Update action buttons
        actionButtons.innerHTML = `
            <button class="btn btn-primary">Start</button>
            <button class="btn btn-secondary">Restart</button>
        `;
    } else if (newStatus === 'error') {
        statusIndicator.classList.add('status-error');
        statusElement.innerHTML = `<span class="status-indicator status-error"></span>Error • ${statusElement.textContent.split('•')[1] || '192.168.1.101'}`;
        
        // Update action buttons
        actionButtons.innerHTML = `
            <button class="btn btn-secondary">Stop</button>
            <button class="btn btn-primary">Restart</button>
        `;
    } else if (newStatus === 'restarting') {
        statusIndicator.classList.add('status-error');
        statusElement.innerHTML = `<span class="status-indicator status-error"></span>Restarting • ${statusElement.textContent.split('•')[1] || '192.168.1.101'}`;
    }
    
    // Update data-status attribute for filtering
    nodeItem.dataset.status = newStatus;
    
    // Re-initialize action buttons for the updated node
    initNodeActions();
}

// Show add node dialog (simplified)
function showAddNodeDialog() {
    // Create a simple notification instead of a full dialog
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        left: 50%;
        transform: translateX(-50%);
        background-color: #1976D2;
        color: white;
        padding: 16px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        z-index: 1000;
        animation: slideDown 0.3s ease-out;
    `;
    notification.textContent = 'Add Node functionality would open a dialog here';
    
    document.body.appendChild(notification);
    
    // Remove notification after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideUp 0.3s ease-out';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Add CSS animation keyframes
const style = document.createElement('style');
style.textContent = `
    @keyframes slideDown {
        from { transform: translate(-50%, -100%); opacity: 0; }
        to { transform: translate(-50%, 0); opacity: 1; }
    }
    
    @keyframes slideUp {
        from { transform: translate(-50%, 0); opacity: 1; }
        to { transform: translate(-50%, -100%); opacity: 0; }
    }
    
    @keyframes pulse {
        0% { box-shadow: 0 4px 8px rgba(0,0,0,0.2); }
        50% { box-shadow: 0 4px 16px rgba(25,118,210,0.4); }
        100% { box-shadow: 0 4px 8px rgba(0,0,0,0.2); }
    }
    
    .pulse {
        animation: pulse 1.5s infinite;
    }
    
    .content {
        transition: opacity 0.2s ease-in-out;
    }
`;
document.head.appendChild(style);

// Add additional CSS animations for real-time notifications
const realtimeStyle = document.createElement('style');
realtimeStyle.textContent = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOutRight {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
    
    .realtime-notification {
        transition: transform 0.3s ease-out;
    }
    
    .connection-status {
        position: fixed;
        bottom: 20px;
        left: 20px;
        padding: 8px 16px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        z-index: 999;
        display: flex;
        align-items: center;
    }
    
    .connection-status.connected {
        background-color: rgba(76, 175, 80, 0.9);
        color: white;
    }
    
    .connection-status.disconnected {
        background-color: rgba(244, 67, 54, 0.9);
        color: white;
    }
    
    .connection-status .status-indicator {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background-color: white;
        margin-right: 8px;
        animation: pulse 2s infinite;
    }
`;
document.head.appendChild(realtimeStyle);

// Create connection status indicator
function createConnectionStatus() {
    const statusElement = document.createElement('div');
    statusElement.id = 'connection-status';
    statusElement.className = 'connection-status disconnected';
    statusElement.innerHTML = `
        <div class="status-indicator"></div>
        <span>Disconnected</span>
    `;
    document.body.appendChild(statusElement);
}

// Update connection status
function updateConnectionStatus(connected) {
    const statusElement = document.getElementById('connection-status');
    if (!statusElement) {
        createConnectionStatus();
        return updateConnectionStatus(connected);
    }
    
    if (connected) {
        statusElement.className = 'connection-status connected';
        statusElement.querySelector('span').textContent = 'Connected';
    } else {
        statusElement.className = 'connection-status disconnected';
        statusElement.querySelector('span').textContent = 'Disconnected';
    }
}

// Initialize connection status indicator
createConnectionStatus();

// Update connection status in WebSocket handlers
// (This will be called from the WebSocket event handlers)