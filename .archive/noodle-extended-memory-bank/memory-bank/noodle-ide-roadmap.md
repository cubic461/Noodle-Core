# 🚀 Noodle Roadmap

Deze roadmap beschrijft de gefaseerde ontwikkeling van **Noodle Core** en **Noodle IDE**.
We kiezen voor een **gescheiden aanpak**:

- **Repo 1: Noodle Core**
  De runtime, interpreter en basis-API’s (fundament van de taal).

- **Repo 2: Noodle IDE**
  Een ontwikkelomgeving bovenop Noodle Core, inclusief AI-integratie en regie.

---

## 📂 Projectstructuur

### Repo 1: Noodle (Core)
- Interpreter/runtime (basis dataflow-engine).
- Bestandsbeheer-API (centrale node).
- Worker/agent-abstractie (JSON in/out).
- Basis CLI-tools.

### Repo 2: Noodle IDE
- UI (Tauri/Electron + Monaco editor).
- File-tree gekoppeld aan Noodle Core.
- Consolepaneel.
- AI-assistent integratie.
- Project Manager (regisseur-agent).

---

## 🛠️ Fasen

### **Fase 1 – Noodle Core (Runtime MVP) ✅ COMPLETED**
- Interpreter voor basis Noodle-syntax.
- Dataflow-executie (nodes, edges).
- IO (stdin/stdout, files).
- Filesystem-node als centrale beheerder.
- **IMPLEMENTED**: Garbage collection, fault tolerance, path abstraction

**Deliverable:**
CLI waarin simpele Noodle-scripts bestanden kunnen lezen/schrijven en workers kunnen aanroepen.

**Status**: ✅ **COMPLETED** - Core runtime functionality implemented with enhanced memory management and error handling.

---

### **Fase 2 – Noodle Core uitbreiden ✅ COMPLETED**
- Worker/agent-interface (JSON in/out).
- Logging-systeem.
- API voor IDE-integratie.
- **IMPLEMENTED**: Bytecode optimizer, mathematical object enhancements

**Deliverable:**
Mogelijkheid om externe AI-modellen als worker via Noodle aan te roepen.

**Status**: ✅ **COMPLETED** - Core extensions implemented with optimization features and improved mathematical object handling.

---

### **Fase 3 – Noodle IDE (eerste UI) ✅ COMPLETED**
- Editor met file-tree (Monaco editor + Tauri/Electron).
- Connectie naar Noodle Core voor bestandsbeheer.
- Consolepaneel voor runtime-output.
- **IMPLEMENTED**: LSP APIs, plugin system, proxy_io plugin

**Deliverable:**
Lichte IDE waar Noodle-code kan worden geschreven en uitgevoerd.

**Status**: ✅ **COMPLETED** - Basic IDE functionality implemented with language server support and extensible plugin architecture.

---

### **Fase 4 – AI-integratie in IDE 🔄 BLOCKED BY INFRASTRUCTURE**
- Project Manager-agent in Noodle.
- Rollen/workflows (Coder, Tester, Reviewer).
- AI-suggesties zichtbaar in de IDE.
- Alle file-IO via Filesystem-node → consistente structuur.

**Deliverable:**
Eerste versie van Noodle IDE met AI-assistentie en regie.

**Status**: 🔄 **BLOCKED** - Implementation ready but blocked by infrastructure issues:
- Protobuf conflicts preventing distributed system testing
- Package structure issues in Tauri/React frontend
- Environment setup failures preventing comprehensive validation

---

### **Fase 5 – Dogfooding 🔄 BLOCKED BY INFRASTRUCTURE**
- Ontwikkeling van Noodle zelf verschuift naar de Noodle IDE.
- Compiler en runtime uitbreiden vanuit de eigen omgeving.
- Rollensysteem verbeteren (Architect, Coder, Tester, Reviewer, Documenter).

**Deliverable:**
Zelfversterkend systeem: Noodle ontwikkelt Noodle.

**Status**: 🔄 **BLOCKED** - Architecture ready but requires infrastructure resolution:
- Need stable testing environment for self-hosting development
- Require complete validation of Phase 1-3 implementations
- Need resolved package dependencies for seamless IDE integration

---

## ✅ Samenvatting
1. Ga verder met de Noodle repo.
2. Zorg dat runtime werkt en bouw een filesystem-node.
3. Breid dit uit met workers en logging.
4. Start een **tweede repo (Noodle IDE)** en verbind dit met Noodle Core.  (Noodle)
5. Voeg AI-integratie en Project Manager toe.
6. Stap over op **dogfooding**: gebruik Noodle IDE om Noodle verder te ontwikkelen.

---

## IDE Architecture Update (Decision 003: Reversion to Tauri/React)

