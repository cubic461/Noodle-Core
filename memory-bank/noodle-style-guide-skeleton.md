# Noodle Style Guide (Skeleton)

## Doel
Deze style guide definieert de basisregels voor codekwaliteit, consistentie en structuur binnen Noodle-projecten.
De Quality Manager gebruikt deze guide als referentie om code automatisch te controleren en te corrigeren.

---

## 1. Naamgeving

### Bestanden en mappen
- Kleine letters + underscores (`snake_case`).
- Voorbeelden:
  - `parser_core.nb`
  - `virtual_machine/bytecode.nb`

### Klassen / Types
- `PascalCase`.
- Voorbeeld: `ParserCore`, `NodeGraph`.

### Functies / Methoden
- `snake_case`.
- Voorbeeld: `compile_node()`, `resolve_imports()`.

### Variabelen
- `snake_case`.
- Voorbeeld: `instruction_pointer`, `node_queue`.

### Constanten
- `UPPER_CASE_WITH_UNDERSCORES`.
- Voorbeeld: `MAX_STACK_SIZE`, `DEFAULT_TIMEOUT`.

---

## 2. Indentatie & Layout
- Indentatie: **4 spaties**, geen tabs.
- Regelbreedte: max. **100 tekens**.
- Blanco regels:
  - 1 lege regel tussen functies/methoden.
  - 2 lege regels tussen top-level definities (klassen, modules).

---

## 3. Structuur

### Module-indeling
- Imports altijd bovenaan.
- Daarna constants, types, functies, classes.
- `main` of entrypoint altijd onderaan.

### Documentatie
- Elke module start met een korte docstring (doel van de module).
- Elke functie/klasse heeft een docstring met:
  - **Beschrijving**.
  - **Parameters**.
  - **Return waarde**.

### Voorbeeld
```noodle
# parser_core.nb
# Doel: verantwoordelijk voor parsing van broncode naar AST.

CONST MAX_DEPTH = 1024

class ParserCore:
    """
    De ParserCore verwerkt tokens en genereert een AST.
    """

    def parse(tokens):
        """
        Parse tokens naar een AST.

        Args:
            tokens (List[Token]) - de tokenstream
        Returns:
            AST - de abstract syntax tree
        """
        ...
```

---

## 4. Error Handling
- Fouten krijgen duidelijke en consistente namen.
- Gebruik `PascalCaseError`.
- Voorbeeld: `SyntaxError`, `RuntimeError`.

---

## 5. Commentaar
- Inline comments alleen als de code niet vanzelfsprekend is.
- Gebruik `#` gevolgd door 1 spatie.
- Geen "commented-out code" in de repository.

---

## 6. Best Practices
- Kleine, duidelijke functies.
- Geen duplicatie van code (gebruik herbruikbare functies).
- Vermijd magische getallen → gebruik constants.
- Consistente naamgeving in heel de codebase.

---

## 7. NBC Specifiek
- NBC-opcodes altijd `UPPERCASE`.
- Voorbeeld: `LOAD_CONST`, `JUMP_IF_FALSE`.
- NBC-bestanden krijgen extensie `.nbc`.

---

## 8. Testen
- Testbestanden in `tests/` folder.
- Testnamen: `test_<functie_of_module>.nb`.
- Elke test moet self-contained zijn.

---

## Samenvatting
Deze style guide zorgt voor:
- Eenduidige naamgeving.
- Consistente code layout.
- Helderere structuur en documentatie.
- Uniforme NBC-conventies.

---

Deze guide is een **skelet** — genoeg om de eerste checks en correcties te laten draaien.
Later kun je dit uitbreiden met meer specifieke Noodle-regels (bv. graph-nodes, dataflow-patronen).
