# Lean4 Backend - Incomplete Features & TODO List

## Current Status
✅ **Working**: Basic scope translation, literals, types, expressions, operators, struct declarations
❌ **Not Working Yet**: Listed below

---

## High Priority - Core Features

### 1. Expression Support (Critical for most programs)

#### 1.1 Pattern Matching (`EMatch`)
- **Status**: `sorry -- match not yet implemented`
- **Impact**: HIGH - Used in enum handling, conditionals
- **Complexity**: Medium
- **Required for**: Enum destructuring, option handling
- **Example**:
  ```catala
  definition x equals match y with pattern
    | Case1: value1
    | Case2: value2
  ```

#### 1.2 Lambda Abstractions (`EAbs`)
- **Status**: `sorry -- lambda not yet implemented`
- **Impact**: MEDIUM - Used in higher-order functions
- **Complexity**: Medium
- **Required for**: Map, filter, fold operations
- **Example**:
  ```catala
  definition doubled equals list map (fun x -> x * 2) input_list
  ```

#### 1.3 Location References (`ELocation`)
- **Status**: `sorry -- location not yet implemented`
- **Impact**: HIGH - Used for variable references in desugared AST
- **Complexity**: Low
- **Required for**: Internal variable references, state tracking
- **Notes**: Desugared AST uses `ELocation` to refer to scope variables

#### 1.4 Scope Calls (`EScopeCall`)
- **Status**: `sorry -- scope call not yet implemented`
- **Impact**: HIGH - Required for subscope invocation
- **Complexity**: Medium
- **Required for**: Programs with multiple scopes
- **Example**:
  ```catala
  scope A:
    definition x equals output of B

  scope B:
    output y content integer
  ```

### 2. Default Calculus Logic (Critical for Catala semantics)

#### 2.1 Default Expressions (`EDefault`, `EPureDefault`)
- **Status**: `sorry -- default logic not yet implemented`
- **Impact**: CRITICAL - Core of Catala's semantics
- **Complexity**: High
- **Required for**: Exception handling, rule prioritization
- **Translation Strategy**: Use `D` monad and `processExceptions` from CatalaRuntime
- **Example**:
  ```catala
  definition x under condition c1 consequence e1
  definition x under condition c2 consequence e2
  -- Results in: processExceptions [if c1 then some e1 else none, if c2 then some e2 else none]
  ```

#### 2.2 Empty Values (`EEmpty`, `EErrorOnEmpty`)
- **Status**: `sorry -- default logic not yet implemented`
- **Impact**: HIGH
- **Complexity**: Medium
- **Required for**: Handling undefined values, error propagation

### 3. Rule-to-Function Conversion (Pending in TODO)

#### 3.1 Multiple Rules per Variable
- **Status**: Currently assumes ONE rule per variable (line 241: `RuleName.Map.choose`)
- **Impact**: HIGH - Most real programs have multiple rules
- **Complexity**: High
- **Required for**: Exception hierarchies, conditional definitions
- **Current Code**:
  ```ocaml
  let _rule_id, rule = RuleName.Map.choose rules in
  ```
- **Should be**: Process all rules with exception hierarchy

#### 3.2 Exception Hierarchy Processing
- **Status**: Not implemented
- **Impact**: CRITICAL - Core Catala feature
- **Complexity**: High
- **Required for**: Rule priorities, exception handling
- **Strategy**: Build exception graph, use `processExceptions` for each level

#### 3.3 Rule Justifications (`rule_just`)
- **Status**: Ignored (line 242 only uses `rule_cons`)
- **Impact**: HIGH - Conditional rules
- **Complexity**: Medium
- **Required for**: Rules with conditions
- **Translation**: `if justification then consequence else none`

#### 3.4 Rule Labels and Exceptions
- **Status**: Not handled
- **Impact**: HIGH
- **Complexity**: Medium
- **Required for**: Labeled exception rules

---

## Medium Priority - Extended Features

### 4. Advanced Operators

#### 4.1 Array Operations
- **Status**: `sorry -- array operations not yet fully implemented`
- **Impact**: MEDIUM
- **Complexity**: Medium
- **Missing**: `Map`, `Filter`, `Fold`, `Reduce`, `Concat`, `Map2`
- **Depends on**: Lambda abstractions (EAbs)

#### 4.2 Type Conversions
- **Status**: Basic implementations (ToInt, ToRat, ToMoney, Round)
- **Impact**: LOW - Rarely used explicitly
- **Complexity**: Low

### 5. Struct Operations

