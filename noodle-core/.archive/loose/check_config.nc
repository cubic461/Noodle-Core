# NoodleCore converted from Python
#!/usr/bin/env python3
# import json
# from pathlib # import Path

config_file = Path.home() / '.noodlecore' / 'ai_config.json'
println('Config file exists:', config_file.exists())
if config_file.exists():
    println('Content:', config_file.read_text())