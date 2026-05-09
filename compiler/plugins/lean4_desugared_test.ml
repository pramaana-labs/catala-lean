(* This file is part of the Catala compiler, a specification language for tax
   and social benefits computation rules. Copyright (C) 2020 Inria.

   Licensed under the Apache License, Version 2.0 (the "License"); you may not
   use this file except in compliance with the License. You may obtain a copy of
   the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
   License for the specific language governing permissions and limitations under
   the License. *)

(** Unit tests for the Lean4 desugared backend.
    
    This test suite provides comprehensive regression testing for the Lean4 code
    generator. Each test guards against specific bugs discovered during development.
    
    Test Categories:
    1. Name Sanitization - Lean keyword collisions, scope function naming
    2. Literal Formatting - CRITICAL: Negative rational parentheses
    3. Polymorphism - Inhabited constraints, type variable consistency
    4. Type Formatting - Primitive types, tuples, nested types
    5. Detuplification - Tier 1/2 splatting, implicit arguments
    6. Expression Formatting - Tuple access, boolean decide
    7. Variable Classification - Context vars, pure inputs, reentrant
    8. Struct/Enum DecidableEq - Function type checking
    9. Rule Processing - Unconditional, conditional, exceptions
    10. Runtime/Stdlib - Date arithmetic, Money operations
    11. Scope/Subscope - Dependencies, multi-level calls
    12. Edge Cases - Empty collections, optional types
    13. Integration - End-to-end scope generation
*)

open Catala_utils
open Shared_ast
open Lean4_desugared

module Ast = Desugared.Ast
module Runtime = Catala_runtime

(** {1 Test Helpers} *)

module Helpers = struct
  (** Common mark for untyped expressions *)
  let nomark = Untyped { pos = Pos.void }
  
  (** {2 Type Construction Helpers} *)
  
  let mk_int_ty () = Mark.add Pos.void (TLit TInt)
  let mk_bool_ty () = Mark.add Pos.void (TLit TBool)
  let mk_unit_ty () = Mark.add Pos.void (TLit TUnit)
  let mk_rat_ty () = Mark.add Pos.void (TLit TRat)
  let mk_money_ty () = Mark.add Pos.void (TLit TMoney)
  let mk_date_ty () = Mark.add Pos.void (TLit TDate)
  let mk_duration_ty () = Mark.add Pos.void (TLit TDuration)
  
  let mk_option_ty ty = Mark.add Pos.void (TOption ty)
  let mk_list_ty ty = Mark.add Pos.void (TArray ty)
  let mk_arrow_ty args ret = Mark.add Pos.void (TArrow (args, ret))
  let mk_tuple_ty tys = Mark.add Pos.void (TTuple tys)
  
  (** {2 Literal Construction Helpers} 
      Note: All Expr construction functions return boxed_gexpr *)
  
  let mk_lit l = Expr.elit l nomark
  let mk_int n = mk_lit (LInt (Runtime.integer_of_int n))
  let mk_bool b = mk_lit (LBool b)
  let mk_rat num den = mk_lit (LRat (Q.of_ints num den))
  let mk_money cents = mk_lit (LMoney (Runtime.money_of_cents_integer (Runtime.integer_of_int cents)))
  let mk_unit () = mk_lit LUnit
  
  (** {2 Expression Construction Helpers}
      All return boxed_gexpr *)
  
  let mk_var name = 
    let var = Var.make name in
    Expr.evar var nomark
  
  let mk_if cond etrue efalse =
    Expr.eifthenelse cond etrue efalse nomark
  
  let mk_app f args =
    Expr.eapp ~f ~args ~tys:[] nomark
  
  let mk_app_with_tys f args tys =
    Expr.eapp ~f ~args ~tys nomark
  
  let mk_tuple es =
    Expr.etuple es nomark
  
  let mk_tuple_access e index size =
    Expr.etupleaccess ~e ~index ~size nomark
  
  let mk_location loc =
    Expr.elocation loc nomark
  
  let mk_appop op args =
    Expr.eappop ~op ~args ~tys:[] nomark
  
  (** Create a lambda (EAbs) and immediately apply it (EApp).
      [mk_immediate_app var_name ty body_fn arg] builds
      ((fun (var_name : ty) => body_fn(var_expr)) arg). *)
  let mk_abs_app var_name ty body_fn arg =
    let var = Var.make var_name in
    let var_expr = Expr.evar var nomark in
    let body = body_fn var_expr in
    let binder = Bindlib.bind_mvar [|var|] (Expr.Box.lift body) in
    let abs = Expr.eabs_ghost binder [ty] nomark in
    mk_app abs [arg]

  (** Create a standalone lambda (EAbs) without application. *)
  let mk_abs var_name ty body_fn =
    let var = Var.make var_name in
    let var_expr = Expr.evar var nomark in
    let body = body_fn var_expr in
    let binder = Bindlib.bind_mvar [|var|] (Expr.Box.lift body) in
    Expr.eabs_ghost binder [ty] nomark

  (** {2 String Checking Helpers} *)
  
  let contains_substring haystack needle =
    try
      let _ = Str.search_forward (Str.regexp_string needle) haystack 0 in
      true
    with Not_found -> false
  
  let count_occurrences haystack needle =
    let rec count pos acc =
      try
        let found_pos = Str.search_forward (Str.regexp_string needle) haystack pos in
        count (found_pos + 1) (acc + 1)
      with Not_found -> acc
    in
    count 0 0
  
  let starts_with str prefix =
    String.length str >= String.length prefix &&
    String.sub str 0 (String.length prefix) = prefix
  
  let ends_with str suffix =
    let str_len = String.length str in
    let suffix_len = String.length suffix in
    str_len >= suffix_len &&
    String.sub str (str_len - suffix_len) suffix_len = suffix
  
  (** {2 Alcotest Custom Testables} *)
  
  let string_list = Alcotest.list Alcotest.string
  
  let check_contains ~msg haystack needle =
    Alcotest.(check bool) msg true (contains_substring haystack needle)
  
  let check_not_contains ~msg haystack needle =
    Alcotest.(check bool) msg false (contains_substring haystack needle)
  
  let check_regex ~msg pattern haystack =
    Alcotest.(check bool) msg true 
      (Str.string_match (Str.regexp pattern) haystack 0)
end

(** {1 Test Category 1: Name Sanitization} *)

