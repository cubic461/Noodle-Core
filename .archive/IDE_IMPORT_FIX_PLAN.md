# IDE Import Fix Plan

## Problem Summary

The complete NoodleCore IDE (`enhanced_native_ide_complete.py`) cannot be imported due to multiple issues in `ast_nodes.py`:

1. Missing `CompilationError` class definition
2. Class definition order issues (classes referenced before being defined)
3. Import order problems causing forward reference issues
4. Missing AST node classes that are imported by other modules
5. Naming inconsistencies between class definitions and imports

## Root Cause Analysis

The enhanced_parser.py and other compiler modules import many AST node classes that were not properly defined in ast_nodes.py. Additionally, there were forward reference issues where classes were referenced before being defined.

## Detailed Fix Plan

### Phase 1: Core Error Classes (COMPLETED)

- ✅ Added `CompilationError` base class
- ✅ Added `ParserError`, `TypeError`, `RuntimeError` subclasses
- ✅ Fixed `SourceLocation` class definition order

### Phase 2: Missing AST Node Classes (COMPLETED)

- ✅ Added all missing pattern matching classes:
  - `MatchExpressionNode`, `MatchCaseNode`
  - `WildcardPatternNode`, `LiteralPatternNode`, `IdentifierPatternNode`
  - `TuplePatternNode`, `ArrayPatternNode`, `ObjectPatternNode`
  - `OrPatternNode`, `AndPatternNode`, `GuardPatternNode`
  - `TypePatternNode`, `RangePatternNode`
- ✅ Added all missing generics classes:
  - `GenericParameterNode`, `GenericType`
  - `GenericFunction`, `GenericClass`
  - `TypeInferenceContext`, `TypeInferenceEngine`
  - `GenericTypeChecker`, `GenericOptimizer`
- ✅ Added all missing async/await classes:
  - `AsyncFunctionDefinitionNode`, `AwaitExpressionNode`
  - `AsyncForStatementNode`, `AsyncWithStatementNode`
  - `YieldExpressionNode`, `AsyncRuntime`, `AsyncError`, `AsyncCompiler`
- ✅ Added all missing type system classes:
  - `Type`, `TypeKind`, `PrimitiveType`, `FunctionType`
  - `UnionType`, `IntersectionType`, `TupleType`, `ArrayType`, `ObjectType`
  - `TypeAlias`, `ComputedType`, `UnknownType`, `TypeChecker`

### Phase 3: Import Order and Forward References (COMPLETED)

- ✅ Fixed import order to prevent forward reference issues
- ✅ Added fallback definitions for noodle_lang imports
- ✅ Ensured all classes are defined before being referenced

### Phase 4: Naming Consistency Issues (PENDING)

**Issue**: The `GenericClass` class is trying to use `GenericParameter` but we defined it as `GenericParameterNode`.

**Fix Required**:

1. Update `GenericClass.generic_parameters` field to use `List['GenericParameterNode']` instead of `List[GenericParameter]`
2. Check for any other similar naming inconsistencies

### Phase 5: Testing and Verification (PENDING)

1. Test IDE import after all fixes
2. Verify no remaining import errors
3. Document the complete solution

## Implementation Steps

### Step 1: Fix GenericClass Reference

```python
@dataclass
class GenericClass(ASTNode):
    name: str
    generic_parameters: List['GenericParameterNode']  # Fix this line
    base_classes: List[str]
    members: List['ASTNode']
```

### Step 2: Verify All Class References

- Check all AST node class definitions for correct type references
- Ensure all forward references use string annotations (e.g., `'GenericParameterNode'`)

### Step 3: Test IDE Import

```bash
cd noodle-core
python -c "from src.noodlecore.desktop.ide.enhanced_native_ide_complete import EnhancedNativeNoodleCoreIDE; print('✅ Complete IDE imported successfully')"
```

### Step 4: Document Solution

- Create summary of all fixes made
- Document the import chain and dependencies
- Note any remaining limitations or workarounds

## Expected Outcome

After completing all phases, the complete NoodleCore IDE should be importable without errors, allowing users to launch the full-featured IDE instead of falling back to the enhanced version.

## Risk Assessment

- **Low Risk**: Changes are additive (adding missing classes) and corrective (fixing references)
- **Medium Risk**: Import order changes could affect other modules
- **Mitigation**: Test thoroughly and maintain backward compatibility

## Success Criteria

1. ✅ `enhanced_native_ide_complete.py` imports successfully
2. ✅ No import errors or NameError exceptions
3. ✅ All AST node classes are properly defined and exported
4. ✅ Import order is correct with no forward reference issues
