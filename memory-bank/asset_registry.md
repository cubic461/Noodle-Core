# Noodle Project Asset Registry

## Overview

This document serves as the central registry for all project assets in the Noodle project. It tracks the status, ownership, and relationships of all project components.

## Code Assets

### Noodle Core

- **Type**: Code Asset
- **Owner**: Core Development Team
- **Status**: Active
- **Location**: [`noodle-core/`](../noodle-core/)
- **Dependencies**: Python 3.9+, pytest, redis-py, psycopg2-binary
- **Last Updated**: 2025-10-18
- **Version**: 0.24.0
- **Notes**: Core runtime and compiler for Noodle language

#### Core Modules

- **noodlecore Runtime**
  - **Type**: Code Asset
  - **Owner**: Core Development Team
  - **Status**: Active
  - **Location**: [`noodle-core/src/noodlecore/`](../noodle-core/src/noodlecore/)
  - **Dependencies**: Python standard library
  - **Last Updated**: 2025-10-18
  - **Notes**: Main runtime environment

- **TRM-Agent**
  - **Type**: Code Asset
  - **Owner**: AI Team
  - **Status**: Active
  - **Location**: [`noodle-core/trm_agent/`](../noodle-core/trm_agent/)
  - **Dependencies**: Python AST libraries, ML frameworks
  - **Last Updated**: 2025-10-10
  - **Version**: 1.0.0
  - **Notes**: AI-powered optimization system

### Noodle IDE

- **Type**: Code Asset
- **Owner**: IDE Development Team
- **Status**: In Development
- **Location**: [`noodle-ide/`](../noodle-ide/)
- **Dependencies**: Node.js 16+, Tauri, React, TypeScript
- **Last Updated**: 2025-10-15
- **Version**: 0.1.0-alpha
- **Notes**: Development environment with AI integration

### NoodleNet

- **Type**: Code Asset
- **Owner**: Networking Team
- **Status**: In Development
- **Location**: [`noodlenet/`](../noodlenet/)
- **Dependencies**: Python networking libraries
- **Last Updated**: 2025-10-12
- **Version**: 0.1.0-alpha
- **Notes**: Distributed networking capabilities

## Documentation Assets

### Master Prompt

- **Type**: Documentation
- **Owner**: Project Leadership
- **Status**: Active
- **Location**: [`docs/hierarchy/00-master-prompt/`](../docs/hierarchy/00-master-prompt/)
- **Dependencies**: None
- **Last Updated**: 2025-10-19
- **Notes**: Central alignment blueprint for the project

### API Documentation

- **Type**: Documentation
- **Owner**: Documentation Team
- **Status**: Active
- **Location**: [`docs/api/`](../docs/api/)
- **Dependencies**: Code implementation
- **Last Updated**: 2025-10-15
- **Notes**: Complete API reference and examples

### Navigation System

- **Type**: Documentation
- **Owner**: Project Leadership
- **Status**: Active
- **Location**: [`PROJECT_NAVIGATION.md`](../PROJECT_NAVIGATION.md)
- **Dependencies**: Project structure
- **Last Updated**: 2025-10-19
- **Notes**: Central navigation hub for the project

## Infrastructure Assets

### CI/CD Pipeline

- **Type**: Infrastructure
- **Owner**: DevOps Team
- **Status**: Active
- **Location**: GitHub Actions
- **Dependencies**: GitHub, Docker
- **Last Updated**: 2025-10-18
- **Notes**: Automated build, test, and deployment

### Docker Configuration

- **Type**: Infrastructure
- **Owner**: DevOps Team
- **Status**: Active
- **Location**: [`noodle-core/docker-compose.yml`](../noodle-core/docker-compose.yml)
- **Dependencies**: Docker
- **Last Updated**: 2025-10-18
- **Notes**: Containerized deployment configuration

## Tools Assets

### Build Scripts

- **Type**: Tool
- **Owner**: DevOps Team
- **Status**: Active
- **Location**: [`scripts/`](../scripts/)
- **Dependencies**: Python, Node.js
- **Last Updated**: 2025-10-18
- **Notes**: Build and utility scripts

### Testing Framework

- **Type**: Tool
- **Owner**: QA Team
- **Status**: Active
- **Location**: [`tests/`](../tests/)
- **Dependencies**: pytest, testing libraries
- **Last Updated**: 2025-10-18
- **Notes**: Test suite and testing utilities

## Intellectual Property Assets

### Noodle Language Specification

- **Type**: Intellectual Property
- **Owner**: Project Leadership
- **Status**: Active
- **Location**: [`docs/hierarchy/03-core-concepts/`](../docs/hierarchy/03-core-concepts/)
- **Dependencies**: None
- **Last Updated**: 2025-10-19
- **Notes**: Language specification and design

### Project Branding

- **Type**: Intellectual Property
- **Owner**: Project Leadership
- **Status**: Active
- **Location**: Repository assets
- **Dependencies**: None
- **Last Updated**: 2025-10-01
- **Notes**: Logos, trademarks, and brand guidelines

## Asset Relationships

### Dependencies

```
Noodle IDE → Noodle Core
NoodleNet → Noodle Core
TRM-Agent → Noodle Core
Documentation → Code Assets
Tests → Code Assets
CI/CD → All Assets
```

### Impact Analysis

- Changes to Noodle Core affect: IDE, NoodleNet, TRM-Agent
- Changes to Master Prompt affect: All documentation and development
- Changes to Development Standards affect: All code assets

## Asset Lifecycle Management

### Active Assets

All assets listed above are currently active and maintained.

### Deprecated Assets

None currently deprecated.

### Archived Assets

- Old build scripts (archived 2025-09-15)
- Legacy documentation (archived 2025-09-01)

## Maintenance Schedule

### Weekly

- Review asset status
- Update last modified dates
- Check for new dependencies

### Monthly

- Complete asset audit
- Review ownership assignments
- Update asset relationships

### Quarterly

- Review asset lifecycle
- Plan asset retirement
- Update asset registry structure

---

*This asset registry is part of the Noodle Governance System and is maintained according to the CMDB change management process.*
