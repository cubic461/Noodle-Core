# Pseudocode voor Linting/Formatting Regels (Quality Manager)

## Introductie
Dit document bevat een eerste set van controle- en correctieregels in pseudocode voor de Quality Manager. Deze regels kunnen door de verschillende componenten worden geïmplementeerd om code te analyseren en te corrigeren volgens de Noodle Style Guide.

---

## 1. StyleEnforcer Regels

### Naamgeving
```python
// Functiecontrole
FUNCTION check_function_naming(function_name):
    IF NOT function_name.matches(r'^[a-z_][a-z0-9_]*$'): // snake_case
        RETURN ERROR "Functienaam moet snake_case zijn: " + function_name
    RETURN OK

// Klascontrole
FUNCTION check_class_naming(class_name):
    IF NOT class_name.matches(r'^[A-Z][a-zA-Z0-9]*$'): // PascalCase
        RETURN ERROR "Klasnaam moet PascalCase zijn: " + class_name
    RETURN OK

// Variabelecontrole
FUNCTION check_variable_naming(variable_name):
    IF NOT variable_name.matches(r'^[a-z_][a-z0-9_]*$'): // snake_case
        RETURN ERROR "Variabele moet snake_case zijn: " + variable_name
    RETURN OK

// Constantencontrole
FUNCTION check_constant_naming(constant_name):
    IF NOT constant_name.matches(r'^[A-Z][A-Z0-9_]*$'): // UPPER_SNAKE_CASE
        RETURN ERROR "Constante moet UPPER_SNAKE_CASE zijn: " + constant_name
    RETURN OK
```

### Indentatie & Layout
```python
// Indentatiecontrole
FUNCTION check_indentation(file_content):
    lines = file_content.split('\n')
    FOR EACH line IN lines:
        IF line CONTAINS '\t': // Tab gevonden
            RETURN ERROR "Gebruik 4 spaties in plaats van tabs: " + line
        IF line CONTAINS '    ': // 4 spaties
            CONTINUE // Correct
        // Andere indentatie niveaus (0, 8, etc.) kunnen ook correct zijn, afhankelijk van context
        // Hier zou een meer geavanceerde AST-gebaseerde analyse nodig zijn
    RETURN OK

// Regelbreedte controle
FUNCTION check_line_length(file_content):
    lines = file_content.split('\n')
    FOR EACH line IN lines:
        IF line.length > 100:
            RETURN WARNING "Regel te lang (> 100 tekens): " + line
    RETURN OK
```

### Bestandsindeling
```python
// Importvolgorde controle
FUNCTION check_import_order(file_content):
    lines = file_content.split('\n')
    imports_found = []
    non_imports_found = []
    IN state = "searching_for_imports"
    FOR EACH line IN lines:
        IF line.trim().startswith("IMPORT"):
            IF state == "non_imports_found":
                RETURN ERROR "Imports moeten bovenaan het bestand staan: " + line
            imports_found.append(line)
        ELSE IF line.trim() != "":
            state = "non_imports_found"
            non_imports_found.append(line)
    RETURN OK
```

### Documentatie
```python
// Docstringcontrole voor functies
FUNCTION check_function_docstring(function_node):
    IF function_node.parameters.exists(param => param.documentation is missing):
        RETURN ERROR "Parameter '" + param.name + "' mist documentatie"
    IF function_node.return_type.exists AND function_node.return_type.documentation is missing:
        RETURN ERROR "Return type mist documentatie"
    IF function_node.description is missing OR function_node.description == "":
        RETURN ERROR "Functie mist beschrijvende docstring"
    RETURN OK

// Docstringcontrole voor klassen
FUNCTION check_class_docstring(class_node):
    IF class_node.description is missing OR class_node.description == "":
        RETURN ERROR "Klas mist beschrijvende docstring"
    RETURN OK
```

---

## 2. ArchitectureWatcher Regels

### Node Input-Output Graph
```python
// Controleer of elke node een duidelijke input-output heeft
FUNCTION check_node_io_graph(node):
    IF node.inputs is empty AND node.outputs is empty:
        RETURN WARNING "Node heeft geen input of output: " + node.name
    IF node.input_connections is empty AND NOT node.is_source_node:
        RETURN ERROR "Node heeft geen input connecties: " + node.name
    IF node.output_connections is empty AND NOT node.is_sink_node:
        RETURN WARNING "Node heeft geen output connecties: " + node.name
    RETURN OK
```

