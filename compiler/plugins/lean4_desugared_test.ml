(* Unit tests for Lean4 desugared backend *)

open Catala_utils
open Shared_ast

module Runtime = Catala_runtime

(** {1 Test helpers} *)

(** Assert string equality *)
let assert_string_equal (expected : string) (actual : string) : unit =
  if expected <> actual then
    Alcotest.failf "Expected:\n%s\n\nGot:\n%s" expected actual

(** {1 Literal formatting tests} *)

let test_format_lit_bool_true () =
  let lit = LBool true in
  let result = Lean4_desugared.format_lit lit in
  assert_string_equal "true" result

let test_format_lit_bool_false () =
  let lit = LBool false in
  let result = Lean4_desugared.format_lit lit in
  assert_string_equal "false" result

let test_format_lit_int () =
  let lit = LInt (Runtime.integer_of_int 42) in
  let result = Lean4_desugared.format_lit lit in
  assert_string_equal "(42 : Int)" result

let test_format_lit_int_negative () =
  let lit = LInt (Runtime.integer_of_int (-123)) in
  let result = Lean4_desugared.format_lit lit in
  assert_string_equal "(-123 : Int)" result

let test_format_lit_unit () =
  let lit = LUnit in
  let result = Lean4_desugared.format_lit lit in
  assert_string_equal "()" result

let test_format_lit_money () =
  let lit = LMoney (Runtime.money_of_cents_integer (Runtime.integer_of_int 1000000)) in
  let result = Lean4_desugared.format_lit lit in
  assert_string_equal "(CatalaRuntime.Money.ofCents 1000000)" result

let test_format_lit_rat () =
  let lit = LRat (Q.of_ints 3 4) in
  let result = Lean4_desugared.format_lit lit in
  assert_string_equal "(Rat.mk 3 4)" result

(** {1 Type formatting tests} *)

let test_format_typ_unit () =
  let ty = TLit TUnit, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "Unit" result

let test_format_typ_bool () =
  let ty = TLit TBool, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "Bool" result

let test_format_typ_int () =
  let ty = TLit TInt, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "Int" result

let test_format_typ_rat () =
  let ty = TLit TRat, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "Rat" result

let test_format_typ_money () =
  let ty = TLit TMoney, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "CatalaRuntime.Money" result

let test_format_typ_date () =
  let ty = TLit TDate, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "CatalaRuntime.Date" result

let test_format_typ_duration () =
  let ty = TLit TDuration, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "CatalaRuntime.Duration" result

let test_format_typ_option () =
  let inner_ty = TLit TInt, Pos.void in
  let ty = TOption inner_ty, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "(Option Int)" result

let test_format_typ_array () =
  let inner_ty = TLit TBool, Pos.void in
  let ty = TArray inner_ty, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "(Array Bool)" result

let test_format_typ_tuple_2 () =
  let ty = TTuple [(TLit TInt, Pos.void); (TLit TBool, Pos.void)], Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "(Int × Bool)" result

let test_format_typ_tuple_3 () =
  let ty = TTuple [
    (TLit TInt, Pos.void);
    (TLit TBool, Pos.void);
    (TLit TMoney, Pos.void)
  ], Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "(Int × Bool × CatalaRuntime.Money)" result

let test_format_typ_option_of_tuple () =
  let inner_ty = TTuple [(TLit TInt, Pos.void); (TLit TBool, Pos.void)], Pos.void in
  let ty = TOption inner_ty, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "(Option (Int × Bool))" result

let test_format_typ_arrow_simple () =
  let arg_ty = TLit TInt, Pos.void in
  let ret_ty = TLit TBool, Pos.void in
  let ty = TArrow ([arg_ty], ret_ty), Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "(Int → Bool)" result

let test_format_typ_arrow_multiple_args () =
  let arg1_ty = TLit TInt, Pos.void in
  let arg2_ty = TLit TMoney, Pos.void in
  let ret_ty = TLit TBool, Pos.void in
  let ty = TArrow ([arg1_ty; arg2_ty], ret_ty), Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "(Int → CatalaRuntime.Money → Bool)" result

let test_format_typ_struct () =
  let struct_name = StructName.fresh [] ("Individual", Pos.void) in
  let ty = TStruct struct_name, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "Individual" result

