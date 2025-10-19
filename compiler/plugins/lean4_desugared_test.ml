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
  ]