### Module Hiërarchie
```python
// Controleer op inconsistenties in module hiërarchie
FUNCTION check_module_hierarchy(module):
    FOR EACH dependency IN module.dependencies:
        IF NOT dependency.exists_in_project:
            RETURN ERROR "Moduleafhankelijkheid bestaat niet: " + dependency.name
        IF dependency.version.is_not_compatible(module.required_version_of_dependency):
            RETURN ERROR "Incompatibele versie van module: " + dependency.name
    RETURN OK
```

---

## 3. AIOutputNormalizer Regels

### Consistentie met Style Guide
```python
// Normaliseer AI-gegenereerde code naar stijlgids
FUNCTION normalize_ai_code(raw_code):
    normalized_code = raw_code

    // Pas naamgevingsconventies toe
    normalized_code = apply_naming_conventions(normalized_code)

    // Pas indentatie toe
    normalized_code = apply_indentation(normalized_code)

    // Verwijder Python-achtige constructies indien van toepassing op NBC
    IF target_format == "NBC":
        normalized_code = convert_python_constructs_to_nbc(normalized_code)

    // Optimaliseer expressies
    normalized_code = simplify_expressions(normalized_code)

    RETURN normalized_code
```

### Verwijder Redundantie
```python
// Verwijder redundante codeblokken
FUNCTION remove_redundant_blocks(code):
    // Zoek naar dubbele functie-definities
    IF code.duplicate_function_definitions.exists:
        RETURN ERROR "Dubbele functie-definities gevonden"

    // Zoek naar ongebruikte variabelen (vereist flow analysis)
    unused_vars = find_unused_variables(code)
    FOR var IN unused_vars:
        code = code.remove_variable(var)

    RETURN code
```

---

## 4. PythonNBCTransitioner Regels

### Controle op Mapping
```python
// Controleer of Python constructs correct vertaald zijn naar NBC
FUNCTION check_python_to_nbc_mapping(python_construct, nbc_node):
    IF python_construct.type == "function_definition":
        IF NOT nbc_node.type == "function_node":
            RETURN ERROR "Python-functie niet correct gemapt naar NBC-functie-node"
    // ... meer mapping controles
    RETURN OK
```

### Consistentie-check
```python
// Zorg ervoor dat NBC-output consistent is met handgeschreven Noodle-code
FUNCTION check_nbc_consistency(nbc_code, project_style_guide):
    // Pas style guide regels toe op NBC-code
    violations = apply_style_rules(nbc_code, project_style_guide)
    IF violations is not empty:
        RETURN "NBC-code voldoet niet aan stijlgids: " + violations
    RETURN OK
```

### Optimalisatie
```python
// Optimaliseer NBC-code
FUNCTION optimize_nbc_code(nbc_code):
    // Verwijder dode code
    optimized_code = remove_dead_code(nbc_code)

    // Herschrijf control flow
    optimized_code = rewrite_control_flow(optimized_code)

    // Simplificeer expressies
    optimized_code = simplify_exbc_expressions(optimized_code)

    RETURN optimized_code
```

---

## 5. Algemene Hulpfuncties

```python
// Pas naamgevingsconventies toe op een blok code
FUNCTION apply_naming_conventions(code_block):
    // Regex voor functies
    code_block = regex_replace(code_block, r'def\s+([a-z0-9_]+)\s*\(', 'def \1(') // Zorg voor snake_case

    // Regex voor klassen
    code_block = regex_replace(code_block, r'class\s+([A-Z][a-zA-Z0-9]*)\s*:', 'class \1:')

    // ... meer regexes voor andere constructies
    RETURN code_block

// Pas indentatie toe
FUNCTION apply_indentation(code_block):
    lines = code_block.split('\n')
    indented_lines = []
    indent_level = 0
    FOR EACH line IN lines:
        stripped_line = line.strip()
        IF stripped_line.startswith("}"): // Sluit een blok (NBC-specifiek of algemeen)
            indent_level = max(0, indent_level - 1)
        indented_lines.add("    " * indent_level + stripped_line)
        IF stripped_line.endswith("{"): // Open een blok
            indent_level = indent_level + 1
    RETURN '\n'.join(indented_lines)

// Converteer Python-specifieke constructies naar NBC
FUNCTION convert_python_constructs_to_nbc(code):
    // Voorbeeld: `if-elif-else` naar `if-jump_if_false-label`
    // Dit vereist een goede parser en transpiler

    // Converteer `for` loops
    // Converteer `while` loops
    // Converteer try-except blokken

    RETURN converted_code
```

---

## Conclusie
Deze pseudocode biedt een startpunt voor de implementatie van de Quality Manager's linting- en formattingfunctionaliteit. Deze regels zullen verder verfijnd moeten worden naarmate de syntaxis en semantiek van de Noodle-taal verder worden uitgewerkt.
