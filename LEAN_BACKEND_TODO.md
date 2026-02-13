# Lean4 Backend - Incomplete Features & TODO List

## 🎉 Recent Major Milestones

The Lean4 backend now generates **modular, well-structured code** with comprehensive expression support:
- **77 unit tests passing** covering all implemented features
- **Method-per-Variable Architecture**: Each Catala rule tree node → separate Lean method
- **Lambda Abstractions**: Full support for higher-order functions with Lean 4 `fun` syntax
- Smart parameter handling (input structs + required internal variables only)
- Full exception hierarchy support via recursive tree processing
- Context-aware variable references (`input.field` for inputs, direct names for internals)

## Current Status
✅ **Working**: 
- Basic scope translation, literals, types, expressions, operators
- Struct declarations
- Variable references (ELocation) with input/internal variable distinction
- Rule justifications (conditional rules)
- Internal variables
- **Lambda abstractions (EAbs)**: Full support for higher-order functions with Lean 4 `fun` syntax
- **Method-per-variable architecture**: Each rule tree node generates its own Lean method
- **Exception hierarchy**: Using `processExceptions` with rule trees
- **Input structs**: Proper parameterization with input variables accessed via `input.field`
- **Dependency analysis**: Methods receive only required internal variable parameters

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

#### 1.2 Lambda Abstractions (`EAbs`) ✅ COMPLETED
- **Status**: ✅ **Implemented** - Full lambda abstraction support
- **Impact**: MEDIUM - Used in higher-order functions
- **Complexity**: Medium
- **Completed**: Full support for lambda expressions with proper Lean 4 syntax
- **Implementation**:
  - Uses `Bindlib.unmbind` to extract parameters and body
  - Formats as `fun (x : Type) (y : Type) => body` in Lean 4
  - Handles unit parameters: `fun () => body`
  - Handles multiple parameters with proper type annotations
  - `scope_defs` context propagates through lambda bodies
- **Test Coverage**: 5 comprehensive tests covering single/multiple params, unit params, conditional bodies
- **Example Translation**:
  ```catala
  λ (x: integer) → x + 1
  ```
  **Becomes:**
  ```lean
  fun (x : Int) => (x + (1 : Int))
  ```

#### 1.3 Location References (`ELocation`) ✅ COMPLETED
- **Status**: ✅ Implemented - Handles DesugaredScopeVar and ToplevelVar
- **Impact**: HIGH - Used for variable references in desugared AST
- **Complexity**: Low
- **Completed**: Can reference scope variables with optional state, top-level definitions

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

### 3. Rule-to-Function Conversion & Code Architecture

#### 3.0 Method-per-Variable Refactoring ✅ COMPLETED
- **Status**: ✅ **Implemented** - Tree-based method generation per rule tree node
- **Impact**: CRITICAL - Cleaner, more modular Lean code
- **Complexity**: High
- **Completed**: 
  - ✅ Phase 0: Exposed `scopelang` functions (`scope_to_exception_graphs`, `def_map_to_tree`)
  - ✅ Phase 1: Variable collection with dependency analysis using `Desugared.Dependency` and `Scopelang.From_desugared`
  - ✅ Phase 2: Method generation per rule tree node with proper input/internal variable distinction
  - ✅ Input struct generation (`{ScopeName}_Input`)
  - ✅ Methods return `D Type` with proper exception handling
  - ✅ Smart parameter passing (input struct + only required internal variables)
  - ✅ `processExceptions` integration for exception hierarchy
  - ✅ Comprehensive test coverage (72 tests passing)
- **Design**:
  - Each rule tree node becomes a separate method: `{ScopeName}_{VarName}_{Label}`
  - All methods return `D Type` (monadic type for default calculus)
  - Methods take input struct + required internal variables as parameters
  - Input variables are accessed via `input.field`, not as separate parameters
  - Base methods use `processExceptions` to combine exception child methods
  - Recursive tree traversal generates child exception methods before parent methods
- **Example**:
  ```lean
  -- Input struct
  structure MyScope_Input where
    x : Int
    y : Bool
  
  -- Internal variable method
  def MyScope_temp_base (inputs : MyScope_Input) : D Int :=
    .ok (some (inputs.x + 10))
  
  -- Output variable method (depends on internal var)
  def MyScope_result_base (inputs : MyScope_Input) (temp : Int) : D Money :=
    .ok (some (Money.mk temp 0))
  
  -- Main scope function
  def MyScope_func (inputs : MyScope_Input) : D MyScope :=
    match MyScope_temp_base inputs with
    | .ok (some temp) =>
        match MyScope_result_base inputs temp with
        | .ok (some result) => .ok (some { result := result })
        | e => e
    | e => e
  ```