#### 5.1 Struct Amendment (`EDStructAmend`)
- **Status**: `sorry -- struct amendment not yet implemented`
- **Impact**: LOW - Sugar for struct updates
- **Complexity**: Low
- **Example**: `{ old_struct with field := new_value }`

### 6. Scope Features

#### 6.1 Input Parameters
- **Status**: Not handled in `format_scope`
- **Impact**: HIGH
- **Complexity**: Medium
- **Required for**: Scopes that take inputs
- **Current**: Only handles output variables
- **Needed**: Generate function parameters from input variables

#### 6.2 Subscope Variables
- **Status**: Not handled
- **Impact**: HIGH
- **Complexity**: Medium
- **Required for**: Accessing subscope outputs
- **Handled by**: `ScopeDef.SubScopeInput` kind (line 218 ignores `_kind`)

#### 6.3 Scope Assertions
- **Status**: Not handled
- **Impact**: MEDIUM - Useful for verification
- **Complexity**: Low
- **Current**: `scope_decl.Ast.scope_assertions` is ignored
- **Translation**: Generate Lean `example` or `theorem` statements

#### 6.4 Variable States
- **Status**: Not handled
- **Impact**: MEDIUM
- **Complexity**: High
- **Required for**: State-based variable definitions
- **Example**:
  ```catala
  declaration structure Result:
    data x content integer state before state after
  ```

### 7. Top-Level Definitions

#### 7.1 Module Functions (`topdef`)
- **Status**: Not handled
- **Impact**: MEDIUM
- **Complexity**: Low
- **Required for**: Reusable functions across scopes
- **Current**: Only processes scopes, not `program_root.module_topdefs`

---

## Low Priority - Advanced Features

### 8. Enum Declarations
- **Status**: Not generated
- **Impact**: MEDIUM - Required for complex programs with enums
- **Complexity**: Low
- **Current**: Uses struct declarations from `program_ctx.ctx_structs`, should also handle `ctx_enums`
- **Translation**: Lean `inductive` type

### 9. Module System
- **Status**: Not handled
- **Impact**: LOW - For large multi-module programs
- **Complexity**: High
- **Current**: Only processes `program_root`, ignores `program_modules`

### 10. Metadata & Annotations
- **Status**: Not handled
- **Impact**: LOW - Nice to have
- **Complexity**: Low
- **Examples**: Assertions, meta-assertions, scope options, visibility

---

## Code Quality & Testing

### 11. Error Messages
- **Current**: Many "sorry" placeholders give no context
- **Needed**: Better error messages for unsupported features
- **Example**: "Variable X uses exception hierarchy which is not yet supported"

### 12. Integration Tests
- **Current**: Unit tests for formatting functions only
- **Needed**: End-to-end tests for various Catala programs
- **Suggested**: Create tests for each feature category

### 13. Documentation
- **Current**: Basic comments
- **Needed**: 
  - Translation semantics documentation
  - Design decisions
  - Examples of translated code

---

## Immediate Next Steps (Prioritized)

1. **ELocation support** - Required for variable references (LOW COMPLEXITY, HIGH IMPACT)
2. **Rule justifications** - Handle conditional rules (MEDIUM COMPLEXITY, HIGH IMPACT)
3. **Multiple rules + exception hierarchy** - Core Catala feature (HIGH COMPLEXITY, CRITICAL IMPACT)
4. **EDefault/EPureDefault** - Translate to D monad (HIGH COMPLEXITY, CRITICAL IMPACT)
5. **Pattern matching (EMatch)** - Required for enums (MEDIUM COMPLEXITY, HIGH IMPACT)
6. **Scope inputs** - Make scopes parametric (MEDIUM COMPLEXITY, HIGH IMPACT)
7. **EScopeCall** - Subscope invocation (MEDIUM COMPLEXITY, HIGH IMPACT)
8. **Lambda abstractions (EAbs)** - For higher-order functions (MEDIUM COMPLEXITY, MEDIUM IMPACT)

---

## Testing Strategy

For each feature:
1. Add unit tests to `lean4_desugared_test.ml`
2. Find a simple Catala test case that uses the feature
3. Generate Lean code and verify it compiles
4. Verify the Lean code produces correct results

Suggested test progression:
- `tests/default/good/empty.catala_en` - Default logic
- `tests/exception/good/exception.catala_en` - Exception hierarchy
- `tests/scope/good/subscope.catala_en` - Subscope calls
- `tests/enum/good/disambiguation.catala_en` - Pattern matching
- `tests/func/good/closure_conversion.catala_en` - Lambda abstractions

