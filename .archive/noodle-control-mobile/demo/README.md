# NoodleControl Mobile App Demo

A comprehensive web-based demo showcasing the NoodleControl mobile application interface with real-time data, WebSocket support, and PWA capabilities.

## Overview

The NoodleControl demo is a fully functional web application that simulates the mobile experience of managing and monitoring Noodle network nodes. It features a responsive design that works seamlessly across mobile, tablet, and desktop devices, with Progressive Web App (PWA) capabilities for an app-like experience.

## Features

### Core Functionality
- **Real-time Dashboard**: Live monitoring of system metrics including CPU usage, memory consumption, and network traffic
- **Node Management**: Start, stop, and restart compute nodes with instant status updates
- **WebSocket Integration**: Real-time data synchronization without page refreshes
- **Responsive Design**: Optimized for mobile, tablet, and desktop viewports
- **PWA Support**: Installable web app with offline capabilities

### User Interface
- **Mobile-First Design**: Touch-friendly interface optimized for mobile devices
- **Material Design**: Clean, modern UI following Material Design principles
- **Interactive Elements**: Functional buttons, filters, and search capabilities
- **Status Indicators**: Visual indicators for node status and system health
- **Navigation**: Tab-based navigation for different app sections

### Technical Features
- **RESTful API**: Backend API with proper error handling and response formatting
- **WebSocket Events**: Real-time event broadcasting for status changes
- **Service Worker**: Offline support and caching strategies
- **CORS Support**: Properly configured for cross-origin requests
- **Docker Support**: Containerized deployment with Docker Compose

## Quick Start

### Prerequisites
- Python 3.9 or higher
- pip 21.0 or higher
- Docker Desktop (optional, for containerized deployment)

### Option 1: Using the Startup Scripts (Recommended)

For Windows users, run one of the following scripts:

**PowerShell:**
```powershell
.\start_complete_app.ps1
```

**Command Prompt:**
```
start_complete_app.bat
```

These scripts provide a menu-driven interface with options to:
- Start with Local Python (Recommended for development)
- Start with Docker (Recommended for production)
- Install Dependencies Only
- View Application Status

### Option 2: Manual Setup

1. Navigate to the demo directory:
   ```
   cd noodle_control_mobile_app/demo
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Start the frontend server (port 8081):
   ```
   python server.py
   ```

4. In a new terminal, start the backend API (port 8082):
   ```
   python api.py
   ```

5. Open your browser and navigate to:
   - Frontend: http://localhost:8081
   - Backend API: http://localhost:8082

## Architecture Overview

The demo application consists of three main components:

### Frontend (Web Interface)
- **Technology**: HTML5, CSS3, JavaScript (ES6+)
- **Framework**: Vanilla JavaScript with WebSocket client
- **Styling**: Material Design with custom CSS
- **Features**: Responsive layout, PWA capabilities, real-time updates

### Backend API
- **Technology**: Python 3.9+, Flask, Flask-SocketIO
- **Endpoints**: RESTful API for node management and metrics
- **WebSocket**: Real-time event broadcasting
- **Data Storage**: In-memory storage for demo purposes

### Service Worker
- **Technology**: JavaScript Service Worker API
- **Features**: Caching, offline support, background sync
- **Strategy**: Cache-first for static assets, network-first for API calls

## User Interface Screenshots

### Dashboard View
The main dashboard displays:
- System metrics cards with trend indicators
- Active nodes count and running tasks
- CPU and memory usage visualization
- Quick access to node management

### Node Management
The node management section provides:
- Search and filter capabilities
- Node status indicators (running, stopped, error)
- Action buttons for start, stop, and restart operations
- IP address and resource usage information

### Performance Monitoring
Real-time performance metrics including:
- CPU usage trends
- Memory consumption
- Network traffic
- Disk I/O statistics

## Development Documentation

For detailed development setup, code structure, and contribution guidelines, see:
- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup and guidelines
- [README_API.md](README_API.md) - API documentation
- [README_DOCKER.md](README_DOCKER.md) - Docker deployment guide

## Deployment Documentation

For deployment instructions and production considerations, see:
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment options and configuration

## Project History

For a detailed history of changes and updates, see:
- [CHANGELOG.md](CHANGELOG.md) - Version history and release notes

## Browser Compatibility

The demo application supports all modern browsers:
- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

## Mobile Compatibility

The responsive design is optimized for:
- iOS Safari 13+
- Chrome Mobile 80+
- Samsung Internet 12+

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   - Change ports in server.py (frontend) and api.py (backend)
   - Or stop the process using the port

2. **CORS Errors**
   - Ensure both frontend and backend are running
   - Check that ports are correctly configured in script.js

3. **WebSocket Connection Issues**
   - Verify the backend API is running
   - Check browser console for connection errors

4. **PWA Installation Issues**
   - Ensure the site is served over HTTPS (or localhost)
   - Check that the service worker is properly registered

For more troubleshooting tips, see [DEPLOYMENT.md](DEPLOYMENT.md).

## License

This demo is part of the NoodleControl project and is licensed under the same terms as the main project.

## Support

For issues, questions, or contributions:
1. Check the documentation files
2. Review existing issues in the project repository
3. Create a new issue with detailed information

## Future Enhancements

Planned improvements for the demo:
- User authentication system
- More complex node management features
- Advanced performance charts
- Push notifications
- Enhanced offline capabilities
- Mobile app integration