module NameSanitizationTests = struct
  open Helpers
  
  (** Test: Lean keyword "def" should be sanitized to "_def" *)
  let test_sanitize_keyword_def () =
    let result = sanitize_name "def" in
    Alcotest.(check string) "keyword def sanitized" "_def" result
  
  (** Test: Lean keyword "match" should be sanitized to "_match" *)
  let test_sanitize_keyword_match () =
    let result = sanitize_name "match" in
    Alcotest.(check string) "keyword match sanitized" "_match" result
  
  (** Test: Lean keyword "if" should be sanitized to "_if" *)
  let test_sanitize_keyword_if () =
    let result = sanitize_name "if" in
    Alcotest.(check string) "keyword if sanitized" "_if" result
  
  (** Test: REGRESSION - "assert" keyword collision
      Guards against: Using Lean reserved keyword without sanitization
      Bug: declaration assert content boolean equals true
      Expected: def _assert : Bool := true *)
  let test_sanitize_keyword_assert () =
    let result = sanitize_name "assert" in
    Alcotest.(check string) "keyword assert sanitized" "_assert" result
  
  (** Test: REGRESSION - "sort" keyword collision
      Guards against: Using Lean reserved keyword without sanitization
      Bug: declaration sort content collection integer equals [1, 2, 3]
      Expected: def _sort : (List Int) := [1, 2, 3] *)
  let test_sanitize_keyword_sort () =
    let result = sanitize_name "sort" in
    Alcotest.(check string) "keyword sort sanitized" "_sort" result
  
  (** Test: REGRESSION - "insert" keyword collision
      Guards against: Using Lean reserved keyword without sanitization
      Bug: declaration insert content integer equals 5
      Expected: def _insert : Int := 5 *)
  let test_sanitize_keyword_insert () =
    let result = sanitize_name "insert" in
    Alcotest.(check string) "keyword insert sanitized" "_insert" result
  
  (** Test: Type keyword collisions *)
  let test_sanitize_type_keywords () =
    Alcotest.(check string) "List" "_List" (sanitize_name "List");
    Alcotest.(check string) "Option" "_Option" (sanitize_name "Option");
    Alcotest.(check string) "Type" "_Type" (sanitize_name "Type");
    Alcotest.(check string) "Prop" "_Prop" (sanitize_name "Prop")
  
  (** Test: REGRESSION - Leading apostrophe in type variables
      Guards against: Invalid Lean identifiers from type variable names
      Bug: Type variable 'a becomes invalid in Lean
      Expected: 'a → ta, 'type → ttype *)
  let test_sanitize_apostrophe () =
    Alcotest.(check string) "type var 'a" "ta" (sanitize_name "'a");
    Alcotest.(check string) "type var 'b" "tb" (sanitize_name "'b");
    Alcotest.(check string) "type var 'type" "ttype" (sanitize_name "'type")
  
  (** Test: Non-keywords should pass through unchanged *)
  let test_sanitize_normal_names () =
    Alcotest.(check string) "normal name" "myVar" (sanitize_name "myVar");
    Alcotest.(check string) "underscore name" "_private" (sanitize_name "_private");
    Alcotest.(check string) "camelCase" "taxComputation" (sanitize_name "taxComputation")
  
  (** Test: Empty string handling *)
  let test_sanitize_empty () =
    let result = sanitize_name "" in
    Alcotest.(check string) "empty string" "" result
  
  (** Test: REGRESSION - Scope function name vs struct name collision
      Guards against: Function name conflicting with struct name
      Bug: Scope struct "TaxComputation" and function "TaxComputation" collide
      Expected: Function named "taxComputation" (lowercase), struct named "TaxComputation" *)
  let test_uncapitalize_simple () =
    let result = uncapitalize_qualified_name "TaxComputation" in
    Alcotest.(check string) "uncapitalize simple" "taxComputation" result
  
  (** Test: Qualified name uncapitalization - only last component *)
  let test_uncapitalize_qualified () =
    let result = uncapitalize_qualified_name "Sections.IRCSimplified" in
    Alcotest.(check string) "qualified name" "Sections.iRCSimplified" result
  
  (** Test: Module qualified name *)
  let test_uncapitalize_module_qualified () =
    let result = uncapitalize_qualified_name "Module.SubModule.ScopeName" in
    Alcotest.(check string) "module qualified" "Module.SubModule.scopeName" result
  
  (** Test: Already lowercase should stay lowercase *)
  let test_uncapitalize_already_lower () =
    let result = uncapitalize_qualified_name "myScope" in
    Alcotest.(check string) "already lowercase" "myScope" result
  
  (** Test: Single letter capitalized *)
  let test_uncapitalize_single_letter () =
    let result = uncapitalize_qualified_name "A" in
    Alcotest.(check string) "single letter" "a" result
  
  (** Test: All Lean keywords are properly sanitized
      Guards against: Missing keywords in sanitization list *)
  let test_all_keywords_sanitized () =
    let keywords = ["def"; "theorem"; "axiom"; "inductive"; "structure"; "class";
                    "instance"; "let"; "in"; "fun"; "match"; "if"; "then"; "else";
                    "do"; "return"; "import"; "where"; "deriving"; "namespace"; 
                    "assert"; "sort"; "insert"; "type"; "decide"] in
    List.iter (fun kw ->
      let sanitized = sanitize_name kw in
      Alcotest.(check bool) 
        (Printf.sprintf "keyword %s is sanitized" kw)
        true
        (String.length sanitized > String.length kw || 
         (String.length sanitized > 0 && sanitized.[0] = '_'))
    ) keywords
  
  let suite = [
    Alcotest.test_case "sanitize keyword def" `Quick test_sanitize_keyword_def;
    Alcotest.test_case "sanitize keyword match" `Quick test_sanitize_keyword_match;
    Alcotest.test_case "sanitize keyword if" `Quick test_sanitize_keyword_if;
    Alcotest.test_case "REGRESSION: sanitize assert" `Quick test_sanitize_keyword_assert;
    Alcotest.test_case "REGRESSION: sanitize sort" `Quick test_sanitize_keyword_sort;
    Alcotest.test_case "REGRESSION: sanitize insert" `Quick test_sanitize_keyword_insert;
    Alcotest.test_case "sanitize type keywords" `Quick test_sanitize_type_keywords;
    Alcotest.test_case "REGRESSION: apostrophe in type vars" `Quick test_sanitize_apostrophe;
    Alcotest.test_case "normal names unchanged" `Quick test_sanitize_normal_names;
    Alcotest.test_case "empty string" `Quick test_sanitize_empty;
    Alcotest.test_case "REGRESSION: scope function name" `Quick test_uncapitalize_simple;
    Alcotest.test_case "uncapitalize qualified name" `Quick test_uncapitalize_qualified;
    Alcotest.test_case "module qualified name" `Quick test_uncapitalize_module_qualified;
    Alcotest.test_case "already lowercase" `Quick test_uncapitalize_already_lower;
    Alcotest.test_case "single letter" `Quick test_uncapitalize_single_letter;
    Alcotest.test_case "all keywords sanitized" `Quick test_all_keywords_sanitized;
  ]
end

(** {1 Test Category 2: Detuplification & Function Application} *)

module DetuplificationTests = struct
  open Helpers
  
  (** Test 1: REGRESSION - Tier 1 ETuple Literal Splatting
      Guards against: Not splatting tuple literals when tys indicates multiple args
      Bug: f of (3, 4) with tys=[Int; Int] should become "f 3 4" not "f (3, 4)"
      Context: LetIn-derived application marks multi-arg calls via tys length *)
  let test_tier1_etuple_splat () =
    (* Simulate: f of (3, 4) where f expects two args *)
    let int_ty = mk_int_ty () in
    let f_var = mk_var "f" in
    let tuple_arg = mk_tuple [mk_int 3; mk_int 4] in
    let app_boxed = mk_app_with_tys f_var [tuple_arg] [int_ty; int_ty] in
    let app = Expr.unbox app_boxed in
    let formatted = format_expr app in
    (* Should splat: (f 3 4) *)
    check_contains ~msg:"has f" formatted "f";
    check_contains ~msg:"has 3" formatted "3";
    check_contains ~msg:"has 4" formatted "4";
    check_not_contains ~msg:"no tuple syntax" formatted "(3, 4)"
  
  (** Test 2: REGRESSION - Tier 1 Variable Projection
      Guards against: Not projecting tuple variables when tys indicates multiple args
      Bug: f of pair where pair:(Int×Int) and tys=[Int; Int] should become "f pair.1 pair.2"
      Context: LetIn introduces let-bindings that need projection *)
  let test_tier1_variable_projection () =
    (* Simulate: let pair = (1, 2) in f of pair *)
    let int_ty = mk_int_ty () in
    let f_var = mk_var "f" in
    let pair_var = mk_var "pair" in
    let app_boxed = mk_app_with_tys f_var [pair_var] [int_ty; int_ty] in
    let app = Expr.unbox app_boxed in
    let formatted = format_expr app in
    (* Should project: (f (pair).1 (pair).2) - parentheses around pair are correct *)
    check_contains ~msg:"has (pair).1" formatted "(pair).1";
    check_contains ~msg:"has (pair).2" formatted "(pair).2";
    Alcotest.(check bool) "exactly 2 projections" true 
      (count_occurrences formatted "pair)." = 2)
  
  (** Test 3: REGRESSION - CRITICAL - Implicit Position Argument Filtering
      Guards against: Counting implicit args in detuplification decision
      Bug: Function need_position : SourcePosition → Int → Int (first implicit)
           Call: need_position of 33
           EApp.tys = [SourcePosition; Int] but args = [33]
           After filtering implicit: tys_explicit = [Int], arity = 1
           Should NOT detuplify: "need_position 33" NOT "need_position 33.1"
      Context: Implicit args inserted in scopelang, not present in desugared *)
  let test_implicit_position_arg_filtering () =
    (* Simulate: need_position of 33 where SourcePosition is implicit *)
    let source_pos_ty_base = Mark.add Pos.void (TLit TPos) in
    (* Add ImplicitPosArg attribute to the mark *)
    let source_pos_ty = Mark.map_mark (fun pos -> Pos.add_attr pos ImplicitPosArg) source_pos_ty_base in
    let int_ty = mk_int_ty () in
    let f_var = mk_var "need_position" in
    let arg = mk_int 33 in
    let app_boxed = mk_app_with_tys f_var [arg] [source_pos_ty; int_ty] in
    let app = Expr.unbox app_boxed in
    let formatted = format_expr app in
    (* Should NOT project: (need_position 33) not (need_position 33.1) *)
    check_contains ~msg:"has function name" formatted "need_position";
    check_contains ~msg:"has argument" formatted "33";
    check_not_contains ~msg:"no .1 projection" formatted "33.1";
    check_not_contains ~msg:"no .2 projection" formatted "33.2"
  
  (** Test 4: REGRESSION - Tier 2 ETuple Splatting with Topdef Arity Match
      Guards against: Not splatting ETuple when topdef expects multiple args
      Bug: g of (5, 6) where g is topdef with arity 2 and tys=[]
           Should become "g 5 6" not "g (5, 6)"
      Context: Regular FunCall (not LetIn) needs topdef lookup *)
  let test_tier2_etuple_splat_with_arity () =
    (* Create a mock program_ctx with topdef g : Int → Int → Int *)
    let int_ty = mk_int_ty () in
    let arrow_ty = mk_arrow_ty [int_ty; int_ty] int_ty in
    let topdef_name = TopdefName.fresh [] ("g", Pos.void) in
    let topdefs = TopdefName.Map.singleton topdef_name (arrow_ty, Public) in
    let ctx = { Shared_ast.Program.empty_ctx with ctx_topdefs = topdefs } in
    
    (* Simulate: g of (5, 6) with tys=[] *)
    let f_toplevel = mk_location 
      (ToplevelVar { name = Mark.add Pos.void topdef_name; is_external = false }) in
    let tuple_arg = mk_tuple [mk_int 5; mk_int 6] in
    let app_boxed = mk_app_with_tys f_toplevel [tuple_arg] [] in
    let app = Expr.unbox app_boxed in
    let formatted = format_expr ~program_ctx:(Some ctx) app in
    (* Should splat: (g 5 6) *)
    check_contains ~msg:"has 5" formatted "5";
    check_contains ~msg:"has 6" formatted "6";
    check_not_contains ~msg:"no tuple syntax" formatted "(5, 6)"
  
  (** Test 5: REGRESSION - CRITICAL - Tier 2 No Variable Projection
      Guards against: Projecting tuple variables in Tier 2 (regular FunCall)
      Bug: h of x where x:(Int×Int) and tys=[]
           Should become "h x" NOT "h x.1 x.2"
      Context: Desugared AST may not have all args yet (implicit args added later)
      This is the CRITICAL difference between Tier 1 and Tier 2! *)
  let test_tier2_no_variable_projection () =
    (* Create topdef h : (Int × Int) → Int (takes single tuple arg) *)
    let int_ty = mk_int_ty () in
    let tuple_ty = mk_tuple_ty [int_ty; int_ty] in
    let arrow_ty = mk_arrow_ty [tuple_ty] int_ty in
    let topdef_name = TopdefName.fresh [] ("h", Pos.void) in
    let topdefs = TopdefName.Map.singleton topdef_name (arrow_ty, Public) in
    let ctx = { Shared_ast.Program.empty_ctx with ctx_topdefs = topdefs } in
    
    (* Simulate: h of x where x is a variable *)
    let f_toplevel = mk_location 
      (ToplevelVar { name = Mark.add Pos.void topdef_name; is_external = false }) in
    let x_var = mk_var "x" in
    let app_boxed = mk_app_with_tys f_toplevel [x_var] [] in
    let app = Expr.unbox app_boxed in
    let formatted = format_expr ~program_ctx:(Some ctx) app in
    (* Should NOT project: (h x) not (h x.1 x.2) *)
    check_contains ~msg:"has function" formatted "h";
    check_contains ~msg:"has variable" formatted "x";
    check_not_contains ~msg:"no .1 projection" formatted "x.1";
    check_not_contains ~msg:"no .2 projection" formatted "x.2"
  
  (** Test 6: Multiple Arguments - No Detuplification Needed
      Guards against: Breaking normal multi-arg calls
      Bug: f 1 2 3 should stay "f 1 2 3"
      Context: When args already has multiple elements, no detuplification *)
  let test_multiple_args_no_detuplify () =
    let f_var = mk_var "f" in
    let arg1 = mk_int 1 in
    let arg2 = mk_int 2 in
    let arg3 = mk_int 3 in
    let app_boxed = mk_app_with_tys f_var [arg1; arg2; arg3] [] in
    let app = Expr.unbox app_boxed in
    let formatted = format_expr app in
    (* Should format normally: (f 1 2 3) *)
    check_contains ~msg:"has 1" formatted "1";
    check_contains ~msg:"has 2" formatted "2";
    check_contains ~msg:"has 3" formatted "3";
    (* Should not have any projections *)
    check_not_contains ~msg:"no .1" formatted ".1";
    check_not_contains ~msg:"no .2" formatted ".2"
  
  let suite = [
    Alcotest.test_case "REGRESSION: Tier 1 ETuple splat" `Quick test_tier1_etuple_splat;
    Alcotest.test_case "REGRESSION: Tier 1 variable projection" `Quick test_tier1_variable_projection;
    Alcotest.test_case "REGRESSION CRITICAL: implicit arg filtering" `Quick test_implicit_position_arg_filtering;
    Alcotest.test_case "REGRESSION: Tier 2 ETuple splat with arity" `Quick test_tier2_etuple_splat_with_arity;
    Alcotest.test_case "REGRESSION CRITICAL: Tier 2 no var projection" `Quick test_tier2_no_variable_projection;
    Alcotest.test_case "multiple args no detuplify" `Quick test_multiple_args_no_detuplify;
  ]
