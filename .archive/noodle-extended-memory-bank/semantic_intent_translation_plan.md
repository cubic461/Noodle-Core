# Semantic Intent Translation Plan for Noodle

## Context
Het Noodle-project wil een semantische vertaal-laag ontwikkelen die externe code (bijvoorbeeld Python, JavaScript, TypeScript) niet letterlijk vertaalt, maar de bedoeling (intent) van functies/methodes herkent en omzet naar Noodle-native constructen. Dit maakt Noodle robuuster, sneller en toekomstbestendig.

Dit bouwt voort op de bestaande ALE (Adaptive Library Evolution) en Python transpiler, door AST-analyse te upgraden naar intent-herkenning. Het integreert met de Global Registry in ALE voor mapping-tabels en self-improvement, en richt zich op performance-optimalisaties via NBC-runtime.

## Doelen
Interpreterlaag bouwen (ALE uitbreiding):
- Scripts in Python/JS/TS analyseren.
- Niet de syntaxis 1-op-1 omzetten, maar de semantiek (wat bedoelt de code?).
- Herkennen van patronen zoals numpy.dot, pandas.groupby().sum(), math.sqrt.

Intent-mapping tabel:
- Elke externe functie → een intent (abstracte betekenis).
- Voorbeeld: numpy.dot → matrix_multiplication; pandas.groupby+sum → dataframe_group_sum; math.sqrt → square_root.

Intent → Noodle-kern mapping:
- Elke intent moet worden gemapt op een Noodle-native primitive.
- Als die nog niet bestaat → maak een tijdelijke wrapper.
- Als intent vaak voorkomt → optimaliseer en vervang wrapper met native kernel.

Zelfverbeterend systeem:
- Logging van intent usage.
- Monitor prestaties.
- Automatisch genereren en uitwisselen van snellere Noodle-native optimalisaties.

**Optimal Execution Extension**: Uitbreiding van intent-herkenning naar runtime-optimalisatie. Herken programmeur's intent (bijv. loop → aggregate_sum) en schakel automatisch naar meest efficiënte implementatie (SIMD/GPU/distributed).

**Werking**:
- Intent Recognizer in compiler/parser.py: Extract intent trees (abstracte representatie, bijv. naïeve loop → "aggregate_sum(numbers)").
- Optimal Execution Engine (OEE): Vertaal intent naar beste variant (CPU, GPU via NBC opcodes; fallback naar originele code).
- Modes: Safe (exact execution + IDE hints), Optimized (auto-optimalisatie), Explicit (no-optimize via @no_optimize of !raw blocks).
- IDE Feedback: LSP-hints in VS Code voor optimalisaties (bijv. "Je loop is vervangen door parallel_sum (18x sneller)").

**Benefits**: Programmeurs schrijven simpele code; Noodle optimaliseert onderwater. Zelflerend via usage logs in PerformanceMonitor.

## Implementatiestappen
Proof of Concept (Python focus):
- Maak een intent_mapper.py die Python AST doorloopt en intents genereert. (Plaats in noodle-dev/transpiler/python/)
- Bouw een kleine mapping-tabel voor NumPy en Pandas. (Integreer met adapters/ in transpiler)
- Genereer Noodle IR (intermediate representation) op basis van intents. (Uitbreiding op translator.py)

Noodle-native implementaties:
- Voor matrix_multiplication, square_root, dataframe_group_sum implementaties in NBC-runtime maken. (Uitbreid matrix_ops.py en mathematical_objects.py)
- Benchmarks draaien om snelheidsverschillen te tonen. (Gebruik performance_benchmark.py)

ALE Integratie:
- Intent layer koppelen aan de bestaande Adaptive Library Engine. (Update transpiler_ai.py en replacement_manager.py)
- Zorgen dat wrappers automatisch native kernels vervangen als er optimalisaties beschikbaar zijn. (Via Benchmark/Validator in ALE)

Cross-language uitbreidingen:
- Na Python ook intent mappers maken voor JavaScript en TypeScript. (js_bridge.py uitbreiden)
- Andere talen als optionele uitbreiding.

## Voorbeeld
Python input:

import numpy as np
A = np.random.rand(1000, 1000)
B = np.random.rand(1000, 1000)
C = np.dot(A, B)

Intent IR:

[
  { "intent": "matrix_random", "args": [1000, 1000], "var": "A" },
  { "intent": "matrix_random", "args": [1000, 1000], "var": "B" },
  { "intent": "matrix_multiplication", "args": ["A", "B"], "var": "C" }
]

Noodle output:

A = Matrix.random(1000, 1000)
B = Matrix.random(1000, 1000)
C = A ⨯ B

Voorbeeld OEE:

Programmeur code (naïeve loop):
```
total = 0
for i in numbers:
    total += i
```

Intent: aggregate_sum(numbers)

Optimalized:
```
total = numbers.parallel_sum()
```
Met IDE hint: "Je loop is vervangen door parallel_sum (18x sneller)".

## Verwachte Resultaten
✅ Robuust systeem dat versieverschillen in externe libs negeert.

✅ Noodle groeit dynamisch: elke keer dat een intent wordt gebruikt, kan er een optimalisatie bijkomen.

✅ Snellere prestaties zichtbaar via benchmarks.

✅ Basis voor universele multi-language ondersteuning (Python → JS → TS → …).

## Integration Notes
- **Roadmap.md**: Toegevoegd onder Stap 9 als AI-Specific Enhancement, uitgebreid met OEE.
- **Interop Strategy**: Semantic Intent Mapping toegevoegd aan AI Transpiler; fases bijgewerkt voor POC in Phase 1 en self-improvement in Phase 3.
- **Python Transpiler Roadmap**: Intent-herkenning geïntegreerd in Phase 2; nieuwe Phase 4 voor self-improving layer.
- **Dependencies**: Python AST, esprima voor JS; PerformanceMonitor voor logging; NBC voor kernels.
- **Next Steps in ACT MODE**: Implementeer intent_mapper.py, update adapters, test met NumPy POC, documenteer in examples/.

Status: Plan geïntegreerd in memory-bank; klaar voor code-implementatie.
