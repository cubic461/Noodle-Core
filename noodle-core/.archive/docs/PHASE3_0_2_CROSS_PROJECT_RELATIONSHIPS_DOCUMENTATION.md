# Phase 3.0.2: Cross-project Relationships Component Documentation

## Overview

The Cross-project Relationships component is part of Phase 3.0.2: Knowledge Graph & Context for NoodleCore. This component enables knowledge sharing and relationship management between different projects within the NoodleCore ecosystem.

## Architecture

The Cross-project Relationships component consists of five main modules:

1. **Cross-project Relationship Manager** - Core component for managing relationships between projects
2. **Project Registry** - Project discovery and metadata management
3. **Knowledge Sharing Framework** - Configurable knowledge sharing with permission management
4. **Version Compatibility System** - Semantic version analysis and compatibility checking
5. **Knowledge Transfer Engine** - Safe and efficient knowledge transfer between projects

## Components

### 1. Cross-project Relationship Manager

**Location**: `noodle-core/src/noodlecore/ai_agents/knowledge_graph/cross_project_relationship_manager.py`

The Cross-project Relationship Manager is the core component that manages relationships between different projects.

#### Key Features

- Project registry and discovery mechanismes
- Knowledge sharing with configurable sharing levels
- Version compatibility checking with semantic analysis
- Knowledge transfer mechanismes for safe and efficient knowledge transfer
- Integration with enterprise authentication systemens

#### Main Classes

- `CrossProjectRelationshipManager` - Main class for managing cross-project relationships
- `ProjectRelationship` - Represents a relationship between projects
- `TransferableKnowledge` - Represents knowledge that can be transferred
- `VersionCompatibility` - Represents compatibility between project versions
- `CrossProjectCache` - Cache for cross-project operations

#### Usage Example

```python
from noodlecore.ai_agents.knowledge_graph.cross_project_relationship_manager import (
    CrossProjectRelationshipManager, ProjectRelationshipType, KnowledgeSharingLevel
)
from noodlecore.ai_agents.ml_configuration_manager import MLConfigurationManager
from noodlecore.database.connection_pool import DatabaseConnectionPool

# Initialize components
config_manager = MLConfigurationManager()
db_pool = DatabaseConnectionPool()

# Create relationship manager
relationship_manager = CrossProjectRelationshipManager(
    config_manager=config_manager,
    db_pool=db_pool
)

# Create a relationship between projects
result = relationship_manager.create_relationship(
    source_project_id="project-a",
    target_project_id="project-b",
    relationship_type=ProjectRelationshipType.DEPENDENCY,
    description="Project B depends on Project A"
)

if result["success"]:
    print(f"Created relationship: {result['relationship_id']}")
else:
    print(f"Failed to create relationship: {result['error']}")

# Query relationships
relationships = relationship_manager.get_relationships(
    source_project_id="project-a"
)

for rel in relationships["relationships"]:
    print(f"Relationship: {rel['source_project_id']} -> {rel['target_project_id']} ({rel['relationship_type']})")
```

### 2. Project Registry

**Location**: `noodle-core/src/noodlecore/ai_agents/knowledge_graph/project_registry.py`

The Project Registry handles project discovery and metadata management.

#### Key Features

- Project discovery with metadata tracking
- Project categorization and tagging
- Project lifecycle management
- Project dependencies and version management

#### Main Classes

- `ProjectRegistryManager` - Main class for managing project registry
- `ProjectMetadata` - Represents project metadata
- `ProjectDiscoveryResult` - Result of project discovery operations
- `ProjectRegistrationResult` - Result of project registration operations

#### Usage Example

