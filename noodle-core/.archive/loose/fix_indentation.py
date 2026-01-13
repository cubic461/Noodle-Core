#!/usr/bin/env python3
"""
Noodle Core::Fix Indentation - fix_indentation.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Script to fix indentation issue in native_gui_ide.py
"""

def fix_indentation():
    file_path = "src/noodlecore/desktop/ide/native_gui_ide.py"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix the indentation issue in fetch_models function
    fixed_lines = []
    for i, line in enumerate(lines):
        line_num = i + 1
        if 3185 <= line_num <= 3209:
            # Fix indentation for fetch_models function
            if line_num == 3185:  # def fetch_models():
                fixed_lines.append("            def fetch_models():\n")
            elif line_num == 3186:  # safe_print line
                fixed_lines.append("                safe_print(f\"[ðŸ” AI SETTINGS] Starting model fetch for {provider_name}...\")\n")
            elif line_num == 3187:  # loop = asyncio.new_event_loop()
                fixed_lines.append("                loop = asyncio.new_event_loop()\n")
            elif line_num == 3188:  # asyncio.set_event_loop(loop)
                fixed_lines.append("                asyncio.set_event_loop(loop)\n")
            elif line_num == 3189:  # try:
                fixed_lines.append("                try:\n")
            elif line_num == 3190:  # print line
                fixed_lines.append("                    print(f\"[ðŸ” AI SETTINGS] Calling fetch_models_for_provider({provider_name})...\")\n")
            elif line_num == 3191:  # models = loop.run_until_complete...
                fixed_lines.append("                    models = loop.run_until_complete(self.fetch_models_for_provider(provider_name))\n")
            elif line_num == 3192:  # print(f"[âœ… AI SETTINGS] Models fetched: {models}")
                fixed_lines.append("                    print(f\"[âœ… AI SETTINGS] Models fetched: {models}\")\n")
            elif line_num == 3193:  # empty line
                fixed_lines.append("        \n")
            elif line_num == 3194:  # model_combo['values'] = models
                fixed_lines.append("                    model_combo['values'] = models\n")
            elif line_num == 3195:  # if models and len(models) > 0:
                fixed_lines.append("                    if models and len(models) > 0:\n")
            elif line_num == 3196:  # model_combo.set(models[0])
                fixed_lines.append("                        model_combo.set(models[0])  # Auto-select first model\n")
            elif line_num == 3197:  # status_label.config
                fixed_lines.append("                        status_label.config(text=f\"Found {len(models)} models - Selected: {models[0]}\")\n")
            elif line_num == 3198:  # print line
                fixed_lines.append("                        print(f\"[âœ… AI SETTINGS] Successfully fetched {len(models)} models for {provider_name}\")\n")
            elif line_num == 3199:  # else:
                fixed_lines.append("                    else:\n")
            elif line_num == 3200:  # status_label.config(text="No models found...")
                fixed_lines.append("                        status_label.config(text=\"No models found for this provider\")\n")
            elif line_num == 3201:  # print line
                fixed_lines.append("                        print(f\"[âš ï¸  AI SETTINGS] No models found for {provider_name}\")\n")
            elif line_num == 3202:  # except Exception as e:
                fixed_lines.append("                except Exception as e:\n")
            elif line_num == 3203:  # status_label.config(text=f"Error: {str(e)}")
                fixed_lines.append("                    status_label.config(text=f\"Error: {str(e)}\")\n")
            elif line_num == 3204:  # print line
                fixed_lines.append("                    print(f\"[âŒ AI SETTINGS] Failed to fetch models for {provider_name}: {e}\")\n")
            elif line_num == 3205:  # import traceback
                fixed_lines.append("                    import traceback\n")
            elif line_num == 3206:  # print line
                fixed_lines.append("                    print(f\"[âŒ AI SETTINGS] Full traceback: {traceback.format_exc()}\")\n")
            elif line_num == 3207:  # finally:
                fixed_lines.append("                finally:\n")
            elif line_num == 3208:  # loop.close()
                fixed_lines.append("                    loop.close()\n")
            elif line_num == 3209:  # print line
                fixed_lines.append("                    print(f\"[âœ… AI SETTINGS] Model fetch completed for {provider_name}\")\n")
            else:
                fixed_lines.append(line)
        else:
            fixed_lines.append(line)
    
    # Write the fixed content back to the file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(fixed_lines)
    
    print("Fixed indentation issue in native_gui_ide.py")

if __name__ == "__main__":
    fix_indentation()