let test_format_typ_enum () =
  let enum_name = EnumName.fresh [] ("Color", Pos.void) in
  let ty = TEnum enum_name, Pos.void in
  let result = Lean4_desugared.format_typ ty in
  assert_string_equal "Color" result

(** {1 Expression formatting tests} *)

let test_format_expr_lit () =
  let expr = (ELit (LBool true), Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "true" result

let test_format_expr_var () =
  let var = Var.make "my_variable" in
  let expr = (EVar var, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "my_variable" result

let test_format_expr_if_then_else () =
  let cond = (ELit (LBool true), Untyped { pos = Pos.void }) in
  let etrue = (ELit (LInt (Runtime.integer_of_int 42)), Untyped { pos = Pos.void }) in
  let efalse = (ELit (LInt (Runtime.integer_of_int 0)), Untyped { pos = Pos.void }) in
  let expr = (EIfThenElse { cond; etrue; efalse }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(if true then (42 : Int) else (0 : Int))" result

let test_format_expr_tuple_2 () =
  let e1 = (ELit (LInt (Runtime.integer_of_int 10)), Untyped { pos = Pos.void }) in
  let e2 = (ELit (LBool false), Untyped { pos = Pos.void }) in
  let expr = (ETuple [e1; e2], Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((10 : Int), false)" result

let test_format_expr_tuple_access () =
  let var = Var.make "my_tuple" in
  let tuple_expr = (EVar var, Untyped { pos = Pos.void }) in
  let expr = (ETupleAccess { e = tuple_expr; index = 0; size = 2 }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(my_tuple).1" result

let test_format_expr_tuple_access_second () =
  let var = Var.make "my_tuple" in
  let tuple_expr = (EVar var, Untyped { pos = Pos.void }) in
  let expr = (ETupleAccess { e = tuple_expr; index = 1; size = 2 }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(my_tuple).2" result

let test_format_expr_app_simple () =
  let f_var = Var.make "my_function" in
  let f = (EVar f_var, Untyped { pos = Pos.void }) in
  let arg = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let expr = (EApp { f; args = [arg]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(my_function (5 : Int))" result

let test_format_expr_app_multiple_args () =
  let f_var = Var.make "add" in
  let f = (EVar f_var, Untyped { pos = Pos.void }) in
  let arg1 = (ELit (LInt (Runtime.integer_of_int 3)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 4)), Untyped { pos = Pos.void }) in
  let expr = (EApp { f; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(add (3 : Int) (4 : Int))" result

let test_format_expr_struct () =
  let struct_name = StructName.fresh [] ("Person", Pos.void) in
  let name_field = StructField.fresh ("name", Pos.void) in
  let age_field = StructField.fresh ("age", Pos.void) in
  let name_val = (ELit (LInt (Runtime.integer_of_int 0)), Untyped { pos = Pos.void }) in (* placeholder *)
  let age_val = (ELit (LInt (Runtime.integer_of_int 25)), Untyped { pos = Pos.void }) in
  let fields = StructField.Map.empty
    |> StructField.Map.add name_field name_val
    |> StructField.Map.add age_field age_val
  in
  let expr = (EStruct { name = struct_name; fields }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  (* Note: Map iteration order might vary, but let's check it contains the key parts *)
  let has_struct_name = String.contains result '{' && String.contains result '}' in
  if not has_struct_name then
    Alcotest.failf "Expected struct construction syntax, got: %s" result

let test_format_expr_struct_access () =
  let struct_name = StructName.fresh [] ("Person", Pos.void) in
  let field = StructField.fresh ("age", Pos.void) in
  let var = Var.make "person" in
  let struct_expr = (EVar var, Untyped { pos = Pos.void }) in
  let expr = (EStructAccess { e = struct_expr; field; name = struct_name }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(person).age" result

let test_format_expr_inj () =
  let enum_name = EnumName.fresh [] ("Option", Pos.void) in
  let cons = EnumConstructor.fresh ("Some", Pos.void) in
  let payload = (ELit (LInt (Runtime.integer_of_int 42)), Untyped { pos = Pos.void }) in
  let expr = (EInj { e = payload; cons; name = enum_name }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(Option.Some (42 : Int))" result

let test_format_expr_array () =
  let e1 = (ELit (LInt (Runtime.integer_of_int 1)), Untyped { pos = Pos.void }) in
  let e2 = (ELit (LInt (Runtime.integer_of_int 2)), Untyped { pos = Pos.void }) in
  let e3 = (ELit (LInt (Runtime.integer_of_int 3)), Untyped { pos = Pos.void }) in
  let expr = (EArray [e1; e2; e3], Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "#[(1 : Int), (2 : Int), (3 : Int)]" result

(** {1 Operator formatting tests} *)

let test_format_operator_add_int () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 1)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 2)), Untyped { pos = Pos.void }) in
  let op = (Op.Add, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((1 : Int) + (2 : Int))" result

let test_format_operator_sub_int () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 10)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 3)), Untyped { pos = Pos.void }) in
  let op = (Op.Sub, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((10 : Int) - (3 : Int))" result

let test_format_operator_mult_int () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 3)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 4)), Untyped { pos = Pos.void }) in
  let op = (Op.Mult, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((3 : Int) * (4 : Int))" result

let test_format_operator_lt_int () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 10)), Untyped { pos = Pos.void }) in
  let op = (Op.Lt, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((5 : Int) < (10 : Int))" result

let test_format_operator_lte_int () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let op = (Op.Lte, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((5 : Int) ≤ (5 : Int))" result

let test_format_operator_gt_int () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 10)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let op = (Op.Gt, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((10 : Int) > (5 : Int))" result

let test_format_operator_gte_int () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 10)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 10)), Untyped { pos = Pos.void }) in
  let op = (Op.Gte, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((10 : Int) ≥ (10 : Int))" result

let test_format_operator_eq () =
  let arg1 = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let op = (Op.Eq, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "((5 : Int) = (5 : Int))" result

let test_format_operator_and () =
  let arg1 = (ELit (LBool true), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LBool false), Untyped { pos = Pos.void }) in
  let op = (Op.And, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(true ∧ false)" result

let test_format_operator_or () =
  let arg1 = (ELit (LBool true), Untyped { pos = Pos.void }) in
  let arg2 = (ELit (LBool false), Untyped { pos = Pos.void }) in
  let op = (Op.Or, Pos.void) in
  let expr = (EAppOp { op; args = [arg1; arg2]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(true ∨ false)" result

let test_format_operator_not () =
  let arg = (ELit (LBool true), Untyped { pos = Pos.void }) in
  let op = (Op.Not, Pos.void) in
  let expr = (EAppOp { op; args = [arg]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(¬true)" result

let test_format_operator_minus_int () =
  let arg = (ELit (LInt (Runtime.integer_of_int 5)), Untyped { pos = Pos.void }) in
  let op = (Op.Minus, Pos.void) in
  let expr = (EAppOp { op; args = [arg]; tys = [] }, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "(-(5 : Int))" result

(** {1 Location (variable reference) tests} *)

let test_format_location_simple () =
  let var = ScopeVar.fresh ("my_var", Pos.void) in
  let loc = DesugaredScopeVar { name = (var, Pos.void); state = None } in
  let result = Lean4_desugared.format_location loc in
  assert_string_equal "my_var" result

let test_format_location_with_state () =
  let var = ScopeVar.fresh ("counter", Pos.void) in
  let state = StateName.fresh ("before", Pos.void) in
  let loc = DesugaredScopeVar { name = (var, Pos.void); state = Some state } in
  let result = Lean4_desugared.format_location loc in
  assert_string_equal "counter_before" result

let test_format_expr_location () =
  let var = ScopeVar.fresh ("x", Pos.void) in
  let loc = DesugaredScopeVar { name = (var, Pos.void); state = None } in
  let expr = (ELocation loc, Untyped { pos = Pos.void }) in
  let result = Lean4_desugared.format_expr expr in
  assert_string_equal "x" result

(** {1 Scope generation with rule justifications tests} *)

(* Helper: check if string contains substring *)
let string_contains s sub =
  try
    let re = Str.regexp_string sub in
    let _ = Str.search_forward re s 0 in
    true
  with Not_found -> false

(* Helper: create a scope with a single variable and rule *)
let make_test_scope scope_name var_name var_type is_output just_expr cons_expr =
  let open Desugared.Ast in
  let scope_name_t = ScopeName.fresh [] (scope_name, Pos.void) in
  let var = ScopeVar.fresh (var_name, Pos.void) in
  
  let rule = {
    rule_id = RuleName.fresh ("rule_" ^ var_name, Pos.void);
    rule_just = Expr.box just_expr;
    rule_cons = Expr.box cons_expr;
    rule_parameter = None;
    rule_exception = BaseCase;
    rule_label = Unlabeled;
  } in
  
  let scope_def = {
    scope_def_rules = RuleName.Map.singleton rule.rule_id rule;
    scope_def_typ = var_type;
    scope_def_parameters = None;
    scope_def_is_condition = false;
    scope_def_io = {
      io_output = Mark.add Pos.void is_output;
      io_input = Mark.add Pos.void Runtime.NoInput;
    };
  } in
  
  let scope_def_key = ((var, Pos.void), ScopeDef.Var None) in
  let scope_defs = ScopeDef.Map.singleton scope_def_key scope_def in
  
  let scope_decl = {
    scope_vars = ScopeVar.Map.singleton var WholeVar;
    scope_sub_scopes = ScopeVar.Map.empty;
    scope_uid = scope_name_t;
    scope_defs = scope_defs;
    scope_assertions = AssertionName.Map.empty;
    scope_options = [];
    scope_meta_assertions = [];
    scope_visibility = Public;
  } in
  
  (scope_name_t, scope_decl)

let test_scope_unconditional_rule () =
  (* Test: Unconditional rule should NOT have "if" wrapper 
     
     Expected Lean code:
     
     structure TestUnconditional where
       result : Int
     
     def TestUnconditional_func : TestUnconditional :=
       { result := (42 : Int) }
  *)
  let just = (ELit (LBool true), Untyped { pos = Pos.void }) in
  let cons = (ELit (LInt (Runtime.integer_of_int 42)), Untyped { pos = Pos.void }) in
  let int_type = Mark.add Pos.void (TLit TInt) in
  
  let (scope_name, scope_decl) = make_test_scope "TestUnconditional" "result" int_type true just cons in
  let generated = Lean4_desugared.format_scope scope_name scope_decl in
  
  (* Verify the complete struct declaration and function *)
  let expected_struct = "structure TestUnconditional where\n  result : Int" in
  let expected_func = "def TestUnconditional_func : TestUnconditional :=\n  { result := (42 : Int) }" in
  
  let has_struct = string_contains generated expected_struct in
  let has_func = string_contains generated expected_func in
  let has_if = string_contains generated "if" in
  
  Alcotest.(check bool) "contains complete struct declaration" true has_struct;
  Alcotest.(check bool) "contains complete function definition" true has_func;
  Alcotest.(check bool) "should not contain if" false has_if

let test_scope_simple_conditional () =
  (* Test: Conditional rule should generate if-then-else 
     
     Expected Lean code:
     
     structure TestConditional where
       result : Int
     
     def TestConditional_func : TestConditional :=
       { result := (if (x > (0 : Int)) then (100 : Int) else sorry "undefined conditional value") }
  *)
  let x_var = ScopeVar.fresh ("x", Pos.void) in
  let x_loc = DesugaredScopeVar { name = (x_var, Pos.void); state = None } in
  
  let just = (EAppOp { 
    op = (Op.Gt, Pos.void);
    args = [
      (ELocation x_loc, Untyped { pos = Pos.void });
      (ELit (LInt (Runtime.integer_of_int 0)), Untyped { pos = Pos.void })
    ];
    tys = []
  }, Untyped { pos = Pos.void }) in
  
  let cons = (ELit (LInt (Runtime.integer_of_int 100)), Untyped { pos = Pos.void }) in
  let int_type = Mark.add Pos.void (TLit TInt) in
  
  let (scope_name, scope_decl) = make_test_scope "TestConditional" "result" int_type true just cons in
  let generated = Lean4_desugared.format_scope scope_name scope_decl in
  
  (* Verify the complete expression with conditional *)
  let expected_struct = "structure TestConditional where\n  result : Int" in
  let expected_condition = "if (x > (0 : Int)) then (100 : Int) else sorry \"undefined conditional value\"" in
  let expected_field = "result := (" ^ expected_condition ^ ")" in
  
  let has_struct = string_contains generated expected_struct in
  let has_condition = string_contains generated expected_condition in
  let has_field = string_contains generated expected_field in
  
  Alcotest.(check bool) "contains complete struct declaration" true has_struct;
  Alcotest.(check bool) "contains complete conditional expression" true has_condition;
  Alcotest.(check bool) "contains complete field assignment" true has_field

let test_scope_complex_condition () =
  (* Test: Complex AND condition 
     
     Expected Lean code:
     
     structure TestComplexCond where
       result : Int
     
     def TestComplexCond_func : TestComplexCond :=
       { result := (if ((x > (0 : Int)) ∧ (y < (10 : Int))) then (77 : Int) else sorry "undefined conditional value") }
  *)
  let x_var = ScopeVar.fresh ("x", Pos.void) in
  let y_var = ScopeVar.fresh ("y", Pos.void) in
  let x_loc = DesugaredScopeVar { name = (x_var, Pos.void); state = None } in
  let y_loc = DesugaredScopeVar { name = (y_var, Pos.void); state = None } in
  
  let cond1 = (EAppOp {
    op = (Op.Gt, Pos.void);
    args = [
      (ELocation x_loc, Untyped { pos = Pos.void });
      (ELit (LInt (Runtime.integer_of_int 0)), Untyped { pos = Pos.void })
    ];
    tys = []
  }, Untyped { pos = Pos.void }) in
  
  let cond2 = (EAppOp {
    op = (Op.Lt, Pos.void);
    args = [
      (ELocation y_loc, Untyped { pos = Pos.void });
      (ELit (LInt (Runtime.integer_of_int 10)), Untyped { pos = Pos.void })
    ];
    tys = []
  }, Untyped { pos = Pos.void }) in
  
  let just = (EAppOp {
    op = (Op.And, Pos.void);
    args = [cond1; cond2];
    tys = []
  }, Untyped { pos = Pos.void }) in
  
  let cons = (ELit (LInt (Runtime.integer_of_int 77)), Untyped { pos = Pos.void }) in
  let int_type = Mark.add Pos.void (TLit TInt) in
  
  let (scope_name, scope_decl) = make_test_scope "TestComplexCond" "result" int_type true just cons in
  let generated = Lean4_desugared.format_scope scope_name scope_decl in
  
  (* Verify the complete complex conditional expression *)
  let expected_struct = "structure TestComplexCond where\n  result : Int" in
  let expected_condition = "((x > (0 : Int)) ∧ (y < (10 : Int)))" in
  let expected_if_expr = "if " ^ expected_condition ^ " then (77 : Int) else sorry \"undefined conditional value\"" in
  
  let has_struct = string_contains generated expected_struct in
  let has_condition = string_contains generated expected_condition in
  let has_if_expr = string_contains generated expected_if_expr in
  
  Alcotest.(check bool) "contains complete struct declaration" true has_struct;
  Alcotest.(check bool) "contains complete AND condition" true has_condition;
  Alcotest.(check bool) "contains complete if expression" true has_if_expr

let test_scope_internal_var_conditional () =
  (* Test: Internal variable with conditional rule 
     
     Expected Lean code:
     
     structure TestInternal where
     
     def TestInternal_func : TestInternal :=
       let temp := (if flag then (999 : Int) else sorry "undefined conditional value") in
       { }
  *)
  let x_var = ScopeVar.fresh ("flag", Pos.void) in
  let x_loc = DesugaredScopeVar { name = (x_var, Pos.void); state = None } in
  
  let just = (ELocation x_loc, Untyped { pos = Pos.void }) in
  let cons = (ELit (LInt (Runtime.integer_of_int 999)), Untyped { pos = Pos.void }) in
  let int_type = Mark.add Pos.void (TLit TInt) in
  
  (* Make it internal (not output) *)
  let (scope_name, scope_decl) = make_test_scope "TestInternal" "temp" int_type false just cons in
  let generated = Lean4_desugared.format_scope scope_name scope_decl in
  
  (* Internal variable should generate complete let binding with conditional expression *)
  let expected_let_binding = "let temp := (if flag then (999 : Int) else sorry \"undefined conditional value\")" in
  
  let has_let_binding = string_contains generated expected_let_binding in
  
  Alcotest.(check bool) "contains complete let binding with conditional" true has_let_binding

(** {1 Struct declaration tests} *)

let test_format_struct_decl_simple () =
  let x_field = StructField.fresh ("x", Pos.void) in
  let y_field = StructField.fresh ("y", Pos.void) in
  let fields = StructField.Map.of_list [
    (x_field, Mark.add Pos.void (TLit TInt));
    (y_field, Mark.add Pos.void (TLit TBool));
  ] in
  let result = Lean4_desugared.format_struct_decl "MyStruct" fields in
  (* The order depends on UID comparison, so check that both fields are present *)
  let has_x = string_contains result "x : Int" in
  let has_y = string_contains result "y : Bool" in
  let has_struct_decl = String.starts_with ~prefix:"structure MyStruct where\n" result in
  if not (has_x && has_y && has_struct_decl) then
    Alcotest.fail (Printf.sprintf "Expected struct with x and y fields, got:\n%s" result)

let test_format_struct_decl_single_field () =
  let fields = StructField.Map.of_list [
    ((StructField.fresh ("value", Pos.void)), Mark.add Pos.void (TLit TInt));
  ] in
  let result = Lean4_desugared.format_struct_decl "SingleField" fields in
  assert_string_equal "structure SingleField where\n  value : Int" result

let test_format_struct_decl_complex_types () =
  let fields = StructField.Map.of_list [
    ((StructField.fresh ("count", Pos.void)), Mark.add Pos.void (TLit TInt));
    ((StructField.fresh ("amount", Pos.void)), Mark.add Pos.void (TLit TMoney));
    ((StructField.fresh ("values", Pos.void)), Mark.add Pos.void (TArray (Mark.add Pos.void (TLit TInt))));
  ] in
  let result = Lean4_desugared.format_struct_decl "ComplexStruct" fields in
  (* Check that all fields are present *)
  let has_count = string_contains result "count : Int" in
  let has_amount = string_contains result "amount : CatalaRuntime.Money" in
  let has_values = string_contains result "values : (Array Int)" in
  let has_struct_decl = String.starts_with ~prefix:"structure ComplexStruct where\n" result in
  if not (has_count && has_amount && has_values && has_struct_decl) then
    Alcotest.fail (Printf.sprintf "Expected struct with count, amount, and values fields, got:\n%s" result)

(** {1 Phase 0 - Scopelang function exports} *)

(** Test that we can call scope_to_exception_graphs on a simple scope *)
let test_scopelang_exception_graphs () =
  (* Create a simple scope with one variable and one rule *)
  let scope_name_t = ScopeName.fresh [] ("TestScope", Pos.void) in
  let var = ScopeVar.fresh ("x", Pos.void) in
  
  let rule = {
    Desugared.Ast.rule_id = RuleName.fresh ("rule_x", Pos.void);
    rule_just = Expr.box (ELit (LBool true), Untyped { pos = Pos.void });
    rule_cons = Expr.box (ELit (LInt (Runtime.integer_of_int 42)), Untyped { pos = Pos.void });
    rule_parameter = None;
    rule_exception = Desugared.Ast.BaseCase;
    rule_label = Desugared.Ast.Unlabeled;
  } in
  
  let scope_def = {
    Desugared.Ast.scope_def_rules = RuleName.Map.singleton rule.rule_id rule;
    scope_def_typ = Mark.add Pos.void (TLit TInt);
    scope_def_parameters = None;
    scope_def_is_condition = false;
    scope_def_io = {
      io_output = Mark.add Pos.void true;
      io_input = Mark.add Pos.void Runtime.NoInput;
    };
  } in
  
  let scope_def_key = ((var, Pos.void), Desugared.Ast.ScopeDef.Var None) in
  let scope_defs = Desugared.Ast.ScopeDef.Map.singleton scope_def_key scope_def in
  
  let scope_decl = {
    Desugared.Ast.scope_vars = ScopeVar.Map.singleton var Desugared.Ast.WholeVar;
    scope_sub_scopes = ScopeVar.Map.empty;
    scope_uid = scope_name_t;
    scope_defs = scope_defs;
    scope_assertions = Desugared.Ast.AssertionName.Map.empty;
    scope_options = [];
    scope_meta_assertions = [];
    scope_visibility = Public;
  } in
  
  (* Call the exported function *)
  let exc_graphs = Scopelang.From_desugared.scope_to_exception_graphs scope_decl in
  
  (* Verify we got an exception graph for our variable *)
  let has_graph = Desugared.Ast.ScopeDef.Map.mem scope_def_key exc_graphs in
  Alcotest.(check bool) "exception graph exists for variable" true has_graph

(** Test that we can call def_map_to_tree and get a rule tree *)
let test_scopelang_def_to_tree () =
  (* Create a simple rule *)
  let rule = {
    Desugared.Ast.rule_id = RuleName.fresh ("rule_test", Pos.void);
    rule_just = Expr.box (ELit (LBool true), Untyped { pos = Pos.void });
    rule_cons = Expr.box (ELit (LInt (Runtime.integer_of_int 100)), Untyped { pos = Pos.void });
    rule_parameter = None;
    rule_exception = Desugared.Ast.BaseCase;
    rule_label = Desugared.Ast.Unlabeled;
  } in
  
  let rules = RuleName.Map.singleton rule.rule_id rule in
  
  (* Build a trivial exception graph (no exceptions) *)
  let var = ScopeVar.fresh ("test_var", Pos.void) in
  let scope_def_key = ((var, Pos.void), Desugared.Ast.ScopeDef.Var None) in
  let scope_name_t = ScopeName.fresh [] ("TestScope", Pos.void) in
  
  let scope_def = {
    Desugared.Ast.scope_def_rules = rules;
    scope_def_typ = Mark.add Pos.void (TLit TInt);
    scope_def_parameters = None;
    scope_def_is_condition = false;
    scope_def_io = {
      io_output = Mark.add Pos.void true;
      io_input = Mark.add Pos.void Runtime.NoInput;
    };
  } in
  
  let scope_defs = Desugared.Ast.ScopeDef.Map.singleton scope_def_key scope_def in
  
  let scope_decl = {
    Desugared.Ast.scope_vars = ScopeVar.Map.singleton var Desugared.Ast.WholeVar;
    scope_sub_scopes = ScopeVar.Map.empty;
    scope_uid = scope_name_t;
    scope_defs = scope_defs;
    scope_assertions = Desugared.Ast.AssertionName.Map.empty;
    scope_options = [];
    scope_meta_assertions = [];
    scope_visibility = Public;
  } in
  
  let exc_graphs = Scopelang.From_desugared.scope_to_exception_graphs scope_decl in
  let exc_graph = Desugared.Ast.ScopeDef.Map.find scope_def_key exc_graphs in
  
  (* Call def_map_to_tree *)
  let rule_trees = Scopelang.From_desugared.def_map_to_tree rules exc_graph in
  
  (* Verify we got a non-empty list of rule trees *)
  let has_trees = List.length rule_trees > 0 in
  Alcotest.(check bool) "rule trees generated" true has_trees;
  
  (* Verify it's a Leaf (no exceptions) *)
  match List.hd rule_trees with
  | Scopelang.From_desugared.Leaf _ -> ()
  | Scopelang.From_desugared.Node _ -> 
      Alcotest.fail "Expected Leaf node for rule with no exceptions"

(** Test that rule_tree pattern matching works *)
let test_scopelang_rule_tree_type () =
  (* This test verifies the rule_tree type is accessible and usable *)
  let rule1 = {
    Desugared.Ast.rule_id = RuleName.fresh ("rule1", Pos.void);
    rule_just = Expr.box (ELit (LBool true), Untyped { pos = Pos.void });
    rule_cons = Expr.box (ELit (LInt (Runtime.integer_of_int 1)), Untyped { pos = Pos.void });
    rule_parameter = None;
    rule_exception = Desugared.Ast.BaseCase;
    rule_label = Desugared.Ast.Unlabeled;
  } in
  
  (* Create a Leaf manually *)
  let leaf = Scopelang.From_desugared.Leaf [rule1] in
  
  (* Pattern match on it *)
  let rule_count = match leaf with
    | Scopelang.From_desugared.Leaf rules -> List.length rules
    | Scopelang.From_desugared.Node (_, rules) -> List.length rules
  in
  
  Alcotest.(check int) "leaf contains one rule" 1 rule_count

(** {1 Test suite} *)

let suite =
  [
    "format_lit",
    [
      Alcotest.test_case "bool true" `Quick test_format_lit_bool_true;
      Alcotest.test_case "bool false" `Quick test_format_lit_bool_false;
      Alcotest.test_case "int positive" `Quick test_format_lit_int;
      Alcotest.test_case "int negative" `Quick test_format_lit_int_negative;
      Alcotest.test_case "unit" `Quick test_format_lit_unit;
      Alcotest.test_case "money" `Quick test_format_lit_money;
      Alcotest.test_case "rational" `Quick test_format_lit_rat;
    ];
    "format_typ",
    [
      Alcotest.test_case "unit" `Quick test_format_typ_unit;
      Alcotest.test_case "bool" `Quick test_format_typ_bool;
      Alcotest.test_case "int" `Quick test_format_typ_int;
      Alcotest.test_case "rat" `Quick test_format_typ_rat;
      Alcotest.test_case "money" `Quick test_format_typ_money;
      Alcotest.test_case "date" `Quick test_format_typ_date;
      Alcotest.test_case "duration" `Quick test_format_typ_duration;
      Alcotest.test_case "option" `Quick test_format_typ_option;
      Alcotest.test_case "array" `Quick test_format_typ_array;
      Alcotest.test_case "tuple 2 elements" `Quick test_format_typ_tuple_2;
      Alcotest.test_case "tuple 3 elements" `Quick test_format_typ_tuple_3;
      Alcotest.test_case "arrow simple" `Quick test_format_typ_arrow_simple;
      Alcotest.test_case "arrow multiple args" `Quick test_format_typ_arrow_multiple_args;
      Alcotest.test_case "struct" `Quick test_format_typ_struct;
      Alcotest.test_case "enum" `Quick test_format_typ_enum;
    ];
    "format_expr",
    [
      Alcotest.test_case "literal" `Quick test_format_expr_lit;
      Alcotest.test_case "variable" `Quick test_format_expr_var;
      Alcotest.test_case "if-then-else" `Quick test_format_expr_if_then_else;
      Alcotest.test_case "tuple 2 elements" `Quick test_format_expr_tuple_2;
      Alcotest.test_case "tuple access first" `Quick test_format_expr_tuple_access;
      Alcotest.test_case "tuple access second" `Quick test_format_expr_tuple_access_second;
      Alcotest.test_case "application simple" `Quick test_format_expr_app_simple;
      Alcotest.test_case "application multiple args" `Quick test_format_expr_app_multiple_args;
      Alcotest.test_case "struct construction" `Quick test_format_expr_struct;
      Alcotest.test_case "struct access" `Quick test_format_expr_struct_access;
      Alcotest.test_case "enum injection" `Quick test_format_expr_inj;
      Alcotest.test_case "array" `Quick test_format_expr_array;
    ];
    "format_operator",
    [
      Alcotest.test_case "add int" `Quick test_format_operator_add_int;
      Alcotest.test_case "sub int" `Quick test_format_operator_sub_int;
      Alcotest.test_case "mult int" `Quick test_format_operator_mult_int;
      Alcotest.test_case "lt int" `Quick test_format_operator_lt_int;
      Alcotest.test_case "lte int" `Quick test_format_operator_lte_int;
      Alcotest.test_case "gt int" `Quick test_format_operator_gt_int;
      Alcotest.test_case "gte int" `Quick test_format_operator_gte_int;
      Alcotest.test_case "eq" `Quick test_format_operator_eq;
      Alcotest.test_case "and" `Quick test_format_operator_and;
      Alcotest.test_case "or" `Quick test_format_operator_or;
      Alcotest.test_case "not" `Quick test_format_operator_not;
      Alcotest.test_case "minus int" `Quick test_format_operator_minus_int;
    ];
    "format_location",
    [
      Alcotest.test_case "simple variable" `Quick test_format_location_simple;
      Alcotest.test_case "variable with state" `Quick test_format_location_with_state;
      Alcotest.test_case "location in expression" `Quick test_format_expr_location;
    ];
    "scope_with_justifications",
    [
      Alcotest.test_case "unconditional rule" `Quick test_scope_unconditional_rule;
      Alcotest.test_case "simple conditional" `Quick test_scope_simple_conditional;
      Alcotest.test_case "complex condition" `Quick test_scope_complex_condition;
      Alcotest.test_case "internal var conditional" `Quick test_scope_internal_var_conditional;
    ];
    "format_struct_decl",
    [
      Alcotest.test_case "simple struct" `Quick test_format_struct_decl_simple;
      Alcotest.test_case "single field" `Quick test_format_struct_decl_single_field;
      Alcotest.test_case "complex types" `Quick test_format_struct_decl_complex_types;
    ];
    "phase0_scopelang_exports",
    [
      Alcotest.test_case "exception graphs" `Quick test_scopelang_exception_graphs;
      Alcotest.test_case "def to tree" `Quick test_scopelang_def_to_tree;
      Alcotest.test_case "rule tree type" `Quick test_scopelang_rule_tree_type;
    ];
  ]

