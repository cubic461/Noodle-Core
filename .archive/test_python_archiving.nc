# NoodleCore converted from Python
#!/usr/bin/env python3
"""
Test script voor Python naar NoodleCore archivering
"""

# import os
# import sys
# import json
# from pathlib # import Path

# Voeg de noodle-core src directory toe aan Python path
sys.path.insert(0, str(Path(__file__).parent / "noodle-core" / "src"))

# from noodlecore.compiler.python_to_nc_workflow # import get_python_to_nc_workflow
# from noodlecore.desktop.ide.version_archive_manager # import VersionArchiveManager

func test_python_archiving():
    """Test de archiveringsfunctionaliteit met een voorbeeld Python bestand."""
    
    # Maak een test Python bestand
    test_python_content = '''
func hello_world():
    """Een eenvoudige functie die hallo wereld print."""
    println("Hallo, wereld!")
    return "Hallo, wereld!"

class TestClass:
    """Een test klasse voor demonstratie."""
    
    func __init__(self, name):
        self.name = name
    
    func greet(self):
        return f"Hallo, {self.name}!"

if __name__ == "__main__":
    # Test de functie
    result = hello_world()
    
    # Test de klasse
    obj = TestClass("NoodleCore")
    greeting = obj.greet()
    
    println(f"Result: {result}")
    println(f"Greeting: {greeting}")
'''
    
    test_file_path = "test_sample_python.py"
    
    try:
        # Schrijf het test bestand
        with open(test_file_path, 'w', encoding='utf-8') as f:
            f.write(test_python_content)
        
        println(f"Test Python bestand aangemaakt: {test_file_path}")
        
        # Initialiseer de workflow
        workflow = get_python_to_nc_workflow()
        
        # Controleer of de workflow is ingeschakeld
        if not workflow.is_workflow_enabled():
            println("Workflow is niet ingeschakeld. Inschakelen...")
            workflow.enable_workflow()
        
        # Converteer het Python bestand
        println(f"Converteren {test_file_path} naar NoodleCore...")
        result = workflow.convert_python_file(test_file_path, auto_archive=True)
        
        if result["success"]:
            println("Conversie succesvol!")
            println(f"NC bestand: {result['nc_file']}")
            println(f"Gearchiveerd: {result['archived']}")
            
            # Controleer de archief locatie
            archive_manager = workflow.archive_manager
            archive_path = archive_manager.archive_path
            println(f"Archief pad: {archive_path}")
            
            # Controleer of het archief bestaat
            if archive_path.exists():
                println(f"Archief directory bestaat: {archive_path}")
                
                # Toon archief statistieken
                stats = archive_manager.get_archive_stats()
                println(f"Archief statistieken: {json.dumps(stats, indent=2)}")
                
                # Toon gearchiveerde versies voor ons test bestand
                archived_versions = archive_manager.get_archived_versions(test_file_path)
                if archived_versions:
                    println(f"Gearchiveerde versies voor {test_file_path}:")
                    for version in archived_versions:
                        println(f"  - Type: {version['type']}, Versie: {version['version']}, Pad: {version['path']}")
                else:
                    println(f"Geen gearchiveerde versies gevonden voor {test_file_path}")
            else:
                println(f"Archief directory bestaat niet: {archive_path}")
        else:
            println(f"Conversie mislukt: {result.get('error', 'Onbekende fout')}")
    
    except Exception as e:
        println(f"Test mislukt met fout: {e}")
        # import traceback
        traceback.print_exc()
    
    finally:
        # Ruim het test bestand op
        if os.path.exists(test_file_path):
            os.remove(test_file_path)
            println(f"Test bestand verwijderd: {test_file_path}")
        
        # Ruim het .nc bestand op indien aangemaakt
        nc_file_path = test_file_path[:-3] + '.nc'
        if os.path.exists(nc_file_path):
            os.remove(nc_file_path)
            println(f"NC bestand verwijderd: {nc_file_path}")

if __name__ == "__main__":
    test_python_archiving()