# Noodle Project Structure

## Overview

Dit document beschrijft de georganiseerde structuur van het Noodle project na de uitgebreide reorganisatie en opruiming.

## 📁 Directory Structuur

```
noodle/ (ENTERPRISE ECOSYSTEM)
├── 📄 Essentiële Root Bestanden
├── 🏗️ Core Componenten
├── 🔧 Infrastructure & Tools
├── 📚 Documentatie & Kennisbank
├── 🗃️ Archieven & Project Management
└── 📋 Development Environment
```

## 📄 Essentiële Root Bestanden

| Bestand | Doel | Status |
|----------|--------|---------|
| [`README.md`](README.md) | Project overzicht en quick start | ✅ Actief |
| [`NOODLE_IMPLEMENTATION_PLAN.md`](NOODLE_IMPLEMENTATION_PLAN.md) | Hoofd implementatie plan (18 maanden) | ✅ Actief |
| [`NOODLE_UNIFIED_DOCUMENTATION.md`](NOODLE_UNIFIED_DOCUMENTATION.md) | Complete project documentatie | ✅ Actief |
| [`Makefile`](Makefile) | Unified build system | ✅ Actief |
| [`requirements.txt`](requirements.txt) | Centralized dependencies | ✅ Actief |
| [`pyproject.toml`](pyproject.toml) | Modern Python packaging | ✅ Actief |
| [`pytest.ini`](pytest.ini) | Test configuratie | ✅ Actief |
| [`AGENTS.md`](🛡️%20AGENTS.md) | AI agents documentatie | ✅ Actief |

## 🏗️ Core Componenten

### Primary Components

- **[`noodle-core/`](noodle-core/)** - Core runtime en AI infrastructure
- **[`noodle-ide/`](noodle-ide/)** - Unified IDE componenten
- **[`noodle-lang/`](noodle-lang/)** - Language & compiler systemen

### Specialized Services

- **[`noodle-agents-trm/`](noodle-agents-trm/)** - TRM AI agents
- **[`noodle-cli-typescript/`](noodle-cli-typescript/)** - TypeScript CLI tools
- **[`noodle-control-mobile/`](noodle-control-mobile/)** - Mobile control interface
- **[`noodle-desktop-tauri/`](noodle-desktop-tauri/)** - Desktop Tauri applicatie
- **[`noodle-extended-memory-bank/`](noodle-extended-memory-bank/)** - Extended knowledge base
- **[`noodle-network-noodlenet/`](noodle-network-noodlenet/)** - Network layer
- **[`noodle-vector-database/`](noodle-vector-database/)** - Vector database system

## 🔧 Infrastructure & Tools

| Directory | Doel |
|------------|--------|
| [`scripts/`](scripts/) | Build & deployment scripts |
| [`config/`](config/) | Configuration management |
| [`deployment/`](deployment/) | Deployment configuraties |
| [`mcp-config/`](mcp-config/) | MCP configuratie |

## 📚 Documentatie & Kennisbank

| Directory | Doel |
|------------|--------|
| [`docs/`](docs/) | Unified documentation systeem |
| [`memory-bank/`](memory-bank/) | Knowledge base en implementatie beslissingen |

## 🗃️ Archieven & Project Management

| Directory | Doel |
|------------|--------|
| [`archive/`](archive/) | Historische data en rapporten |
| [`project-management/`](project-management/) | Actieve project plannen |

### Archive Structuur

```
archive/
├── 2025/
│   ├── completion-reports/    # Voltooide project fasen
│   └── analysis-reports/      # Technische analyses
└── README.md                 # Archief index
```

### Project Management Structuur

```
project-management/
├── plans/                    # Actieve implementatie plannen
│   ├── NOODLE_IMPLEMENTATION_PLAN.md
│   ├── AI_AGENT_INFRASTRUCTURE_IMPLEMENTATION_PLAN.md
│   └── NEXT_DEVELOPMENT_PHASE_PLAN.md
└── README.md                # Project management index
```

## 📋 Development Environment

| Directory | Doel |
|------------|--------|
| [`tests/`](tests/) | Centralized test suite |
| [`.github/`](.github/) | CI/CD workflows |
| [`.noodlecore/`](.noodlecore/) | NoodleCore configuratie |
| [`.roo/`](.roo/) | Roo development setup |
| [`code_index/`](code_index/) | Code indexing systeem |

## 🚀 Quick Start

### Development Setup

```bash
# Clone en setup
git clone <repository>
cd noodle

# Installeer dependencies
make install

# Start development environment
make dev-setup

# Run tests
make test
```

### Build Targets

```bash
make help           # Toon alle beschikbare targets
make build-dev      # Development build
make build-prod     # Production build
make test          # Run alle tests
make lint          # Code quality checks
make clean         # Cleanup build artifacts
```

## 📖 Documentatie Navigatie

1. **Start Hier**: [`README.md`](README.md) - Project overzicht
2. **Implementatie Plan**: [`NOODLE_IMPLEMENTATION_PLAN.md`](NOODLE_IMPLEMENTATION_PLAN.md) - 18 maanden roadmap
3. **Complete Documentatie**: [`NOODLE_UNIFIED_DOCUMENTATION.md`](NOODLE_UNIFIED_DOCUMENTATION.md) - Volledige specificaties
4. **Archief**: [`archive/README.md`](archive/README.md) - Historische rapporten
5. **Project Management**: [`project-management/README.md`](project-management/README.md) - Actieve plannen

## 🔄 Onderhoud Richtlijnen

### Bestandsorganisatie

- **Root files**: Alleen essentiële project bestanden
- **Documentatie**: Gebruik `docs/` voor actieve documentatie
- **Archieven**: Verplaats oude rapporten naar `archive/2025/`
- **Plannen**: Actieve plannen in `project-management/plans/`

### Naming Conventions

- **Files**: `kebab-case.md` voor documentatie
- **Directories**: `kebab-case` voor directories
- **Code**: `snake_case` voor Python, `PascalCase` voor classes

### Quality Standards

- **Testing**: 80%+ coverage vereist
- **Documentation**: Docstrings en type hints verplicht
- **Error Handling**: 4-digit error codes (1001-9999)
- **Environment**: `NOODLE_` prefix voor variabelen

---

**Laatst bijgewerkt**: 2025-11-14  
**Status**: ✅ Project structuur georganiseerd en enterprise-ready  
**Volgende stap**: Implementatie volgens [`NOODLE_IMPLEMENTATION_PLAN.md`](NOODLE_IMPLEMENTATION_PLAN.md)
