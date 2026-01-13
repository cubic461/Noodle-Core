# 📘 Blueprint: Noodle + Noodle-IDE

## 🎯 Doel van het project
Het ontwikkelen van **Noodle**, een nieuwe programmeertaal en ecosysteem dat:
- Geschikt is voor **gedistribueerde AI-systemen**
- **Performance-geoptimaliseerd** is (o.a. nieuwe matrix-methoden, GPU, parallelisme)
- **Toekomstbestendig** (native database, moderne beveiliging, modulaire libraries)
- **Developer-friendly** (VS Code plugin, tooling, duidelijke documentatie)

---

## 🧭 Basisprincipes
1. **Transparantie** → alle beslissingen, wijzigingen en statusupdates worden gelogd in de `memory-bank`.
2. **Iteratief werken** → werk in kleine, toetsbare stappen. Pas na *"definition of done"* mag een rol door naar de volgende milestone.
3. **Kwaliteit boven snelheid** → beter robuust en getest, dan snel maar rommelig.
4. **Samenwerking** → iedere rol is verantwoordelijk voor communicatie en voortgang. Rollen vullen elkaar aan en mogen blockers escaleren.
5. **Parallel werken** → waar mogelijk werken rollen tegelijk, maar alles wordt samengebracht via `memory-bank` en duidelijke milestones.

---

## 📌 Kernscheiding
### Noodle (taal + runtime)
- **Compiler / interpreter** (NBC-runtime).
- **Basis syntax, semantiek, memory management**.
- **Distributed execution layer**.
- **Standaard bibliotheken** (AI-math, crypto, DB-integratie).
- **CLI-tools**: `noodle build`, `noodle run`, `noodle test`.
- **Language server** (LSP) voor integratie met VS Code, JetBrains, enz.

### Noodle-IDE (ontwikkelomgeving)
- **Editor-frontend** (standalone).
- **Plugin-systeem** voor AI-assist.
- **Visual debugger** (ook distributed-aware).
- **Cluster manager** (hardware detectie, load balancing).
- **Indexer + memory-bank** voor AI-assistentie.
- **Orchestration dashboard** (Optie 3, later).

---

## 🔄 Evolutiepad

### Fase 1 – Taalbasis (Noodle-core)
**Doel**: Noodle bruikbaar maken in bestaande IDE's.

**Taken**:
- Ontwikkel NBC-runtime (al begonnen).
- Maak CLI-tools (`noodle run`).
- Bouw een Language Server Protocol (LSP) zodat VS Code en Rocode syntax & linting ondersteunen.

**Resultaat**: Iedereen kan Noodle in z'n favoriete IDE gebruiken.

**Voordelen**: snelle adoptie, lage instap.
**Nadelen**: Noodle-IDE nog geen meerwaarde.

### Fase 2 – Noodle-IDE als optionele frontend
**Doel**: Unieke extra's aanbieden voor Noodle-devs.

