# NoodleCore IDE Scenarios Specification
# Workflow sequences that compose multiple commands
# All workflows MUST be defined as deterministic sequences of existing commands

sequence workflow_analyze_current_file {
    id: "workflow.analyze_current_file"
    commands: [
        "quality.lint_current_file",
        "intellisense.suggest"
    ]
}

sequence workflow_project_health_check {
    id: "workflow.project_health_check"
    commands: [
        "git.status",
        "git.recent_commits",
        "git.diff_summary",
        "quality.discover_tests"
    ]
}