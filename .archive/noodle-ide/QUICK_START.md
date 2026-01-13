# Noodle IDE - Quick Start Guide

## 🚀 **IDE Access Information**

### **Primary Access URL**

```
http://localhost:8081/ide.html
```

### **NoodleCore API Server**

```
http://localhost:8080
```

---

## 🟨 **Getting Started with Noodle IDE**

### **Step 1: Open the IDE**

1. Open your web browser
2. Navigate to: **<http://localhost:8081/ide.html>**
3. The IDE will automatically connect to NoodleCore

### **Step 2: Verify Connection**

- Look for the green **"Connected to NoodleCore"** indicator in the header
- Check the output panel for connection confirmation

### **Step 3: Start Coding**

1. The IDE comes with a welcome file already loaded
2. Start typing Noodle language code in the editor
3. Use the **Execute (F5)** button to run your code

---

## 🎯 **Key IDE Features**

### **File Operations**

- **New File** (Ctrl+N): Create new Noodle files
- **Open File**: Load existing files from NoodleCore
- **Save** (Ctrl+S): Save current file through NoodleCore API

### **Code Execution**

- **Execute (F5)**: Execute current code via NoodleCore
- **Output Panel**: View execution results and errors
- **Clear**: Clear output panel for fresh results

### **IDE Interface**

- **File Explorer**: Browse files and recent projects
- **Tab Management**: Work with multiple files simultaneously
- **Connection Status**: Monitor NoodleCore connection health

---

## 🔧 **Available IDE Endpoints**

The IDE integrates with these NoodleCore API endpoints:

### **Core IDE Operations**

- `GET /api/v1/ide/status` - IDE system status
- `POST /api/v1/ide/execute` - Execute Noodle code
- `POST /api/v1/ide/file/open` - Open file
- `POST /api/v1/ide/file/save` - Save file
- `POST /api/v1/ide/file/create` - Create new file
- `POST /api/v1/ide/file/delete` - Delete file
- `POST /api/v1/ide/file/list` - List directory contents

### **Code Analysis**

- `POST /api/v1/ide/syntax/highlight` - Syntax highlighting
- `POST /api/v1/ide/completions` - Code completion suggestions

### **Project Management**

- `POST /api/v1/ide/project/create` - Create new project
- `POST /api/v1/ide/project/open` - Open existing project
- `POST /api/v1/ide/project/close` - Close project

---

## 💡 **Example Noodle Code**

Try this code in the IDE to test execution:

```noodle
# Noodle Language Example
def fibonacci(n):
    """Calculate fibonacci number"""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# Test the function
print("Fibonacci sequence:")
for i in range(10):
    print(f"fib({i}) = {fibonacci(i)}")

# Demonstrate language independence
class LanguageIndependent:
    def __init__(self):
        self.message = "Running in Noodle IDE!"
    
    def greet(self):
        return self.message

obj = LanguageIndependent()
print(obj.greet())
```

---

## 🟢 **Status Indicators**

### **Connection Status**

- 🟢 **Connected**: Green indicator - Ready to use
- 🔴 **Disconnected**: Red indicator - Check NoodleCore server

### **File Status**

- **Plain filename**: File saved
- **filename***: Unsaved changes (with asterisk)

---

## 🚨 **Troubleshooting**

### **IDE Won't Load**

1. Verify NoodleCore is running on port 8080
2. Check browser console for errors
3. Ensure no firewall blocking localhost

### **NoodleCore Connection Failed**

1. Start NoodleCore: `python -m noodlecore.api.server --debug`
2. Check port 8080 is available
3. Verify API endpoints respond: `curl http://localhost:8080/api/v1/health`

### **Code Execution Errors**

1. Check output panel for detailed error messages
2. Verify code syntax matches Noodle language standards
3. Ensure file is saved before execution

---

## 🎮 **Keyboard Shortcuts**

| Shortcut | Action |
|----------|--------|
| `Ctrl+N` | New File |
| `Ctrl+O` | Open File |
| `Ctrl+S` | Save File |
| `F5` | Execute Code |
| `Ctrl+Z` | Undo |
| `Ctrl+Y` | Redo |
| `Ctrl+F` | Find |
| `Ctrl+H` | Replace |

---

## 🏗️ **Architecture Overview**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Browser   │    │   Noodle IDE    │    │   NoodleCore    │
│                 │    │   Web Server    │    │   API Server    │
│   IDE Interface │◄──►│   Port 8081     │◄──►│   Port 8080     │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────►│  NoodleCore    │◄─────────────┘
                        │  IDE Components│
                        │  (.nc files)   │
                        └─────────────────┘
```

---

## 🎯 **Next Steps**

1. **Explore Noodle Language**: Try various Noodle language features
2. **Project Management**: Create and manage Noodle projects
3. **API Integration**: Use all 13 IDE-specific endpoints
4. **Custom Development**: Extend IDE functionality through NoodleCore

---

**🚀 Ready to code in Noodle! Open <http://localhost:8081/ide.html> now! 🚀**
