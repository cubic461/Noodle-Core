# Noodle Language Specification v2.0

## Overview

Noodle v2.0 represents a significant evolution of the Noodle programming language, incorporating modern language features while maintaining backward compatibility. This specification documents all language constructs, syntax, and semantics for the enhanced Noodle language.

## Table of Contents

1. [Language Philosophy](#language-philosophy)
2. [Lexical Structure](#lexical-structure)
3. [Types and Type System](#types-and-type-system)
4. [Expressions and Statements](#expressions-and-statements)
5. [Control Flow](#control-flow)
6. [Functions and Methods](#functions-and-methods)
7. [Pattern Matching](#pattern-matching)
8. [Generic Types](#generic-types)
9. [Async/Await](#asyncawait)
10. [Modern Collections](#modern-collections)
11. [Enhanced I/O Abstractions](#enhanced-io-abstractions)
12. [Error Handling](#error-handling)
13. [Modules and Packages](#modules-and-packages)
14. [Memory Management](#memory-management)
15. [Standard Library](#standard-library)

## Language Philosophy

Noodle v2.0 is designed with the following principles:

- **Simplicity**: Clean, readable syntax that minimizes boilerplate
- **Expressiveness**: Powerful abstractions for common programming patterns
- **Type Safety**: Strong static typing with type inference
- **Performance**: Efficient compilation and runtime execution
- **Modularity**: Clear separation of concerns and reusable components
- **Modern Features**: Contemporary language capabilities for productive development

## Lexical Structure

### Source Code Encoding

Noodle source files use UTF-8 encoding by default.

### Whitespace

Spaces, tabs, and newlines are used as whitespace. Newlines separate statements, and indentation is used for block structure.

### Comments

```noodle
// Single-line comment
/* Multi-line comment */
```

### Identifiers

Identifiers start with a letter or underscore, followed by letters, digits, or underscores:

```noodle
validIdentifier
_privateVariable
function123
CONSTANT_VALUE
```

### Keywords

Noodle v2.0 includes the following reserved keywords:

**Control Flow**: `if`, `else`, `elif`, `while`, `for`, `in`, `break`, `continue`, `return`, `yield`, `async`, `await`

**Type System**: `type`, `interface`, `implements`, `extends`, `enum`, `struct`, `class`, `trait`, `where`

**Pattern Matching**: `match`, `case`, `when`, `is`, `as`

**Generic Types**: `List`, `Map`, `Set`, `Stream`, `Option`, `Result`

**Collections**: `map`, `filter`, `reduce`, `fold`, `collect`, `pipe`

**I/O Operations**: `File`, `open`, `read`, `write`, `close`, `HTTP`, `request`, `response`, `socket`, `connect`, `listen`, `accept`, `send`, `receive`

**Resource Management**: `with`, `try`, `catch`, `finally`, `throw`, `throws`

**Modularity**: `import`, `export`, `module`, `package`, `as`, `from`

**Other**: `true`, `false`, `null`, `self`, `super`, `new`, `delete`

### Literals

**String Literals**:

```noodle
"Hello, World!"
'Single quoted string'
`Template string with ${expression}`
```

**Number Literals**:

```noodle
42           // Integer
3.14159      // Float
1.23e-4      // Scientific notation
0xFF           // Hexadecimal
0b1010        // Binary
```

**Boolean Literals**:

```noodle
true
false
```

**Null Literal**:

```noodle
null
```

**Collection Literals**:

```noodle
[1, 2, 3, 4, 5]                    // List
{"key": "value", "count": 42}            // Map
{1, 2, 3, 4, 5}                    // Set
```

## Types and Type System

### Basic Types

```noodle
int         // 64-bit signed integer
float       // 64-bit floating point
bool        // Boolean value
string      // UTF-8 string
char        // Unicode character
bytes       // Byte array
void        // No return value
```

### Collection Types

```noodle
List<T>      // Ordered collection of T
Map<K, V>     // Key-value mapping from K to V
Set<T>       // Unordered collection of unique T
Stream<T>     // Async sequence of T
Option<T>     // Optional value of T
Result<T, E>  // Result of type T or error E
```

### Function Types

```noodle
(T) -> R              // Function from T to R
(T, U) -> V           // Function from T and U to V
async (T) -> R         // Async function from T to R
(T) throws E -> R       // Function that may throw E
```

### Custom Types

```noodle
// Struct definition
struct Person {
    name: string
    age: int
    email?: string      // Optional field
}

// Interface definition
interface Drawable {
    draw(context: Canvas): void
    getBounds(): Rectangle
}

// Enum definition
enum Color {
    Red
    Green
    Blue
    Custom(hex: int)
}

// Class definition
class Animal {
    name: string
    
    constructor(name: string) {
        self.name = name
    }
    
    virtual makeSound(): string
}
```

### Type Inference

Noodle supports type inference for local variables:

```noodle
// Type inferred as int
count = 42

// Type inferred as string
message = "Hello"

// Type inferred as List<int>
numbers = [1, 2, 3, 4, 5]
```

## Expressions and Statements

### Variable Declaration

```noodle
// Explicit type
name: string = "Alice"

// Type inference
age = 25

// Constant
const PI: float = 3.14159

// Mutable variable
var counter: int = 0
```

### Assignment

```noodle
// Simple assignment
x = 10

// Destructuring assignment
{name, age} = person

// Spread assignment
{first, ...rest} = items
```

### Arithmetic Expressions

```noodle
result = a + b * c - d / e
remainder = dividend % divisor
power = base ** exponent
```

### Comparison Expressions

```noodle
if (x > y && z <= w) {
    // ...
}

if (name != null && age >= 18) {
    // ...
}
```

### Logical Expressions

```noodle
isValid = x > 0 && x < 100
canProceed = hasPermission || isAdministrator
```

### String Operations

```noodle
greeting = "Hello, " + name
template = "Value: ${calculateValue()}"
substring = text[0:10]
```

## Control Flow

### If Statements

```noodle
if (condition) {
    // then branch
} elif (anotherCondition) {
    // else if branch
} else {
    // else branch
}
```

### While Loops

```noodle
while (condition) {
    // loop body
}

do {
    // loop body
} while (condition)
```

### For Loops

```noodle
// Traditional for loop
for (i = 0; i < 10; i++) {
    // loop body
}

// For-each loop
for (item in collection) {
    // loop body
}

// For-each with destructuring
for (key, value in map) {
    // loop body
}
```

### Break and Continue

```noodle
for (item in items) {
    if (shouldSkip(item)) {
        continue
    }
    
    if (isDone(item)) {
        break
    }
}
```

## Functions and Methods

### Function Definition

```noodle
// Basic function
function add(a: int, b: int): int {
    return a + b
}

// Async function
async function fetchData(url: string): Result<string, Error> {
    // implementation
}

// Function with error handling
function divide(a: float, b: float) throws DivisionError: float {
    if (b == 0) {
        throw DivisionError("Division by zero")
    }
    return a / b
}

// Generic function
function first<T>(list: List<T>): Option<T> {
    if (list.length > 0) {
        return Some(list[0])
    } else {
        return None
    }
}
```

### Method Definition

```noodle
class Calculator {
    // Instance method
    function add(a: int, b: int): int {
        return a + b
    }
    
    // Static method
    static function create(): Calculator {
        return new Calculator()
    }
    
    // Virtual method
    virtual function calculate(): int
}
```

### Function Calls

```noodle
// Basic call
result = add(10, 20)

// Named arguments
result = calculate(base: 10, height: 5)

// Method call
value = object.method(arg1, arg2)

// Async call
data = await fetchData("https://api.example.com")
```

### Lambda Functions

```noodle
// Basic lambda
square = x => x * x

// Multi-parameter lambda
add = (a, b) => a + b

// Lambda with block
process = item => {
    // multiple statements
    return transformed
}
```

## Pattern Matching

### Match Expression

```noodle
match (value) {
    case 42 => "The answer"
    case n when n > 0 => "Positive"
    case n when n < 0 => "Negative"
    case 0 => "Zero"
    case null => "Null"
    case _ => "Unknown"
}
```

### Pattern Types

```noodle
match (data) {
    case Some(value) => processValue(value)
    case None => handleNone()
    case Success(result) => handleSuccess(result)
    case Error(error) => handleError(error)
    case {name: "Alice", age: age} => handleAlice(age)
    case [first, second, ...rest] => handleList(first, second, rest)
    case x when isString(x) => handleString(x)
    case _ => handleDefault()
}
```

### Destructuring Patterns

```noodle
// Struct destructuring
match (person) {
    case {name: name, age: age} => process(name, age)
}

// List destructuring
match (items) {
    case [first, second] => handleTwo(first, second)
    case [first, ...rest] => handleMany(first, rest)
    case [] => handleEmpty()
}

// Nested destructuring
match (data) {
    case {user: {name: name, email: email}} => processUser(name, email)
}
```

## Generic Types

### Generic Functions

```noodle
// Generic function with type constraints
function max<T: Comparable>(a: T, b: T): T {
    return if (a > b) a else b
}

// Multiple type parameters
function zip<T, U>(list1: List<T>, list2: List<U>): List<Pair<T, U>> {
    // implementation
}
```

### Generic Types

```noodle
// Generic struct
struct Container<T> {
    value: T
    timestamp: int
}

// Generic interface
interface Repository<T> {
    find(id: int): Option<T>
    save(item: T): Result<T, Error>
    delete(id: int): Result<void, Error>
}
```

### Type Constraints

```noodle
// Bounded type parameter
function process<T: Drawable>(item: T) {
    item.draw(canvas)
}

// Multiple constraints
function compare<T: Comparable + Hashable>(a: T, b: T): int {
    return a.compareTo(b)
}

// Where clause
function complex<T, U>(a: T, b: U) where T: Convertible<U> {
    return a.convert()
}
```

## Async/Await

### Async Functions

```noodle
// Async function definition
async function fetchUserData(userId: int): Result<User, Error> {
    response = await HTTP.get("https://api.example.com/users/" + userId)
    if (response.statusCode == 200) {
        return Success(parseUser(response.body))
    } else {
        return Error(NetworkError("Failed to fetch user"))
    }
}
```

### Await Expressions

```noodle
// Basic await
data = await fetchData()

// Await in expression
result = await fetchData() + await processData()

// Await in loop
async for item in stream<int> {
    processed = await processItem(item)
    await saveItem(processed)
}
```

### Async Iteration

```noodle
// Async for loop
async for line in stream<string> from file {
    await processLine(line)
}

// Async comprehension
results = [await processItem(item) async for item in items]
```

## Modern Collections

### Generic Collections

```noodle
// List operations
numbers: List<int> = [1, 2, 3, 4, 5]
names: List<string> = ["Alice", "Bob", "Charlie"]
matrix: List<List<int>> = [[1, 2], [3, 4]]

// Map operations
scores: Map<string, int> = {"Alice": 95, "Bob": 87}
config: Map<string, string> = {"host": "localhost", "port": "8080"}

// Set operations
unique: Set<int> = {1, 2, 3, 4, 5}
permissions: Set<string> = {"read", "write", "execute"}
```

### Functional Programming

```noodle
// Functional operations
numbers = [1, 2, 3, 4, 5]
doubled = map(numbers, n => n * 2)
filtered = filter(numbers, n => n > 3)
summed = reduce(numbers, 0, (a, b) => a + b)

// Pipeline operations
result = numbers
    | filter(n => n > 0)
    | map(n => n * 2)
    | reduce(0, (a, b) => a + b)
```

### Stream Processing

```noodle
// Stream creation
numberStream = stream<int> from [1, 2, 3, 4, 5]
fileStream = stream<string> from File("data.txt")

// Stream operations
processed = numberStream
    | filter(n => n > 0)
    | map(n => n * 2)
    | collect(toList())

// Async stream iteration
async for item in stream<int> {
    await processItem(item)
}
```

## Enhanced I/O Abstractions

### File Operations

```noodle
// Basic file operations
file = open("data.txt", mode: "read")
content = read(file)
write(file, "Hello, World!")
close(file)

// Resource management
with File("config.json") as config {
    data = read(config)
    settings = parse(data)
}

// Buffered I/O
buffer = createBuffer(size: 8192)
write(file, buffer)
flush(buffer)
```

### HTTP Operations

```noodle
// HTTP requests
response = HTTP.get("https://api.example.com/data")
result = HTTP.post("https://api.example.com/submit", data: payload)
updated = HTTP.put("https://api.example.com/update", data: updateData)
deleted = HTTP.delete("https://api.example.com/item/123")

// Advanced HTTP
headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer " + token
}

response = HTTP.get("https://api.example.com/secure", 
    headers: headers, 
    timeout: 5000)
```

### Socket Operations

```noodle
// TCP socket operations
socket = createSocket(type: "TCP")
connect(socket, "localhost:8080")
send(socket, "Hello, Server!")
response = receive(socket, bufferSize: 1024)
close(socket)

// Server operations
serverSocket = createSocket(type: "TCP")
listen(serverSocket, port: 8080, backlog: 128)

async for client in accept(serverSocket) {
    handleConnection(client)
}
```

### Resource Management

```noodle
// Context managers
with File("input.txt") as inputFile, File("output.txt") as outputFile {
    data = read(inputFile)
    processed = transform(data)
    write(outputFile, processed)
}

// Network resources
with HTTP.connection("https://api.example.com") as conn {
    response = conn.get("/data")
    process(response)
}
```

## Error Handling

### Try-Catch-Finally

```noodle
// Basic error handling
try {
    result = riskyOperation()
} catch (SpecificError error) {
    handleSpecificError(error)
} catch (GenericError error) {
    handleGenericError(error)
} finally {
    cleanup()
}

// Error handling with resource management
try {
    with File("data.txt") as file {
        content = read(file)
        return parse(content)
    }
} catch (FileNotFoundError error) {
    return getDefaultData()
} catch (ParseError error) {
    throw ConfigurationError("Invalid data format")
}
```

### Error Types

```noodle
// Custom error types
error FileNotFoundError extends Error {
    filename: string
    
    constructor(filename: string) {
        self.filename = filename
        super("File not found: " + filename)
    }
}

error NetworkError extends Error {
    code: int
    message: string
    
    constructor(code: int, message: string) {
        self.code = code
        self.message = message
        super("Network error: " + message)
    }
}
```

### Result Types

```noodle
// Result type usage
function divide(a: float, b: float): Result<float, DivisionError> {
    if (b == 0) {
        return Error(DivisionError("Division by zero"))
    } else {
        return Success(a / b)
    }
}

// Result handling
match (divide(10, 2)) {
    case Success(result) => console.log("Result: " + result)
    case Error(error) => console.log("Error: " + error.message)
}
```

## Modules and Packages

### Import Statements

```noodle
// Import specific items
import { List, Map } from "collections"
import { readFile, writeFile } from "fs"

// Import entire module
import "http"
import "database"

// Import with alias
import { User as Person } from "models"
import * as Math from "math"
```

### Export Statements

```noodle
// Export specific items
export { User, Product, Order }
export { calculateTotal, generateReport }

// Export with alias
export { User as Person }
export { default as Calculator }

// Re-export
export * from "utils"
export { User } from "models"
```

### Module Structure

```noodle
// Module declaration
module "mymodule" version "1.0.0"

// Package declaration
package "com.example.mymodule"

// Module dependencies
requires "collections" version "2.0.0"
requires "http" version "1.5.0"
```

## Memory Management

### Stack Allocation

```noodle
// Stack-allocated variables (default)
x: int = 42
name: string = "Alice"
items: List<int> = [1, 2, 3]
```

### Heap Allocation

```noodle
// Explicit heap allocation
data: Box<int> = box(42)
largeObject: Heap<MyStruct> = heap(MyStruct())

// Manual memory management
ptr: Pointer<int> = allocate<int>(size: 100)
deallocate(ptr)
```

### Reference Counting

```noodle
// Reference counted objects
class RefCounted {
    private count: int = 0
    
    function retain() {
        self.count++
    }
    
    function release() {
        self.count--
        if (self.count == 0) {
            delete self
        }
    }
}
```

### Garbage Collection

```noodle
// GC-managed objects
class GcManaged {
    // Finalizer
    destructor() {
        cleanup()
    }
}

// Weak references
weakRef: WeakReference<Object> = WeakReference(object)
if (weakRef.isAlive()) {
    obj = weakRef.get()
}
```

## Standard Library

### Core Library

```noodle
// Basic operations
print(value: any): void
debug(message: string): void
assert(condition: bool, message?: string): void

// Type utilities
typeOf(value: any): Type
is<T>(value: any): bool
as<T>(value: any): Option<T>
```

### Collections Library

```noodle
// List operations
List<T>.length: int
List<T>.append(item: T): void
List<T>.remove(index: int): T
List<T>.slice(start: int, end: int): List<T>

// Map operations
Map<K, V>.get(key: K): Option<V>
Map<K, V>.set(key: K, value: V): void
Map<K, V>.remove(key: K): Option<V>
Map<K, V>.keys(): List<K>

// Set operations
Set<T>.add(item: T): bool
Set<T>.contains(item: T): bool
Set<T>.remove(item: T): bool
Set<T>.union(other: Set<T>): Set<T>
```

### I/O Library

```noodle
// File operations
File.open(path: string, mode: string): File
File.read(file: File): string
File.write(file: File, content: string): void
File.close(file: File): void

// HTTP operations
HTTP.get(url: string, options?: RequestOptions): Response
HTTP.post(url: string, data: any, options?: RequestOptions): Response
HTTP.put(url: string, data: any, options?: RequestOptions): Response
HTTP.delete(url: string, options?: RequestOptions): Response
```

### Concurrency Library

```noodle
// Thread operations
Thread.start(function: () -> void): Thread
Thread.join(thread: Thread): void
Thread.sleep(milliseconds: int): void

// Async operations
async sleep(milliseconds: int): void
async parallel<T>(tasks: List<async () -> T>): List<T>
async race<T>(tasks: List<async () -> T>): T
```

## Language Extensions

### Compiler Directives

```noodle
// Optimization directives
@optimize("speed")
function criticalFunction() {
    // implementation
}

@inline
function smallFunction() {
    // implementation
}

// Metadata directives
@deprecated("Use newFunction instead")
function oldFunction() {
    // implementation
}

@experimental
function newFeature() {
    // implementation
}
```

### Macros

```noodle
// Macro definition
macro debugPrint(message: string) {
    if (DEBUG) {
        print("[DEBUG] " + message)
    }
}

// Macro usage
debugPrint("This is a debug message")
```

### Foreign Function Interface

```noodle
// Foreign function declaration
foreign function printf(format: string, ...args): int
foreign function malloc(size: int): Pointer<void>
foreign function free(ptr: Pointer<void>): void

// Calling foreign functions
printf("Hello, %s!\n", "World")
ptr = malloc(1024)
free(ptr)
```

## Implementation Notes

### Compilation Process

1. **Lexical Analysis**: Tokenization of source code
2. **Syntax Analysis**: Parsing and AST construction
3. **Semantic Analysis**: Type checking and symbol resolution
4. **Optimization**: Code optimization and transformation
5. **Code Generation**: Target code generation

### Runtime System

- **Memory Management**: Automatic garbage collection with manual control options
- **Type System**: Runtime type information and dynamic dispatch
- **Exception Handling**: Stack unwinding and error propagation
- **Concurrency**: Lightweight threads and async/await support

### Performance Characteristics

- **Compilation Speed**: Fast incremental compilation
- **Execution Speed**: Optimized native code generation
- **Memory Usage**: Efficient memory layout and garbage collection
- **Concurrency**: Low-overhead async operations

## Migration Guide

### From Noodle v1.x

**Breaking Changes**:

- Some syntax changes for pattern matching
- Updated generic type syntax
- Modified I/O operation signatures

**Migration Steps**:

1. Update syntax for pattern matching
2. Convert to new generic type syntax
3. Update I/O operation calls
4. Test with new compiler

### Compatibility

Noodle v2.0 maintains backward compatibility for most v1.x code with minimal modifications required.

## Conclusion

Noodle v2.0 represents a comprehensive modernization of the language while maintaining its core philosophy of simplicity and expressiveness. The new features provide developers with powerful tools for building modern applications while keeping the language approachable and maintainable.

The specification serves as the foundation for compiler implementation, tool development, and ecosystem growth.
