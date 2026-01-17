# 🚀 Quick Start Guide - NIP v3.0.0 Web UI

## Get Started in 3 Minutes!

### Windows Users

1. **Double-click** `start.bat`
   - This will automatically:
     - Create a virtual environment
     - Install dependencies
     - Create configuration file
     - Start the application

2. **Wait for browser to open** at http://localhost:8501

3. **Start chatting!** 🎉

### Linux/Mac Users

1. **Make script executable** (first time only):
   ```bash
   chmod +x start.sh
   ```

2. **Run the script**:
   ```bash
   ./start.sh
   ```

3. **Wait for browser to open** at http://localhost:8501

4. **Start chatting!** 🎉

---

## Manual Installation

If the startup script doesn't work, follow these steps:

### 1. Create Virtual Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure Environment
```bash
# Windows
copy env.example .env

# Linux/Mac
cp env.example .env
```

Edit `.env` and add your API keys if needed.

### 4. Start Application
```bash
streamlit run app.py
```

---

## First Time Setup

1. **Configure API** (in sidebar):
   - Set API URL (default: http://localhost:8000)
   - Add API key if required

2. **Choose Model**:
   - Select your preferred AI model
   - Adjust temperature (0.7 is good for most uses)

3. **Test It Out**:
   - Type "Hello!" in the chat
   - Click Send
   - Watch the response stream in real-time

---

## What Can You Do?

### 💬 Chat
- Ask questions about code
- Get programming help
- Explain complex concepts

### 📁 Analyze Files
1. Click "Upload Files for Analysis"
2. Select code files (Python, JS, Java, etc.)
3. Ask questions about the code
4. Get detailed analysis

### 📜 View History
- See all past conversations
- Export as JSON, Markdown, or TXT
- Review your coding journey

### ⚙️ Customize
- Switch between dark/light themes
- Adjust model parameters
- Configure advanced settings

---

## Tips & Tricks

✅ **Use keyboard shortcuts**: Enter to send, Shift+Enter for new line

✅ **Upload multiple files**: Select all at once for batch analysis

✅ **Export important chats**: Save conversations as Markdown for documentation

✅ **Adjust temperature**: Lower for focused answers, higher for creative ideas

✅ **Use file analysis**: Paste error messages and ask for explanations

---

## Troubleshooting

**"Module not found" error?**
```bash
pip install -r requirements.txt --upgrade
```

**"Connection refused" error?**
- Check if NIP server is running
- Verify API URL in settings

**App won't start?**
- Make sure Python 3.10+ is installed
- Try: `pip install --upgrade streamlit`

---

## Need Help?

- Read the full README.md for detailed documentation
- Check the .env.example for configuration options
- Review comments in app.py for customization ideas

---

**You're ready to go!** 🚀

Start the app with `start.bat` (Windows) or `./start.sh` (Linux/Mac)
