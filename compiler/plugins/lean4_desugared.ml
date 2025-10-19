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

(** Lean4 backend from desugared AST *)

open Catala_utils
open Shared_ast

module Runtime = Catala_runtime

(** {1 Formatting functions} *)

(** Format a literal to Lean code *)
let format_lit (l : lit) : string =
  match l with
  | LBool true -> "true"
  | LBool false -> "false"
  | LInt i -> Printf.sprintf "(%s : Int)" (Runtime.integer_to_string i)
  | LUnit -> "()"
  | LRat r -> 
      let num = Q.num r in
      let den = Q.den r in
      Printf.sprintf "(Rat.mk %s %s)" 
        (Runtime.integer_to_string num)
        (Runtime.integer_to_string den)
  | LMoney m ->
      let cents = Runtime.money_to_cents m in
      Printf.sprintf "(CatalaRuntime.Money.ofCents %s)" 
        (Runtime.integer_to_string cents)
  | LDate d ->
      let y, m, d = Runtime.date_to_years_months_days d in
      Printf.sprintf "(CatalaRuntime.Date.create %d %d %d)" y m d
  | LDuration dur ->
      let y, m, d = Runtime.duration_to_years_months_days dur in
      Printf.sprintf "(CatalaRuntime.Duration.create %d %d %d)" y m d

(** Format a type to Lean code *)
let rec format_typ (ty : typ) : string =
  match Mark.remove ty with
  | TLit TUnit -> "Unit"
  | TLit TBool -> "Bool"
  | TLit TInt -> "Int"
  | TLit TRat -> "Rat"
  | TLit TMoney -> "CatalaRuntime.Money"
  | TLit TDate -> "CatalaRuntime.Date"
  | TLit TDuration -> "CatalaRuntime.Duration"
  | TLit TPos -> "CatalaRuntime.SourcePosition"
  | TTuple [] -> "Unit"
  | TTuple ts ->
      let formatted = List.map format_typ ts in
      Printf.sprintf "(%s)" (String.concat " × " formatted)
  | TStruct s -> StructName.to_string s
  | TEnum e -> EnumName.to_string e
  | TOption t ->
      Printf.sprintf "(Option %s)" (format_typ t)
  | TArrow (args, ret) ->
      let all_types = args @ [ret] in
      let formatted = List.map format_typ all_types in
      Printf.sprintf "(%s)" (String.concat " → " formatted)
  | TArray t ->
      Printf.sprintf "(Array %s)" (format_typ t)
  | TDefault t -> format_typ t
  | TVar _ | TForAll _ | TClosureEnv ->
      (* For now, output Unit for complex types we don't fully support *)
      "Unit"

