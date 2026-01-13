# Brein Visualisatie Project Analyse voor Noodle-IDE

## 🎯 Idee Samenvatting
Een doorschijnend, interactief brein-visualisatie in Noodle-IDE waarin:
- **Knobbels** = scripts, functies, modules, klassen
- **Verbindingen** = datastromen, imports, functie-aanroepen
- **Kleuren** = type datastroom (bijv. geheugen, I/O, control flow)
- **Interactie** = inzoomen, verbeteren, refactoren via klikken

**Doel**: Visueel begrijpen hoe met wat praat en mogelijkheden tot verbetering direct zien.

---

## 📊 Hoe Dev-Tools Dit Ondersteunen

### 1. **Data-extractie met analyze_project.py**
- **Knobbels**: Functies, klassen, bestanden (geëxtraheerd via AST).
- **Verbindingen**: Import statements, dependency graph (NetworkX).
- **Kleurlogica**: Type afhankelijkheden bepalen (bijv. "import", "functie-call", "geheugen-overdracht").

### 2. **Vector Search voor Context**
- Semantische zoekopdrachten helpen te bepalen welke knobbels gerelateerd zijn (bijv. "alles wat met sheaf memory doet").
- Geept context bij interactie (bijv. klik op knobbel → toont relevante codefragmenten).

### 3. **Incrementele Updates**
- Watcher voor live updates tijdens ontwikkelen.
- Graph hergenereren na wijzigingen.

---

## 🛠️ Implementatiestappen

### A. Uitbreiden van `analyze_project.py`
Voeg datastroom-typeherkenning toe:
```python
# Voorbeeld: analyseer imports voor datastroom-kleuren
def detect_dataflow_type(import_stmt):
    if "memory" in import_stmt:
        return "geheugen"
    elif "database" in import_stmt:
        return "data"
    elif "api" in import_stmt:
        return "netwerk"
    else:
        return "algemeen"
```

### B. GraphML naar Visualisatieformaat
Converteer `code_graph.graphml` naar een formaat geschikt voor:
- D3.js (web-based)
- Three.js (3D, transparant)
- VS Code WebView

### C. Interactie Componenten
- **Knobbels**: Toon naam, type (functie/module), docstring-kopje.
- **Verbindingen**: Kleuren en dikte op basis van datastroom-intensiteit.
- **Zoom**: Inzoomen op knobbel → toont sub-knobbels (functies in een module).

---

## 📋 Voorbeeld Gebruiksscenario

### Startpunt
- Gebruiker opent Noodle-IDE, ziet brein-visualisatie met:
  - Grote centrale "Sheaf Memory" knobbel.
  - Blauwe verbindingen naar "Runtime Manager".
  - Groene naar "Database Connectie".

### Interactie
- Gebruiker klikt "Sheaf Memory".
- Zoom in: ziet interne functies (`alloc`, `dealloc`, `compact`).
- Klikt `alloc`: ziet welke andere modules deze aanroepen.

### Verbetering
- Visualisatie markeert een "dode" verbinding (ongebruikte functie).
- Gebruiker kan klikken om te refactoren of te verwijderen.

---

## 🔧 Technical Planning

### 1. Datastructuur voor Brein-Graph
```json
{
  "nodes": [
    {"id": "sheaf.py", "type": "module", "label": "Sheaf Memory", "docstring": "..."},
    {"id": "alloc", "type": "function", "label": "alloc()", "parent": "sheaf.py"}
  ],
  "edges": [
    {"from": "sheaf.py", "to": "runtime.py", "type": "geheugen", "weight": 5},
    {"from": "alloc", "to": "memory_manager.py", "type": "aanroep"}
  ]
}
```

### 2. Visualisatie Tooling
- **Technologie**: D3.js + VS Code WebView (of apart webpaneel).
- **Realtime**: Update na elke save (via watcher in `analyze_project.py`).

### 3. Integratie met Noodle-IDE
- Tab in IDE: "Brein Visualisatie".
- Koppeling met dev-tools: knop "Update Graph".

---

## 🚀 Volgende Stappen

1. **Proof of Concept**:
   - Breid `analyze_project.py` uit met datastroom-detectie.
   - Genereer voorbeeld-graph (kleur, verbindingen).

2. **Visualisatie Prototype**:
   - Bouw eenvoudige D3.js visualisatie in HTML.
   - Laad GraphML data.

3. **IDE Integratie**:
   - Koppel aan Noodle-IDE via WebView of externe server.

4. **Interactie**:
   - Implementeer zoom, klik, context-menu.

---

## 📚 Gerelateerde Docs
- `noodle-ide-tree-graph-view-architecture.md`: Algemene visuele architectuur.
- `distributed_ai_os_vision.md`: Brein als centrale AI.
- `dev-tools-usage-documentation.md`: Hoe de dev-tool data levert.

---

*Status: Concept – klaar voor uitwerking*
*Creatie: 2025-10-02*