```python
from noodlecore.ai_agents.knowledge_graph.project_registry import (
    ProjectRegistryManager, ProjectCategory, ProjectLifecycleStage
)

# Create project registry manager
registry = ProjectRegistryManager(
    config_manager=config_manager,
    db_pool=db_pool
)

# Register a project
result = registry.register_project(
    project_id="my-web-app",
    name="My Web Application",
    version="1.0.0",
    description="A sample web application",
    category=ProjectCategory.WEB_APPLICATION,
    tags=["web", "frontend", "react"],
    lifecycle_stage=ProjectLifecycleStage.ACTIVE
)

if result["success"]:
    print(f"Registered project: {result['project_id']}")
else:
    print(f"Failed to register project: {result['error']}")

# Discover projects
projects = registry.discover_projects(
    category=ProjectCategory.WEB_APPLICATION,
    tags=["web"]
)

for project in projects["projects"]:
    print(f"Found project: {project['name']} ({project['version']})")
```

### 3. Knowledge Sharing Framework

**Location**: `noodle-core/src/noodlecore/ai_agents/knowledge_graph/knowledge_sharing_framework.py`

The Knowledge Sharing Framework implements configurable knowledge sharing with permission management.

#### Key Features

- Different sharing levels (none, metadata, structure, semantic, full)
- Controlled access with permission management
- Knowledge validation and sanitization
- Audit trails for knowledge sharing

#### Main Classes

- `KnowledgeSharingFramework` - Main class for managing knowledge sharing
- `SharingPermission` - Represents sharing permissions
- `SharingAuditRecord` - Represents audit records
- `KnowledgeValidationResult` - Result of knowledge validation
- `KnowledgeSanitizationResult` - Result of knowledge sanitization

#### Usage Example

```python
from noodlecore.ai_agents.knowledge_graph.knowledge_sharing_framework import (
    KnowledgeSharingFramework, KnowledgeSharingLevel, PermissionModel, KnowledgeType
)

# Create knowledge sharing framework
sharing_framework = KnowledgeSharingFramework(
    config_manager=config_manager,
    db_pool=db_pool
)

# Set sharing permission
result = sharing_framework.set_sharing_permission(
    source_project_id="project-a",
    target_project_id="project-b",
    sharing_level=KnowledgeSharingLevel.SEMANTIC,
    permission_model=PermissionModel.ROLE_BASED,
    roles=["developer", "admin"]
)

if result["success"]:
    print(f"Set sharing permission: {result['permission_id']}")
else:
    print(f"Failed to set permission: {result['error']}")

# Check sharing permission
permission = sharing_framework.check_sharing_permission(
    source_project_id="project-a",
    target_project_id="project-b",
    sharing_level=KnowledgeSharingLevel.SEMANTIC
)

if permission["success"] and permission["allowed"]:
    print("Sharing is allowed")
else:
    print("Sharing is not allowed")
```

### 4. Version Compatibility System

**Location**: `noodle-core/src/noodlecore/ai_agents/knowledge_graph/version_compatibility_system.py`

The Version Compatibility System provides semantic version analysis and compatibility checking.

#### Key Features

- Semantic version analysis
- Version dependency tracking
- Compatibility matrices for different project versions
- Upgrade and migration paths

#### Main Classes

- `VersionCompatibilitySystem` - Main class for version compatibility checking
- `SemanticVersion` - Represents a semantic version
- `VersionChange` - Represents a change between versions
- `DependencyRelation` - Represents a dependency relationship
- `MigrationPath` - Represents a migration path between versions

#### Usage Example

