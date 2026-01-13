# Sample NoodleCore configuration file
# Testing debug functionality

attribute git_integration
  description: Enable Git integration features
  version: 1.0
  category: integration
  enabled: true
  capabilities:
    - status
    - diff
    - commits

attribute real_time_linting
  description: Enable real-time code linting
  version: 1.0
  category: quality
  enabled: true
  ai_hint: "Provides instant code quality feedback"

provider ai_assistant
  provider: OpenAI
  model: gpt-3.5-turbo
  role: "Code assistant"
  system_prompt: "Help with NoodleCore development"

schema project_config
  description: Project configuration schema
  version: 1.0