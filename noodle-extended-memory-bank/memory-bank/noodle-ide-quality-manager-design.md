# Noodle IDE - Quality Manager Design

## Doel
De Quality Manager is een speciale agent binnen de Noodle IDE die zorgt voor:
- Consistente **stijl en conventies** in alle Noodle-projecten.
- Bewaking van **architectuurregels** binnen de taal.
- Ondersteuning bij **transitie van Python naar Noodle Bytecode (NBC)**.
- Post-processing en **optimalisatie van AI-gegenereerde code**.

---

## Kernconcepten

### 1. Style & Convention Enforcer
- Zorgt dat alle code dezelfde afspraken volgt:
  - Naamconventies (bijv. PascalCase voor types, snake_case voor functies).
  - Indentatie en format.
  - Bestandsindeling en importstructuur.
- Voert automatische correcties uit of genereert voorstellen (diff).

### 2. Architectuur Bewaker
- Houdt in de gaten dat modules en nodes de **Noodle architectuurprincipes** volgen.
- Voorbeelden:
  - Elke node heeft een duidelijke input-output graph.
  - Geen inconsistenties in module hiërarchie.
  - Documentatie en metadata aanwezig.

### 3. AI Output Normalizer
- AI’s kunnen inconsistent schrijven.
- Quality Manager herschrijft AI-output zodat deze:
  - Volledig in lijn is met de style guide.
  - Geen afwijkende structuren introduceert.
  - Gemakkelijker te onderhouden blijft.

---

## Python → NBC Transitie

### Context
Bij de migratie van Python-code naar Noodle Bytecode (NBC) kan veel ruis en inconsistentie ontstaan.
De Quality Manager speelt hier een sleutelrol in.

### Taken
1. **Controle op mapping**
   - Checkt of Python constructs correct vertaald zijn naar NBC-nodes.
   - Corrigeert waar nodig de node-indeling.

2. **Consistentie-check**
   - NBC-output volgt dezelfde naamgeving en stijlregels als handgeschreven Noodle-code.
   - Voorkomt dat Python-achtige patronen direct worden overgenomen.

3. **Optimalisatie**
   - Verwijdert redundante nodes of dode code.
   - Herschrijft control flow naar efficiëntere graph-structuren.
   - Simplificeert expressies.

4. **Review & Diff**
   - Toont verschillen tussen ruwe NBC-output en geoptimaliseerde versie.
   - Geeft suggesties of past automatisch aan.

---

## Workflow

1. **Broncode-ingang**
   - Input kan komen van:
     - Handmatige ontwikkeling.
     - AI-codegeneratie.
     - Python → NBC transitie.

2. **Kwaliteitscontrole**
   - Style check.
   - Architectuur check.
   - Python/NBC mapping check (indien van toepassing).

3. **Rapportage**
   - Diff en verbeteringsvoorstellen.
   - Optioneel automatische correctie.

4. **Merge**
   - Geaccepteerde wijzigingen worden toegevoegd aan de hoofdprojectstructuur.

---

## Toekomstige uitbreidingen
- **Configuratieprofielen**: verschillende style guides per project of module.
- **Zelflerende optimalisatie**: Quality Manager kan patronen herkennen en suggesties doen voor betere NBC-constructies.
- **Integratie met CI/CD**: automatische kwaliteitsbewaking bij builds en releases.

---

## Samenvatting
De Quality Manager:
- Houdt de codebase van Noodle consistent en onderhoudbaar.
- Corrigeert AI-output naar uniforme standaarden.
- Begeleidt de transitie van Python naar NBC met checks, optimalisaties en stijlhandhaving.
- Werkt als een geïntegreerde kwaliteitslaag binnen de Noodle IDE.