- **Implementation Notes**:
  - Reuses existing `scopelang/from_desugared.ml` infrastructure
  - Uses `Desugared.Dependency` for variable ordering and cycle detection
  - Uses `Scopelang.From_desugared` for exception graph and rule tree construction
  - `format_expr` and `format_location` support optional `scope_defs` parameter for context-aware formatting

#### 3.1 Multiple Rules per Variable ✅ COMPLETED
- **Status**: ✅ **Implemented** - Via rule tree processing
- **Impact**: HIGH - Most real programs have multiple rules
- **Complexity**: High
- **Completed**: All rules for a variable are now processed via the rule tree structure
- **Implementation**: 
  - `Scopelang.From_desugared.def_map_to_tree` converts rule maps to trees
  - Leaf nodes contain piecewise rules (multiple rules at same level)
  - Node branches represent exception hierarchies
  - `processExceptions` combines multiple piecewise rules at each level

#### 3.2 Exception Hierarchy Processing ✅ COMPLETED
- **Status**: ✅ **Implemented** - Using rule trees and `processExceptions`
- **Impact**: CRITICAL - Core Catala feature
- **Complexity**: High
- **Completed**: Full exception hierarchy support via recursive tree traversal
- **Implementation**: 
  - `Scopelang.From_desugared.scope_to_exception_graphs` builds exception dependency graphs
  - Rule trees encode exception relationships (Node with exception children)
  - Child exception methods generated before parent methods
  - Parent methods call `processExceptions` with child method results
  - Proper conflict detection and empty value handling in `D` monad

#### 3.3 Rule Justifications (`rule_just`) ✅ COMPLETED
- **Status**: ✅ Implemented - Wraps consequence in if-then-else
- **Impact**: HIGH - Conditional rules
- **Complexity**: Medium
- **Completed**: Unconditional rules (just=true) are optimized without if-wrapper
- **Translation**: `if justification then consequence else sorry "undefined"`

#### 3.4 Rule Labels and Exceptions ✅ COMPLETED
- **Status**: ✅ **Implemented** - Method names use explicit labels or generate unique names
- **Impact**: HIGH
- **Complexity**: Medium
- **Completed**: Full support for both explicitly labeled and unlabeled rules
- **Implementation**: 
  - `format_tree_method_name` generates method names from rule labels
  - Explicit labels: `{ScopeName}_{VarName}_{Label}` (e.g., `TaxCalc_rate_article_3`)
  - Unlabeled rules: `{ScopeName}_{VarName}_leaf_{index}` for unique identification
  - Exception relationships preserved through tree structure

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

#### 6.1 Input Parameters ✅ COMPLETED
- **Status**: ✅ **Implemented** - Input structs and smart variable references
- **Impact**: HIGH
- **Complexity**: Medium
- **Completed**: Full support for scope input parameters via input structs
- **Implementation**: 
  - `format_input_struct` generates `{ScopeName}_Input` structures
  - Input variables collected via `collect_inputs` from scope definitions
  - Methods receive `(input : {ScopeName}_Input)` parameter when inputs exist
  - Input variable references formatted as `input.{field_name}` in expressions
  - Internal variables passed as separate typed parameters to methods that need them
  - Proper distinction between input and internal variables in dependency analysis

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

### Recently Completed ✅
1. ✅ **ELocation support** - Variable references with input/internal distinction
2. ✅ **Rule justifications** - Conditional rules with if-then-else
3. ✅ **Method-per-variable refactoring** - Tree-based method generation (Phases 0, 1, 2.1-2.6 complete)
4. ✅ **Multiple rules + exception hierarchy** - Via rule trees and `processExceptions`
5. ✅ **Scope inputs** - Input structs with smart variable references
6. ✅ **Rule labels and exceptions** - Explicit and generated method names
7. ✅ **Lambda abstractions (EAbs)** - Full support with Lean 4 `fun` syntax (77 tests passing)

### Next Priority Features
1. 🔥 **EDefault/EPureDefault** - Translate default expressions to D monad (HIGH COMPLEXITY, CRITICAL IMPACT)
   - Current infrastructure supports this via `processExceptions`
   - Need to handle `EDefault` nodes in `format_expr`
2. **EScopeCall** - Subscope invocation (MEDIUM COMPLEXITY, HIGH IMPACT)
3. **Pattern matching (EMatch)** - Required for enums (MEDIUM COMPLEXITY, HIGH IMPACT)
4. **Enum declarations** - Generate Lean inductive types (LOW COMPLEXITY, MEDIUM IMPACT)
5. **Array operations (Map, Filter, Fold)** - Depends on EAbs ✅ and pattern matching (MEDIUM COMPLEXITY, MEDIUM IMPACT)

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

