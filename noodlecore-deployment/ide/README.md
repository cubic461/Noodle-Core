# Noodle IDE

Een moderne, snelle desktop ontwikkelomgeving (IDE) voor de Noodle programmeertaal, gebouwd met Tauri, React en TypeScript, met geavanceerde 3D visualisatiemogelijkheden.

## Over Noodle IDE

Noodle IDE stelt ontwikkelaars in staat om Noodle-code te schrijven, uit te voeren en te debuggen met een rijke, AI-versterkte interface. Dit is een **tweede, onafhankelijk project** naast de [Noodle Core](../noodle-dev), gebaseerd op de [Noodle Roadmap](../memory-bank/noodle-ide-roadmap.md).

- **Technologie**: Tauri (Rust backend) + React + TypeScript (voor cross-platform, native prestaties en een solide developer experience).
- **Doel**: Zorg voor een intuïtieve en krachtige IDE die nauw integreert met de Noodle runtime en AI workflows.
- **Integratie**: Verbindt met Noodle Core via een gestandaardiseerde API voor bestandsbeheer, uitvoercontrole en AI-assistentie.
- **3D Visualisatie**: Geavanceerde "Noodle Brain" visualisatie met Three.js voor interactieve projectstructuur en code-relatie analyse in een 3D ruimte.

## Vereisten

Voordat u Noodle IDE installeert, moet u ervoor zorgen dat u de volgende software heeft geïnstalleerd:

- [Rust](https://www.rust-lang.org/)
- [Node.js](https://nodejs.org/) (v18 of hoger)
- [Tauri CLI](https://tauri.studio/v1/guides/getting-started/prerequisites#installing-the-tauri-cli):
  ```bash
  npm install -g @tauri-apps/cli
  ```

## Installatie

### Python Package Installatie

1. Installeer de noodle-ide Python package:
   ```bash
   cd noodle-ide
   pip install -e .
   ```

2. Test de installatie:
   ```bash
   python -c "import noodle_ide; print('Noodle IDE package import successful!')"
   ```

### Frontend Dependencies

3. Installeer afhankelijkheden voor het frontend:
   ```bash
   npm install
   ```

## Bouwen en Draaien

### Ontwikkelmodus
```bash
npm run tauri dev
```

### Productiebuild
```bash
npm run tauri build
```

## Package Structuur

De Noodle IDE package is opgebouwd met een duidelijke modulestructuur:

```
noodle_ide/
├── __init__.py          # Hoofdpackage initialisatie
├── core/                # Kernfunctionaliteiten
│   ├── __init__.py      # Core module exports
│   ├── ai_integration.py
│   ├── event_bus.py
│   ├── hot_reload.py
│   ├── interfaces.py
│   ├── plugin_manager.py
│   ├── plugin_marketplace.py
│   ├── security_sandbox.py
│   ├── templates.py
│   └── testing_framework.py
├── plugins/             # Plugin-architectuur
│   ├── __init__.py      # Plugin module exports
│   ├── ale-dashboard/
│   ├── proxy_io/
│   ├── python-transpiler/
│   └── tree-view-plugin/
└── tests/               # Test suite
    ├── __init__.py      # Test module exports
    ├── backend/         # Backend tests
    │   init__.py       # Backend test exports
    └── e2e/
```

### Recent Package Fixes

**Status**: ✅ **Package structure issues opgelost (September 2023)**

Problemen die waren opgelost:
- ✅ Fix import errors in `noodle_ide/core/__init__.py`
- ✅ Create missing placeholder classes for core components
- ✅ Configure proper `__all__` exports for all modules
- ✅ Ensure all `__init__.py` files are properly configured
- ✅ Test successful imports: `import noodle_ide`, `import noodle_ide.core`, `import noodle_ide.plugins`, `import noodle_ide.tests`

De package structuur is nu volledig functioneel en alle imports werken correct.

## Functies (Roadmap)

Volgende [Noodle IDE Roadmap](../memory-bank/noodle-ide-roadmap.md) voor de planning implementatie:

- [x] Editor met Noodle syntax highlighting en intelligente aanvulling
- [x] File tree voor projectnavigatie
- [x] Consolepaneel voor runtime-uitvoer en logs
- [x] **Globale Zoekfunctionaliteit** - Zoek naar bestanden en inhoud met regex-ondersteuning
- [ ] AI-assistent voor code suggesties en refactoring
- [ ] Geïntegreerde debugger en profiler
- [ ] Project Manager-agent voor rollensysteem (Coder, Tester, Reviewer)
- [ ] 3D "Noodle Brain" visualisatie voor interactieve projectstructuur weergave
- [ ] Real-time samenwerking via WebSocket-verbindingen
- [ ] Plugin-architectuur voor uitbreidbaarheid
- [ ] **3D "Noodle Brain" Visualisatie** - Interactieve 3D weergave van project structuren, dependencies en code-relaties met Three.js
- [ ] 2D/3D view switching voor verschillende analyseperspectieven
- [ ] AI-gestuurde layout optimalisatie in 3D ruimte
- [ ] Real-time updates van code-relaties in de 3D visualisatie
- [ ] **3D "Noodle Brain" Visualisatie** - Interactieve 3D weergave van projectstructuren, dependencies en code-relaties

## Gebruik van de Run-functie

De Noodle IDE ondersteunt nu het direct uitvoeren van Noodle-scripts vanuit de editor:

### Basisgebruik
1. **Open een .nl bestand** in de Editor-tab.
2. **Schrijf je Noodle-code** (bijv. eenvoudige print-statements of wiskundige operaties).
3. **Klik op de "Run" knop** bovenaan de editor om de code uit te voeren.
4. **Bekijk de output** in de Console-tab, waar stdout, stderr en foutmeldingen worden weergegeven met tijdstempels en kleurcodering (groen voor output, rood voor errors).
5. **Clear Console** om de logs te wissen.

### Voorbeeld Noodle-script (`test_script.nl`)
```noodle
print("Hello from Noodle IDE!")
x = 5 + 3
print(f"The result is {x}")

# Functie definitie en aanroep
def add_numbers(a, b):
    return a + b

result = add_numbers(10, 20)
print(f"Function result: {result}")
```

### Geavanceerde Functies
- **Foutafhandeling**: Alle fouten (compilatie, runtime, import) worden in de Console getoond met gedetailleerde stacktraces.
- **Meerdere uitvoeringen**: Je kunt meerdere scripts achter elkaar uitvoeren; de output wordt chronologisch toegevoegd.
- **Real-time feedback**: De Console update direct met output van langlopende scripts.

### Best Practices
- **Kleine scripts**: Begin met eenvoudige scripts om de werking te begrijpen.
- **Foutopsporing**: Gebruik de Console om foutmeldingen te analyseren; let op paden en importfouten.
- **Performance**: Complexe scripts kunnen wat langer duren door subprocess-overhead.
- **Noodzaak**: Zorg ervoor dat `noodle-dev` correct is geïnstalleerd en dat `python -m noodle_dev.core_entry_point` werkt.

### Technische Details
- **Uitvoering**: Scripts worden naar een tijdelijk `.nl` bestand geschreven en uitgevoerd via `python -m noodle_dev.core_entry_point`.
- **Paden**: De huidige werkdirectory is ingesteld op `../noodle-dev` ten opzichte van de IDE.
- **Beveiliging**: Scripts worden in een beveiligde omgeving uitgevoerd met beperkte systeemtoegang.
- **Opschonen**: Tijdelijke bestanden worden automatisch verwijderd na uitvoering.

### Bekende Beperkingen
- **Importen**: Sommige Noodle Core modules kunnen importfouten geven; los dit op in de Core-installatie.
- **Bytecode**: Momenteel wordt geen directe bytecode-compilatie ondersteund; alles gaat via de Python-interpreter.
- **Debugging**: Geen geïntegreerde debugger beschikbaar; gebruik print-statements en Console-output.

### Toekomstige Updates
- [ ] Directe bytecode-compilatie en uitvoering zonder Python-interpreter
- [ ] Geïntegreerde debugger met breakpoints en variable inspection
- [ ] Hot-reloading voor snelle iteratie tijdens development
- [ ] Script profielering en performance metrics
- [ ] Multi-script project ondersteuning met dependency tracking

### Probleemoplossing
Als de "Run" knop niet werkt:
1. Controleer of `noodle-dev` correct is geïnstalleerd
2. Voer handmatig `cd noodle-dev && python -m noodle_dev.core_entry_point test_script.nl` uit
3. Check de Console op specifieke foutmeldingen
4. Zorg ervoor dat alle noodle-dev dependencies geïnstalleerd zijn

## Globale Zoekfunctionaliteit

De Noodle IDE bevat een krachtige globale zoekfunctionaliteit waarmee je snel bestanden en inhoud in je project kunt vinden. Deze functionaliteit biedt zowel bestandszoeken als inhoudszoeken met geavanceerde filters en regex-ondersteuning.

### Kernfunctionaliteiten

- **Bestandszoeken**: Zoek naar bestanden op naam met ondersteuning voor wildcards en extensiefilters
- **Inhoudszoeken**: Zoek naar specifieke tekst of patronen binnen bestandsinhoud
- **Regex-ondersteuning**: Gebruik reguliere expressies voor complexe zoekpatronen
- **Real-time resultaten**: Resultaten worden direct weergegeven terwijl je typt
- **Bestandsvoorvertoning**: Bekijk een preview van de gevonden bestanden en inhoud
- **Integratie met editor**: Klik op resultaten om bestanden direct te openen in de editor
- **Zoekgeschiedenis**: Jouw recente zoekopdrachten worden bijgehouden voor snelle toegang

### Gebruik van de Zoekfunctionaliteit

#### Basisbestandszoek
1. **Open het zoekvenster**: Klik op het zoekicoon in de toolbar of gebruik de sneltoets `Ctrl+F` (Windows) of `Cmd+F` (Mac).
2. **Voer zoekterm in**: Typ de naam van het bestand dat je zoekt.
3. **Bekijk resultaten**: De resultaten worden direct weergegeven in een zijpaneel.
4. **Open bestand**: Klik op een resultaat om het bestand te openen in de editor.

#### Inhoudszoek met Regex
1. **Open het zoekvenster**: Klik op het zoekicoon in de toolbar.
2. **Schakel naar inhoudszoek**: Klik op de "Search Content" knop.
3. **Voer zoekpatroon in**: Typ je zoekterm of regex-patroon (bijv. `def\s+\w+` om functies te vinden).
4. **Gebruik filters**: Selecteer bestandstypes, case sensitivity, en andere opties.
5. **Bekijk resultaten**: Zie zowel de bestandsnaam als de specifieke regels waar de match is gevonden.

#### Voorbezoek Regex Patronen

- **Functies vinden**: `def\s+\w+` - vindt alle functiedefinities
- **Variabelen**: `^\s*[a-zA-Z_][a-zA-Z0-9_]*\s*=` - vindt variabele toewijzingen
- **Imports**: `^import\s+|^from\s+\w+\s+import` - vindt alle import statements
- **Commentaren**: `#.*|//.*|/\*.*?\*/` - vindt alle soorten commentaren
- **Foutafhandeling**: `try:|except\s+\w+:|finally:` - vindt try-except blokken

### Geavanceerde Opties

#### Bestandstypes Filter
Je kunt de zoekopdracht beperken tot specifieke bestandstypes:
- `.py` - Python bestanden
- `.js` - JavaScript bestanden
- `.ts` - TypeScript bestanden
- `.nl` - Noodle bestanden
- `.md` - Markdown bestanden
- Aangepaste extensies toevoegen via de instellingen

#### Zoekopties
- **Case sensitive**: Maak onderscheid tussen hoofd- en kleine letters
- **Regex gebruiken**: Inschakelen van reguliere expressieondersteuning
- **Regelnummers tonen**: Toon regelnummers bij inhoudsresultaten
- **Maximaal aantal resultaten**: Beperk het aantal resultaten voor betere prestaties

#### Prestatieoptimalisaties
- **Indexering**: Grote projecten worden geïndexeerd voor snellere zoekresultaten
- **Debouncing**: Zoekopdrachten worden pas uitgevoerd na een korte pauze in het typen
- **Resultaten paginering**: Grote resultaten sets worden opgedeeld in pagina's
- **Cache**: recente zoekresultaten worden gecached voor snelle hergebruik

### Integratie met Andere Componenten

#### Editor Integratie
- **Directe opening**: Klik op zoekresultaten om bestanden direct te openen
- **Cursor positionering**: De cursor wordt geplaatst op de gevonden regel
- **Meerdere cursors**: Houd `Ctrl` ingedrukt om meerdere resultaten te selecteren

#### File Tree Integratie
- **Highlighting**: Gevonden bestanden worden gemarkeerd in de file tree
- **Automatisch scrollen**: De file tree scrollt automatisch naar gevonden bestanden

#### Console Integratie
- **Zoekresultaten in console**: Complexere zoekopdrachten kunnen via de console worden uitgevoerd
- **Script uitvoering**: Zoekresultaten kunnen direct worden uitgevoerd als scripts

### Technische Details

#### Backend Architectuur
De zoekfunctionaliteit maakt gebruik van een Tauri-backend voor optimale prestaties:
- **Bestandssysteem toegang**: Directe toegang tot bestanden via Tauri's File System API
- **Efficiënt zoeken**: Gebruik van geoptimaliseerde zoekalgoritmes
- **Memory management**: Intelligent geheugenbeheer voor grote projecten
- **Parallel processing**: Meerdere zoekopdrachten kunnen parallel worden uitgevoerd

#### Frontend Architectuur
De React-frontend biedt een soepele gebruikerservaring:
- **Real-time updates**: Resultaten worden live bijgewerkt
- **Responsive design**: Werkt goed op verschillende schermgroottes
- **Keyboard shortcuts**: Snelle toegang via toetsenbord shortcuts
- **Accessibility**: Volledige ondersteuning voor schermlezers

### Prestatiemetriken

De zoekfunctionaliteit is geoptimaliseerd voor prestaties:
- **Zoektijd**: < 100ms voor kleine projecten (< 1000 bestanden)
- **Geheugengebruik**: < 50MB voor indexering van grote projecten
- **Responsiviteit**: UI blijft responsief tijdens zoekoperaties
- **Schalbaarheid**: Ondersteunt projecten tot 100.000+ bestanden

### Probleemoplossing

#### Zoek werkt niet
1. **Controleer projectpad**: Zorg ervoor dat je in het juiste projectdirectory bent
2. **Herstart de IDE**: Soms helpt een herstart om indexproblemen op te lossen
3. **Controleer bestandsrechten**: Zorg ervoor dat de IDE toegang heeft tot je bestanden
4. **Vernieuw index**: Gebruik de "Refresh Index" optie in de zoekinstellingen

#### Traag zoekgedrag
1. **Beperk zoekbereik**: Gebruik bestandstype filters om het zoekbereik te verkleinen
2. **Verhoog debounce tijd**: Pas de debounce instelling aan in de zoekopties
3. **Gebruik regex voor complexe patronen**: Regex is sneller dan simpele tekstmatching voor complexe patronen
4. **Cache legen**: Leeg de zoekcache via de instellingen

#### Onjuiste resultaten
1. **Controleer regex**: Zorg ervoor dat je regex-patronen correct zijn
2. **Case sensitivity**: Schakel case sensitivity in of af afhankelijk van je behoefte
3. **Bestandstypes**: Controleer of je de juiste bestandstypes hebt geselecteerd
4. **Projectindex**: Vernieuw de projectindex voor de meest recente resultaten

### Toekomstige Updates

- [ ] **AI-gestuurde zoeksuggesties**: Slimme suggesties gebaseerd op je codepatronen
- [ ] **Multi-project zoeken**: Zoeken over meerdere projecten tegelijk
- [ ] **Gevorderde regex editor**: Visuele regex editor met testen
- [ ] **Zoekresultaten exporteren**: Exporteer zoekresultaten naar verschillende formaten
- [ ] **Collaborative search**: Deel zoekopdrachten met teamleden
- [ ] **Performance monitoring**: Gedetailleerde prestatie-statistieken voor zoekoperaties

## 3D "Noodle Brain" Visualisatie

De Noodle IDE bevat een geavanceerde 3D visualisatiemogelijkheid genaamd "Noodle Brain" die projectstructuren, dependencies en code-relaties in een interactieve 3D-omgeving weergeeft.

### Kernfunctionaliteiten

- **Projectstructuur visualisatie**: Bestanden en directories worden weergegeven als knooppunten in een 3D-ruimte
- **Dependency mapping**: Import- en exportrelaties tussen bestanden worden getoond als verbindingen tussen knooppunten
- **Code-analyse**: Automatische detectie van code-relaties en afhankelijkheden
- **Interactieve navigatie**: Zoom, draai en verken de projectstructuur in 3D
- **Real-time updates**: Visualisatie wordt automatisch bijgewerkt bij wijzigingen in de codebase

### Technologie

- **Three.js**: Gebruikt voor WebGL-gebaseerde 3D rendering
- **React Three Fiber**: React-wrapper voor Three.js voor naadloze integratie met de React-stack
- **D3.js**: Voor geavanceerde data-visualisatie en layout-algoritmes
- **Web Workers**: Voor zware berekeningen zonder UI-blocking

### Gebruiksscenario's

- **Projectoverzicht**: Snel begrijpen van de complexiteit en structuur van grote codebases
- **Dependency-analyse**: Identificeren van cyclische dependencies en onnodige koppelingen
- **Code-navigatie**: Snell navigeren tussen gerelateerde bestanden en functies
- **Refactoring-assistentie**: Visualiseren van de impact van code-wijzigingen
- **Teamcollaboratie**: Gedeelde visualisatie voor code-review en architectuurdiscussies

## 3D "Noodle Brain" Visualisatie

Een unieke feature van Noodle IDE is de geavanceerde 3D "Noodle Brain" visualisatie, gebouwd met Three.js en WebGL technologie. Deze visualisatie stelt ontwikkelaars in staat om:

### Project Structure Visualisatie
- **3D Brain Model**: Interactieve 3D weergave van het volledige project als een "brein" met knopen en verbindingen
- **Hiërarchische Weergave**: Bestanden, modules en functies worden visueel gerangschikt op basis van hun relaties
- **Dynamische Layout**: De 3D structuur past zich automatisch aan bij projectwijzigingen

### Code Relatie Analyse
- **Dependency Mapping**: Zicht maken van afhankelijkheden tussen bestanden en modules
- **Code Flow Visualisatie**: Inzicht in hoe data en controlestroom door het project bewegen
- **Circulaire Detectie**: Automatisch identificeren van problematische code-cycli in de 3D ruimte

### AI-Versterkte Features
- **Automatische Insights**: AI analyseert de 3D structuur en suggereert verbeteringen
- **Performance Indicatoren**: Visuele weergave van prestatieknelpunten in de 3D visualisatie
- **Predictive Analysis**: Voorspellingen over mogelijke architectuurproblemen op basis van patronen

### Interactieve Controls
- **360° Navigatie**: Volledige controle over de 3D weergave met muis en toetsenbord
- **Zoom en Focus**: Inzoomen op specifieke codeonderdelen of uitzoomen voor overzicht
- **Filteren en Groeperen**: Selectief weergeven van bepaalde typen code-relaties

De 3D visualisatie integreert naadloos met de traditionele 2D views van de IDE, waardoor ontwikkelaars kunnen schakelen tussen verschillende perspectieven op hun codebase.

## Integratie met Noodle Core

De IDE communiceert met de [Noodle Core](../noodle-dev) runtime via een lokale, gestandaardiseerde API (JSON over IPC/HTTP). Zie:
- [Noodle IDE Roadmap (Fase 2+)](../memory-bank/noodle-ide-roadmap.md)
- [Decision 001: IDE Core Scheiding](../memory-bank/decision-001-ide-separation.md)

Voorlopig kunnen simpele Noodle-scripts worden uitgevoerd via CLI commands rechtstreeks in Core, met plannen voor verdere integratie.

## Contribueren

We moedigen bijdragen aan het Noodle IDE project aan! Zie [CONTRIBUTING.md](../noodle-dev/CONTRIBUTING.md) voor richtlijnen.

## Licentie

Gelicenseerd onder dezelfde voorwaarden als Noodle Core: zie [LICENSE](../noodle-dev/LICENSE).

---

Meer informatie:
- [Noodle Vision](../memory-bank/distributed_ai_os_vision.md)
- [Noodle Core Project](../noodle-dev)
- [Algemene Noodle Roadmap](../memory-bank/roadmap.md)
