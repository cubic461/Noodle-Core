# 🤖 NIP v3.0.0 Web UI

A modern, production-ready Streamlit web interface for the NIP (Intelligent Programming Assistant) v3.0.0.

![Version](https://img.shields.io/badge/version-3.0.0-blue)
![Python](https://img.shields.io/badge/python-3.10+-green)
![Streamlit](https://img.shields.io/badge/streamlit-1.31+-red)

## ✨ Features

### 🎨 Beautiful User Interface
- **Modern Design**: Clean, professional interface with smooth animations
- **Dark/Light Mode**: Toggle between themes for comfortable viewing
- **Responsive Layout**: Adapts to different screen sizes
- **Custom CSS**: Beautiful styling with hover effects and transitions

### 💬 Interactive Chat Interface
- **Real-time Streaming**: Watch responses generate in real-time
- **Message History**: Complete conversation history with timestamps
- **File Upload Support**: Analyze code files directly in chat
- **Export Conversations**: Save chats as JSON, Markdown, or TXT

### ⚙️ Configuration Panel
- **API Settings**: Configure API URL and authentication
- **Model Selection**: Choose from multiple AI models
- **Temperature Control**: Adjust response randomness
- **Token Limits**: Set maximum response length
- **Advanced Options**: Timeout, retry attempts, debug mode

### 📁 File Analysis
- **Multi-format Support**: Python, JavaScript, TypeScript, Java, C++, Go, Rust, and more
- **Batch Upload**: Upload multiple files at once
- **Syntax Highlighting**: Automatic code highlighting
- **File Preview**: Preview uploaded files before analysis

### 📜 Conversation Management
- **Persistent Sessions**: Conversations persist across refreshes
- **Export Functionality**: Download conversations in multiple formats
- **Search History**: Browse past conversations easily
- **Statistics**: View message counts and session info

## 📋 Prerequisites

- **Python**: 3.10 or higher
- **pip**: Latest version
- **NIP Server**: Running instance of NIP API (optional for demo mode)

## 🚀 Installation

### 1. Clone or Navigate to Directory

```bash
cd C:/Users/micha/Noodle/web-ui
```

### 2. Create Virtual Environment (Recommended)

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Copy the example environment file:

```bash
copy .env.example .env
```

Edit `.env` with your configuration:

```env
# API Configuration
NIP_API_URL=http://localhost:8000
NIP_API_KEY=your_api_key_here

# Model Configuration
DEFAULT_MODEL=gpt-4
TEMPERATURE=0.7
MAX_TOKENS=4000

# UI Configuration
DEFAULT_THEME=dark
STREAM_RESPONSES=true
```

## 🎯 Usage

### Start the Application

```bash
streamlit run app.py
```

The application will open in your browser at:
```
http://localhost:8501
```

### Basic Workflow

1. **Configure Settings** (Sidebar)
   - Set API URL and key
   - Select AI model
   - Adjust parameters

2. **Start Chatting**
   - Type your message in the chat box
   - Click "Send" or press Enter
   - Watch the response stream in real-time

3. **Upload Files** (Optional)
   - Expand "Upload Files for Analysis"
   - Select one or more code files
   - Files are ready for analysis

4. **View History**
   - Click the "History" tab
   - Browse all past conversations
   - Export as needed

### Keyboard Shortcuts

- **Enter**: Send message (when in chat input)
- **Shift + Enter**: New line in chat input
- **Ctrl/Cmd + K**: Clear chat
- **Ctrl/Cmd + S**: Save configuration

## 📸 Screenshots

### Main Chat Interface
```
[Chat Interface Screenshot Placeholder]
- Modern dark theme
- Chat messages with timestamps
- File upload section
- Input area with send button
```

### Configuration Panel
```
[Settings Screenshot Placeholder]
- API settings section
- Model selection dropdown
- Temperature slider
- Theme toggle
- Advanced settings
```

### File Analysis
```
[File Upload Screenshot Placeholder]
- Multiple file uploads
- Syntax highlighting
- File preview
- Analysis button
```

## 🔧 Configuration

### API Settings

| Setting | Description | Default |
|---------|-------------|---------|
| API URL | Base URL for NIP API | http://localhost:8000 |
| API Key | Authentication key | (empty) |

### Model Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Model | AI model to use | gpt-4 |
| Temperature | Response randomness (0-2) | 0.7 |
| Max Tokens | Maximum response length | 4000 |

### UI Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Theme | Dark or light mode | dark |
| Stream Responses | Show real-time generation | true |
| Show Thinking | Display reasoning process | false |

## 🌐 Features in Detail

### Real-time Streaming
Responses appear as they're generated, providing immediate feedback and reducing perceived latency.

### File Analysis
Upload code files for AI-powered analysis:
- Code review and suggestions
- Bug detection
- Performance optimization
- Documentation generation

### Export Formats
- **JSON**: Full data structure with metadata
- **Markdown**: Formatted for documentation
- **TXT**: Plain text for compatibility

### Session Persistence
Conversations are stored in session state and can be exported for future reference.

## 🐛 Troubleshooting

### Issue: Application won't start
**Solution**: Ensure all dependencies are installed
```bash
pip install --upgrade -r requirements.txt
```

### Issue: API connection error
**Solution**: Verify NIP server is running at configured URL

### Issue: File upload not working
**Solution**: Check file size and format are supported

### Issue: Theme not applying
**Solution**: Clear browser cache and refresh

## 🔒 Security Notes

- **API Keys**: Store in `.env` file, never commit to version control
- **File Uploads**: Files are processed in memory, not permanently stored
- **Session Data**: Cleared when browser tab is closed

## 📝 Development

### Project Structure
```
web-ui/
├── app.py              # Main Streamlit application
├── requirements.txt    # Python dependencies
├── README.md          # This file
├── .env.example       # Environment variables template
└── .env               # Your configuration (gitignored)
```

### Adding New Features

1. Edit `app.py` with your changes
2. Test locally with `streamlit run app.py`
3. Update documentation in README.md
4. Update requirements.txt if adding dependencies

### Customization

The application uses custom CSS for styling. Modify the `load_custom_css()` function in `app.py` to change:
- Colors and themes
- Message styling
- Layout spacing
- Animations and transitions

## 🚀 Deployment

### Streamlit Cloud
1. Push code to GitHub repository
2. Connect to Streamlit Cloud
3. Add environment variables in deployment settings
4. Deploy!

### Docker (Optional)
```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8501
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

## 📄 License

This project is part of NIP v3.0.0. See main project LICENSE file for details.

## 🤝 Support

For issues, questions, or contributions:
- Check the main NIP documentation
- Open an issue on the project repository
- Contact the development team

## 🎉 Acknowledgments

Built with:
- [Streamlit](https://streamlit.io/) - Web framework
- [httpx](https://www.python-httpx.org/) - Async HTTP client
- [Plotly](https://plotly.com/) - Interactive charts

---

**Version**: 3.0.0  
**Last Updated**: 2026-01-17  
**Status**: ✅ Production Ready