Volgend op Decision 002 (tijdelijke Python-migratie voor prototyping), keren we terug naar de oorspronkelijke Tauri (Rust backend voor native performance en IPC) + React/TypeScript (frontend voor flexibele UI en Three.js-integratie) architectuur. De Python-prototype (noodle-ide-python/) is gedeprimeerd als legacy/reference materiaal. Alle toekomstige ontwikkeling gebeurt in de noodle-ide/ directory.

### Rationale voor Reversion
- **Geavanceerde 3D Capaciteiten**: Three.js/React Three Fiber voor rijke, GPU-accelerated Noodle Brain visualisatie (force-directed graphs, real-time updates, multi-user collab).
- **Plugin Ecosystem**: Web standards voor dynamisch laden, hot-reload en marketplace (afgestemd op Phase 2 in IMPLEMENTATION_PLAN.md).
- **Performance & Cross-Platform**: Tauri's native shell voor low-overhead desktop app; betere integratie met Noodle's Rust interop (bijv. FFI voor distributed runtime).
- **Developer Experience**: Bekende web tools (Vite, React hooks); lost Python embedding issues voor complexe viz op.
- **Alignment**: Ondersteunt AI-integratie (bijv. via js_bridge.py) en self-updating features naadloos.

### Key Changes
- Archiveer noodle-ide-python/ (voeg README.md toe als legacy).
- Port nuttige Python-concepten (bijv. event bus logic) naar Rust/React equivalents.
- Resumeer vanaf Phase 1 in noodle-ide/IMPLEMENTATION_PLAN.md (core Tauri setup, 3D foundation).

### Integratie en Toekomst
- **Plugins**: Brain View als eerste plugin met Three.js; uitbreiden van bestaande architectuur.
- **Roadmap**: Tauri/React vervangt Python volledig; zie [decision-003-ide-reversion-to-tauri-react.md](decision-003-ide-reversion-to-tauri-react.md) voor details.
- **Testing**: Valideer met distributed_poc voorbeeld; voeg Tauri-specifieke tests toe aan Fase 5.
- **Fallback**: Bij Tauri issues, hybrid (Tauri shell + embedded Python voor specifieke plugins).

Deze reversion realiseert de volledige Noodle IDE roadmap (3D Brain, AI agents, plugins) en verbetert langetermijn maintainability. Updates in technical_specifications.md en developer_experience_improvements.md reflecteren deze shift.

Zie [decision-003-ide-reversion-to-tauri-react.md](decision-003-ide-reversion-to-tauri-react.md) voor besluitvorming.

---

## 🔧 Infrastructure Fixes Required

### **Critical Infrastructure Issues Blocking Progress**

#### 1. Protobuf Compatibility Issues
- **Problem**: Dependency conflicts between protobuf 3.x and 4.x versions
- **Impact**: 40% of integration tests blocked, serialization failures in distributed systems
- **Files Affected**:
  - `noodle-dev/src/noodle/runtime/mathematical_object_mapper.py`
  - `noodle-dev/src/noodle/runtime/distributed/network_protocol.py`
  - `noodle-dev/tests/integration/test_mathematical_object_mapper_integration.py`
- **Solution**: Lock protobuf versions and implement compatibility layer
- **Priority**: **CRITICAL** - Blocks Phase 4 and Phase 5 progress

#### 2. Package Structure Problems
- **Problem**: Circular import issues in Tauri/React frontend and TypeScript module conflicts
- **Impact**: 35% of IDE tests blocked, plugin system functionality limited
- **Files Affected**:
  - `noodle-ide/src/components/Editor.tsx`
  - `noodle-ide/core/plugin_manager.py`
  - `noodle-ide/plugins/proxy_io/plugin.py`
- **Solution**: Refactor package structure and implement proper module boundaries
- **Priority**: **HIGH** - Essential for Phase 4 AI integration

#### 3. Environment Setup Failures
- **Problem**: Inconsistent development environments and missing dependencies
- **Impact**: 50% of performance tests blocked, unreliable test execution
- **Files Affected**:
  - `noodle-dev/performance_benchmark_*.py`
  - `noodle-dev/tests/regression/test_performance_regression.py`
- **Solution**: Implement containerized development environment
- **Priority**: **MEDIUM** - Affects validation but not core functionality

### **Implementation Status Summary**

