# Decision 004: Integration of Semantic Intent Translation as ALE Enhancement

## Datum
2025-09-21

## Achtergrond
De gebruiker heeft een voorstel ingediend voor een semantische vertaal-laag in Noodle om externe code (Python/JS/TS) te vertalen op basis van intent in plaats van letterlijke syntaxis. Dit ondersteunt robuustheid tegen lib-versies en self-improvement via logging/benchmarks.

Relevante context: Bestaande ALE (interop_strategy.md) en Python transpiler (python_transpiler_roadmap.md) bieden al een basis voor AI-gedreven optimalisatie. Het idee sluit aan bij projectdoelen (performance, future-proofing) maar moet iteratief en consistent geïmplementeerd worden per rules.md.

## Alternatieven overwogen
1. **Standalone Feature (Nieuw Subsystem)**: Maak een zelfstandige module los van ALE, met eigen phases voor elke taal.
   - Pros: Geïsoleerd, makkelijk te scheiden.
   - Cons: Duplicatie met ALE's AI Transpiler en Global Registry; verhoogde onderhoudskosten; niet aligned met bestaande self-improving mechanisme.
   - Rating: 2/5 (beperkt herbruikbaar).

2. **Volledige Vervanging van Transpiler**: Herstructureer de gehele Python/JS bridges om altijd intent-based te worden, zonder fallback.
   - Pros: Eenduidige aanpak, potentieel hogere performance.
   - Cons: Risico van te snelle refactoring (veroorzaakt bugs in core runtime); breekt backwards compatibility tijdens MVP-fase. Niet geschikt voor non-semantic patterns (bijv. I/O).
   - Rating: 2/5 (te disruptief zonder POC).

3. **Optionele Tool zonder Core Integratie**: Implementeer als plugin voor transpiler, opt-in via config.
   - Pros: Minimale impact op bestaande code.
   - Cons: Onvoldoende self-improvement; mist diepgang in prestaties; te veel overlap met ALE zonder synergie.
   - Rating: 3/5 (acceptabel maar suboptimal).

## Aangenomen Aanpak
Integreer als enhancement van ALE (interop_strategy.md) en Python transpiler (python_transpiler_roadmap.md):
- **Rationale**: ALE is al ontworpen voor dynamische optimalisatie (logging → AI Transpiler → replacement). Intent-mapping past perfect als geavanceerde stap in AI Transpiler: analyseer AST voor semantiek in plaats van templates.
- **Voordelen**:
  - Hergebruik bestaande componenten (performance_monitor, registry voor mappings).
  - Align met bestaande phases: POC in Phase 1 (Python focus), self-improvement in Phase 3.
  - Voldoet aan principes: Transparantie via memory-bank logs, iteratief (kleine stappen), kwaliteit via fallback (syntax als intent faalt).
  - Synergie met self-improvement: Intent usage logs voeden ALE's replacement manager.
- **Implementatiedetails**:
  - Intent_layer: intent_mapper.py in transpiler/python/, integreer met existing AST in translator.py.
  - Mapping-tabel: Extend Global Registry (registry.py) voor intent → primitive mappings.
  - Integration: Update transpiler_ai.py voor intent-IR; benchmarks in performance/ dir.
  - Prioriteit: Python POC eerst (gebruikersvoorbeeld), dan cross-language.
  - Updates: Roadmap (Stap 9), interop_strategy (AI Transpiler), python_transpiler_roadmap (Phase 2/4), en nieuw semantic_intent_translation_plan.md. Zie die bestanden voor details.
- **Trade-offs Aangenomen**:
  - Semantisch vs. Syntactisch: Semantisch voor compute-heavy libs (robuust), syntactisch als fallback (simpel).
  - Risk van inaccurate intent: Mitigeren met validatie in ALE's Benchmark/Validator; rating 4/5 voor core, verwacht 90% accuracy via patterns.

## Impact
- Opbouwend op bestaande werk: Geen grote refactors; hergebruik 70% van interop code.
- Time Estimate: +2-3 weken aan Phase 2 van ALE.
- Metrics for Success: 95% intent recognition rate voor NumPy/Pandas pilots; documentatie consistentie.
- Volgende Stappen: Implementeer POC in ACT MODE; rol Architect blijft verantwoordelijk voor verdere extensies.

## Alternatieven Afgewezen met Rating
- Standalone: 2/5 (duplicatie).
- Volledige Vervanging: 2/5 (disruptief).
- Optionele Tool: 3/5 (te beperkt voor self-improvement).

Dit besluit voldoet aan Definition of Done: Documented, tested (n.v.t.), logged in memory-bank.
