# AI Role Management System - Complete Guide

## Overview

Your NoodleCore IDE includes a sophisticated AI role management system that allows you to create, edit, and use AI roles defined in text documents. Each role has its own document that defines how the AI should behave during conversations.

## How It Works

### 🎯 Core Concept

- **Individual Text Documents**: Each AI role has its own `.md` (Markdown) file
- **Role Selection**: Choose roles from a dropdown in the IDE
- **Automatic Integration**: Selected role content is automatically passed to AI operations
- **Real-time Editing**: Edit role documents directly in the IDE

### 📁 File Structure

```
noodle-core/
└── .noodlecore/
    └── ai_roles/
        ├── roles_config.json      # Configuration file
        ├── code_architect.md      # Role 1 document
        ├── noodlecore_developer.md # Role 2 document
        ├── code_reviewer.md       # Role 3 document
        └── ...                    # More role documents
```

## Using the AI Role System

### 1. **Role Selection**

- Open the IDE and look for the AI panel
- Use the "AI Role" dropdown to select from available roles
- Options include:
  - Code Architect
  - NoodleCore Developer  
  - Code Reviewer
  - Debugging Expert
  - Documentation Specialist
  - Test Engineer
  - Performance Optimizer
  - Security Analyst

### 2. **Editing Role Documents**

- **Method 1**: Select a role → Click "Edit Role" button → Document opens automatically
- **Method 2**: Right-click role in management dialog → Select "Edit"
- The role document opens in the IDE editor as a regular file

### 3. **Creating New Roles**

- Click "Create New Role" in the AI panel
- Fill in:
  - **Role Name**: Descriptive name for the role
  - **Description**: Brief explanation of the role
  - **Category**: Choose from predefined categories
- Click "Create" → New role document is created and opened for editing

### 4. **Managing Roles**

- Click "Manage Roles" to see all roles in a management dialog
- Options for each role:
  - **Edit**: Open the role document for editing
  - **Delete**: Remove the role (with confirmation)
  - **View**: See role details and metadata

## Role Document Structure

### Default Template

Each role document follows this structure:

```markdown
# Role Name

## Role Description
Provide a detailed description of this AI role's responsibilities, expertise areas, and how it should behave during conversations.

## Key Responsibilities
- Responsibility 1
- Responsibility 2
- Responsibility 3

## Communication Style
- Tone: [professional/friendly/technical/etc.]
- Level of detail: [concise/detailed/comprehensive]
- Response format: [bullet points/paragraphs/code examples/etc.]

## Areas of Expertise
- Expertise area 1
- Expertise area 2
- Expertise area 3

## Interaction Guidelines
- How to handle questions outside expertise
- Preferred approach to problem-solving
- When to ask clarifying questions

## Example Scenarios
Describe how this role would handle typical scenarios or provide example interactions.
```

### Customizing Role Documents

#### Example: Code Reviewer Role

```markdown
# Code Reviewer

## Role Description
Expert code reviewer specializing in code quality, best practices, and security analysis for software development projects.

## Key Responsibilities
- Review code for security vulnerabilities
- Ensure adherence to coding standards
- Identify potential bugs and issues
- Suggest performance improvements
- Validate test coverage and quality

## Communication Style
- Tone: Professional and constructive
- Level of detail: Comprehensive with specific examples
- Response format: Bullet points with actionable feedback

## Areas of Expertise
- Security analysis and vulnerability detection
- Code quality assessment
- Performance optimization
- Testing strategies
- NoodleCore language specifics

## Interaction Guidelines
- Always provide specific, actionable feedback
- Reference specific code sections with line numbers
- Suggest alternative implementations when appropriate
- Ask clarifying questions about business logic when needed

## Example Scenarios
When reviewing a function:
1. Check input validation and error handling
2. Review security implications
3. Assess performance impact
4. Validate against project coding standards
5. Suggest improvements with clear rationale
```

## AI Integration

### How Role Content is Used

When you select a role and perform AI operations (analyze code, generate docs, fix errors), the system:

1. **Reads the role document** content automatically
2. **Includes role context** in AI requests
3. **Influences AI responses** based on role specifications
4. **Provides role-specific suggestions** tailored to the selected role

### Example AI Operations

- **Code Analysis**: Role-specific analysis based on selected role
- **Auto-completion**: Completion style tailored to role
- **Documentation**: Documentation format matching role preferences
- **Error Fixing**: Fix strategies aligned with role expertise

## Best Practices

### 1. **Document Organization**

- Keep role descriptions concise but comprehensive
- Use consistent formatting across role documents
- Include specific examples in interaction guidelines

### 2. **Role Categories**

Use appropriate categories for better organization:

- **Architecture**: System design and planning
- **Development**: Implementation and coding
- **Review**: Code review and quality assurance
- **Debugging**: Troubleshooting and problem-solving
- **Documentation**: Writing and documentation
- **Testing**: Test strategy and quality assurance
- **Optimization**: Performance and efficiency
- **Security**: Security analysis and compliance

### 3. **Maintenance**

- Regularly update role documents based on project needs
- Review and refine role descriptions as requirements evolve
- Archive unused roles rather than deleting them

### 4. **Customization Tips**

- **Be Specific**: Include detailed guidelines rather than generic advice
- **Use Examples**: Provide concrete examples of desired behavior
- **Define Boundaries**: Clearly specify what the role should and shouldn't do
- **Style Guidelines**: Include communication style preferences

## Troubleshooting

### Common Issues

#### Role Documents Not Loading

- Ensure role documents are in `.noodlecore/ai_roles/` directory
- Check that `roles_config.json` exists and is valid
- Verify document paths in configuration match actual file locations

#### Role Not Appearing in Dropdown

- Check that role is properly saved in `roles_config.json`
- Verify role has a valid name and document path
- Restart the IDE to reload role configurations

#### Edit Button Not Working

- Ensure the selected role has a valid document path
- Check that the role document file exists
- Verify file permissions allow reading

### Getting Help

- Check the IDE status bar for error messages
- Review the management dialog for role details
- Verify role documents are properly formatted Markdown

## Advanced Features

### Import/Export Roles

- **Export**: Save role configurations for backup or sharing
- **Import**: Load role configurations from other projects
- **Backup**: Regular backups of role configurations

### Search and Filter

- Search roles by name, description, or tags
- Filter roles by category
- Quick role switching during development

### Integration with Other IDE Features

- Role context affects code analysis results
- Role preferences influence auto-completion
- Documentation style follows role guidelines

## Conclusion

Your AI role management system provides a powerful way to customize AI behavior for different development tasks. By carefully crafting role documents, you can ensure the AI provides responses tailored to your specific needs and project requirements.

The system seamlessly integrates with your IDE workflow, making it easy to switch between different AI personalities and expertise levels as your development tasks evolve.
