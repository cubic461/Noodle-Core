# NoodleControl Demo API

This document describes the Flask backend API for the NoodleControl mobile app demo.

**For a complete overview of the demo application, see the main [README.md](README.md).**

## Additional Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup and guidelines
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment instructions
- [README_DOCKER.md](README_DOCKER.md) - Docker deployment guide
- [CHANGELOG.md](CHANGELOG.md) - Version history

## Overview

The Flask API provides endpoints for the frontend to fetch node data, handle node status changes, and return real-time performance metrics. It stores node data in memory for demo purposes.

## Prerequisites

- Python 3.9 or higher
- pip 21.0 or higher

## Installation

1. Navigate to the demo directory:
   ```
   cd noodle_control_mobile_app/demo
   ```

2. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

## Running the API Server

### Option 1: Using the startup scripts (Windows)

For PowerShell users:
```powershell
.\start_complete_app.ps1
```

For Command Prompt users:
```
start_complete_app.bat
```

These scripts provide a menu-driven interface with options to:
- Start with Local Python (Recommended for development)
- Start with Docker (Recommended for production)
- Install Dependencies Only
- View Application Status

### Option 2: Using the API-only batch script (Windows)

Run the API-only batch script:
```
start_api.bat
```

### Option 3: Manual execution

1. Set environment variables:
   ```
   set NOODLE_ENV=development
   set NOODLE_PORT=8080
   set DEBUG=1
   ```

2. Start the API server:
   ```
   python api.py
   ```

The API server will start on `http://localhost:8080`

## API Endpoints

### 1. Get All Nodes

**Endpoint:** `GET /api/nodes`

**Description:** Returns a list of all nodes with their current status and metrics.

**Response:**
```json
{
  "requestId": "uuid-v4",
  "data": [
    {
      "id": "node-01",
      "name": "Node-01",
      "status": "running",
      "ip_address": "192.168.1.101",
      "cpu_usage": 45,
      "memory_usage": 1.2,
      "last_updated": "2023-10-17T11:52:38.100Z"
    }
  ],
  "timestamp": "2023-10-17T11:52:38.100Z"
}
```

### 2. Start a Node

**Endpoint:** `POST /api/nodes/{node_id}/start`

**Description:** Starts a node with the specified ID.

**Response:**
```json
{
  "requestId": "uuid-v4",
  "data": {
    "message": "Node node-01 started successfully"
  },
  "timestamp": "2023-10-17T11:52:38.100Z"
}
```

### 3. Stop a Node

**Endpoint:** `POST /api/nodes/{node_id}/stop`

**Description:** Stops a node with the specified ID.

**Response:**
```json
{
  "requestId": "uuid-v4",
  "data": {
    "message": "Node node-01 stopped successfully"
  },
  "timestamp": "2023-10-17T11:52:38.100Z"
}
```

### 4. Restart a Node

**Endpoint:** `POST /api/nodes/{node_id}/restart`

**Description:** Restarts a node with the specified ID.

**Response:**
```json
{
  "requestId": "uuid-v4",
  "data": {
    "message": "Node node-01 restarted successfully"
  },
  "timestamp": "2023-10-17T11:52:38.100Z"
}
```

### 5. Get Performance Metrics

**Endpoint:** `GET /api/metrics`

**Description:** Returns current performance metrics for the system.

**Response:**
```json
{
  "requestId": "uuid-v4",
  "data": {
    "active_nodes": 2,
    "total_nodes": 4,
    "running_tasks": 12,
    "cpu_usage": 67,
    "memory_usage": 4.2,
    "network_traffic": 125,
    "disk_io": 45,
    "last_updated": "2023-10-17T11:52:38.100Z"
  },
  "timestamp": "2023-10-17T11:52:38.100Z"
}
```

### 6. Health Check

**Endpoint:** `GET /api/health`

**Description:** Returns the health status of the API.

**Response:**
```json
{
  "requestId": "uuid-v4",
  "data": {
    "status": "healthy"
  },
  "timestamp": "2023-10-17T11:52:38.100Z"
}
```

## Integration with Frontend

The JavaScript in `script.js` has been updated to fetch data from this API instead of using static data. The frontend will:

1. Load initial node and metrics data when the page loads
2. Refresh metrics data every 5 seconds
3. Send requests to start, stop, or restart nodes when buttons are clicked
4. Show notifications for successful actions or errors
5. Fall back to static data if the API is not available

## Error Handling

All API responses include a `requestId` field for tracking requests. If an error occurs, the API will return an appropriate HTTP status code and an error message in the response body.

## Environment Variables

The API respects the following environment variables:

- `NOODLE_ENV`: Set to 'development' or 'production' (default: 'development')
- `NOODLE_PORT`: Port number for the API server (default: 8080)
- `DEBUG`: Set to 1 for debug mode, 0 for production (default: 1 in development)

## Security Considerations

This is a demo API intended for development and testing purposes. It does not implement authentication or authorization. In a production environment, you should:

1. Implement proper authentication and authorization
2. Use HTTPS instead of HTTP
3. Validate and sanitize all input data
4. Implement rate limiting
5. Add proper logging and monitoring