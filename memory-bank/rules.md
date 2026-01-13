# 📜 Noodle Project Rules (`rules.md`)

## 🎯 Doel van het project
Het ontwikkelen van **Noodle**, een nieuwe programmeertaal en ecosysteem dat:
- Geschikt is voor **gedistribueerde AI-systemen**
- **Performance-geoptimaliseerd** is (o.a. nieuwe matrix-methoden, GPU, parallelisme)
- **Toekomstbestendig** (native database, moderne beveiliging, modulaire libraries)
- **Developer-friendly** (VS Code plugin, tooling, duidelijke documentatie)

---

## 🧭 Basisprincipes
1. **Transparantie** → alle beslissingen, wijzigingen en statusupdates worden gelogd in de `memory-bank`.
2. **Iteratief werken** → werk in kleine, toetsbare stappen. Pas na *“definition of done”* mag een rol door naar de volgende milestone.
3. **Kwaliteit boven snelheid** → beter robuust en getest, dan snel maar rommelig.
4. **Samenwerking** → iedere rol is verantwoordelijk voor communicatie en voortgang. Rollen vullen elkaar aan en mogen blockers escaleren.
5. **Parallel werken** → waar mogelijk werken rollen tegelijk, maar alles wordt samengebracht via `memory-bank` en duidelijke milestones.

---

## 📌 Rollen & verantwoordelijkheden
- **Project Manager** → bewaakt scope, planning en "definition of done".
- **Lead Architect** → bepaalt taalstructuur, runtime en compiler-keuzes.
- **Library/Interop Engineer** → onderzoekt en implementeert library-compatibiliteit (inspiratie: Python, Mojo, Rust).
- **Database & Data Engineer** → ontwikkelt de database-functies en query-API.
- **Performance Engineer** → optimalisaties (GPU, parallelisatie, nieuwe matrix-algoritmes).
- **Security Engineer** → crypto, veilige runtime, audit van kwetsbaarheden.
- **Developer Experience Engineer** → VS Code plugin, MCP-server, CLI, tooling.
- **Tester/QA** → schrijft testplannen, CI/CD checks, proof-of-concepts.
- **Technical Writer** → documentatie en updates in `memory-bank`.
- **Project Structure Guardian** → bestandsorganisatie, foutanalyse en preventie, documentatie consistentie.

Rollen mogen sub-rollen voorstellen en toevoegen indien nodig.

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

### Voorbeeld: XML Structure Problemen
**Probleem**: `apply_diff` operaties mislukken door verkeerde XML-structuur

**Beste oplossing** (⭐⭐⭐⭐⭐):
```xml
<apply_diff>
<args>
<file>
  <path>bestandspad</path>
  <diff>
    <content><![CDATA[
<<<<<<< SEARCH
:start_line:regelnummer
---
exact te vinden content
=======
nieuwe content
>>>>>>> REPLACE
]]>

### Voorbeeld: Bestandsanalyse en Verificatie
**Probleem**: Content niet up-to-date na wijzigingen, of diff operaties mislukken

**Beste oplossing** (⭐⭐⭐⭐⭐):
```python
# Stap 1: Lees het bestand eerst om structuur te begrijpen
read_file(<args><file><path>bestandspad</path></file></args>)

# Stap 2: Analyseer de output om te weten waar alles staat
# Let op: regelnummers, witruimte, exacte content

# Stap 3: Voer de gewenste wijziging uit
# Gebruik de gelezen content als basis voor de diff

# Stap 4: Lees het bestand opnieuw na wijzigingen om te verifiëren
# "You do not need to re-read the file, as you have seen all changes"
# Gebruik deze notice als bevestiging dat de content is bijgewerkt
```

**Voordelen**:
- Begrijpt de exacte structuur van het bestand
- Vermijdt matching problemen door onjuiste regelnummers
- Kan complexe documentatie structuren aan
- Zorgt voor consistente wijzigingen

**Best Practice Werkwijze**:
1. **Eerst lezen**: Gebruik `read_file` om de huidige staat te begrijpen
2. **Analyseren**: Identificeer exact waar je wilt wijzigen
3. **Uitvoeren**: Voer de wijziging uit met correcte parameters
4. **Verifiëren**: Lees opnieuw of vertrouw op notice system
5. **Documenteren**: Noteer de wijziging in memory-bank

### Voorbeeld: Bestandsorganisatie en Foutanalyse
**Probleem**: Test/debug scripts komen op verkeerde plek, fouten in scripts worden niet systematisch geanalyseerd

**Beste oplossing** (⭐⭐⭐⭐⭐):
```python
# Stap 1: Analyseer projectstructuur voor juiste locatie
# Lees bestanden om te begrijpen waar iets hoor thuis te komen
read_file(<args><file><path>noodle-dev/docs/index.md</path></file></args>)

# Stap 2: Identificeer juiste map op basis van bestandsindex
# Tests → tests/unit/ of tests/integration/
# Debug scripts → debug_*.py in hoofdmap of specifieke map

# Stap 3: Maak bestand aan op juiste locatie
# Gebruik correcte pad en naamconventies

# Stap 4: Documenteer de wijziging in memory-bank
# Waarom is het hier geplaatst? Wat is het doel?
```

**Voordelen**:
- Consistente projectstructuur
- Makkelijker navigeren en onderhouden
- Duidelijke scheiding van verantwoordelijkheden
- Systematische foutenanalyse

**Best Practice Werkwijze**:
1. **Structuur analyse**: Begrijp de projecthiërarchie
2. **Locatie bepalen**: Gebruik de documentatie als gids
3. **Correct plaatsen**: Zorg voor juiste pad en naam
4. **Documenteren**: Leg de keuze vast in memory-bank
