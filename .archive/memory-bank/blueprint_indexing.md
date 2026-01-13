# Noodle Indexing Blueprint

## 🎯 Doel
Indexering is een kernonderdeel van Noodle. Het zorgt ervoor dat variabelen, functies, taken, data en AI-modules snel en efficiënt teruggevonden en uitgevoerd kunnen worden. Dit maakt Noodle sneller, schaalbaarder en beter geschikt voor AI en gedistribueerde systemen.

---

## 🔹 1. Symbol Index (Compiler & Runtime)
- Houdt bij waar variabelen, functies, modules gedefinieerd zijn.
- Datastructuren:
  - Hashmap voor variabelen → O(1) lookup.
  - Trie voor namespaces → snelle hiërarchische toegang.
- Voordelen:
  - Snellere executie.
  - Minder dynamische overhead dan Python.

---

## 🔹 2. Task Index (Execution Layer)
- Houdt bij welke taken actief zijn en waar ze moeten draaien.
- Datastructuren:
  - Task Table: ID, status, prioriteit, afhankelijkheden.
  - Worker Registry: beschikbare threads, cores, devices.
- Scheduler gebruikt de index om taken direct aan workers te koppelen.
- Voordelen:
  - Automatisch multithreaded en parallel.
  - Eenvoudige schaalbaarheid naar GPU of meerdere cores.

---

## 🔹 3. Data Index (Memory & Storage)
- Houdt bij waar objecten staan: RAM, VRAM, disk of remote.
- Datastructuren:
  - Object Index: ID → geheugenlocatie.
  - Cache Index: check of resultaten al berekend zijn.
  - Garbage Map: bepaalt wat kan worden opgeruimd.
- Voordelen:
  - Supersnelle data-toegang.
  - Slim geheugenbeheer voor GPU/CPU samen.

---

## 🔹 4. Distributed Index (Multi-PC & Hardware Types)
- Zorgt dat meerdere computers samenwerken alsof het één systeem is.
- Datastructuren:
  - Distributed Hash Table (DHT): waar staat welke data?
  - Consensus Layer (Raft/Paxos): houdt index consistent.
  - Latency Index: kiest snelste node voor data-toegang.
- Voordelen:
  - Schaalbaar van 1 laptop tot een cluster.
  - Maximale hardwarebenutting, inclusief heterogene hardware.

---

## 🔹 5. Knowledge Index (AI & Libraries)
- Houdt bij welke AI-modellen en libraries beschikbaar zijn.
- Datastructuren:
  - Model Catalogus: lijst van AI-modellen (CPU/GPU/TPU).
  - Library Index: Python, C, CUDA of Noodle-native.
  - Semantic Index: betekenis-gebaseerd zoeken (“matrix inversion” → juiste functie).
- Voordelen:
  - AI-first design.
  - Ontwikkelaars hoeven niet exact te weten waar iets zit.

---

## 🚀 Roadmap
1. **Fase 1**: Symbol Index + Task Index (lokale snelheid).
2. **Fase 2**: Data Index (beter geheugenbeheer).
3. **Fase 3**: Distributed Index (schalen over meerdere pc’s).
4. **Fase 4**: Knowledge Index (AI-native).

---

## 🔑 Samenvatting
Indexering maakt Noodle:
- Sneller dan Python (minder dynamische lookups).
- Flexibeler dan C/C++ (hardwarebewust).
- Meer schaalbaar dan bestaande talen (distributed ingebakken).
- AI-native (semantic indexing en knowledge base).