**Taken**:
- Bouw Noodle-IDE skeleton (standalone app).
- Voeg AI-autocomplete, AI-debugger, en een Memory-Bank indexer toe.
- Zorg dat Noodle-IDE projectstatus + logging bijhoudt (kritisch voor samenwerken met meerdere AI's).

**Resultaat**:
Ontwikkelaars kunnen kiezen:
- Werken in VS Code/JetBrains, of
- Werken in Noodle-IDE met AI-first features.

**Voordelen**: Noodle-IDE wordt aantrekkelijk zonder verplichting.
**Nadelen**: dubbele onderhoudslast (IDE + LSP).

### Fase 3 – Noodle-IDE als orchestrator (AI-distributed hub)
**Doel**: Maak Noodle-IDE hét centrum voor AI/distributed ontwikkeling.

**Taken**:
- Cluster manager integreren (detecteer en gebruik hardware → CPU/GPU/TPU).
- Visualiseringslaag: laat zien waar processen draaien (per node, per thread).
- Integratie met database in de taal → query's en datasets live volgen.
- Orchestratie van AI-agents → ontwikkelomgeving waarin AI-rollen samenwerken.

**Resultaat**:
Noodle-IDE = het controlepaneel voor een distributed AI-first OS.

**Voordelen**:
- Dit maakt Noodle uniek en moeilijk te vervangen.
- Sluit perfect aan op je visie van "één systeem over meerdere machines".

**Nadelen**:
- Hoge complexiteit.
- Pas haalbaar als Fase 1 + 2 stabiel zijn.

---

## 🚦 Waarom dit pad?

**Pragmatisch** → snel starten met bestaande tools (lage drempel, community kan instappen).

**Flexibel** → ontwikkelaars hoeven niet meteen over naar Noodle-IDE.

**Toekomstbestendig** → Noodle-IDE kan groeien naar orchestrator zonder lock-in.

**Uniek** → distributed debugging en AI-hub functies maken Noodle speciaal.

---

## 📋 Milestones

### Milestone 1 – Noodle-core werkt
- [ ] NBC-runtime stabiel.
- [ ] CLI-tools (`noodle run`).
- [ ] LSP voor syntax highlighting en autocomplete.

### Milestone 2 – Noodle-IDE v1 (optie)
- [ ] Basis editor werkt.
- [ ] AI-assist (memory-bank indexing).
- [ ] Logging van projectstatus.

### Milestone 3 – Noodle-IDE v2 (hub)
- [ ] Cluster manager en distributed debugger.
- [ ] Visual orchestration van nodes.
- [ ] AI-agents kunnen samenwerken in Noodle-IDE.

### Milestone 4 – Distributed AI-first OS (long-term)
- [ ] Noodle + Noodle-IDE samen functioneren als OS-level distributed system.
- [ ] Alles voelt als één geheel, ook over meerdere pc's/hardware.

---

## 📝 Definition of Done (DoD)
Een taak is **afgerond** als:
- Het resultaat voldoet aan de beschrijving van het doel.
- Het is getest en gedocumenteerd.
- Eventuele afhankelijkheden en blockers zijn gelogd.
- Het staat bijgewerkt in de `memory-bank`.

---

## 🔄 Workflow
1. Iedere rol werkt vanuit de laatste status in `memory-bank`.
2. Bij iedere wijziging wordt een korte update toegevoegd (status/todo/resultaat).
3. Grote beslissingen worden vastgelegd in een apart `.md` bestand (bv. `decision-001.md`).
4. Alles wordt iteratief verbeterd en getest voor de volgende milestone.

---

## 🚦 Communicatie
- **Memory-bank = single source of truth**
- Korte notities: inline in statusbestanden
- Lange notities/besluiten: apart bestand met nummering (`decision-###.md`, `design-###.md`)

---

## 🛠️ Leren van Fouten en Verbeteringen

### Kernprincipe
**Elke AI en mens in het project leert van fouten en verbeteringen continu**. We gebruiken een gestructureerd systeem om oplossingen te evalueren, te ratingen en te optimaliseren.

### Rating Systeem
- ⭐⭐⭐⭐⭐ **5 punten**: Uitstekende oplossing, werkt altijd, goed gedocumenteerd
- ⭐⭐⭐⭐ **4 punten**: Goede oplossing, werkt meestal, redelijk gedocumenteerd
- ⭐⭐⭐ **3 punten**: Acceptabele oplossing, werkt soms, basis documentatie
- ⭐⭐ **2 punten**: Beperkte oplossing, zelden werkt, minimale documentatie
- ⭐ **1 punt**: Slechte oplossing, werkt bijna nooit, geen documentatie

### Oplossingen Database
Raadpleeg [`solution_database.md`](solution_database.md) voor:
- **Gestructureerde oplossingen** voor voorkomende problemen
- **Hogerst gerateerde oplossingen** worden eerst geprobeerd
- **Fallback mechanisme**: als oplossing A faalt, probeer oplossing B
- **Success metrics** en tracking van verbeteringen

### Probleemoplossingsproces
1. **Identificeer het probleem**: Wat is de exacte fout? Welke tool mislukt?
2. **Raadpleeg de database**: Zoek in [`solution_database.md`](solution_database.md) naar vergelijkbare problemen
3. **Selecteer oplossing**: Kies de hoogst gerateerde oplossing die past bij het probleem
4. **Test en evalueer**: Documenteer het resultaat (succes/falen)
5. **Update rating**: Pas de punten aan op basis van het resultaat

### Rating Updates
- **Succes**: +1 punt (maximaal 5)
- **Falen**: -1 punt (minimaal 1)
- **Periodieke review**: Maandelijks her-evalueren van alle oplossingen

### Verantwoordelijkheden per Rol
- **Technical Writer**: Onderhoudt de oplossingen database en documentatie
- **Lead Architect**: Evalueert technische oplossingen en complexe problemen
- **Tester/QA**: Test oplossingen en documenteert resultaten
- **Alle rollen**: Rapporteert problemen en successen, suggesteert nieuwe oplossingen

---

## 👉 Voor de AI's
Dit blueprintbestand dient als de "single source of truth" voor alle AI's die aan het Noodle-project werken. Het biedt:
- Duidelijke scheiding tussen wat bij Noodle-taal hoort en wat bij Noodle-IDE hoort.
- Het evolutiepad van een simpele taal naar een volledig AI-distributed platform.
- Redenen achter de gekozen strategie en fasering.
- Concrete milestones om voortgang te meten.
- Een framework voor continu leren en verbeteren.

Alle AI's moeten dit document raadplegen voor context en richting bij hun taken.
