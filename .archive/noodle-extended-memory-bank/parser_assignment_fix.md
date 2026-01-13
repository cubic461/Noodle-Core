# Parser Assignment Fix

## Probleem
De parser kon assignment expressies met `=` (gelijkheidsoperator) niet parsen, omdat alleen `:=` (assignment operator) werd geaccepteerd.

## Oorzaak
In de `assignment()` methode van de Parser klasse werd alleen gecheckt op `TokenType.ASSIGN` (voor `:=`), maar niet op `TokenType.EQUALS` (voor `=`).

## Oplossing
De `assignment()` methode is aangepast om beide token types te accepteren:

```python
def assignment(self) -> Expression:
    """Parse assignment expressions"""
    expr = self.equality()

    if self.match(TokenType.ASSIGN, TokenType.EQUALS):  # Accepteer zowel := als =
        equals = self.previous()
        value = self.equality()

        if isinstance(expr, Identifier):
            position = expr.position
            return Assignment(expr, value, position)

        self.error("Invalid assignment target")

    return expr
```

## Extra correcties
Ook zijn type attributen in verschillende literal nodes gecorrigeerd:
- `ListLiteral`: `self.type = "list"` in plaats van `self.type = Type("list")`
- `DictLiteral`: `self.type = "dict"` in plaats van `self.type = Type("dict")`
- `ArrayLiteral`: `self.type = "array"` in plaats van `self.type = Type("array")`

## Resultaat
Alle assignment expressies worden nu correct geparsed, inclusief:
- `x = 42`
- `name = 'hello'`
- `result = a + b * c`
- `matrix = [[1, 2], [3, 4]]`

## Test cases
Alle test cases in `test_token_debug.py` slagen nu:
- ✅ `x = 42` - Successfully parsed
- ✅ `name = 'hello'` - Successfully parsed
- ✅ `print(message)` - Successfully parsed
- ✅ `result = a + b * c` - Successfully parsed
- ✅ `matrix = [[1, 2], [3, 4]]` - Successfully parsed
