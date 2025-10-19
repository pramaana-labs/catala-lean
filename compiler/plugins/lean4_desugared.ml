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

(** Format an expression to Lean code *)
let rec format_expr (e : (desugared, untyped) gexpr) : string =
  match Mark.remove e with
  | ELit l -> format_lit l
  | EVar v -> Bindlib.name_of v
  | EIfThenElse { cond; etrue; efalse } ->
      Printf.sprintf "(if %s then %s else %s)"
        (format_expr cond)
        (format_expr etrue)
        (format_expr efalse)
  | ETuple es ->
      let formatted = List.map format_expr es in
      Printf.sprintf "(%s)" (String.concat ", " formatted)
  | ETupleAccess { e; index; size = _ } ->
      (* Lean uses 1-indexed tuple access *)
      Printf.sprintf "(%s).%d" (format_expr e) (index + 1)
  | EApp { f; args; tys = _ } ->
      let f_str = format_expr f in
      let args_str = List.map format_expr args in
      Printf.sprintf "(%s %s)" f_str (String.concat " " args_str)
  | EStruct { name = _; fields } ->
      let bindings = StructField.Map.bindings fields in
      let formatted_fields = List.map (fun (field, e) ->
        Printf.sprintf "%s := %s"
          (StructField.to_string field)
          (format_expr e)
      ) bindings in
      Printf.sprintf "{ %s }" (String.concat ", " formatted_fields)
  | EStructAccess { e; field; name = _ } ->
      Printf.sprintf "(%s).%s" (format_expr e) (StructField.to_string field)
  | EInj { e; cons; name } ->
      Printf.sprintf "(%s.%s %s)"
        (EnumName.to_string name)
        (EnumConstructor.to_string cons)
        (format_expr e)
  | EArray es ->
      let formatted = List.map format_expr es in
      Printf.sprintf "#[%s]" (String.concat ", " formatted)
  | EAppOp { op; args; tys = _ } ->
      format_operator op args
  | EMatch _ ->
      (* Pattern matching - complex, will handle later *)
      "sorry -- match not yet implemented"
  | EAbs _ ->
      (* Lambda abstractions - will handle later *)
      "sorry -- lambda not yet implemented"
  | ELocation _ ->
      (* Variable references in desugared AST - will handle later *)
      "sorry -- location not yet implemented"
  | EScopeCall _ ->
      (* Scope calls - will handle later *)
      "sorry -- scope call not yet implemented"
  | EDefault _ | EPureDefault _ | EEmpty | EErrorOnEmpty _ ->
      (* Default logic - will handle later *)
      "sorry -- default logic not yet implemented"
  | EDStructAmend _ ->
      "sorry -- struct amendment not yet implemented"
  | _ ->
      "sorry -- unsupported expression"

(** Format an operator and its arguments to Lean code *)
and format_operator (op : desugared operator Mark.pos) (args : (desugared, untyped) gexpr list) : string =
  let open Op in
  let binop sym =
    match args with
    | [arg1; arg2] ->
        Printf.sprintf "(%s %s %s)"
          (format_expr arg1) sym (format_expr arg2)
    | _ -> "sorry -- wrong number of args for binop"
  in
  let unop sym =
    match args with
    | [arg] -> Printf.sprintf "(%s%s)" sym (format_expr arg)
    | _ -> "sorry -- wrong number of args for unop"
  in
  match Mark.remove op with
  (* Overloaded operators in desugared AST *)
  | Add -> binop "+"
  | Sub -> binop "-"
  | Mult -> binop "*"
  | Div -> binop "/"
  | Minus -> unop "-"
  | Lt -> binop "<"
  | Lte -> binop "≤"
  | Gt -> binop ">"
  | Gte -> binop "≥"
  | Eq -> binop "="
  (* Boolean operators *)
  | And -> binop "∧"
  | Or -> binop "∨"
  | Xor -> binop "⊕"
  | Not -> unop "¬"
  (* Polymorphic operators *)
  | Length ->
      (match args with
       | [arg] -> Printf.sprintf "(%s).size" (format_expr arg)
       | _ -> "sorry -- wrong args for Length")
  | Map | Filter | Fold | Reduce | Concat | Map2 ->
      "sorry -- array operations not yet fully implemented"
  (* Conversions *)
  | ToInt ->
      (match args with
       | [arg] -> Printf.sprintf "(Int.ofRat %s)" (format_expr arg)
       | _ -> "sorry -- wrong args for ToInt")
  | ToRat ->
      (match args with
       | [arg] -> Printf.sprintf "(Rat.ofInt %s)" (format_expr arg)
       | _ -> "sorry -- wrong args for ToRat")
  | ToMoney ->
      (match args with
       | [arg] -> Printf.sprintf "(CatalaRuntime.Money.ofInt %s)" (format_expr arg)
       | _ -> "sorry -- wrong args for ToMoney")
  | Round ->
      (match args with
       | [arg] -> Printf.sprintf "(round %s)" (format_expr arg)
       | _ -> "sorry -- wrong args for Round")
  (* Other *)
  | Log _ -> (match args with [arg] -> format_expr arg | _ -> "sorry -- log")
  | ToClosureEnv | FromClosureEnv -> "sorry -- closure env"
  | _ -> "sorry -- unsupported operator"

(** Format a struct declaration to Lean code *)
let format_struct_decl (name : string) (fields : typ StructField.Map.t) : string =
  let field_list = StructField.Map.bindings fields in
  let formatted_fields = List.map (fun (field, ty) ->
    Printf.sprintf "  %s : %s"
      (StructField.to_string field)
      (format_typ ty)
  ) field_list in
  Printf.sprintf "structure %s where\n%s"
    name
    (String.concat "\n" formatted_fields)

