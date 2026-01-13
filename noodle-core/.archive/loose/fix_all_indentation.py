#!/usr/bin/env python3
"""
Noodle Core::Fix All Indentation - fix_all_indentation.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Script to fix all indentation issues in native_gui_ide.py
"""

def fix_all_indentation():
    file_path = "src/noodlecore/desktop/ide/native_gui_ide.py"
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix all indentation issues
    fixed_lines = []
    for i, line in enumerate(lines):
        line_num = i + 1
        line_str = line.rstrip()
        
        # Fix indentation issues based on line numbers
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
        elif line_num == 3197:  # status_label.config(text=f"Found {len(models)} models - Selected: {models[0]}")
            fixed_lines.append("                        status_label.config(text=f\"Found {len(models)} models - Selected: {models[0]}\")\n")
        elif line_num == 3198:  # print line
            fixed_lines.append("                        print(f\"[âœ… AI SETTINGS] Successfully fetched {len(models)} models for {provider_name}\")\n")
        elif line_num == 3199:  # else:
            fixed_lines.append("                    else:\n")
        elif line_num == 3200:  # status_label.config(text="No models found for this provider")
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
        elif line_num == 3702:  # except Exception as e:
            fixed_lines.append("        except Exception as e:\n")
        elif line_num == 3703:  # safe_print line
            fixed_lines.append("            safe_print(f\"Error during IDE exit: {e}\")\n")
        elif line_num == 3704:  # self.root.quit()
            fixed_lines.append("            self.root.quit()\n")
        elif line_num == 3705:  # self.root.destroy()
            fixed_lines.append("            self.root.destroy()\n")
        elif line_num == 3712:  # return 0  # Success exit code
            fixed_lines.append("        return 0  # Success exit code\n")
        elif line_num == 3713:  # except KeyboardInterrupt:
            fixed_lines.append("        except KeyboardInterrupt:\n")
        elif line_num == 3714:  # safe_print line
            fixed_lines.append("            safe_print(\"IDE interrupted by user\")\n")
        elif line_num == 3715:  # return 1
            fixed_lines.append("            return 1\n")
        elif line_num == 3742:  # except Exception as e:
            fixed_lines.append("                                except Exception as e:\n")
        elif line_num == 3743:  # safe_print line
            fixed_lines.append("                                    safe_print(f\"Failed to index {rel_path}: {e}\")\n")
        elif line_num == 3744:  # else:
            fixed_lines.append("                                else:\n")
        elif line_num == 3745:  # Update index for specific file operation
            fixed_lines.append("                # Update index for specific file operation\n")
        elif line_num == 3746:  # if ai_command['type'] in ['read', 'write', 'modify']:
            fixed_lines.append("                if ai_command['type'] in ['read', 'write', 'modify']:\n")
        elif line_num == 3747:  # file_path = ai_command['file']
            fixed_lines.append("                    file_path = ai_command['file']\n")
        elif line_num == 3748:  # if not os.path.isabs(file_path):
            fixed_lines.append("                    if not os.path.isabs(file_path):\n")
        elif line_num == 3749:  # file_path = os.path.join(self.current_project_path, file_path)
            fixed_lines.append("                        file_path = os.path.join(self.current_project_path, file_path)\n")
        elif line_num == 3750:  # rel_path = os.path.relpath(file_path, self.current_project_path)
            fixed_lines.append("                    rel_path = os.path.relpath(file_path, self.current_project_path)\n")
        elif line_num == 3751:  # if ai_command['type'] == 'write' or ai_command['type'] == 'modify':
            fixed_lines.append("                    if ai_command['type'] == 'write' or ai_command['type'] == 'modify':\n")
        elif line_num == 3752:  # Add/update file in index
            fixed_lines.append("                        # Add/update file in index\n")
        elif line_num == 3753:  # self.project_index[rel_path] = ai_command.get('content', '')
            fixed_lines.append("                        self.project_index[rel_path] = ai_command.get('content', '')\n")
        elif line_num == 3754:  # elif ai_command['type'] == 'read' and os.path.exists(file_path):
            fixed_lines.append("                    elif ai_command['type'] == 'read' and os.path.exists(file_path):\n")
        elif line_num == 3755:  # Read and add file to index
            fixed_lines.append("                        # Read and add file to index\n")
        elif line_num == 3756:  # try:
            fixed_lines.append("                        try:\n")
        elif line_num == 3757:  # with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            fixed_lines.append("                            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:\n")
        elif line_num == 3758:  # content = f.read()
            fixed_lines.append("                                content = f.read()\n")
        elif line_num == 3759:  # except Exception as e:
            fixed_lines.append("                                except Exception as e:\n")
        elif line_num == 3760:  # safe_print line
            fixed_lines.append("                                    safe_print(f\"Failed to index {rel_path}: {e}\")\n")
        elif line_num == 3761:  # else:
            fixed_lines.append("                            else:\n")
        else:
            fixed_lines.append(line_str)
    
    # Write the fixed content back to the file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(fixed_lines)
    
    print("Fixed all indentation issues in native_gui_ide.py")

if __name__ == "__main__":
    fix_all_indentation()

