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
      result "@[reducible]"

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

(** {1 Main Test Suite} *)

let suite = [
  ("Name Sanitization", NameSanitizationTests.suite);
  ("Detuplification & Function Application", DetuplificationTests.suite);
  ("Expression Formatting", ExpressionFormattingTests.suite);
  ("Split Wrapper Generation", SplitWrapperTests.suite);
]