end

(** {1 Test Category 3: Expression Formatting} *)

module ExpressionFormattingTests = struct
  open Helpers
  
  (** Test 1: REGRESSION - Tuple Access Index Conversion
      Guards against: Using 0-based indexing instead of 1-based for Lean tuples
      Bug: Catala uses 0-indexed tuple access, Lean uses 1-indexed
           tuple.0 should become tuple.1, tuple.1 should become tuple.2.1, etc.
      Context: Lean represents tuples as nested pairs: (a,b,c) = (a,(b,c)) *)
  let test_tuple_access_index_conversion () =
    let tuple_var = mk_var "myTuple" in
    (* Access index 0 of size 3 tuple *)
    let access0_boxed = mk_tuple_access tuple_var 0 3 in
    let access0 = Expr.unbox access0_boxed in
    let formatted0 = format_expr access0 in
    (* Should be: (myTuple).1 *)
    check_contains ~msg:"index 0 uses .1" formatted0 ".1";
    check_not_contains ~msg:"no .0" formatted0 ".0";
    
    (* Access index 1 of size 3 tuple *)
    let access1_boxed = mk_tuple_access tuple_var 1 3 in
    let access1 = Expr.unbox access1_boxed in
    let formatted1 = format_expr access1 in
    (* Should be: (myTuple).2.1 *)
    check_contains ~msg:"index 1 uses .2.1" formatted1 ".2.1";
    
    (* Access last element (index 2 of size 3) *)
    let access2_boxed = mk_tuple_access tuple_var 2 3 in
    let access2 = Expr.unbox access2_boxed in
    let formatted2 = format_expr access2 in
    (* Should be: (myTuple).2.2 (last element: just chain .2's) *)
    check_contains ~msg:"last element uses .2.2" formatted2 ".2.2";
    check_not_contains ~msg:"no .1 for last" formatted2 ".2.2.1"
  
  (** Test 2: REGRESSION - If-Then-Else Formatting
      Guards against: Incorrect if-then-else syntax
      Bug: Must use correct Lean syntax: (if cond then expr1 else expr2)
      Context: Lean requires specific syntax with parentheses *)
  let test_if_then_else_formatting () =
    let cond = mk_bool true in
    let then_branch = mk_int 42 in
    let else_branch = mk_int 0 in
    let if_expr_boxed = mk_if cond then_branch else_branch in
    let if_expr = Expr.unbox if_expr_boxed in
    let formatted = format_expr if_expr in
    (* Should have if-then-else structure *)
    check_contains ~msg:"has if keyword" formatted "if";
    check_contains ~msg:"has then keyword" formatted "then";
    check_contains ~msg:"has else keyword" formatted "else";
    check_contains ~msg:"has true condition" formatted "true";
    check_contains ~msg:"has then value 42" formatted "42"
  
  (** Test 3: Tuple Literal Formatting
      Guards against: Incorrect tuple syntax in Lean
      Bug: Tuples must use comma-separated syntax: (a, b, c)
      Context: Ensure proper parentheses and comma separation *)
  let test_tuple_literal_formatting () =
    let elem1 = mk_int 1 in
    let elem2 = mk_int 2 in
    let elem3 = mk_int 3 in
    let tuple_boxed = mk_tuple [elem1; elem2; elem3] in
    let tuple = Expr.unbox tuple_boxed in
    let formatted = format_expr tuple in
    (* Should be: (1, 2, 3) *)
    check_contains ~msg:"has 1" formatted "1";
    check_contains ~msg:"has 2" formatted "2";
    check_contains ~msg:"has 3" formatted "3";
    check_contains ~msg:"has commas" formatted ","
  
  (** Test 4: REGRESSION - Literal Formatting (Critical Rationals)
      Guards against: Incorrect rational number formatting
      Bug: Negative rationals must be: Rat.mk (-1) 2, NOT Rat.mk -1 2
      Context: Parentheses around negative numerator are critical for parsing *)
  let test_literal_negative_rational () =
    let neg_one = ~-1 in
    let neg_rat = mk_rat neg_one 2 in
    let neg_rat_expr = Expr.unbox neg_rat in
    let formatted = format_expr neg_rat_expr in
    (* Should be: Rat.mk (-1) 2 with parentheses around -1 *)
    check_contains ~msg:"has Rat.mk" formatted "Rat.mk";
    check_contains ~msg:"has (-1) with parens" formatted "(-1)";
    check_not_contains ~msg:"not -1 without parens" formatted "Rat.mk -1"
  
  (** Test 5: Variable Name Formatting
      Guards against: Not sanitizing variable names in expressions
      Bug: Variable names that are Lean keywords must be prefixed with _
      Context: Ensures sanitize_name is called on variables in expressions *)
  let test_variable_name_sanitization () =
    let def_var = mk_var "def" in
    let def_expr = Expr.unbox def_var in
    let formatted = format_expr def_expr in
    (* Should be sanitized to _def *)
    check_contains ~msg:"sanitized to _def" formatted "_def";
    check_not_contains ~msg:"not raw def" formatted " def"
  
  let suite = [
    Alcotest.test_case "REGRESSION: tuple access index conversion" `Quick test_tuple_access_index_conversion;
    Alcotest.test_case "REGRESSION: if-then-else formatting" `Quick test_if_then_else_formatting;
    Alcotest.test_case "tuple literal formatting" `Quick test_tuple_literal_formatting;
    Alcotest.test_case "REGRESSION CRITICAL: negative rational formatting" `Quick test_literal_negative_rational;
    Alcotest.test_case "variable name sanitization" `Quick test_variable_name_sanitization;
  ]
end

(** {1 Test Category 4: Split Wrapper Generation} *)

module SplitWrapperTests = struct
  open Helpers

  let mk_input_info name ty =
    let var = ScopeVar.fresh (name, Pos.void) in
    ({ var_name = var; var_state = None; var_type = ty;
       io_input = Mark.add Pos.void Runtime.OnlyInput } : Lean4_desugared.input_info)

  let mk_context_info name ty =
    let var = ScopeVar.fresh (name, Pos.void) in
    ({ ctx_var_name = var; ctx_state = None; ctx_var_type = ty;
       ctx_io_input = Mark.add Pos.void Runtime.Reentrant;
       ctx_default = None } : Lean4_desugared.context_var_info)

  let mk_input_info_with_state name state_name ty =
    let var = ScopeVar.fresh (name, Pos.void) in
    let state = StateName.fresh (state_name, Pos.void) in
    ({ var_name = var; var_state = Some state; var_type = ty;
       io_input = Mark.add Pos.void Runtime.OnlyInput } : Lean4_desugared.input_info)

  let mk_context_info_with_state name state_name ty =
    let var = ScopeVar.fresh (name, Pos.void) in
    let state = StateName.fresh (state_name, Pos.void) in
    ({ ctx_var_name = var; ctx_state = Some state; ctx_var_type = ty;
       ctx_io_input = Mark.add Pos.void Runtime.Reentrant;
       ctx_default = None } : Lean4_desugared.context_var_info)

  let test_pure_inputs_only () =
    let inputs = [
      mk_input_info "tax_year" (mk_int_ty ());
      mk_input_info "income" (mk_money_ty ());
    ] in
    let result = Lean4_desugared.format_split_wrapper "MyScope" "myScope" inputs [] in
    check_contains ~msg:"PureInput struct declared"
      result "structure MyScope_PureInput where";
    check_contains ~msg:"pure field tax_year"
      result "tax_year : Int";
    check_contains ~msg:"pure field income"
      result "income : CatalaRuntime.Money";
    check_contains ~msg:"ContextInput struct declared"
      result "structure MyScope_ContextInput where";
    check_contains ~msg:"theorem wrapper declared"
      result "def myScope_theorem";
    check_contains ~msg:"wrapper takes pure param"
      result "(pure : MyScope_PureInput)";
    check_contains ~msg:"wrapper takes ctx param with default"
      result "(ctx : MyScope_ContextInput := {})";
    check_contains ~msg:"wrapper maps pure.tax_year"
      result "tax_year := pure.tax_year";
    check_contains ~msg:"wrapper maps pure.income"
      result "income := pure.income";
    check_contains ~msg:"wrapper is reducible"
      result "@[simp, reducible]"

  let test_context_inputs_only () =
    let contexts = [
      mk_context_info "is_married" (mk_bool_ty ());
      mk_context_info "deduction" (mk_money_ty ());
    ] in
    let result = Lean4_desugared.format_split_wrapper "MyScope" "myScope" [] contexts in
    check_contains ~msg:"PureInput struct declared"
      result "structure MyScope_PureInput where";
    check_contains ~msg:"ContextInput has is_married"
      result "is_married : Option Bool := none";
    check_contains ~msg:"ContextInput has deduction"
      result "deduction : Option CatalaRuntime.Money := none";
    check_contains ~msg:"wrapper maps ctx.is_married"
      result "is_married := ctx.is_married";
    check_contains ~msg:"wrapper maps ctx.deduction"
      result "deduction := ctx.deduction"

  let test_mixed_inputs () =
    let inputs = [
      mk_input_info "persons" (mk_list_ty (mk_bool_ty ()));
      mk_input_info "tax_year" (mk_int_ty ());
    ] in
    let contexts = [
      mk_context_info "adjusted_gross_income" (mk_money_ty ());
      mk_context_info "is_dependent" (mk_bool_ty ());
    ] in
    let result = Lean4_desugared.format_split_wrapper "TaxCalc" "taxCalc" inputs contexts in
    check_contains ~msg:"PureInput has persons"
      result "persons : (List Bool)";
    check_contains ~msg:"PureInput has tax_year"
      result "tax_year : Int";
    check_contains ~msg:"ContextInput has adjusted_gross_income"
      result "adjusted_gross_income : Option CatalaRuntime.Money := none";
    check_contains ~msg:"ContextInput has is_dependent"
      result "is_dependent : Option Bool := none";
    check_contains ~msg:"pure field mapped with pure prefix"
      result "persons := pure.persons";
    check_contains ~msg:"context field mapped with ctx prefix"
      result "adjusted_gross_income := ctx.adjusted_gross_income";
    check_contains ~msg:"wrapper calls original function"
      result "taxCalc {";
    check_contains ~msg:"wrapper returns correct type"
      result ": TaxCalc :="

  let test_state_qualified_variables () =
    let inputs = [
      mk_input_info_with_state "foo" "s1" (mk_int_ty ());
    ] in
    let contexts = [
      mk_context_info_with_state "bar" "s2" (mk_bool_ty ());
    ] in
    let result = Lean4_desugared.format_split_wrapper "MyScope" "myScope" inputs contexts in
    check_contains ~msg:"state-qualified pure field"
      result "foo_s1 : Int";
    check_contains ~msg:"state-qualified context field"
      result "bar_s2 : Option Bool := none";
    check_contains ~msg:"state-qualified pure mapping"
      result "foo_s1 := pure.foo_s1";
    check_contains ~msg:"state-qualified context mapping"
      result "bar_s2 := ctx.bar_s2"

  let test_empty_scope () =
    let result = Lean4_desugared.format_split_wrapper "Empty" "empty" [] [] in
    check_contains ~msg:"PureInput struct exists"
      result "structure Empty_PureInput where";
    check_contains ~msg:"ContextInput struct exists"
      result "structure Empty_ContextInput where";
    check_contains ~msg:"theorem wrapper exists"
      result "def empty_theorem"

  let suite = [
    Alcotest.test_case "split wrapper: pure inputs only" `Quick test_pure_inputs_only;
    Alcotest.test_case "split wrapper: context inputs only" `Quick test_context_inputs_only;
    Alcotest.test_case "split wrapper: mixed inputs" `Quick test_mixed_inputs;
    Alcotest.test_case "split wrapper: state-qualified variables" `Quick test_state_qualified_variables;
    Alcotest.test_case "split wrapper: empty scope" `Quick test_empty_scope;
  ]
end

(** {1 Test Category 5: Beta-Reduction (Transformation C)} *)

module BetaReductionTests = struct
  open Helpers

  (** Test: Simple immediate lambda application → let binding.
      (fun (x : Int) => x) 42  →  (let x : Int := 42; x) *)
  let test_simple_identity () =
    let int_ty = mk_int_ty () in
    let app = mk_abs_app "x" int_ty (fun x -> x) (mk_int 42) in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has let binding" formatted "let";
    check_contains ~msg:"has variable x" formatted "x :";
    check_contains ~msg:"has Int type" formatted "Int";
    check_contains ~msg:"has value 42" formatted "42";
    check_not_contains ~msg:"no fun keyword" formatted "fun"

  (** Test: Lambda with computation body.
      (fun (y : Int) => y + 1) 10  →  (let y : Int := 10; (y + ...)) *)
  let test_computation_body () =
    let int_ty = mk_int_ty () in
    let app = mk_abs_app "y" int_ty
      (fun y ->
        mk_appop (Mark.add Pos.void Op.Add) [y; mk_int 1])
      (mk_int 10)
    in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has let" formatted "let y";
    check_contains ~msg:"has value 10" formatted "10";
    check_contains ~msg:"has addition" formatted "+";
    check_not_contains ~msg:"no fun" formatted "fun"

  (** Test: Unit parameter is skipped entirely.
      (fun () => 42) ()  →  42 *)
  let test_unit_param_skipped () =
    let unit_ty = mk_unit_ty () in
    let app = mk_abs_app "unused" unit_ty
      (fun _u -> mk_int 42)
      (mk_unit ())
    in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has 42" formatted "42";
    check_not_contains ~msg:"no let binding" formatted "let";
    check_not_contains ~msg:"no fun" formatted "fun"

  (** Test: Nested immediate lambda applications → nested let bindings.
      (fun (a : Int) => (fun (b : Int) => a + b) 20) 10
      →  (let a : Int := 10; (let b : Int := 20; a + b)) *)
  let test_nested_lambdas () =
    let int_ty = mk_int_ty () in
    let app = mk_abs_app "a" int_ty
      (fun a ->
        mk_abs_app "b" int_ty
          (fun b -> mk_appop (Mark.add Pos.void Op.Add) [a; b])
          (mk_int 20))
      (mk_int 10)
    in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has let a" formatted "let a";
    check_contains ~msg:"has let b" formatted "let b";
    check_contains ~msg:"has 10" formatted "10";
    check_contains ~msg:"has 20" formatted "20";
    check_not_contains ~msg:"no fun" formatted "fun"

  (** Test: Lambda passed as argument is NOT beta-reduced.
      f (fun (x : Int) => x)  →  (f (fun (x : Int) => x)) *)
  let test_lambda_as_arg_not_reduced () =
    let int_ty = mk_int_ty () in
    let f_var = mk_var "f" in
    let lambda = mk_abs "x" int_ty (fun x -> x) in
    let app = mk_app f_var [lambda] in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has fun" formatted "fun";
    check_contains ~msg:"has f" formatted "f";
    check_not_contains ~msg:"no let" formatted "let"

  (** Test: Normal function application is NOT beta-reduced.
      g 42  →  (g 42) *)
  let test_normal_app_not_reduced () =
    let f_var = mk_var "g" in
    let app = mk_app f_var [mk_int 42] in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has g" formatted "g";
    check_contains ~msg:"has 42" formatted "42";
    check_not_contains ~msg:"no let" formatted "let";
    check_not_contains ~msg:"no fun" formatted "fun"

  (** Test: Bool-typed let binding.
      (fun (flag : Bool) => if flag then 1 else 0) true *)
  let test_bool_typed_let () =
    let bool_ty = mk_bool_ty () in
    let app = mk_abs_app "flag" bool_ty
      (fun flag -> mk_if flag (mk_int 1) (mk_int 0))
      (mk_bool true)
    in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has let flag" formatted "let flag";
    check_contains ~msg:"has Bool type" formatted "Bool";
    check_contains ~msg:"has true value" formatted "true";
    check_not_contains ~msg:"no fun" formatted "fun"

  (** Test: Money-typed let binding preserves type annotation. *)
  let test_money_typed_let () =
    let money_ty = mk_money_ty () in
    let app = mk_abs_app "amount" money_ty
      (fun amount -> amount)
      (mk_money 1000)
    in
    let formatted = format_expr (Expr.unbox app) in
    check_contains ~msg:"has let amount" formatted "let amount";
    check_contains ~msg:"has Money type" formatted "CatalaRuntime.Money";
    check_not_contains ~msg:"no fun" formatted "fun"

  let suite = [
    Alcotest.test_case "simple identity lambda" `Quick test_simple_identity;
    Alcotest.test_case "computation body" `Quick test_computation_body;
    Alcotest.test_case "unit param skipped" `Quick test_unit_param_skipped;
    Alcotest.test_case "nested lambdas" `Quick test_nested_lambdas;
    Alcotest.test_case "lambda as arg not reduced" `Quick test_lambda_as_arg_not_reduced;
    Alcotest.test_case "normal app not reduced" `Quick test_normal_app_not_reduced;
    Alcotest.test_case "bool-typed let" `Quick test_bool_typed_let;
    Alcotest.test_case "money-typed let" `Quick test_money_typed_let;
  ]
end

(** {1 Test Category 6: strip_outer_decide} *)

module StripOuterDecideTests = struct

  let test_standalone_single_paren () =
    let result = strip_outer_decide "(decide (x = y))" in
    Alcotest.(check string) "single outer paren" "(x = y)" result

  let test_standalone_double_paren () =
    let result = strip_outer_decide "((decide (x = y)))" in
    Alcotest.(check string) "double outer paren" "(x = y)" result

  let test_standalone_triple_paren () =
    let result = strip_outer_decide "(((decide (x = y))))" in
    Alcotest.(check string) "triple outer paren" "(x = y)" result

  let test_no_outer_paren () =
    let result = strip_outer_decide "decide (x = y)" in
    Alcotest.(check string) "no outer paren" "(x = y)" result

  let test_nested_inner_parens () =
    let result = strip_outer_decide "(decide ((a + b) = (c + d)))" in
    Alcotest.(check string) "nested inner parens" "((a + b) = (c + d))" result

  let test_compound_and_unchanged () =
    let input = "((decide (a = b)) && (decide (c = d)))" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "compound && unchanged" input result

  let test_compound_or_unchanged () =
    let input = "((decide (x > 0)) || (decide (y < 10)))" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "compound || unchanged" input result

  let test_negation_unchanged () =
    let input = "(!(decide (x = y)))" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "negation unchanged" input result

  let test_bool_var_unchanged () =
    let input = "my_flag" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "bool var unchanged" input result

  let test_function_call_unchanged () =
    let input = "(f x)" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "function call unchanged" input result

  let test_bool_literal_unchanged () =
    let input = "true" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "bool literal unchanged" input result

  let test_empty_string () =
    let result = strip_outer_decide "" in
    Alcotest.(check string) "empty string" "" result

  let test_decide_no_arg_paren () =
    let input = "decide x" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "decide without arg parens unchanged" input result

  let test_decide_partial_coverage () =
    let input = "(decide (a = b) && something_else)" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "decide partial coverage unchanged" input result

  let test_realistic_comparison () =
    let result = strip_outer_decide "(decide (income ≤ (CatalaRuntime.Money.ofCents 3690000)))" in
    Alcotest.(check string) "realistic money comparison"
      "(income ≤ (CatalaRuntime.Money.ofCents 3690000))" result

  let test_realistic_equality () =
    let result = strip_outer_decide "(decide (((m).spouse_1).id = (p).id))" in
    Alcotest.(check string) "realistic struct equality"
      "(((m).spouse_1).id = (p).id)" result

  let test_realistic_compound_unchanged () =
    let input = "((decide (((m).spouse_1).id = (p).id)) || (decide (((m).spouse_2).id = (p).id)))" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "realistic compound unchanged" input result

  let test_decide_keyword_in_varname () =
    let input = "decide_result" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "decide in varname unchanged" input result

  let test_only_parens () =
    let input = "((()))" in
    let result = strip_outer_decide input in
    Alcotest.(check string) "only parens unchanged" input result

  let suite = [
    Alcotest.test_case "standalone single paren" `Quick test_standalone_single_paren;
    Alcotest.test_case "standalone double paren" `Quick test_standalone_double_paren;
    Alcotest.test_case "standalone triple paren" `Quick test_standalone_triple_paren;
    Alcotest.test_case "no outer paren" `Quick test_no_outer_paren;
    Alcotest.test_case "nested inner parens" `Quick test_nested_inner_parens;
    Alcotest.test_case "compound && unchanged" `Quick test_compound_and_unchanged;
    Alcotest.test_case "compound || unchanged" `Quick test_compound_or_unchanged;
    Alcotest.test_case "negation unchanged" `Quick test_negation_unchanged;
    Alcotest.test_case "bool var unchanged" `Quick test_bool_var_unchanged;
    Alcotest.test_case "function call unchanged" `Quick test_function_call_unchanged;
    Alcotest.test_case "bool literal unchanged" `Quick test_bool_literal_unchanged;
    Alcotest.test_case "empty string" `Quick test_empty_string;
    Alcotest.test_case "decide without arg parens" `Quick test_decide_no_arg_paren;
    Alcotest.test_case "decide partial coverage" `Quick test_decide_partial_coverage;
    Alcotest.test_case "realistic money comparison" `Quick test_realistic_comparison;
    Alcotest.test_case "realistic struct equality" `Quick test_realistic_equality;
    Alcotest.test_case "realistic compound unchanged" `Quick test_realistic_compound_unchanged;
    Alcotest.test_case "decide in varname" `Quick test_decide_keyword_in_varname;
    Alcotest.test_case "only parens unchanged" `Quick test_only_parens;
  ]
end

(** {1 Test Category 7: expr_uses_var (P3 helper)} *)

module ExprUsesVarTests = struct
  open Helpers

  let mk_named_var name =
    Var.make name

  let evar v = Expr.evar v nomark

  (** Variable directly referenced *)
  let test_var_found () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (evar v) in
    Alcotest.(check bool) "var found" true (expr_uses_var v e)

  (** A different variable with same name is NOT the same variable *)
  let test_different_var_same_name () =
    let v1 = mk_named_var "x" in
    let v2 = mk_named_var "x" in
    let e = Expr.unbox (evar v2) in
    Alcotest.(check bool) "different var same name" false (expr_uses_var v1 e)

  (** Literal contains no variables *)
  let test_literal_no_var () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_int 42) in
    Alcotest.(check bool) "literal has no var" false (expr_uses_var v e)

  (** Boolean literal *)
  let test_bool_literal () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_bool true) in
    Alcotest.(check bool) "bool literal" false (expr_uses_var v e)

  (** Variable in function position of EApp *)
  let test_var_in_app_function () =
    let v = mk_named_var "f" in
    let e = Expr.unbox (mk_app (evar v) [mk_int 1]) in
    Alcotest.(check bool) "var in app function" true (expr_uses_var v e)

  (** Variable in argument position of EApp *)
  let test_var_in_app_arg () =
    let v = mk_named_var "x" in
    let f = mk_var "g" in
    let e = Expr.unbox (mk_app f [evar v]) in
    Alcotest.(check bool) "var in app arg" true (expr_uses_var v e)

  (** Variable not in EApp at all *)
  let test_var_not_in_app () =
    let v = mk_named_var "x" in
    let f = mk_var "g" in
    let e = Expr.unbox (mk_app f [mk_int 1]) in
    Alcotest.(check bool) "var not in app" false (expr_uses_var v e)

  (** Variable in EAppOp argument *)
  let test_var_in_appop () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_appop (Mark.add Pos.void Op.Not) [evar v]) in
    Alcotest.(check bool) "var in appop" true (expr_uses_var v e)

  (** Variable not in EAppOp *)
  let test_var_not_in_appop () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_appop (Mark.add Pos.void Op.Not) [mk_bool true]) in
    Alcotest.(check bool) "var not in appop" false (expr_uses_var v e)

  (** Variable in if-then-else condition *)
  let test_var_in_if_cond () =
    let v = mk_named_var "flag" in
    let e = Expr.unbox (mk_if (evar v) (mk_int 1) (mk_int 0)) in
    Alcotest.(check bool) "var in if cond" true (expr_uses_var v e)

  (** Variable in if-then-else true branch *)
  let test_var_in_if_true () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_if (mk_bool true) (evar v) (mk_int 0)) in
    Alcotest.(check bool) "var in if true" true (expr_uses_var v e)

  (** Variable in if-then-else false branch *)
  let test_var_in_if_false () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_if (mk_bool true) (mk_int 1) (evar v)) in
    Alcotest.(check bool) "var in if false" true (expr_uses_var v e)

  (** Variable not in if-then-else *)
  let test_var_not_in_if () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_if (mk_bool true) (mk_int 1) (mk_int 0)) in
    Alcotest.(check bool) "var not in if" false (expr_uses_var v e)

  (** Variable in tuple element *)
  let test_var_in_tuple () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_tuple [mk_int 1; evar v; mk_int 3]) in
    Alcotest.(check bool) "var in tuple" true (expr_uses_var v e)

  (** Variable not in tuple *)
  let test_var_not_in_tuple () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_tuple [mk_int 1; mk_int 2]) in
    Alcotest.(check bool) "var not in tuple" false (expr_uses_var v e)

  (** Variable in tuple access expression *)
  let test_var_in_tuple_access () =
    let v = mk_named_var "t" in
    let e = Expr.unbox (mk_tuple_access (evar v) 0 2) in
    Alcotest.(check bool) "var in tuple access" true (expr_uses_var v e)

  (** Variable inside EAbs body (free occurrence) *)
  let test_var_in_abs_body_free () =
    let outer = mk_named_var "outer" in
    let abs = mk_abs "y" (mk_int_ty ()) (fun _y -> evar outer) in
    let e = Expr.unbox abs in
    Alcotest.(check bool) "free var in abs body" true (expr_uses_var outer e)

  (** Variable bound by EAbs — still detected by expr_uses_var because
      Bindlib.unmbind substitutes fresh variables, so the original target
      variable won't appear as the bound variable. However, if the body
      only uses the bound variable (not target), expr_uses_var returns false. *)
  let test_var_not_free_in_abs () =
    let outer = mk_named_var "outer" in
    let abs = mk_abs "x" (mk_int_ty ()) (fun x -> x) in
    let e = Expr.unbox abs in
    Alcotest.(check bool) "bound-only var not found" false (expr_uses_var outer e)

  (** Variable in deeply nested expression *)
  let test_var_deeply_nested () =
    let v = mk_named_var "deep" in
    let inner = mk_if (mk_bool true) (evar v) (mk_int 0) in
    let mid = mk_app (mk_var "f") [inner] in
    let outer = mk_tuple [mk_int 1; mid] in
    let e = Expr.unbox outer in
    Alcotest.(check bool) "var deeply nested" true (expr_uses_var v e)

  (** Variable not in deeply nested expression *)
  let test_var_not_deeply_nested () =
    let v = mk_named_var "missing" in
    let inner = mk_if (mk_bool true) (mk_int 1) (mk_int 0) in
    let mid = mk_app (mk_var "f") [inner] in
    let outer = mk_tuple [mk_int 1; mid] in
    let e = Expr.unbox outer in
    Alcotest.(check bool) "var not deeply nested" false (expr_uses_var v e)

  (** Multiple occurrences of same variable *)
  let test_multiple_occurrences () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (mk_appop (Mark.add Pos.void Op.Add) [evar v; evar v]) in
    Alcotest.(check bool) "multiple occurrences" true (expr_uses_var v e)

  (** Variable in EArray *)
  let test_var_in_array () =
    let v = mk_named_var "x" in
    let arr = Expr.earray [mk_int 1; evar v; mk_int 3] nomark in
    let e = Expr.unbox arr in
    Alcotest.(check bool) "var in array" true (expr_uses_var v e)

  (** Variable not in EArray *)
  let test_var_not_in_array () =
    let v = mk_named_var "x" in
    let arr = Expr.earray [mk_int 1; mk_int 2] nomark in
    let e = Expr.unbox arr in
    Alcotest.(check bool) "var not in array" false (expr_uses_var v e)

  (** EFatalError has no variables *)
  let test_fatal_error () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.efatalerror Runtime.NoValue nomark) in
    Alcotest.(check bool) "fatal error" false (expr_uses_var v e)

  (** EPureDefault wrapping *)
  let test_var_in_pure_default () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.epuredefault (evar v) nomark) in
    Alcotest.(check bool) "var in pure default" true (expr_uses_var v e)

  (** EErrorOnEmpty wrapping *)
  let test_var_in_error_on_empty () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.eerroronempty (evar v) nomark) in
    Alcotest.(check bool) "var in error on empty" true (expr_uses_var v e)

  (** EDefault — variable in just *)
  let test_var_in_default_just () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.edefault ~excepts:[] ~just:(evar v) ~cons:(mk_int 1) nomark) in
    Alcotest.(check bool) "var in default just" true (expr_uses_var v e)

  (** EDefault — variable in cons *)
  let test_var_in_default_cons () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.edefault ~excepts:[] ~just:(mk_bool true) ~cons:(evar v) nomark) in
    Alcotest.(check bool) "var in default cons" true (expr_uses_var v e)

  (** EDefault — variable in excepts *)
  let test_var_in_default_excepts () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.edefault ~excepts:[evar v] ~just:(mk_bool true) ~cons:(mk_int 1) nomark) in
    Alcotest.(check bool) "var in default excepts" true (expr_uses_var v e)

  (** EDefault — variable not present *)
  let test_var_not_in_default () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.edefault ~excepts:[] ~just:(mk_bool true) ~cons:(mk_int 1) nomark) in
    Alcotest.(check bool) "var not in default" false (expr_uses_var v e)

  (** EEmpty has no variables *)
  let test_empty () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.eempty nomark) in
    Alcotest.(check bool) "empty" false (expr_uses_var v e)

  (** EAssert wrapping *)
  let test_var_in_assert () =
    let v = mk_named_var "x" in
    let e = Expr.unbox (Expr.eassert (evar v) nomark) in
    Alcotest.(check bool) "var in assert" true (expr_uses_var v e)

  let suite = [
    Alcotest.test_case "var directly referenced" `Quick test_var_found;
    Alcotest.test_case "different var same name" `Quick test_different_var_same_name;
    Alcotest.test_case "literal has no var" `Quick test_literal_no_var;
    Alcotest.test_case "bool literal" `Quick test_bool_literal;
    Alcotest.test_case "var in app function" `Quick test_var_in_app_function;
    Alcotest.test_case "var in app arg" `Quick test_var_in_app_arg;
    Alcotest.test_case "var not in app" `Quick test_var_not_in_app;
    Alcotest.test_case "var in appop" `Quick test_var_in_appop;
    Alcotest.test_case "var not in appop" `Quick test_var_not_in_appop;
    Alcotest.test_case "var in if cond" `Quick test_var_in_if_cond;
    Alcotest.test_case "var in if true branch" `Quick test_var_in_if_true;
    Alcotest.test_case "var in if false branch" `Quick test_var_in_if_false;
    Alcotest.test_case "var not in if" `Quick test_var_not_in_if;
    Alcotest.test_case "var in tuple" `Quick test_var_in_tuple;
    Alcotest.test_case "var not in tuple" `Quick test_var_not_in_tuple;
    Alcotest.test_case "var in tuple access" `Quick test_var_in_tuple_access;
    Alcotest.test_case "free var in abs body" `Quick test_var_in_abs_body_free;
    Alcotest.test_case "bound-only var not found" `Quick test_var_not_free_in_abs;
    Alcotest.test_case "var deeply nested" `Quick test_var_deeply_nested;
    Alcotest.test_case "var not deeply nested" `Quick test_var_not_deeply_nested;
    Alcotest.test_case "multiple occurrences" `Quick test_multiple_occurrences;
    Alcotest.test_case "var in array" `Quick test_var_in_array;
    Alcotest.test_case "var not in array" `Quick test_var_not_in_array;
    Alcotest.test_case "fatal error" `Quick test_fatal_error;
    Alcotest.test_case "var in pure default" `Quick test_var_in_pure_default;
    Alcotest.test_case "var in error on empty" `Quick test_var_in_error_on_empty;
    Alcotest.test_case "var in default just" `Quick test_var_in_default_just;
    Alcotest.test_case "var in default cons" `Quick test_var_in_default_cons;
    Alcotest.test_case "var in default excepts" `Quick test_var_in_default_excepts;
    Alcotest.test_case "var not in default" `Quick test_var_not_in_default;
    Alcotest.test_case "empty expr" `Quick test_empty;
    Alcotest.test_case "var in assert" `Quick test_var_in_assert;
  ]
end

(** {1 Test Category 8: Arithmetic Operator Formatting} *)

module ArithmeticOperatorTests = struct
  open Helpers

  (** {2 Baseline: Add, Sub, Div use binop style} *)

  let test_add_uses_binop () =
    let a = mk_var "a" in
    let b = mk_var "b" in
    let expr = mk_appop (Mark.add Pos.void Op.Add) [a; b] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Add uses infix +"
      "(a + b)" formatted

  let test_sub_uses_binop () =
    let a = mk_var "a" in
    let b = mk_var "b" in
    let expr = mk_appop (Mark.add Pos.void Op.Sub) [a; b] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Sub uses infix -"
      "(a - b)" formatted

  let test_div_uses_binop () =
    let a = mk_var "a" in
    let b = mk_var "b" in
    let expr = mk_appop (Mark.add Pos.void Op.Div) [a; b] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Div uses infix /"
      "(a / b)" formatted

  (** {2 Mult uses infix * (HMul via binop)}

      Each type combination below requires a corresponding HMul instance
      in CatalaRuntime.lean. The translator emits (a * b) which Lean
      desugars to HMul.hMul a b, resolved by typeclass inference. *)

  (** Int * Int — covered by Lean's built-in Mul Int *)
  let test_mult_int_int () =
    let a = mk_var "count" in
    let b = mk_var "factor" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [a; b] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Int*Int"
      "(count * factor)" formatted

  (** Rat * Rat — covered by Lean's built-in Mul Rat *)
  let test_mult_rat_rat () =
    let a = mk_var "rate1" in
    let b = mk_var "rate2" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [a; b] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Rat*Rat"
      "(rate1 * rate2)" formatted

  (** Money * Int — HMul Money Int Money instance *)
  let test_mult_money_int () =
    let m = mk_var "salary" in
    let n = mk_var "months" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [m; n] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Money*Int"
      "(salary * months)" formatted

  (** Int * Money — HMul Int Money Money instance *)
  let test_mult_int_money () =
    let n = mk_var "months" in
    let m = mk_var "salary" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [n; m] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Int*Money"
      "(months * salary)" formatted

  (** Money * Rat — HMul Money Rat Money instance *)
  let test_mult_money_rat () =
    let m = mk_var "gross_income" in
    let r = mk_var "tax_rate" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [m; r] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Money*Rat"
      "(gross_income * tax_rate)" formatted

  (** Rat * Money — HMul Rat Money Money instance *)
  let test_mult_rat_money () =
    let r = mk_var "tax_rate" in
    let m = mk_var "gross_income" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [r; m] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Rat*Money"
      "(tax_rate * gross_income)" formatted

  (** Duration * Int — HMul Duration Int Duration instance *)
  let test_mult_duration_int () =
    let d = mk_var "one_year" in
    let n = mk_var "years" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [d; n] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Duration*Int"
      "(one_year * years)" formatted

  (** Int * Duration — HMul Int Duration Duration instance *)
  let test_mult_int_duration () =
    let n = mk_var "years" in
    let d = mk_var "one_year" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [n; d] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "Mult Int*Duration"
      "(years * one_year)" formatted

  (** {2 Mult with literal arguments} *)

  (** Literal int * literal int *)
  let test_mult_literal_ints () =
    let a = mk_int 3 in
    let b = mk_int 7 in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [a; b] in
    let formatted = format_expr (Expr.unbox expr) in
    check_contains ~msg:"has * operator" formatted "*";
    check_contains ~msg:"has 3" formatted "3";
    check_contains ~msg:"has 7" formatted "7"

  (** Literal money * literal int *)
  let test_mult_literal_money_int () =
    let m = mk_money 5000 in
    let n = mk_int 12 in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [m; n] in
    let formatted = format_expr (Expr.unbox expr) in
    check_contains ~msg:"has * operator" formatted "*";
    check_contains ~msg:"has Money literal" formatted "CatalaRuntime.Money.ofCents";
    check_contains ~msg:"has int 12" formatted "12"

  (** Variable * literal rational *)
  let test_mult_var_literal_rat () =
    let m = mk_var "income" in
    let r = mk_rat 15 100 in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [m; r] in
    let formatted = format_expr (Expr.unbox expr) in
    check_contains ~msg:"has * operator" formatted "*";
    check_contains ~msg:"has income" formatted "income";
    check_contains ~msg:"has Rat.mk" formatted "Rat.mk"

  (** {2 Mult in compound expressions} *)

  (** Nested multiplication: (a * b) * c *)
  let test_mult_nested () =
    let a = mk_var "a" in
    let b = mk_var "b" in
    let c = mk_var "c" in
    let inner = mk_appop (Mark.add Pos.void Op.Mult) [a; b] in
    let outer = mk_appop (Mark.add Pos.void Op.Mult) [inner; c] in
    let formatted = format_expr (Expr.unbox outer) in
    Alcotest.(check string) "nested mult" "((a * b) * c)" formatted

  (** Multiplication inside if-then-else *)
  let test_mult_in_conditional () =
    let income = mk_var "income" in
    let high_rate = mk_var "high_rate" in
    let low_rate = mk_var "low_rate" in
    let cond = mk_bool true in
    let then_branch = mk_appop (Mark.add Pos.void Op.Mult) [income; high_rate] in
    let else_branch = mk_appop (Mark.add Pos.void Op.Mult) [income; low_rate] in
    let expr = mk_if cond then_branch else_branch in
    let formatted = format_expr (Expr.unbox expr) in
    check_contains ~msg:"has if" formatted "if";
    check_contains ~msg:"has * in then branch" formatted "(income * high_rate)";
    check_contains ~msg:"has * in else branch" formatted "(income * low_rate)"

  (** Addition of two multiplications: (a*b) + (c*d) *)
  let test_mult_in_addition () =
    let a = mk_var "base" in
    let b = mk_var "rate" in
    let c = mk_var "bonus" in
    let d = mk_var "factor" in
    let left = mk_appop (Mark.add Pos.void Op.Mult) [a; b] in
    let right = mk_appop (Mark.add Pos.void Op.Mult) [c; d] in
    let expr = mk_appop (Mark.add Pos.void Op.Add) [left; right] in
    let formatted = format_expr (Expr.unbox expr) in
    Alcotest.(check string) "mult in addition"
      "((base * rate) + (bonus * factor))" formatted

  (** {2 Edge cases} *)

  let test_mult_wrong_arg_count () =
    let a = mk_var "a" in
    let expr = mk_appop (Mark.add Pos.void Op.Mult) [a] in
    let formatted = format_expr (Expr.unbox expr) in
    check_contains ~msg:"fallback on wrong arity" formatted "default"

  let suite = [
    Alcotest.test_case "Add uses binop +" `Quick test_add_uses_binop;
    Alcotest.test_case "Sub uses binop -" `Quick test_sub_uses_binop;
    Alcotest.test_case "Div uses binop /" `Quick test_div_uses_binop;
    Alcotest.test_case "Mult Int*Int" `Quick test_mult_int_int;
    Alcotest.test_case "Mult Rat*Rat" `Quick test_mult_rat_rat;
    Alcotest.test_case "Mult Money*Int" `Quick test_mult_money_int;
    Alcotest.test_case "Mult Int*Money (reversed)" `Quick test_mult_int_money;
    Alcotest.test_case "Mult Money*Rat" `Quick test_mult_money_rat;
    Alcotest.test_case "Mult Rat*Money (reversed)" `Quick test_mult_rat_money;
    Alcotest.test_case "Mult Duration*Int" `Quick test_mult_duration_int;
    Alcotest.test_case "Mult Int*Duration (reversed)" `Quick test_mult_int_duration;
    Alcotest.test_case "Mult literal ints" `Quick test_mult_literal_ints;
    Alcotest.test_case "Mult literal Money*Int" `Quick test_mult_literal_money_int;
    Alcotest.test_case "Mult var * literal Rat" `Quick test_mult_var_literal_rat;
    Alcotest.test_case "Mult nested" `Quick test_mult_nested;
    Alcotest.test_case "Mult in conditional" `Quick test_mult_in_conditional;
    Alcotest.test_case "Mult in addition" `Quick test_mult_in_addition;
    Alcotest.test_case "Mult wrong arg count" `Quick test_mult_wrong_arg_count;
  ]
end

(** {1 Test Category 9: try_fold_to_any_all (P3 pattern detection)} *)

module FoldToAnyAllTests = struct
  open Helpers

  let mk_named_var name =
    Var.make name

  let evar v = Expr.evar v nomark

  (** Build a Fold(fn, init, collection) expression and format it.
      Returns the formatted string for the whole EAppOp Fold. *)
  let format_fold fn init collection =
    let fold_expr = Expr.eappop
      ~op:(Mark.add Pos.void Op.Fold)
      ~args:[fn; init; collection]
      ~tys:[] nomark in
    format_expr (Expr.unbox fold_expr)

  (** Build an EAbs with given variables, types, and body *)
  let mk_fold_fn vars tys body_fn =
    let var_exprs = Array.map (fun v -> Expr.evar v nomark) vars in
    let body = body_fn var_exprs in
    let binder = Bindlib.bind_mvar vars (Expr.Box.lift body) in
    Expr.eabs_ghost binder tys nomark

  (** Test: Exists pattern — List.foldl (fun acc x => acc || pred(x)) false list
      should become List.any (fun x => pred(x)) list *)
  let test_exists_pattern () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let acc_e = vars.(0) in
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.Or) [acc_e; x_e]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_bool true; mk_bool false] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"uses List.any" result "List.any";
    check_not_contains ~msg:"no List.foldl" result "List.foldl";
    check_contains ~msg:"has lambda" result "fun"

  (** Test: Forall pattern — List.foldl (fun acc x => acc && pred(x)) true list
      should become List.all (fun x => pred(x)) list *)
  let test_forall_pattern () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let acc_e = vars.(0) in
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.And) [acc_e; x_e]
    ) in
    let init = mk_bool true in
    let collection = Expr.earray [mk_bool true; mk_bool false] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"uses List.all" result "List.all";
    check_not_contains ~msg:"no List.foldl" result "List.foldl";
    check_contains ~msg:"has lambda" result "fun"

  (** Test: Non-boolean init — should stay as List.foldl *)
  let test_non_bool_init () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let int_ty = mk_int_ty () in
    let fn = mk_fold_fn [|acc; x|] [int_ty; int_ty] (fun vars ->
      let acc_e = vars.(0) in
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.Add) [acc_e; x_e]
    ) in
    let init = mk_int 0 in
    let collection = Expr.earray [mk_int 1; mk_int 2] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"uses List.foldl" result "List.foldl";
    check_not_contains ~msg:"no List.any" result "List.any";
    check_not_contains ~msg:"no List.all" result "List.all"

  (** Test: Mismatched init/op — init=false but body uses && (should stay foldl) *)
  let test_mismatched_init_and_op () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let acc_e = vars.(0) in
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.And) [acc_e; x_e]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"stays as List.foldl" result "List.foldl"

  (** Test: Mismatched init/op — init=true but body uses || (should stay foldl) *)
  let test_mismatched_init_or_op () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let acc_e = vars.(0) in
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.Or) [acc_e; x_e]
    ) in
    let init = mk_bool true in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"stays as List.foldl" result "List.foldl"

  (** Test: Predicate uses accumulator — safety check prevents transformation *)
  let test_pred_uses_acc_exists () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let acc_e = vars.(0) in
      let pred = mk_appop (Mark.add Pos.void Op.And) [vars.(1); vars.(0)] in
      mk_appop (Mark.add Pos.void Op.Or) [acc_e; pred]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"stays as List.foldl due to acc in pred" result "List.foldl"

  (** Test: Predicate uses accumulator — safety check for forall *)
  let test_pred_uses_acc_forall () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let acc_e = vars.(0) in
      let pred = mk_appop (Mark.add Pos.void Op.Or) [vars.(1); vars.(0)] in
      mk_appop (Mark.add Pos.void Op.And) [acc_e; pred]
    ) in
    let init = mk_bool true in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"stays as List.foldl due to acc in pred" result "List.foldl"

  (** Test: Acc on rhs — body = pred || acc should still become List.any
      (handles Member desugaring where acc is on right side of ||) *)
  let test_acc_on_rhs () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let acc_e = vars.(0) in
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.Or) [x_e; acc_e]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"acc on rhs still List.any" result "List.any";
    check_not_contains ~msg:"no List.foldl" result "List.foldl"

  (** Test: Neither side is acc — should stay foldl *)
  let test_neither_side_acc () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; bool_ty] (fun vars ->
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.Or) [x_e; mk_bool true]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"stays as List.foldl" result "List.foldl"

  (** Test: Complex predicate — (fun acc x => acc || (x > 0)) false list
      should become List.any (fun x => ...) list *)
  let test_complex_predicate_exists () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let int_ty = mk_int_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; int_ty] (fun vars ->
      let acc_e = vars.(0) in
      let pred = mk_appop (Mark.add Pos.void Op.Gt) [vars.(1); mk_int 0] in
      mk_appop (Mark.add Pos.void Op.Or) [acc_e; pred]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_int 1; mk_int 2] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"uses List.any" result "List.any";
    check_not_contains ~msg:"no List.foldl" result "List.foldl";
    check_contains ~msg:"has comparison in predicate" result ">"

  (** Test: Complex predicate — (fun acc x => acc && (x > 0)) true list
      should become List.all (fun x => ...) list *)
  let test_complex_predicate_forall () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let int_ty = mk_int_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; int_ty] (fun vars ->
      let acc_e = vars.(0) in
      let pred = mk_appop (Mark.add Pos.void Op.Gt) [vars.(1); mk_int 0] in
      mk_appop (Mark.add Pos.void Op.And) [acc_e; pred]
    ) in
    let init = mk_bool true in
    let collection = Expr.earray [mk_int 1; mk_int 2] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"uses List.all" result "List.all";
    check_not_contains ~msg:"no List.foldl" result "List.foldl"

  (** Test: Only 1 param in fn (just acc, no predicate var) — should stay foldl *)
  let test_single_param_fn () =
    let acc = mk_named_var "_acc" in
    let bool_ty = mk_bool_ty () in
    let fn = mk_fold_fn [|acc|] [bool_ty] (fun vars ->
      mk_appop (Mark.add Pos.void Op.Not) [vars.(0)]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"stays as List.foldl" result "List.foldl"

  (** Test: fn is not EAbs (e.g. a variable reference) — should stay foldl *)
  let test_fn_not_abs () =
    let f = mk_var "myFolder" in
    let init = mk_bool false in
    let collection = Expr.earray [mk_bool true] nomark in
    let result = format_fold f init collection in
    check_contains ~msg:"stays as List.foldl" result "List.foldl"

  (** Test: Exists with type annotation in lambda output *)
  let test_exists_type_annotation () =
    let acc = mk_named_var "_acc" in
    let x = mk_named_var "x" in
    let bool_ty = mk_bool_ty () in
    let int_ty = mk_int_ty () in
    let fn = mk_fold_fn [|acc; x|] [bool_ty; int_ty] (fun vars ->
      let acc_e = vars.(0) in
      let x_e = vars.(1) in
      mk_appop (Mark.add Pos.void Op.Or) [acc_e; x_e]
    ) in
    let init = mk_bool false in
    let collection = Expr.earray [mk_int 1] nomark in
    let result = format_fold fn init collection in
    check_contains ~msg:"lambda has type annotation" result "(x : Int)";
    check_contains ~msg:"uses List.any" result "List.any"

  let suite = [
    Alcotest.test_case "exists pattern → List.any" `Quick test_exists_pattern;
    Alcotest.test_case "forall pattern → List.all" `Quick test_forall_pattern;
    Alcotest.test_case "non-bool init → List.foldl" `Quick test_non_bool_init;
    Alcotest.test_case "mismatched init(false)/op(&&) → List.foldl" `Quick test_mismatched_init_and_op;
    Alcotest.test_case "mismatched init(true)/op(||) → List.foldl" `Quick test_mismatched_init_or_op;
    Alcotest.test_case "pred uses acc (exists) → List.foldl" `Quick test_pred_uses_acc_exists;
    Alcotest.test_case "pred uses acc (forall) → List.foldl" `Quick test_pred_uses_acc_forall;
    Alcotest.test_case "acc on rhs → List.any" `Quick test_acc_on_rhs;
    Alcotest.test_case "neither side is acc → List.foldl" `Quick test_neither_side_acc;
    Alcotest.test_case "complex pred (exists) → List.any" `Quick test_complex_predicate_exists;
    Alcotest.test_case "complex pred (forall) → List.all" `Quick test_complex_predicate_forall;
    Alcotest.test_case "single param fn → List.foldl" `Quick test_single_param_fn;
    Alcotest.test_case "fn not EAbs → List.foldl" `Quick test_fn_not_abs;
    Alcotest.test_case "exists with type annotation" `Quick test_exists_type_annotation;
  ]
end

(** {1 Main Test Suite} *)

let suite = [
  ("Name Sanitization", NameSanitizationTests.suite);
  ("Detuplification & Function Application", DetuplificationTests.suite);
  ("Expression Formatting", ExpressionFormattingTests.suite);
  ("Split Wrapper Generation", SplitWrapperTests.suite);
  ("Beta-Reduction (Transformation C)", BetaReductionTests.suite);
  ("strip_outer_decide", StripOuterDecideTests.suite);
  ("expr_uses_var", ExprUsesVarTests.suite);
  ("Arithmetic Operators", ArithmeticOperatorTests.suite);
  ("Fold to Any/All (P3)", FoldToAnyAllTests.suite);
]
