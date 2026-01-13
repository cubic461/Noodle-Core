# AI Role Management System - Workflow Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    NoodleCore IDE                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐ │
│  │  Role Panel  │  │  File Tree   │  │   Code Editor       │ │
│  │              │  │              │  │                     │ │
│  │ [Dropdown]   │  │ [.md files]  │  │ [Role Documents]    │ │
│  │ [Edit]       │  │ [Open Files] │  │ [Real-time Editing] │ │
│  │ [Manage]     │  │              │  │                     │ │
│  └──────────────┘  └──────────────┘  └─────────────────────┘ │
│         │                │                      │            │
└─────────┼────────────────┼──────────────────────┼────────────┘
          │                │                      │
          │                │                      │
          ▼                ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│              AI Role Management System                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  AIRoleManager  │  │ Role Documents  │  │  Config      │ │
│  │                 │  │ (.noodlecore)   │  │  (JSON)      │ │
│  │ - Create Roles  │  │                 │  │              │ │
│  │ - Load Roles    │  │ - code_arch.md  │  │ - Role IDs   │ │
│  │ - Save Roles    │  │ - dev_role.md   │  │ - Metadata   │ │
│  │ - Read Docs     │  │ - review_role.md│  │ - Timestamps │ │
│  └─────────────────┘  │ - security.md   │  └──────────────┘ │
│                       └─────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              AI Context Integration                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  When AI operation is triggered:                           │
│  1. Current role selected from dropdown                    │
│  2. Role document content read automatically               │
│  3. Content included in AI request as context              │
│  4. AI responds based on role specifications               │
│                                                             │
│  Examples:                                                  │
│  • Code Analysis → Role-specific analysis style            │
│  • Auto-completion → Role-tailored suggestions            │
│  • Documentation → Role-formatted output                   │
│  • Error Fixing → Role-based solution approach            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## User Workflow

### 1. **Starting a New Role**

```
User Action → Click "Create New Role"
    ↓
Fill Role Details (Name, Description, Category)
    ↓
System → Creates .md file with template
    ↓
IDE → Opens document for editing
    ↓
User → Customize role document
    ↓
System → Saves configuration and document
```

### 2. **Using an Existing Role**

```
User Action → Select role from dropdown
    ↓
System → Loads role metadata
    ↓
IDE → Updates status to show selected role
    ↓
User Action → Perform AI operation
    ↓
System → Reads role document content
    ↓
AI Operation → Uses role context in response
    ↓
Output → Role-specific AI behavior
```

### 3. **Editing a Role**

```
User Action → Select role + Click "Edit Role"
    ↓
System → Opens role document in editor
    ↓
User → Edit document content
    ↓
User → Save file (Ctrl+S)
    ↓
System → Updates role timestamp
    ↓
Next AI operation → Uses updated content
```

## File Organization

```
noodle-core/
├── fully_functional_beautiful_ide.py      # Main IDE application
├── src/noodlecore/ai/role_manager.py      # Role management logic
├── AI_ROLE_MANAGEMENT_GUIDE.md            # User documentation
├── AI_ROLE_WORKFLOW.md                    # This workflow diagram
└── .noodlecore/ai_roles/                  # Role data directory
    ├── roles_config.json                  # Role database
    ├── code_architect.md                  # Individual role documents
    ├── noodlecore_developer.md
    ├── code_reviewer.md
    ├── debugging_expert.md
    ├── documentation_specialist.md
    ├── test_engineer.md
    ├── performance_optimizer.md
    ├── security_analyst.md
    └── role_backups/                      # Backup directory
```

## Key Features

✅ **Individual Text Documents** - Each role has its own .md file  
✅ **Role Selection** - Dropdown to choose from available roles  
✅ **Edit Integration** - Click button to open role document  
✅ **AI Context Integration** - Document content passed to AI operations  
✅ **Real-time Editing** - Edit documents directly in IDE  
✅ **Role Management** - Create, edit, delete, search roles  
✅ **Configuration Storage** - JSON-based role metadata  
✅ **Backup System** - Automatic backups of role configurations  

## Integration Points

- **IDE UI**: Role dropdown, edit buttons, management dialog
- **File System**: Role documents stored as .md files
- **AI Operations**: Code analysis, completion, documentation, error fixing
- **Configuration**: JSON-based role database with metadata
- **Backup**: Automatic role backup and restore functionality