```python
from noodlecore.ai_agents.knowledge_graph.version_compatibility_system import (
    VersionCompatibilitySystem, SemanticVersion, ChangeType
)

# Create version compatibility system
compatibility_system = VersionCompatibilitySystem(
    config_manager=config_manager,
    db_pool=db_pool
)

# Check compatibility between versions
result = compatibility_system.check_compatibility(
    source_project_id="project-a",
    source_version="1.0.0",
    target_project_id="project-b",
    target_version="1.1.0"
)

if result["success"]:
    print(f"Compatibility score: {result['compatibility_score']}")
    print(f"Compatibility level: {result['compatibility_level']}")
    if result["breaking_changes"]:
        print("Breaking changes:")
        for change in result["breaking_changes"]:
            print(f"  - {change}")
else:
    print(f"Failed to check compatibility: {result['error']}")

# Track version change
change_id = compatibility_system.track_version_change(
    project_id="project-a",
    version_from="1.0.0",
    version_to="1.1.0",
    change_type=ChangeType.ENHANCEMENT,
    description="Added new features",
    affected_components=["component1", "component2"]
)

if change_id:
    print(f"Tracked version change: {change_id}")

# Generate migration plan
migration_plan = compatibility_system.generate_migration_plan(
    source_project_id="project-a",
    source_version="1.0.0",
    target_project_id="project-b",
    target_version="2.0.0"
)

if migration_plan["success"]:
    print("Migration plan generated:")
    for step in migration_plan["migration_plan"]["steps"]:
        print(f"  {step['step_id']}: {step['description']}")
```

### 5. Knowledge Transfer Engine

**Location**: `noodle-core/src/noodlecore/ai_agents/knowledge_graph/knowledge_transfer_engine.py`

The Knowledge Transfer Engine provides safe and efficient knowledge transfer between projects.

#### Key Features

- Knowledge transfer with validation and sanitization
- Transfer progress tracking and monitoring
- Batch processing for large transfers
- Rollback capabilities for failed transfers
- Transfer metrics and analytics

#### Main Classes

- `KnowledgeTransferEngine` - Main class for knowledge transfer
- `KnowledgeTransfer` - Represents a knowledge transfer operation
- `TransferValidation` - Represents transfer validation results
- `TransferSanitization` - Represents transfer sanitization results
- `TransferMetrics` - Represents transfer metrics

#### Usage Example

```python
from noodlecore.ai_agents.knowledge_graph.knowledge_transfer_engine import (
    KnowledgeTransferEngine, TransferType, TransferStatus, ValidationLevel
)

# Create knowledge transfer engine
transfer_engine = KnowledgeTransferEngine(
    config_manager=config_manager,
    sharing_framework=sharing_framework,
    compatibility_system=compatibility_system,
    db_pool=db_pool
)

# Prepare knowledge data for transfer
knowledge_data = {
    "patterns": [
        {
            "pattern": "async-await-pattern",
            "description": "Async/await pattern for asynchronous operations",
            "language": "python",
            "code": "async def fetch_data():\n    response = await api_call()\n    return response"
        },
        {
            "pattern": "react-hook-pattern",
            "description": "React hook pattern for state management",
            "language": "javascript",
            "code": "const [state, setState] = useState(initialValue);"
        }
    ],
    "documentation": {
        "title": "Common Programming Patterns",
        "content": "This document describes common programming patterns..."
    }
}

# Initiate knowledge transfer
result = transfer_engine.initiate_transfer(
    source_project_id="project-a",
    source_version="1.0.0",
    target_project_id="project-b",
    target_version="1.0.0",
    transfer_type=TransferType.CODE_PATTERNS,
    transfer_level=KnowledgeSharingLevel.SEMANTIC,
    transfer_data=knowledge_data,
    validation_level=ValidationLevel.STRICT
)

if result["success"]:
    transfer_id = result["transfer_id"]
    print(f"Initiated transfer: {transfer_id}")
    
    # Execute transfer
    execution_result = transfer_engine.execute_transfer(transfer_id)
    
    if execution_result["success"]:
        print(f"Transfer completed successfully")
        print(f"Items transferred: {execution_result['items_transferred']}")
        print(f"Data size: {execution_result['data_size']} bytes")
    else:
        print(f"Transfer failed: {execution_result['error']}")
else:
    print(f"Failed to initiate transfer: {result['error']}")

# Get transfer status
status = transfer_engine.get_transfer_status(transfer_id)
if status["success"]:
    print(f"Transfer status: {status['status']}")
    print(f"Progress: {status['progress'] * 100:.1f}%")
```

## Configuration

The Cross-project Relationships components use the following environment variables for configuration:

### Cross-project Relationship Manager

- `NOODLE_KG_CROSS_PROJECT_ENABLED` - Enable/disable cross-project relationships (default: true)
- `NOODLE_KG_CROSS_PROJECT_CACHE_SIZE` - Cache size for cross-project operations (default: 5000)
- `NOODLE_KG_CROSS_PROJECT_BATCH_SIZE` - Batch size for operations (default: 100)
- `NOODLE_KG_CROSS_PROJECT_MAX_RELATIONSHIPS` - Maximum number of relationships (default: 10000)

### Project Registry

- `NOODLE_KG_PROJECT_REGISTRY_ENABLED` - Enable/disable project registry (default: true)
- `NOODLE_KG_PROJECT_REGISTRY_CACHE_SIZE` - Cache size for registry operations (default: 5000)
- `NOODLE_KG_PROJECT_REGISTRY_BATCH_SIZE` - Batch size for operations (default: 100)
- `NOODLE_KG_PROJECT_REGISTRY_MAX_PROJECTS` - Maximum number of projects (default: 10000)

### Knowledge Sharing Framework

- `NOODLE_KG_KNOWLEDGE_SHARING_ENABLED` - Enable/disable knowledge sharing (default: true)
- `NOODLE_KG_KNOWLEDGE_SHARING_CACHE_SIZE` - Cache size for sharing operations (default: 5000)
- `NOODLE_KG_KNOWLEDGE_SHARING_BATCH_SIZE` - Batch size for operations (default: 100)
- `NOODLE_KG_KNOWLEDGE_SHARING_MAX_PERMISSIONS` - Maximum number of permissions (default: 10000)

### Version Compatibility System

- `NOODLE_KG_VERSION_COMPATIBILITY_ENABLED` - Enable/disable version compatibility (default: true)
- `NOODLE_KG_VERSION_CACHE_SIZE` - Cache size for version operations (default: 5000)
- `NOODLE_KG_VERSION_BATCH_SIZE` - Batch size for operations (default: 100)
- `NOODLE_KG_VERSION_MAX_COMPATIBILITIES` - Maximum number of compatibilities (default: 10000)
- `NOODLE_KG_VERSION_SEMANTIC_ANALYSIS` - Enable semantic analysis (default: true)

### Knowledge Transfer Engine

- `NOODLE_KG_TRANSFER_ENABLED` - Enable/disable knowledge transfer (default: true)
- `NOODLE_KG_TRANSFER_CACHE_SIZE` - Cache size for transfer operations (default: 5000)
- `NOODLE_KG_TRANSFER_BATCH_SIZE` - Batch size for operations (default: 100)
- `NOODLE_KG_TRANSFER_MAX_TRANSFERS` - Maximum number of transfers (default: 10000)
- `NOODLE_KG_TRANSFER_VALIDATION` - Enable transfer validation (default: true)
- `NOODLE_KG_TRANSFER_SANITIZATION` - Enable transfer sanitization (default: true)

## Integration

### Integration with Code Context Graph

The Cross-project Relationships component integrates with the Code Context Graph to analyze code structure and relationships:

```python
from noodlecore.ai_agents.knowledge_graph.code_context_graph import CodeContextGraph

# Initialize code context graph
code_graph = CodeContextGraph()

# Analyze code structure for transfer
analysis_result = code_graph.analyze_code_structure(
    project_id="project-a",
    file_paths=["src/main.py", "src/utils.py"]
)

# Use analysis results for knowledge transfer
if analysis_result["success"]:
    knowledge_data = {
        "code_structure": analysis_result["structure"],
        "patterns": analysis_result["patterns"],
        "dependencies": analysis_result["dependencies"]
    }
    
    # Initiate transfer with code context
    transfer_result = transfer_engine.initiate_transfer(
        source_project_id="project-a",
        source_version="1.0.0",
        target_project_id="project-b",
        target_version="1.0.0",
        transfer_type=TransferType.CODE_PATTERNS,
        transfer_level=KnowledgeSharingLevel.SEMANTIC,
        transfer_data=knowledge_data
    )
```

