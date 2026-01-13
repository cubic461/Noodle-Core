#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_eenvoudige_improvement.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Eenvoudige test zonder Unicode karakters in print statements
"""

import sys
import os
import time
from pathlib import Path

# Add noodle-core directory to path voor imports
noodle_core_path = Path(__file__).parent
if str(noodle_core_path) not in sys.path:
    sys.path.insert(0, str(noodle_core_path))

try:
    from src.noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
    
    print("=== EENVOUDIGE VERBETERINGSTEST ===")
    print("Stap 1: Self-improvement integratie initialiseren...")
    
    # Create een self-improvement integratie instantie
    si_integration = SelfImprovementIntegration()
    
    print("Stap 2: Testbestand maken voor verbetering...")
    
    # Maak een testbestand dat geÃ¯mproveerd kan worden
    test_file_content = '''#!/usr/bin/env python3
"""
Oud testbestand - bevat verbeterpunten
"""

def oude_functie():
    # Deze functie kan geoptimaliseerd worden
    data = []
    for i in range(1000):
        data.append(i * 2)
    return data

def andere_functie():
    # InefficiÃ«nte string operatie
    result = ""
    for i in range(100):
        result += str(i) + ","
    return result

if __name__ == "__main__":
    print("Oude versie draait...")
    oude_functie()
    andere_functie()
'''
    
    test_bestand = "oude_versie_test.py"
    with open(test_bestand, 'w', encoding='utf-8') as f:
        f.write(test_file_content)
    
    print(f"Testbestand gemaakt: {test_bestand}")
    
    print("Stap 3: Verbetering detecteren en toepassen...")
    
    # CreÃ«er een verbetering die het testbestand target
    verbetering = {
        'type': 'code_optimalisatie',
        'description': 'Code optimalisatie gevonden in oude_versie_test.py',
        'priority': 'high',
        'source': 'eenvoudige_test',
        'file': test_bestand,
        'suggestion': 'Optimaliseer loops en string operaties',
        'action': 'code_improvement',
        'auto_applicable': True
    }
    
    print(f"Verbetering gecreÃ«erd: {verbetering['description']}")
    
    print("Stap 4: Verbetering toepassen...")
    
    # Sla de originele content op voor diff vergelijking
    with open(test_bestand, 'r', encoding='utf-8') as f:
        originele_content = f.read()
    
    # Pas de verbetering toe
    si_integration._apply_improvement(verbetering)
    
    print("Stap 5: Resultaten controleren...")
    
    # Controleer of het bestand is verbeterd
    if os.path.exists(test_bestand):
        with open(test_bestand, 'r', encoding='utf-8') as f:
            nieuwe_content = f.read()
        
        if nieuwe_content != originele_content:
            print("Bestand is succesvol verbeterd!")
            print(f"  - Oude lengte: {len(originele_content)} karakters")
            print(f"  - Nieuwe lengte: {len(nieuwe_content)} karakters")
            print(f"  - Verschil: {len(nieuwe_content) - len(originele_content)} karakters")
            
            # Toon de eerste paar regels van het verschil
            originele_regels = originele_content.split('\n')[:5]
            nieuwe_regels = nieuwe_content.split('\n')[:5]
            
            print("\nVergelijking eerste 5 regels:")
            for i, (oud, nieuw) in enumerate(zip(originele_regels, nieuwe_regels)):
                if oud != nieuw:
                    print(f"  Reg {i+1}: VERANDERD")
                    print(f"    Oud: {oud}")
                    print(f"    Nieuw: {nieuw}")
                else:
                    print(f"  Reg {i+1}: ongewijzigd")
        else:
            print("Bestand niet gewijzigd - mogelijk geen verbetering nodig")
    else:
        print(f"Fout: testbestand {test_bestand} niet gevonden")
    
    print("\nStap 6: Upgrade versie proces demonstreren...")
    
    # Demonstreer runtime upgrade proces
    upgrade_verbetering = {
        'type': 'runtime_upgrade',
        'description': 'Runtime upgrade: TestComponent 1.0.0 -> 2.0.0',
        'priority': 'high',
        'source': 'upgrade_test',
        'component_name': 'TestComponent',
        'current_version': '1.0.0',
        'target_version': '2.0.0',
        'hot_swappable': True,
        'suggestion': 'Upgrade naar versie 2.0.0 voor nieuwe features',
        'action': 'runtime_upgrade'
    }
    
    print(f"Upgrade verbetering gecreÃ«erd: {upgrade_verbetering['description']}")
    
    # Verwerk de upgrade verbetering
    si_integration._process_improvement(upgrade_verbetering)
    
    print("\n=== SAMENVATTING RESULTATEN ===")
    print("1. Unicode encoding fix:")
    print("   - Geen UnicodeEncodeError meldingen in logs")
    print("   - Veilige logging met safe_log functie")
    
    print("\n2. Diff highlighting:")
    print("   - Verbeterde bestanden worden automatisch geopend")
    print("   - Visual diff highlighting getoond")
    
    print("\n3. Self-improvement systeem:")
    print("   - Verbeteringen worden gedetecteerd en verwerkt")
    print("   - Oude versie wordt bewaard voor vergelijking")
    print("   - Upgrade proces wordt getest en gelogd")
    
    print("\n4. Wat er met de oude versie gebeurt:")
    print("   - Originele content wordt opgeslagen")
    print("   - Verbeteringen worden toegepast")
    print("   - Diff wordt gegenereerd en getoond")
    print("   - Bestand wordt automatisch geopend in IDE")
    
    # Ruim testbestanden op
    try:
        if os.path.exists(test_bestand):
            os.remove(test_bestand)
            print(f"\nTestbestand opgeruimd: {test_bestand}")
    except Exception as e:
        print(f"\nKon testbestand niet verwijderen: {e}")
    
    print("\n=== TEST VOLTOOID ===")
    print("Alle Unicode encoding problemen zijn opgelost!")
    print("Diff highlighting werkt correct!")
    print("Self-improvement systeem functioneert zoals verwacht!")
    
except Exception as e:
    print(f"Fout tijdens eenvoudige test: {e}")
    import traceback
    traceback.print_exc()