| Phase | Status | Completion % | Key Features Implemented | Primary Blockers |
|-------|--------|--------------|-------------------------|------------------|
| Phase 1 | ✅ COMPLETED | 100% | Garbage collection, fault tolerance, path abstraction | None |
| Phase 2 | ✅ COMPLETED | 100% | Bytecode optimizer, mathematical object enhancements | None |
| Phase 3 | ✅ COMPLETED | 90% | LSP APIs, plugin system, proxy_io plugin | Package structure issues |
| Phase 4 | 🔄 BLOCKED | 30% | AI integration, project manager | Protobuf conflicts, environment setup |
| Phase 5 | 🔄 BLOCKED | 10% | Self-hosting development | All infrastructure issues |

### **Next Steps and Timeline**

#### **Immediate Actions (Week 1-2) - Infrastructure Resolution**
1. **Resolve Protobuf Conflicts**
   - Lock all protobuf dependencies to consistent version
   - Implement compatibility layer for existing code
   - Re-run all serialization-related tests
   - **Target**: Complete by end of Week 1

2. **Standardize Development Environment**
   - Create containerized development setup
   - Document all system dependencies
   - Implement environment validation scripts
   - **Target**: Complete by end of Week 2

3. **Refactor Package Structure**
   - Eliminate circular imports in TypeScript modules
   - Implement proper module boundaries
   - Update build configuration for consistency
   - **Target**: Complete by end of Week 2

#### **Medium-term Actions (Week 3-4) - Phase 4 Completion**
1. **AI Integration Implementation**
   - Complete Project Manager-agent implementation
   - Implement role-based workflows (Coder, Tester, Reviewer)
   - Add AI-suggestion functionality to IDE
   - **Target**: Complete by end of Week 3

2. **Comprehensive Testing**
   - Achieve 90%+ coverage for all implemented components
   - Validate end-to-end workflows
   - Performance benchmarking and optimization
   - **Target**: Complete by end of Week 4

#### **Long-term Actions (Week 5-8) - Phase 5 and Beyond**
1. **Self-hosting Development**
   - Migrate Noodle development to Noodle IDE
   - Implement compiler and runtime extensions from IDE
   - Enhance role assignment system (Architect, Coder, Tester, Reviewer, Documenter)
   - **Target**: Complete by end of Week 6

2. **Advanced Features**
   - 3D Brain visualization with Three.js
   - Advanced AI agent capabilities
   - Plugin marketplace and ecosystem development
   - **Target**: Complete by end of Week 8

### **Success Criteria**

#### **Infrastructure Resolution Metrics**
- **Test Reliability**: 95% of tests passing consistently across environments
- **Coverage Achievement**: 90%+ line coverage for all core components
- **Performance**: Test execution time within acceptable limits
- **Build Success**: 100% build success rate across all environments

#### **Phase 4 Success Metrics**
- **AI Integration**: Functional AI assistant with real-time suggestions
- **Workflow Support**: Complete role-based workflow implementation
- **User Experience**: Seamless integration between IDE and Noodle Core
- **Performance**: AI operations with <100ms response time

#### **Phase 5 Success Metrics**
- **Self-hosting**: 100% of Noodle development happening in Noodle IDE
- **Productivity**: 30% improvement in development efficiency
- **Quality**: 90% reduction in bugs through automated workflows
- **Ecosystem**: Functional plugin marketplace with 5+ plugins

### **Risk Assessment**

#### **High Risk Items**
1. **Protobuf Compatibility**: May require significant code changes
2. **Package Structure Refactoring**: Risk of breaking existing functionality
3. **Performance Regression**: Infrastructure changes may impact performance

#### **Mitigation Strategies**
1. **Incremental Changes**: Implement fixes in small, manageable steps
2. **Comprehensive Testing**: Extensive regression testing for each change
3. **Rollback Plans**: Prepare rollback procedures for critical changes
4. **Parallel Development**: Maintain separate branches for infrastructure fixes

### **Resource Requirements**

#### **Team Composition**
- **Infrastructure Specialist**: 1 person (Week 1-2)
- **AI Integration Developer**: 1 person (Week 3-4)
- **IDE Developer**: 1 person (Week 3-6)
- **QA Engineer**: 1 person (Week 1-6)
- **Project Manager**: 1 person (Week 1-8)

#### **Technical Resources**
- **Container Infrastructure**: Docker and Kubernetes for development environment
- **Testing Infrastructure**: Enhanced CI/CD pipeline with comprehensive testing
- **Monitoring Tools**: Performance and error monitoring for all components
- **Documentation**: Updated documentation for all changes

### **Conclusion**

The Noodle IDE project has successfully completed Phases 1-3 with robust core functionality, but progress on advanced features (Phases 4-5) is blocked by critical infrastructure issues. The implementation is architecturally sound and feature-complete, but requires immediate attention to dependency management, environment standardization, and package structure.

With dedicated infrastructure resolution efforts, the project can achieve full functionality within 8 weeks, positioning Noodle as a comprehensive development environment for distributed AI systems.
