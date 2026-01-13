# NoodleCore IDE Commands Specification
# Executable command definitions for IDE features
# All IDE operations MUST be defined as NoodleCore (.nc) commands

command intellisense_suggest {
    id: "intellisense.suggest"
    feature: "ai_intellisense"
    trigger: "on_key"
    handler: "intellisense_suggest_handler"
    inputs: {
        file_path: "string",
        language: "string", 
        cursor_position: "number",
        prefix: "string",
        context_lines: "number"
    }
    outputs: {
        suggestions: "array",
        completion_type: "string",
        confidence: "number"
    }
}

command debug_suggest_breakpoints {
    id: "debug.suggest_breakpoints"
    feature: "debug_breakpoints"
    trigger: "menu:DebugSuggestBreakpoints"
    handler: "debug_suggest_breakpoints_handler"
    inputs: {
        file_path: "string",
        function_name: "string",
        analysis_scope: "string"
    }
    outputs: {
        breakpoints: "array",
        reasoning: "string",
        priority: "number"
    }
}

command git_status {
    id: "git.status"
    feature: "git_integration"
    trigger: "menu:GitStatus"
    handler: "git_status_handler"
    inputs: {
        project_path: "string",
        include_untracked: "boolean"
    }
    outputs: {
        branch: "string",
        status: "object",
        changes: "array"
    }
}

command git_recent_commits {
    id: "git.recent_commits"
    feature: "git_integration"
    trigger: "menu:GitRecentCommits"
    handler: "git_recent_commits_handler"
    inputs: {
        project_path: "string",
        limit: "number"
    }
    outputs: {
        commits: "array",
        total_count: "number"
    }
}

command git_diff_summary {
    id: "git.diff_summary"
    feature: "git_integration"
    trigger: "menu:GitDiffSummary"
    handler: "git_diff_summary_handler"
    inputs: {
        project_path: "string",
        file_path: "string",
        commit_range: "string"
    }
    outputs: {
        summary: "string",
        changes: "object",
        affected_files: "array"
    }
}

command quality_lint_current_file {
    id: "quality.lint_current_file"
    feature: "real_time_linting"
    trigger: "menu:LintCurrentFile"
    handler: "quality_lint_current_file_handler"
    inputs: {
        file_path: "string",
        language: "string",
        severity_level: "string"
    }
    outputs: {
        issues: "array",
        score: "number",
        suggestions: "array"
    }
}

command quality_discover_tests {
    id: "quality.discover_tests"
    feature: "testing_integration"
    trigger: "menu:DiscoverTests"
    handler: "quality_discover_tests_handler"
    inputs: {
        project_path: "string",
        test_pattern: "string",
        recursive: "boolean"
    }
    outputs: {
        test_files: "array",
        test_count: "number",
        coverage_estimate: "number"
    }
}

command workflow_analyze_current_file {
    id: "workflow.analyze_current_file"
    feature: "workflow_analyze"
    trigger: "menu:NoodlecoreAnalyzeCurrentFile"
    handler: "workflow_analyze_current_file_handler"
    inputs: {
        file_path: "string",
        language: "string",
        content: "string"
    }
    outputs: {
        summary: "object",
        intellisense_hints: "array",
        lint_findings: "array"
    }
}

command workflow_project_health_check {
    id: "workflow.project_health_check"
    feature: "workflow_healthcheck"
    trigger: "menu:NoodlecoreProjectHealthCheck"
    handler: "workflow_project_health_check_handler"
    inputs: {
        project_root: "string"
    }
    outputs: {
        summary: "object",
        git_status: "object",
        test_status: "object",
        quality_status: "object"
    }
}

# AI Commands
command ai_explain_current_file {
    id: "ai.explain_current_file"
    feature: "ai_intellisense"
    type: "ai"
    trigger: "menu:AIExplainCurrentFile"
    handler: "ai_explain_current_file_handler"
    inputs: {
        file_path: "string",
        language: "string",
        content: "string",
        selection: "string"
    }
    outputs: {
        explanation: "string",
        suggestions: "array"
    }
}

command ai_code_review {
    id: "ai.code_review"
    feature: "real_time_linting"
    type: "ai"
    trigger: "menu:AICodeReview"
    handler: "ai_code_review_handler"
    inputs: {
        file_path: "string",
        language: "string",
        content: "string"
    }
    outputs: {
        review: "string",
        issues: "array",
        suggestions: "array"
    }
}

command ai_generate_test {
    id: "ai.generate_test"
    feature: "testing_integration"
    type: "ai"
    trigger: "menu:AIGenerateTest"
    handler: "ai_generate_test_handler"
    inputs: {
        file_path: "string",
        language: "string",
        content: "string",
        test_framework: "string"
    }
    outputs: {
        test_code: "string",
        explanation: "string"
    }
}

command ai_optimize_code {
    id: "ai.optimize_code"
    feature: "ai_intellisense"
    type: "ai"
    trigger: "menu:AIOptimizeCode"
    handler: "ai_optimize_code_handler"
    inputs: {
        file_path: "string",
        language: "string",
        content: "string",
        optimization_type: "string"
    }
    outputs: {
        optimized_code: "string",
        explanation: "string"
    }
}