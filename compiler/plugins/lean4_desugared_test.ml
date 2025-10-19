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
  ]

