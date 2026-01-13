# NoodleControl Demo - Development Guide

This document provides comprehensive information for developers working on the NoodleControl demo application.

## Table of Contents

1. [Development Setup](#development-setup)
2. [Project Structure](#project-structure)
3. [Code Architecture](#code-architecture)
4. [Development Workflow](#development-workflow)
5. [Testing Guidelines](#testing-guidelines)
6. [Adding New Features](#adding-new-features)
7. [Debugging Tips](#debugging-tips)
8. [Performance Considerations](#performance-considerations)
9. [Contribution Guidelines](#contribution-guidelines)

## Development Setup

### Prerequisites

- Python 3.9 or higher
- pip 21.0 or higher
- Git
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Code editor (VS Code recommended)
- Docker Desktop (optional, for containerized development)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd noodle_control_mobile_app/demo
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Verify installation:
   ```bash
   python --version  # Should be 3.9+
   pip --version     # Should be 21.0+
   ```

### Development Environment Configuration

#### Environment Variables

Create a `.env` file in the demo directory (this file should not be committed to version control):

```env
# Environment
NOODLE_ENV=development
DEBUG=1

# Ports
NOODLE_PORT=8082
FRONTEND_PORT=8081

# API Configuration
API_HOST=localhost
API_PROTOCOL=http

# Logging
LOG_LEVEL=DEBUG
```

#### VS Code Configuration

For the best development experience, install these VS Code extensions:
- Python
- Pylance
- Live Server
- Docker
- GitLens

Create a `.vscode/settings.json` file:

```json
{
    "python.defaultInterpreterPath": "./venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "editor.formatOnSave": true,
    "liveServer.settings.port": 8081,
    "liveServer.settings.root": "/"
}
```

## Project Structure

```
demo/
├── api.py                    # Backend API server with WebSocket support
├── server.py                 # Frontend static file server
├── index.html                # Main HTML file
├── script.js                 # Frontend JavaScript logic
├── service-worker.js         # PWA service worker
├── manifest.json             # PWA manifest
├── offline.html              # Offline fallback page
├── websocket_test.html       # WebSocket testing page
├── requirements.txt          # Python dependencies
├── docker-compose.yml        # Docker orchestration
├── Dockerfile.frontend       # Frontend container definition
├── Dockerfile.backend        # Backend container definition
├── start_*.bat               # Windows startup scripts
├── start_*.ps1               # PowerShell startup scripts
├── generate_icons.py         # Icon generation script
├── icons/                    # PWA icons directory
├── README.md                 # Main documentation
├── DEVELOPMENT.md            # Development guide (this file)
├── DEPLOYMENT.md             # Deployment guide
├── CHANGELOG.md              # Version history
├── README_API.md             # API documentation
└── README_DOCKER.md          # Docker documentation
```

## Code Architecture

### Frontend Architecture

The frontend follows a modular JavaScript architecture:

```javascript
// Main components in script.js
- DOM manipulation utilities
- WebSocket client management
- API communication layer
- UI state management
- Event handling
- PWA integration
```

#### Key Frontend Components

1. **WebSocket Client** (`script.js`):
   - Connection management
   - Event handling
   - Reconnection logic
   - Data synchronization

2. **API Client** (`script.js`):
   - HTTP request handling
   - Error management
   - Response parsing
   - Fallback mechanisms

3. **UI Controller** (`script.js`):
   - DOM updates
   - Event listeners
   - State synchronization
   - User interactions

### Backend Architecture

The backend follows a Flask-based microservice architecture:

```python
# Main components in api.py
- Flask application setup
- WebSocket server (Flask-SocketIO)
- RESTful API endpoints
- In-memory data storage
- Background task management
- CORS configuration
```

#### Key Backend Components

1. **API Endpoints** (`api.py`):
   - Node management (`/api/nodes`)
   - Metrics (`/api/metrics`)
   - Health checks (`/api/health`)
   - Error handling

2. **WebSocket Events** (`api.py`):
   - Connection management
   - Real-time data broadcasting
   - Room-based communication
   - Event handling

3. **Data Models** (`api.py`):
   - Node representation
   - Metrics structure
   - Response formatting

## Development Workflow

### 1. Starting the Development Environment

#### Option A: Using Startup Scripts (Recommended)

```bash
# Windows PowerShell
.\start_complete_app.ps1
# Select option 1 (Local Python)

# Windows Command Prompt
start_complete_app.bat
# Select option 1 (Local Python)
```

#### Option B: Manual Startup

```bash
# Terminal 1 - Frontend
python server.py

# Terminal 2 - Backend
python api.py
```

### 2. Development Cycle

1. Make code changes
2. Refresh browser (frontend changes auto-refresh with Live Server)
3. Restart backend server for Python changes
4. Test changes in browser
5. Commit changes with descriptive messages

### 3. Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature description"

# Push and create pull request
git push origin feature/new-feature
```

## Testing Guidelines

### Frontend Testing

#### Manual Testing Checklist

1. **Functionality**:
   - [ ] All buttons work as expected
   - [ ] WebSocket connection established
   - [ ] Real-time updates received
   - [ ] API calls successful
   - [ ] Error handling works

2. **Responsive Design**:
   - [ ] Mobile view (320px+)
   - [ ] Tablet view (768px+)
   - [ ] Desktop view (1024px+)
   - [ ] Orientation changes

3. **PWA Features**:
   - [ ] Service worker registration
   - [ ] Offline functionality
   - [ ] App installation
   - [ ] Cache management

#### Browser Testing

Test in these browsers:
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

### Backend Testing

#### API Testing

Use these tools for API testing:
- Postman
- curl
- Browser DevTools

Test all endpoints:
```bash
# Health check
curl http://localhost:8082/api/health

# Get nodes
curl http://localhost:8082/api/nodes

# Start node
curl -X POST http://localhost:8082/api/nodes/node-01/start
```

#### WebSocket Testing

Use the provided test page:
- Open `http://localhost:8081/websocket_test.html`
- Test connection, events, and reconnection

## Adding New Features

### Frontend Features

1. **Add New UI Components**:
   ```javascript
   // In script.js
   function newComponent() {
       // Implementation
   }
   
   // Add to DOM
   document.addEventListener('DOMContentLoaded', function() {
       // Initialize new component
   });
   ```

2. **Add New API Calls**:
   ```javascript
   // In script.js
   async function callNewAPI() {
       try {
           const response = await fetch('/api/new-endpoint');
           const data = await response.json();
           return data;
       } catch (error) {
           console.error('API call failed:', error);
           return null;
       }
   }
   ```

3. **Add WebSocket Event Handlers**:
   ```javascript
   // In script.js
   socket.on('new_event', function(data) {
       // Handle new event
       updateUI(data);
   });
   ```

### Backend Features

1. **Add New API Endpoints**:
   ```python
   # In api.py
   @app.route('/api/new-endpoint', methods=['GET'])
   def new_endpoint():
       """Handle new endpoint"""
       data = {"message": "New endpoint response"}
       return create_response(data)
   ```

2. **Add WebSocket Events**:
   ```python
   # In api.py
   @socketio.on('new_client_event')
   def handle_new_client_event(data):
       """Handle new client event"""
       # Process data
       emit('server_response', {"status": "processed"})
   ```

3. **Add Background Tasks**:
   ```python
   # In api.py
   def background_task():
       """Background task implementation"""
       while True:
           # Task logic
           time.sleep(interval)
   
   # Start background task
   task_thread = threading.Thread(target=background_task)
   task_thread.daemon = True
   task_thread.start()
   ```

## Debugging Tips

### Frontend Debugging

1. **Browser Developer Tools**:
   - Console: Check for JavaScript errors
   - Network: Monitor API calls and WebSocket connections
   - Application: Inspect service worker and caches

2. **Common Issues**:
   - **CORS errors**: Ensure backend is running and accessible
   - **WebSocket connection failures**: Check backend server status
   - **PWA installation issues**: Verify HTTPS or localhost

3. **Debugging Techniques**:
   ```javascript
   // Add debug logging
   console.log('Debug info:', data);
   
   // Check WebSocket state
   console.log('WebSocket state:', socket.readyState);
   
   // Monitor API responses
   fetch('/api/nodes')
       .then(response => console.log('API response:', response))
       .catch(error => console.error('API error:', error));
   ```

### Backend Debugging

1. **Python Logging**:
   ```python
   # In api.py
   import logging
   
   logging.basicConfig(level=logging.DEBUG)
   logger = logging.getLogger(__name__)
   
   # Add debug statements
   logger.debug('Debug message')
   logger.info('Info message')
   logger.error('Error message')
   ```

2. **Common Issues**:
   - **Port conflicts**: Check if ports are in use
   - **Import errors**: Verify all dependencies are installed
   - **CORS issues**: Check CORS configuration

3. **Debugging Techniques**:
   ```python
   # Add debug prints
   print(f"Debug: {variable}")
   
   # Check request data
   @app.route('/api/debug', methods=['POST'])
   def debug_endpoint():
       print(f"Request data: {request.json}")
       return create_response({"received": request.json})
   ```

## Performance Considerations

### Frontend Optimization

1. **Minimize DOM Manipulation**:
   - Batch DOM updates
   - Use document fragments
   - Avoid layout thrashing

2. **Optimize WebSocket Usage**:
   - Throttle frequent updates
   - Use efficient data serialization
   - Implement proper reconnection logic

3. **PWA Optimization**:
   - Cache static assets
   - Implement lazy loading
   - Optimize image sizes

### Backend Optimization

1. **API Response Times**:
   - Keep responses under 500ms
   - Use efficient data structures
   - Implement proper caching

2. **WebSocket Performance**:
   - Limit broadcast frequency
   - Use rooms for targeted updates
   - Monitor connection count

3. **Memory Management**:
   - Limit in-memory data
   - Implement cleanup routines
   - Monitor memory usage

## Contribution Guidelines

### Code Style

#### Python (Backend)
- Follow PEP 8 style guide
- Use meaningful variable names
- Add docstrings to functions
- Limit line length to 88 characters

#### JavaScript (Frontend)
- Use ES6+ features
- Follow modern JavaScript conventions
- Add JSDoc comments for functions
- Use consistent naming conventions

### Commit Messages

Follow conventional commit format:
```
type(scope): description

feat(api): add new node management endpoint
fix(ui): resolve mobile layout issue
docs(readme): update installation instructions
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance

### Pull Request Process

1. Create feature branch from main
2. Implement changes with tests
3. Update documentation
4. Submit pull request with:
   - Clear description
   - Testing instructions
   - Screenshots if applicable

### Code Review Guidelines

1. Review for:
   - Functionality
   - Code style
   - Performance
   - Security
   - Documentation

2. Provide constructive feedback
3. Suggest improvements
4. Ensure tests pass
5. Verify documentation is updated

## Additional Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Flask-SocketIO Documentation](https://flask-socketio.readthedocs.io/)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Progressive Web App Guide](https://web.dev/progressive-web-apps/)
- [WebSocket API](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)