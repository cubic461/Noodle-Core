# Beslissing 001: Noodle IDE als Gescheiden Project / Repository

**Datum:** 10 september 2025
**Status:** Goedgekeurd
**Betreft:** Scheiding tussen Noodle Core en Noodle IDE in afzonderlijke repositories

---

## 🎯 Probleemstelling

De behoefte aan een duidelijke scheiding tussen de **Noodle Core** (runtime en interpreter) en de **ontwikkelomgeving (IDE)**. Dit促进s modulariteit, onafhankelijke releases, en optimaliseert de ontwikkelcyclus voor zowel de taal als de tooling.

---

## 📋 Overwegingen

### 1. Modulariteit en Onderhoudbaarheid
- **Noodle Core** richt zich op essentiële runtime-functionaliteit: interpreter, dataflow-engine, bestandsbeheer, worker-interface.
- **Noodle IDE** richt zich op de developer experience: UI, Monaco editor, AI-assistentie, project management.

Een gescheiden architecture voorkomt dat runtime-code en UI-afhankelijkheden elkaar in de weg zitten.

### 2. Onafhankelijke Releases
- Core kan onafhankelijk evolueren zonder dat de UI-permanent moet worden bijgewerkt.
- De IDE kan sneller nieuwe UI/UX-functies of AI-integraties toevoegen, gebaseerd op stabiele Core API’s.

### 3. Technologiekeuze
- **Noodle Core**: Gedeeltelijk gebaseerd op Python (/runtime/nbc_runtime), mogelijk in combinatie met Rust voor prestatiekritieke componenten (NBC, MLIR).
- **Noodle IDE**: Vertrouwt op web-technologieën (Tauri/Electron + Monaco editor) voor cross-platform bereik.

### 4. Rollen en Teamindeling
- Ontwikkelaars kunnen zich specialiseren op Core of IDE, met gekoppelde expertise (API-ontwerp aan Core zijde, integratie aan IDE zijde).
- Draagt bij aan diverse workflows en snellere iteratie in beide domeinen.

---

## 🛠️ Technische Aanpak

### Bestandsorganisatie
- **Noodle Core (noodle-dev/)**: Blijft de primaire repository voor runtime, taalcompiler, database-integratie, en extensie-API’s.
- **Noodle IDE (noodle-ide/)**: Nieuwe repository voor de Tauri + IDE-front-end, met integratiepunten naar Noodle Core.

### Communicatie en Integratiepunten
- **API-overbrugging**: De IDE communiceert via een gestandaardiseerde API (bijv. JSON over IPC,stdio, of HTTP) met Core:
  - Bestandsbeheer (lezen/schrijven Noodle scripts)
  - Taal-specifieke commando’s (run, debug, inspect workers)
  - Logging en real-time output
- **Filesystem-node als centraal hubs** (zoals beschreven in IDE roadmap): Voldoen aan Core API-consistentie, gebruikt door zowel Core als IDE.
- **Modules/Gateway**: Volg de geplande uitbreiding van Core met API voor IDE-integratie (Fase 2).

### Testing en Kwaliteitsborging
- Integratietests tussen IDE en Core via lokale API-emulatie of CI/CD-pipelines die beide repositories verbinden.
- Simpele Noodle-scripts worden gebruikt als “canaries” binnen IDE-tests.

---

## Risico's en Mitigatie

| Risico | Mitigatie |
|--------|-----------|
| **API-inconsisties bij Core-update** | Vaste API-contracten, versiebeheer van Core API, gedocumenteerde breaking changes. |
| **Trage synchronisatie tussen Core en IDE** | DevOps-pijplijnen voor automatische tests na elke Core-change; gebruik van semver voor releases. |
| **UI/ UX verzwakt door Core-abstractie** | Bied voldoende API-abstractie in Core zonder te veel details, close samenwerking tussen Core & IDE teams. |
| **Resource-duplicatie (setup, documentatie)** | Gedeelde CI, tools en best practices tussen repositories, cross-referenties voor documentatie. |

---

## 📅 Next Steps

1. **Nieuwe repository aanmaken:** Git repo voor `noodle-ide`, parallel aan `noodle-core`.
2. **API-first ontwikkeling:** Definieer and implementeer minimale Core API voor IDE-integratie (Fase 2) vóór intensieve IDE-ontwikkeling.
3. **IDE-opzet met Tauri:** Initialiseer project, maak basis UI met Monaco editor (zie Fase 3 van IDE-roadmap).
4. **Continuous Integration:** Configureer workflows die Core en IDE-builds testen samen.
5. **Onderhoud strategy:** Maak bij elke Core-release mechanismen beschikbaar voor IDE-teame om snel te reageren op API-changes.

---

## 🧠 Relatie met Bijdere Roadmaps

- **Fase 2 (Noodle Core):** Logging en API voor IDE-integratie, en Worker-integratie moeten prioritair worden gezet.
- **Fase 3-4 (Noodle IDE):** Focus op stabiele verbinding met Core API en AI-geassisteerde workflows.
- **Fase 5 (Dogfooding):** IDE als primaire ontwikkelomgeving (onmogelijk zonder stabiele Core↔IDE integratie).

---

**Beslissing:** Ga door met scheiding van Noodle Core en IDE in aparte repositories met een strikte API-overbrugging. Documenteer alle API-changes zorgvuldig en bouw CI-hulpmiddelen voor geïntegreerde releases.
