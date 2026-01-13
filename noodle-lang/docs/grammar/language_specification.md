# Noodle Language Specification

# ===========================

## Overview

Noodle is een moderne, AI-native programmeertaal ontworpen voor high-performance distributed computing. Deze specificatie definieert de syntax, semantiek, en runtime gedrag van de taal.

## Lexicale Structuur

### Tokens

Noodle gebruikt de volgende token types:

#### Literale Tokens

- **IDENTIFIER**: Variabelen, functienamen, klassenamen
- **NUMBER**: Numerieke waarden (integer en floating-point)
- **STRING**: Tekstuele waarden tussen dubbele quotes
- **BOOLEAN**: `true` of `false` waarden

#### Operatoren

- **Rekenkundig**: `+`, `-`, `*`, `/`, `%`, `**`
- **Vergelijking**: `==`, `!=`, `<`, `<=`, `>=`, `>`, `<`
- **Logisch**: `&&`, `||`, `!`

#### Toewijzing

- `=`: Variabelen toewijzing
- `+=`, `-=`, `*=`, `/=`, `%=`: Samengevoegde toewijzing

#### Scheidingstekens

- `,`: Parameter scheiding
- `;`: Statement einde
- `:`: Type annotatie
- `.`: Member access
- `(`, `)`: Expressie groepering
- `{`, `}`: Blok scheiding

#### Structuur

- `[`, `]`: Array/literal indexing
- `.`: Property/method access

#### Keywords

`if`, `else`, `elif`, `while`, `for`, `function`, `return`, `class`, `import`, `extends`

## Grammatica Regels

### Variabelen en Types

```noodle
# Variabele declaratie met type
naam: Type = waarde
naam: Type = initiele_waarde

# Type inferentie
resultaat = expressie  # Type wordt afgeleid uit context
```

### Functies

```noodle
# Functie definitie
function functienaam(param1: Type1, param2: Type2) -> ReturnType:
    # Function body
    return resultaat

# Lambda functies
lambda (x, y) => x + y

# Methoden met type parameters
object.methode(param: String): Number
```

### Control Flow

```noodle
# Conditionele structuren
if voorwaarde:
    # Code als waar is
elif andere_voorwaarde:
    # Code als andere voorwaarde waar is
else:
    # Code als geen enkele voorwaarde waar is

# Lussen
for item in collectie:
    # Iteratie code

# Range-based for
for i in range(0, 10):
    # Gebruik range iterator
```

### Datastructuren

```noodle
# Arrays/Literals
lijst = [1, 2, 3]
objecten = {key1: "waarde1", key2: "waarde2"}

# Pattern matching
match waarde:
    case patroon1:
        # Code voor patroon 1
    case patroon2:
        # Code voor patroon 2
    case _:
        # Default case
```

### Classes en Objecten

```noodle
# Klasse definitie
class KlassenNaam(BaseClass):
    property: Type
    
    def __init__(self, init_param: Type):
        self.property = init_param
    
    def methode(self, param: Type) -> ReturnType:
        # Methode implementatie
        return resultaat

# Inheritance
class AfgeleideKlasse(BasisKlasse):
    additional_property: Type
    
    def override_methode(self) -> ReturnType:
        # Overschrijf basis methode
        return super().methode() + self.additional_property
```

### Modules en Imports

```noodle
# Import statements
import module.naam
from module import specifieke_functie

# Namespace access
module.functie()
module.Klasse.static_methode()
```

### Error Handling

```noodle
# Try-catch blokken
try:
    # Riskante code
except ErrorType as error:
    # Foutafhandeling
    log_error(error.message, error.context)

# Custom exceptions
class CustomError(Exception):
    def __init__(self, message: str, error_code: str = None):
        self.message = message
        self.error_code = error_code
        super().__init__(message)
```

### Asynchrone Programmering

```noodle
# Async functies
async functienaam(param: Type) -> ReturnType:
    await async_operation(param)
    return resultaat

# Async context
async with resource_manager():
    # Resource wordt automatisch beheerd
    await operation()
    # Resource wordt automatisch opgeruimd

# Concurrentie
async def parallel_verwerking():
    taken1 = async_task1()
    taken2 = async_task2()
    resultaten = await asyncio.gather([taken1, taken2])
    return resultaten
```

## Runtime Gedrag

### Actor Model

Noodle ondersteunt een actor-based concurrency model:

```noodle
# Actor definitie
actor ActorNaam:
    state: Dict[str, Any] = {}
    
    async def receive_message(self, message: Message) -> Any:
        # Berichtverwerking
        pass
    
    async def send_message(self, target: str, message: Any) -> bool:
        # Bericht verzenden
        pass
```

### Type Systeem

Noodle gebruikt een progressief type systeem met:

- **Statische Types**: Compile-time type checking
- **Runtime Types**: Dynamische types met inferentie
- **Generic Types**: Type parameters en constraints
- **Union Types**: Meerdere mogelijke types

## Standaardbibliotheek

### Core Functies

- **I/O Operaties**: Bestand lezen/schrijven, netwerk I/O
- **String Processing**: Pattern matching, regular expressions
- **Mathematische Operaties**: Vector en matrix operaties
- **Collecties**: High-performance datastructuren
- **Concurrency**: Async primitives, synchronization

### AI Integratie

- **Type Inferentie**: Automatische type detectie
- **Code Generatie**: AI-ondersteunde optimalisaties
- **Pattern Matching**: Intelligente code transformaties

## Performance Kenmerken

### Compilation

- **Ahead-of-Time (AOT)**: Statische compilatie
- **Just-in-Time (JIT)**: Runtime optimalisatie
- **Bytecode Generatie**: Efficiënte instructies

### Runtime Optimalisaties

- **Memory Management**: Regio-based geheugenallocatie
- **Garbage Collection**: Automatisch opruimen
- **Instruction Caching**: Veelgebruikte operaties cachen
- **Vectorisatie**: SIMD instructies waar mogelijk

## Best Practices

### Code Stijl

- **Leesbaarheid**: Duidelijke, zelfdocumenterende code
- **Modulariteit**: Losgekoppelde componenten
- **Testbaarheid**: Unit en integratie tests
- **Performance**: Efficiënte algoritmes en datastructuren

### Veiligheid

- **Type Safety**: Sterke type checking
- **Memory Safety**: Geen buffer overflows of use-after-free
- **Input Validatie**: Alle externe input valideren

---

*Specificatie versie: 1.0*  
*Laatst bijgewerkt: 23 November 2025*  
*Auteur: Noodle Language Development Team*
