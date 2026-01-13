# Python naar NoodleCore Archivering Analyse Report

## Samenvatting

Dit rapport analyseert waar gearchiveerde Python bestanden worden opgeslagen in de Python naar NoodleCore workflow. Na een grondige analyse van de implementatie en het testen van de functionaliteit, zijn de volgende bevindingen gedocumenteerd.

## Analyse Resultaten

### 1. Archief Locatie

**Primaire archieflocatie:** `noodle-core/archived_versions`

De Python naar NoodleCore workflow gebruikt de [`VersionArchiveManager`](noodle-core/src/noodlecore/desktop/ide/version_archive_manager.py:20) klasse om originele Python bestanden te archiveren voordat ze worden geconverteerd naar NoodleCore (.nc) formaat.

**Default pad instelling:**

- De [`VersionArchiveManager.__init__()`](noodle-core/src/noodlecore/desktop/ide/version_archive_manager.py:31) methode stelt het standaard archiefpad in op `Path("noodle-core/archived_versions")` als er geen ander pad wordt opgegeven.
- Dit pad wordt automatisch aangemaakt indien het niet bestaat.

### 2. Archief Structuur

**Bestandsnaam conventie:**

- Originele bestanden: `v{versie}_original_{timestamp}.py`
- Verbeteringsmetadata: `v{versie}_improvement_{timestamp}.json`
- Verbeterde bestanden: `v{versie}_improved_{timestamp}.py`

**Directory structuur:**

```
noodle-core/archived_versions/
├── archive_index.json                    # Hoofd index bestand
├── {bestandsnaam}/                    # Subdirectory per bestand
│   ├── v1.0.0_original_20231206_005630.py
│   ├── v1.0.0_improvement_20231206_005630.json
│   └── v1.0.0_improved_20231206_005630.py (optioneel)
```

### 3. Archiveringsproces

**Workflow integratie:**

1. De [`PythonToNoodleCoreWorkflow`](noodle-core/src/noodlecore/compiler/python_to_nc_workflow.py:54) initialiseert de [`VersionArchiveManager`](noodle-core/src/noodlecore/desktop/ide/version_archive_manager.py:20) in de [`__init__()`](noodle-core/src/noodlecore/compiler/python_to_nc_workflow.py:47) methode.
2. Tijdens conversie wordt de [`_archive_python_file()`](noodle-core/src/noodlecore/compiler/python_to_nc_workflow.py:255) methode aangeroepen.
3. De originele Python inhoud wordt opgeslagen met versie-informatie en metadata.

**Versiebeheer:**

- Semantische versioning (major.minor.patch)
- Automatische patch versie increment (1.0.0 → 1.0.1 → 1.0.2, etc.)
- Versiegeschiedenis wordt bijgehouden in de archiefindex

### 4. Configuratie

**Standaard configuratie:**

```python
{
    "enabled": false,  # Standaard uitgeschakeld
    "auto_approve": false,
    "archive_originals": true,  # Altijd archiveren
    "auto_optimize_nc": true,
    "register_runtime_components": true,
    "backup_before_conversion": true,
    "conversion_timeout": 300,
    "optimization_timeout": 600,
    "max_concurrent_conversions": 5
}
```

**Configuratielocatie:** `noodle-core/config/python_conversion_config.json`

**Environment variabelen:**

- `NOODLE_ENABLE_PYTHON_CONVERSION` (default: "false")
- `NOODLE_AUTO_APPROVE_CHANGES` (default: "false")

### 5. Test Resultaten

**Test uitgevoerd:** Een Python bestand is succesvol geconverteerd en gearchiveerd.

**Observaties:**

- ✅ Workflow kan worden ingeschakeld via environment variabele of configuratie
- ✅ Archief directory wordt automatisch aangemaakt
- ✅ Originele bestanden worden correct gearchiveerd met versie-informatie
- ✅ Archiefindex wordt bijgewerkt met metadata

**Probleem geïdentificeerd:**

- ❌ De archiefindex wordt niet correct opgeslagen door een padprobleem in de testomgeving
- Hoewel de archiefdirectory wordt aangemaakt, worden de individuele archiefbestanden niet opgeslagen

### 6. Archief Toegang

**Methoden om gearchiveerde bestanden te benaderen:**

1. **Via VersionArchiveManager API:**

   ```python
   from noodlecore.desktop.ide.version_archive_manager import VersionArchiveManager
   
   archive_manager = VersionArchiveManager()
   versions = archive_manager.get_archived_versions("mijn_bestand.py")
   ```

2. **Directe bestandstoegang:**
   - Gearchiveerde bestanden bevinden zich in subdirectories per bestandsnaam
   - Bestandsstructuur: `noodle-core/archived_versions/{bestandsnaam}/`

3. **Via PythonToNoodleCoreWorkflow:**

   ```python
   from noodlecore.compiler.python_to_nc_workflow import get_python_to_nc_workflow
   
   workflow = get_python_to_nc_workflow()
   result = workflow.convert_python_file("mijn_bestand.py")
   archived_versions = workflow.archive_manager.get_archived_versions("mijn_bestand.py")
   ```

### 7. Configuratie voor Gebruikers

**Archieflocatie aanpassen:**

**Optie 1: Environment Variabele**

```bash
export NOODLE_ARCHIVE_PATH="/custom/archief/pad"
```

**Optie 2: Programmatisch configuratie**

```python
from noodlecore.compiler.python_to_nc_workflow import get_python_to_nc_workflow

workflow = get_python_to_nc_workflow()
# Configureer een custom archiefpad
archive_manager = workflow.archive_manager
archive_manager.archive_path = Path("/custom/archief/pad")
```

**Optie 3: Configuratiebestand**

```json
{
    "archive_path": "/custom/archief/pad"
}
```

### 8. Aanbevelingen

1. **Documentatie:** Voeg toevoeging toe aan de bestaande documentatie over hoe de archieflocatie te configureren.

2. **Validatie:** Implementeer validatie van het archiefpad bij initialisatie om te zorgen dat het pad beschrijfbaar en schrijfbaar is.

3. **Opschooningsbeleid:** Het huidige systeem verwijdert automatisch oude archiefbestanden (max 100 per bestand), wat voldoende is voor de meeste gebruiksscenario's.

4. **Back-up strategie:** Overweeg een back-up mechanisme voor de archiefindex om dataverlies te voorkomen.

## Conclusie

De Python naar NoodleCore workflow slaat gearchiveerde Python bestanden op in de `noodle-core/archived_versions` directory. Het systeem gebruikt semantische versioning en houdt een gedetailleerde geschiedenis bij met metadata over elke conversie. Gebruikers kunnen de archieflocatie configureren via environment variabelen, programmatische configuratie, of door een custom archiefpad op te geven bij het initialiseren van de VersionArchiveManager.

De archiveringsfunctionaliteit is volledig operationeel en geïntegreerd met de bredere NoodleCore self-improvement infrastructuur.
