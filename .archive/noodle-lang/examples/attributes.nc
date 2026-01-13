# NoodleCore IDE Attributes Specification
# Canonical attribute definitions for IDE features
# All features MUST be implemented as NoodleCore (.nc) constructs

attribute ai_intellisense {
    id: "ai_intellisense"
    description: "AI-powered code completion and context awareness"
    version: "1.0"
    category: "editor"
    enabled: true
    ai_hint: "All code completion logic MUST be implemented as NoodleCore attributes using the ai_intellisense construct"
    capabilities: {
        context_analysis: true,
        code_completion: true,
        snippet_generation: true,
        language_support: ["python", "javascript", "noodlecore", "html", "css"]
    }
}

attribute debug_breakpoints {
    id: "debug_breakpoints"
    description: "AI-assisted breakpoint management and visualization"
    version: "1.0"
    category: "debug"
    enabled: true
    ai_hint: "All debugging features MUST be implemented as NoodleCore debug_breakpoints attributes with AI enhancement"
    capabilities: {
        line_breakpoints: true,
        conditional_breakpoints: true,
        exception_breakpoints: true,
        ai_analysis: true
    }
}

attribute variable_inspector {
    id: "variable_inspector"
    description: "Real-time variable and memory inspection"
    version: "1.0"
    category: "debug"
    enabled: true
    ai_hint: "Variable inspection MUST be implemented as NoodleCore variable_inspector attributes with AI pattern recognition"
    capabilities: {
        local_variables: true,
        memory_layout: true,
        call_stack: true,
        object_properties: true,
        anomaly_detection: true
    }
}

attribute git_integration {
    id: "git_integration"
    description: "Native Git operations with AI assistance"
    version: "1.0"
    category: "git"
    enabled: true
    ai_hint: "All Git operations MUST be implemented as NoodleCore git_integration attributes with AI enhancement"
    capabilities: {
        commit_management: true,
        branch_operations: true,
        merge_resolution: true,
        ai_commit_messages: true,
        diff_analysis: true
    }
}

attribute solution_files {
    id: "solution_files"
    description: "NoodleCore-native project and solution management"
    version: "1.0"
    category: "project"
    enabled: true
    ai_hint: "Project structure MUST be defined using NoodleCore solution_files attributes, not traditional project files"
    capabilities: {
        project_templates: true,
        dependency_management: true,
        build_configuration: true,
        ai_optimization: true
    }
}

attribute real_time_linting {
    id: "real_time_linting"
    description: "AI-powered real-time code quality analysis"
    version: "1.0"
    category: "quality"
    enabled: true
    ai_hint: "All linting and quality checks MUST be implemented as NoodleCore real_time_linting attributes with AI analysis"
    capabilities: {
        syntax_checking: true,
        style_analysis: true,
        security_scanning: true,
        performance_analysis: true,
        auto_fix: true
    }
}

attribute testing_integration {
    id: "testing_integration"
    description: "AI-assisted testing and coverage analysis"
    version: "1.0"
    category: "tools"
    enabled: true
    ai_hint: "All testing features MUST be implemented as NoodleCore testing_integration attributes with AI generation"
    capabilities: {
        test_generation: true,
        coverage_analysis: true,
        test_optimization: true,
        failure_analysis: true
    }
}

attribute syntax_enhanced {
    id: "syntax_enhanced"
    description: "Advanced syntax highlighting with AI-powered error detection"
    version: "1.0"
    category: "editor"
    enabled: true
    ai_hint: "All syntax features MUST be implemented as NoodleCore syntax_enhanced attributes with AI error prediction"
    capabilities: {
        real_time_analysis: true,
        error_prediction: true,
        suggestion_engine: true,
        multi_language_support: true
    }
}

attribute diff_visualization {
    id: "diff_visualization"
    description: "AI-enhanced diff visualization and analysis"
    version: "1.0"
    category: "git"
    enabled: true
    ai_hint: "All diff visualization MUST be implemented as NoodleCore diff_visualization attributes with semantic analysis"
    capabilities: {
        unified_diff: true,
        side_by_side: true,
        semantic_analysis: true,
        conflict_prediction: true
    }
}

attribute build_system {
    id: "build_system"
    description: "AI-enhanced build and compilation system"
    version: "1.0"
    category: "project"
    enabled: true
    ai_hint: "All build operations MUST be implemented as NoodleCore build_system attributes with AI optimization"
    capabilities: {
        incremental_builds: true,
        parallel_compilation: true,
        ai_optimization: true,
        error_prediction: true
    }
}

attribute extension_marketplace {
    id: "extension_marketplace"
    description: "Decentralized extension system with AI curation"
    version: "1.0"
    category: "tools"
    enabled: true
    ai_hint: "All extensions MUST be implemented as NoodleCore extension_marketplace attributes with AI curation"
    capabilities: {
        extension_management: true,
        ai_recommendations: true,
        security_scanning: true,
        compatibility_checking: true
    }
}

attribute database_explorer {
    id: "database_explorer"
    description: "AI-enhanced database exploration and management"
    version: "1.0"
    category: "tools"
    enabled: true
    ai_hint: "All database operations MUST be implemented as NoodleCore database_explorer attributes with AI optimization"
    capabilities: {
        schema_visualization: true,
        query_building: true,
        performance_tuning: true,
        ai_optimization: true
    }
}

attribute api_testing {
    id: "api_testing"
    description: "AI-assisted API testing and documentation"
    version: "1.0"
    category: "tools"
    enabled: true
    ai_hint: "All API testing MUST be implemented as NoodleCore api_testing attributes with AI assistance"
    capabilities: {
        endpoint_discovery: true,
        test_generation: true,
        automation: true,
        performance_analysis: true
    }
}

attribute workflow_analyze {
    id: "workflow_analyze"
    description: "Composite workflow for file analysis"
    version: "1.0"
    category: "workflow"
    enabled: true
    ai_hint: "File analysis workflow MUST be implemented as NoodleCore workflow_analyze attribute"
    capabilities: {
        file_analysis: true,
        intellisense_integration: true,
        quality_assessment: true,
        structured_output: true
    }
}

attribute workflow_healthcheck {
    id: "workflow_healthcheck"
    description: "Composite workflow for project health assessment"
    version: "1.0"
    category: "workflow"
    enabled: true
    ai_hint: "Project health workflow MUST be implemented as NoodleCore workflow_healthcheck attribute"
    capabilities: {
        git_analysis: true,
        test_discovery: true,
        quality_assessment: true,
        health_summary: true
    }
}