# Intent → Optimal Execution Architectuurvoorstel voor Noodle

## Overzicht
Deze extensie breidt de semantische intent-translation uit met een runtime Optimal Execution Engine (OEE) die automatically de meest efficiënte uitvoeringsvorm kiest, gebaseerd op intent-herkenning. Programmeurs kunnen simpele code schrijven; Noodle handelt optimalisaties af, met fallback en controle-opties.

## 1. Intent Layer
Doel: Herkennen van programmeur's intent uit code, onafhankelijk van syntax.

- Intent Recognizer (extensie op compiler/parser.py): Analyseert AST om intent-trees te extraheren (bijv. naïeve loop → "aggregate_sum(numbers)").
- Patterns: Herkent patronen zoals loops voor sums, matrix ops voor laadsommming, etc.
- Integration: Bouwt op semantic_intent_translation_plan.md voor externe code patterns.

## 2. Optimal Execution Engine (OEE)
Doel: Vertaalt intent naar de beste implementatie, met benchmarks en fallback.

- Vertaal intent naar variants: CPU (serial), SIMD, GPU (via NBC opcodes), distributed (via cluster_manager.py).
- Auto-switch: Gebruik usage logs uit PerformanceMonitor om de beste te kiezen.
- Benchmarking: Run side-by-side; kies variant met laagste latency/memory, highest speedup.
- Integration: Uitbreiding op NBC-runtime (nbc_runtime/execution/optimizer.py) voor hot paths.

## 3. Modes
- **Safe Mode** (default): Executeert code exact zoals geschreven, maar logt betere alternatieven. IDE toont hints (bijv. "Snellere parallel_sum beschikbaar").
- **Optimized Mode**: Auto-optimalisatie; schakelt transparant over (bijv. loop → parallel_sum).
- **Explicit Mode**: No-optimize; gebruik @no_optimize decorator of !raw block om exact execution af te dwingen.
  - Voorbeeld:
    ```
    @no_optimize
    total = 0
    for i in numbers:
        total += i
    ```
    Dit voorkomt OEE voor debugging of specifieke gevallen.

## 4. IDE Feedback Loop
- LSP-extensie: Integreer met lsp/server.py voor realtime hints (via LSP diagnostics).
- Visualizer: Toon before/after in editor (bijv. "Naïeve loop → parallel kernel (18x sneller)").
- Toggle: Schakel modes per project/file in IDE settings.
- Integration: Voeg toe aan noodle-ide-roadmap.md in LSP plugin.

## 5. Zelflerend Systtem
- Logs: Track usage en performance in PerformanceMonitor; update registry in ai_orchestrator.
- Learning: Gebruik LLM (via workflow_engine.py) om nieuwe patterns te leren en optimalisaties te suggereren.
- Uncertainty: Als intent ambigu, fallback naar safe en vraag user input via IDE.
- Integration: Breid self_updating_mechanism_design.md uit met OEE logs.

## 6. Voorbeeld Workflow
1. Programmeur schrijft naïeve loop:
   ```
   total = 0
   for i in numbers:
       total += i
   ```
2. Intent Recognizer: Bepaalt "aggregate_sum(numbers)".
3. OEE: Kiest optimal variant (bijv. parallel_sum via NBC SIMD).
4. Execution: Run optimized; log speedup.
5. IDE: Hint toont speedup; user kan toggle.
6. Learning: Als succesvol, voeg toe aan registry voor future use.

## 7. Benefits
- Beginners: Simpele code, gratis performance.
- Experts: Expliciete controle via modes/decorator.
- Noodle: Groeit via learned patterns; uniek in intent-based execution.

## 8. Risks & Mitigations
- Verkeerde intent: Fallback naar exact code; IDE warnings.
- Overhead: Alleen optimaliseer voor herkende intents; benchmark threshold.
- Complexity: Start with simple patterns (sums, loops); iterate.

## Next Steps in ACT MODE
- Implementeer Intent Recognizer in compiler.
- Add OEE in runtime/optimization/oee.py.
- Extend LSP for hints (in IDE).
