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

(** {1 Struct declaration tests} *)

(* Helper: check if string contains substring *)
let string_contains s sub =
  try
    let re = Str.regexp_string sub in
    let _ = Str.search_forward re s 0 in
    true
  with Not_found -> false

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
    "format_struct_decl",
    [
      Alcotest.test_case "simple struct" `Quick test_format_struct_decl_simple;
      Alcotest.test_case "single field" `Quick test_format_struct_decl_single_field;
      Alcotest.test_case "complex types" `Quick test_format_struct_decl_complex_types;
    ];
  ]

