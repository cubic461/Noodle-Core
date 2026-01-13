# NoodleCore Project Schema Definition
# Solution/workspace metadata in NoodleCore terms

schema noodlecore_project {
    id: "noodlecore_project"
    description: "NoodleCore-native project structure and metadata"
    version: "1.0"
    
    project_structure: {
        solution_file: "solution.noodle",
        build_config: "build.noodle", 
        dependency_file: "dependencies.noodle",
        deployment_config: "deploy.noodle",
        ide_config: "ide_config.noodle"
    }
    
    required_attributes: {
        minimal: ["ai_intellisense", "syntax_enhanced"],
        standard: ["ai_intellisense", "syntax_enhanced", "debug_breakpoints", "git_integration"],
        full: ["ai_intellisense", "syntax_enhanced", "debug_breakpoints", "variable_inspector", "git_integration", "solution_files", "real_time_linting", "testing_integration"]
    }
    
    workspace_metadata: {
        project_name: "string",
        project_type: "enum(console, web, desktop, library)",
        noodlecore_version: "string",
        created_at: "datetime",
        last_modified: "datetime",
        author: "string",
        description: "string"
    }
}

schema solution_template {
    id: "solution_template"
    description: "Template for NoodleCore solution files"
    version: "1.0"
    
    template_structure: {
        header: "project metadata and configuration",
        attributes: "enabled NoodleCore IDE attributes",
        modules: "project-specific NoodleCore modules",
        dependencies: "external dependencies and requirements"
    }
    
    default_attributes: {
        console_project: ["ai_intellisense", "syntax_enhanced", "real_time_linting"],
        web_project: ["ai_intellisense", "syntax_enhanced", "git_integration", "testing_integration"],
        desktop_project: ["ai_intellisense", "syntax_enhanced", "debug_breakpoints", "variable_inspector"],
        library_project: ["ai_intellisense", "syntax_enhanced", "real_time_linting", "testing_integration"]
    }
}

schema build_configuration {
    id: "build_configuration"
    description: "NoodleCore build system configuration"
    version: "1.0"
    
    build_types: {
        development: "incremental with debugging",
        testing: "optimized with test coverage",
        production: "fully optimized with minification"
    }
    
    build_steps: {
        validation: "validate NoodleCore syntax",
        compilation: "compile .nc to target format",
        testing: "run automated tests",
        packaging: "create distributable package"
    }
    
    ai_enhancement: {
        error_prediction: true,
        optimization_suggestions: true,
        performance_analysis: true
    }
}