# Dev-Tools Brein Visualisatie Voorbeeldgebruik

## Doel
Dit document toont voorbeelden van hoe de `dev-tools/analyze_project.py` script kan worden ingezet als data-bron voor de "brein visualisatie" in Noodle-IDE. Het visualiseert de codebase als interactief netwerk van knobbels (scripts/functies) met gekleurde verbindingen (datastromen).

---

## 🛠️ Voorbeeld 1: Sheaf Memory Brein-Visualisatie

### Stap 1: Data Genereren met Dev-Tools
```bash
cd "c:/Users/micha/Noodle"
echo "sheaf memory" | python dev-tools/analyze_project.py
```

**Output:**
- Vector search resultaten gerelateerd aan sheaf memory.
- GraphML file (`code_graph.graphml`) met volledige dependency graph.
- Metadata JSON met functies, imports, datastromen.

### Stap 2: Graph Verwerken voor Brein
Converteer GraphML naar een visueel vriendelijk formaat (bijv. JSON voor D3.js):

```python
# Voorbeeldconversie (breid analyze_project.py uit)
def generate_brein_graph():
    import json
    import networkx as nx

    G = nx.read_graphml("dev-tools/code_index/code_graph.graphml")
    
    nodes = []
    for node, data in G.nodes(data=True):
        # Bepaal type voor kleurlogica
        node_type = "module" if ".py" in node else "function"
        
        # Zoek datastroom-type in imports/edges
        dataflow_type = "geheugen" if "memory" in data.get("label", "").lower() else "algemeen"
        
        nodes.append({
            "id": node,
            "label": data.get("label", node),
            "type": node_type,
            "dataflow": dataflow_type,
            "docstring": data.get("docstring", "")
        })
    
    edges = []
    for u, v, data in G.edges(data=True):
        edges.append({
            "from": u,
            "to": v,
            "type": data.get("type", "import"),
            "weight": 1  # Kan later complexer (frequentie, etc.)
        })
    
    with open("brein_graph.json", "w") as f:
        json.dump({"nodes": nodes, "edges": edges}, f, indent=2)
```

### Stap 3: Visualisatie in Noodle-IDE
Laad `brein_graph.json` in D3.js:

```html
<!-- Voorbeeld D3.js structuur -->
<div id="brein-viz"></div>
<script>
  // Laad data
  d3.json("brein_graph.json").then(graph => {
    // Teken knobbels en verbindingen
    const node = svg.selectAll(".node")
      .data(graph.nodes)
      .enter().append("g")
      .attr("class", "node")
      .style("fill", d => d.dataflow === "geheugen" ? "blue" : "green");

    node.append("circle")
      .attr("r", 10);

    node.append("text")
      .text(d => d.label);

    // Teken verbindingen
    svg.selectAll(".edge")
      .data(graph.edges)
      .enter().append("line")
      .attr("stroke", d => d.type === "geheugen" ? "blue" : "gray");
  });
</script>
```

**Resultaat in IDE:**
- Blauwe knobbels = geheugen-gerelateerd
- Groene = algemeen
- Dikke lijnen = veel datastroom
- Klik = zoom/focus op sub-netwerk

---

## 🎨 Voorbeeld 2: Interactie met Vector Search

### Scenario
Gebruiker klikt op "Sheaf Memory" knobbel. De visualisatie toont alleen gerelateerde knobbels.

**Stappen:**
1. Gebruiker klikt "Sheaf Memory".
2. Vector search: "alles wat met sheaf memory communiceert".
3. Filter graph alleen voor die knobbels.

```python
def filter_graph_by_query(graph, query, top_k=20):
    # Gebruik vector index om gerelateerde knobbels te vinden
    model, index, metadata, _ = load_index()
    
    query_embedding = model.encode([query])
    distances, indices = index.search(query_embedding, top_k)
    
    # Houd alleen knobbels die in resultaten voorkomen
    relevant_node_ids = [metadata[idx]["filepath"] for idx in indices[0]]
    
    return {
        "nodes": [n for n in graph["nodes"] if n["id"] in relevant_node_ids],
        "edges": [e for e in graph["edges"] if e["from"] in relevant_node_ids or e["to"] in relevant_node_ids]
    }
```

**Output:**
- Gefilterte graph met alleen:
  - Sheaf Memory
  - Runtime Manager
  - Database Connectie
  - Memory Allocator

---

## 🔄 Voorbeeld 3: Live Updates

### Watcher Modus
Bouw een watcher die bij elke save de graph update:

```python
# in analyze_project.py (of apart script)
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class CodeChangeHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path.endswith(".py"):
            print("Code gewijzigd, update brein graph...")
            run_brein_analysis()

observer = Observer()
observer.schedule(CodeChangeHandler(), path="noodle-core/src", recursive=True)
observer.start()
```

### Gebruik in IDE:
- Noodle-IDE pollt of `brein_graph.json` is geüpdatet.
- Visualisatie wordt automatisch ververst.
- Gebruiker ziet live veranderingen (nieuwe verbindingen, kleurwijzigingen).

---

## 🎯 Voorbeeld 4: "Verbeteren" via Brein

### Scenario
Visualisatie markeert een "dode" functie (ongebruikte code).

**Automatische Detectie:**
```python
def find_dead_code(graph):
    # Simpele heuristiek: functie zonder inkomende verbindingen
    used_functions = {e["to"] for e in graph["edges"] if e["type"] == "call"}
    all_functions = {n["id"] for n in graph["nodes"] if n["type"] == "function"}
    
    dead_code = all_functions - used_functions
    return dead_code

dead_functions = find_dead_code(brein_graph)
print("Ongebruikte functies:", dead_functions)
```

**Visuele Feedback:**
- Rode rand om "dode" knobbels.
- Contextmenu: "Verwijder functie", "Refactor", "Maak documentatie".

---

## 📚 Integratie met Noodle-IDE

### IDE Plugin Structuur
```
noodle-ide/
├── src/
│   ├── brein-viz/
│   │   ├── WebViewPanel.tsx     // React/D3 paneel
│   │   ├── BreinGraphProvider.ts // Data fetching
│   │   └── GraphUpdater.ts      // Watcher + updates
│   └── dev-tools-integration/
│       └── runAnalysis.ts       // Roept analyze_project.py aan
```

### Commando's
- `Ctrl+Shift+P > "Brein Visualisatie Openen"` → Toon paneel.
- `Ctrl+Shift+P > "Brein Graph Update"` → Draai dev-tools script.
- Knoopel menu → "Filter op sheaf" → Voert vector search uit.

---

## 🔗 Gerelateerde Bestanden
- `brein-viz-project-analysis.md`: Algemene concept.
- `dev-tools-usage-documentation.md`: Hoe dev-tools werken.
- `noodle-ide-tree-graph-view-implementation-plan.md`: Visuele implementatie.

---

*Status: Concept – klaar voor implementatie*
*Creatie: 2025-10-02*