### Integration with Semantic Analysis Engine

The component integrates with the Semantic Analysis Engine for understanding code semantics:

```python
from noodlecore.ai_agents.knowledge_graph.semantic_analysis_engine import SemanticAnalysisEngine

# Initialize semantic analysis engine
semantic_engine = SemanticAnalysisEngine()

# Analyze code semantics
semantic_result = semantic_engine.analyze_code_semantics(
    code="async def fetch_data():\n    response = await api_call()\n    return response",
    language="python"
)

# Use semantic analysis for validation
if semantic_result["success"]:
    validation_data = {
        "semantic_analysis": semantic_result["analysis"],
        "entities": semantic_result["entities"],
        "relationships": semantic_result["relationships"]
    }
    
    # Validate transfer with semantic analysis
    validation_result = transfer_engine._validate_transfer_with_semantics(
        transfer=transfer,
        semantic_data=validation_data
    )
```

### Integration with Enterprise Authentication

The component integrates with enterprise authentication systems for secure access:

```python
from noodlecore.enterprise.auth_session_manager import AuthSessionManager

# Initialize authentication manager
auth_manager = AuthSessionManager()

# Authenticate user
auth_result = auth_manager.authenticate_user(
    username="user@example.com",
    password="password",
    auth_method="ldap"
)

if auth_result["success"]:
    # Get user roles and permissions
    user_roles = auth_result.get_user_roles(auth_result["session_id"])
    
    # Check sharing permissions based on roles
    if "admin" in user_roles or "knowledge_manager" in user_roles:
        # Allow full access
        sharing_level = KnowledgeSharingLevel.FULL
    elif "developer" in user_roles:
        # Allow semantic access
        sharing_level = KnowledgeSharingLevel.SEMANTIC
    else:
        # Allow metadata access only
        sharing_level = KnowledgeSharingLevel.METADATA
    
    # Set sharing permission with role-based access
    sharing_framework.set_sharing_permission(
        source_project_id="project-a",
        target_project_id="project-b",
        sharing_level=sharing_level,
        permission_model=PermissionModel.ROLE_BASED,
        roles=user_roles
    )
```

## Performance Optimization

### Caching

All components implement multi-level caching for performance optimization:

```python
# Clear cache if needed
relationship_manager.clear_cache()
registry.clear_cache()
sharing_framework.clear_cache()
compatibility_system.clear_cache()
transfer_engine.clear_cache()

# Get cache statistics
relationship_stats = relationship_manager.get_statistics()
registry_stats = registry.get_statistics()
sharing_stats = sharing_framework.get_statistics()
compatibility_stats = compatibility_system.get_statistics()
transfer_stats = transfer_engine.get_statistics()

print(f"Relationship cache hit rate: {relationship_stats['cache_hit_rate']:.2f}%")
print(f"Registry cache hit rate: {registry_stats['cache_hit_rate']:.2f}%")
print(f"Sharing cache hit rate: {sharing_stats['cache_hit_rate']:.2f}%")
print(f"Compatibility cache hit rate: {compatibility_stats['cache_hit_rate']:.2f}%")
print(f"Transfer cache hit rate: {transfer_stats['cache_hit_rate']:.2f}%")
```

### Batch Processing

For large-scale operations, use batch processing:

```python
# Batch register projects
projects = [
    {"project_id": f"project-{i}", "name": f"Project {i}", "version": "1.0.0"}
    for i in range(100)
]

batch_result = registry.batch_register_projects(projects)

# Batch create relationships
relationships = [
    {
        "source_project_id": f"project-{i}",
        "target_project_id": f"project-{i+1}",
        "relationship_type": ProjectRelationshipType.DEPENDENCY,
        "description": f"Dependency {i}"
    }
    for i in range(99)
]

batch_result = relationship_manager.batch_create_relationships(relationships)
```

