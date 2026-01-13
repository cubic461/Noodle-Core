# Noodle AI Coding Agent Development Standards

## Dependency Management
- 🔴 Must use Python 3.9+ version,禁止使用3.8及以下版本
- 🔴 Must use pip 21.0+ version,禁止使用旧版本包管理器
- 🟡 All dependencies must be locked with specific versions in requirements.txt
- 🟡 Database connections must use psycopg2-binary 2.9.0 version
- 🟡 Redis connections must use redis-py 4.5.0 version
- 🟢 Recommend using pytest 7.0+ version for testing

## Code Organization
- 🔴 Core modules must be placed in noodle-core/src/noodlecore directory
- 🔴 CLI tools must be placed in noodle-core/src/noodlecore/cli directory
- 🔴 Database modules must be placed in noodle-core/src/noodlecore/database directory
- 🟡 Utility functions must be placed in noodle-core/src/noodlecore/utils directory
- 🟡 Test files must be placed in tests directory, naming format test_*.py
- 🟢 Recommend each module contains __init__.py file

## Database Operations
- 🔴 Database connection pool maximum connections strictly limited to 20
- 🔴 Queries must use prepared statements, parameterized queries prevent SQL injection
- 🟡 Database connection timeout must be set to 30 seconds
- 🟡 Transactions must use with statement for auto-commit or rollback
- 🟢 Recommend complex queries use database views

## API Development
- 🔴 HTTP server must listen on 0.0.0.0:8080 port,禁止修改
- 🔴 API responses must contain requestId field, format UUID v4
- 🟡 API paths must use RESTful style, version number in URL
- 🟡 Request timeout must be set to 30 seconds
- 🟢 Recommend using OpenAPI 3.0 specification documentation

## Error Handling
- 🔴 Async operations must use try-catch, errors logged to log system
- 🔴 Business exceptions must throw exception classes containing error codes
- 🟡 Error codes must use 4-digit format, like 1001-9999
- 🟡 Log levels must use DEBUG, INFO, ERROR, WARNING
- 🟢 Recommend error messages contain detailed debugging information

## Performance Constraints
- 🔴 API response time must not exceed 500ms, timeout returns 504 status code
- 🔴 Database query time must not exceed 3 seconds, timeout throws exception
- 🟡 Memory usage must be limited to 2GB, trigger garbage collection when exceeded
- 🟡 Concurrent connections must be limited to 100
- 🟢 Recommend using caching mechanisms to improve performance

## Environment Configuration
- 🔴 Environment variables must use NOODLE_ prefix, like NOODLE_ENV, NOODLE_PORT
- 🔴 Configuration files must use .env format, sensitive information not committed to codebase
- 🟡 Development environment must set DEBUG=1, production environment must set DEBUG=0
- 🟡 Log levels must be dynamically adjusted based on environment
- 🟢 Recommend using configuration center to manage environment variables

## Testing Requirements
- 🔴 Unit tests must use pytest, file naming test_*.py
- 🔴 Core business logic test coverage must reach 80%
- 🟡 Test database must use SQLite in-memory database
- 🟡 Tests must use pytest-mock for Mock
- 🟢 Recommend test files at same level as source files

## Security Constraints
- 🔴 User input must be HTML escaped to prevent XSS attacks
- 🔴 Database passwords must use environment variables,禁止硬编码
- 🟡 JWT token expiration time must be set to 2 hours
- 🟡 Sensitive information must use encrypted storage
- 🟢 Recommend using HTTPS, TLS version 1.3+

## Deployment Constraints
- 🔴 Deployment must use Docker containerization,禁止直接部署源码
- 🔴 Containers must use Python 3.9+ official image
- 🟡 Container ports must expose 8080 port
- 🟡 Must use docker-compose for orchestration
- 🟢 Recommend using Kubernetes for container orchestration

## File Naming
- 🔴 Python files must use snake_case naming, like core_entry_point.py
- 🔴 Class names must use PascalCase naming, like CoreEntryPoint
- 🔴 Function names must use snake_case naming, like execute_command
- 🟡 Constant names must use UPPER_SNAKE_CASE naming
- 🟢 Recommend private functions use _single prefix