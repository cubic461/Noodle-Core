#!/usr/bin/env python3
"""
Noodle Core::Setup Self Improvement Env - setup_self_improvement_env.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Setup script for NoodleCore Self-Improvement System Environment Variables

This script configures the required environment variables for the self-improvement system
to function properly. These variables control activation of various components.
"""

import os
import sys
import json
from pathlib import Path

# Environment variables configuration
ENVIRONMENT_CONFIG = {
    # Core self-improvement settings
    "NOODLE_SELF_IMPROVEMENT_ENABLED": "1",
    "NOODLE_DEBUG": "1",  # Enable debug logging for troubleshooting
    
    # Component activation settings
    "NOODLE_PERFORMANCE_MONITORING": "1",
    "NOODLE_FEEDBACK_ENABLED": "1",
    "NOODLE_ADAPTIVE_OPTIMIZATION": "1",
    "NOODLE_RUNTIME_UPGRADE_ENABLED": "1",
    "NOODLE_AI_DECISION_ENGINE": "1",
    
    # Adaptive optimizer settings
    "NOODLE_CRITICAL_COMPONENTS": "compiler,optimizer,runtime,ai_agents,deployment",
    "NOODLE_HYBRID_MODE_ENABLED": "1",
    "NOODLE_ROLLOUT_PERCENTAGE": "10.0",
    
    # Feedback collector settings
    "NOODLE_FEEDBACK_STORAGE": "feedback_data.json",
    "NOODLE_FEEDBACK_RETENTION": "10000",
    "NOODLE_AUTO_LEARNING": "1",
    
    # Runtime upgrade settings
    "NOODLE_UPGRADE_AUTO_APPROVE": "0",  # Require manual approval for safety
    "NOODLE_UPGRADE_BACKUP_ENABLED": "1",
    "NOODLE_UPGRADE_ROLLBACK_ENABLED": "1",
    
    # AI decision engine settings
    "NOODLE_AI_MODEL_PATH": "models/ai_decision_engine.pkl",
    "NOODLE_AI_TRAINING_ENABLED": "1",
    "NOODLE_AI_PREDICTION_CONFIDENCE_THRESHOLD": "0.7",
    
    # Performance monitoring settings
    "NOODLE_PERFORMANCE_INTERVAL": "60",  # seconds
    "NOODLE_PERFORMANCE_RETENTION": "10080",  # 7 days in minutes
    "NOODLE_PERFORMANCE_ALERT_THRESHOLD": "5.0",  # seconds
    
    # General settings
    "NOODLE_ENV": "development",
    "NOODLE_LOG_LEVEL": "DEBUG",
    "NOODLE_DATA_DIR": str(Path.home() / ".noodlecore" / "data"),
}

def setup_environment_variables():
    """Set up environment variables for self-improvement system."""
    print("Setting up NoodleCore Self-Improvement environment variables...")
    
    # Create data directory if it doesn't exist
    data_dir = Path(ENVIRONMENT_CONFIG["NOODLE_DATA_DIR"])
    data_dir.mkdir(parents=True, exist_ok=True)
    
    # Set environment variables
    for key, value in ENVIRONMENT_CONFIG.items():
        os.environ[key] = value
        print(f"  {key}={value}")
    
    print(f"\nData directory: {data_dir}")
    
    # Save configuration to file for persistence
    env_file = data_dir / "self_improvement_env.json"
    try:
        with open(env_file, 'w') as f:
            json.dump(ENVIRONMENT_CONFIG, f, indent=2)
        print(f"Environment configuration saved to: {env_file}")
    except Exception as e:
        print(f"Warning: Could not save environment configuration: {e}")
    
    # Create .env file for shell sessions
    env_file_path = Path.cwd() / ".noodle_self_improvement.env"
    try:
        with open(env_file_path, 'w') as f:
            for key, value in ENVIRONMENT_CONFIG.items():
                f.write(f"export {key}={value}\n")
        print(f"Shell environment file created: {env_file_path}")
        print(f"\nTo load in shell: source {env_file_path}")
    except Exception as e:
        print(f"Warning: Could not create shell environment file: {e}")
    
    print("\nSelf-improvement environment setup complete!")
    print("\nKey settings:")
    print(f"  - Self-improvement enabled: {ENVIRONMENT_CONFIG['NOODLE_SELF_IMPROVEMENT_ENABLED']}")
    print(f"  - Performance monitoring: {ENVIRONMENT_CONFIG['NOODLE_PERFORMANCE_MONITORING']}")
    print(f"  - Feedback collection: {ENVIRONMENT_CONFIG['NOODLE_FEEDBACK_ENABLED']}")
    print(f"  - Adaptive optimization: {ENVIRONMENT_CONFIG['NOODLE_ADAPTIVE_OPTIMIZATION']}")
    print(f"  - Runtime upgrade: {ENVIRONMENT_CONFIG['NOODLE_RUNTIME_UPGRADE_ENABLED']}")
    print(f"  - AI decision engine: {ENVIRONMENT_CONFIG['NOODLE_AI_DECISION_ENGINE']}")
    print(f"  - Debug mode: {ENVIRONMENT_CONFIG['NOODLE_DEBUG']}")
    
    return True

def verify_environment():
    """Verify that environment variables are set correctly."""
    print("\nVerifying environment variables...")
    
    required_vars = [
        "NOODLE_SELF_IMPROVEMENT_ENABLED",
        "NOODLE_PERFORMANCE_MONITORING",
        "NOODLE_FEEDBACK_ENABLED",
        "NOODLE_ADAPTIVE_OPTIMIZATION",
        "NOODLE_RUNTIME_UPGRADE_ENABLED",
        "NOODLE_AI_DECISION_ENGINE"
    ]
    
    all_set = True
    for var in required_vars:
        value = os.environ.get(var)
        if value is None:
            print(f"  [ERROR] {var} is not set")
            all_set = False
        else:
            print(f"  [OK] {var}={value}")
    
    return all_set

def main():
    """Main function."""
    if len(sys.argv) > 1 and sys.argv[1] == "--verify":
        success = verify_environment()
        sys.exit(0 if success else 1)
    else:
        success = setup_environment_variables()
        if success:
            print("\n[SUCCESS] Environment setup completed successfully!")
            print("\nNext steps:")
            print("1. Restart your NoodleCore application")
            print("2. Run the diagnostic script: python diagnose_self_improvement.py")
            print("3. Check that all components are activated")
        else:
            print("\n[ERROR] Environment setup failed!")
            sys.exit(1)

if __name__ == "__main__":
    main()