## Security Considerations

### Knowledge Sanitization

The Knowledge Transfer Engine automatically sanitizes data to remove sensitive information:

```python
# Data with sensitive information
sensitive_data = {
    "patterns": [
        {"pattern": "test-pattern", "description": "Test pattern"}
    ],
    "secrets": [
        {"key": "api_key", "value": "secret_value"}
    ],
    "urls": [
        "https://example.com/path?param=value&secret=token"
    ],
    "file_paths": [
        "/secret/private/data.txt"
    ]
}

# Sanitization is automatic during transfer
transfer_result = transfer_engine.initiate_transfer(
    source_project_id="project-a",
    target_project_id="project-b",
    transfer_type=TransferType.CODE_PATTERNS,
    transfer_level=KnowledgeSharingLevel.SEMANTIC,
    transfer_data=sensitive_data
)

# Sensitive data will be removed automatically
```

### Access Control

Implement proper access control with role-based permissions:

```python
# Set up role-based permissions
sharing_framework.set_sharing_permission(
    source_project_id="project-a",
    target_project_id="project-b",
    sharing_level=KnowledgeSharingLevel.SEMANTIC,
    permission_model=PermissionModel.ROLE_BASED,
    roles=["developer", "admin"]
)

# Set up attribute-based permissions
sharing_framework.set_sharing_permission(
    source_project_id="project-a",
    target_project_id="project-b",
    sharing_level=KnowledgeSharingLevel.FULL,
    permission_model=PermissionModel.ATTRIBUTE_BASED,
    attributes={
        "department": "engineering",
        "clearance_level": "confidential"
    }
)
```

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
python -m pytest test_knowledge_graph/test_cross_project_relationships.py -v

# Run specific test cases
python -m pytest test_knowledge_graph/test_cross_project_relationships.py::TestCrossProjectRelationships::test_cross_project_relationship_creation -v

# Run performance benchmarks
python -m pytest test_knowledge_graph/test_cross_project_relationships.py::TestPerformanceBenchmarks -v
```

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Ensure database connection pool is properly configured
   - Check database credentials and connection parameters
   - Verify database schema is initialized

2. **Cache Issues**
   - Clear cache if stale data is causing issues
   - Increase cache size if memory allows
   - Check cache hit rates for performance optimization

3. **Permission Errors**
   - Verify sharing permissions are properly configured
   - Check user roles and attributes
   - Ensure authentication system is working

4. **Compatibility Issues**
   - Check version compatibility before transfers
   - Verify semantic version format is correct
   - Review migration paths for version upgrades

### Debug Logging

Enable debug logging for troubleshooting:

```python
import logging

# Set logging level
logging.basicConfig(level=logging.DEBUG)

# Enable component-specific logging
logging.getLogger('noodlecore.ai_agents.knowledge_graph').setLevel(logging.DEBUG)
```

## Future Enhancements

Planned enhancements for the Cross-project Relationships component:

1. **Advanced Semantic Analysis**
   - Integration with large language models for code understanding
   - Enhanced pattern recognition and recommendation
   - Automated knowledge extraction from documentation

2. **Distributed Knowledge Graph**
   - Support for distributed project repositories
   - Real-time synchronization across multiple instances
   - Scalable architecture for enterprise deployments

3. **AI-Powered Recommendations**
   - Intelligent project recommendations
   - Automated knowledge transfer suggestions
   - Predictive compatibility analysis

4. **Enhanced Security**
   - Zero-knowledge proof for sensitive data
   - Advanced encryption for knowledge transfer
   - Blockchain-based audit trails

## Conclusion

The Cross-project Relationships component provides a comprehensive solution for managing knowledge sharing and relationships between projects in the NoodleCore ecosystem. With its modular architecture, robust security features, and performance optimizations, it enables efficient knowledge transfer while maintaining proper access control and data integrity.

For more information, refer to the API documentation and code examples provided in the test suite.
