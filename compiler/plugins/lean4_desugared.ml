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

module Ast = Desugared.Ast

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

(** Format a location (variable reference) to Lean code *)
let format_location (loc : desugared glocation) : string =
  match loc with
  | DesugaredScopeVar { name; state } ->
      let var_name = ScopeVar.to_string (Mark.remove name) in
      (match state with
       | None -> var_name
       | Some state_name -> 
           Printf.sprintf "%s_%s" var_name (StateName.to_string state_name))
  | ToplevelVar { name; _ } ->
      TopdefName.to_string (Mark.remove name)

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
      "sorry -- match not yet implemented\n"
  | EAbs _ ->
      (* Lambda abstractions - will handle later *)
      "sorry -- lambda not yet implemented\n"
  | ELocation loc ->
      format_location loc
  | EScopeCall _ ->
      (* Scope calls - will handle later *)
      "sorry -- scope call not yet implemented\n"
  | EDefault _ | EPureDefault _ | EEmpty | EErrorOnEmpty _ ->
      (* Default logic - will handle later *)
      "sorry -- default logic not yet implemented\n"
  | EDStructAmend _ ->
      "sorry -- struct amendment not yet implemented\n"
  | _ ->
      "sorry -- unsupported expression\n"

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

(** Generate Lean code for a scope *)
let format_scope (scope_name : ScopeName.t) (scope_decl : Ast.scope) : string =
  let scope_name_str = ScopeName.to_string scope_name in
  
  (* 1. Generate output struct *)
  let output_fields = Ast.ScopeDef.Map.fold (fun scope_def def acc ->
    let var, _kind = scope_def in
    let var_name, _pos = var in
    match Mark.remove def.Ast.scope_def_io.io_output with
    | true ->
        let field_name = StructField.fresh (ScopeVar.to_string var_name, Pos.void) in
        let field_type = def.Ast.scope_def_typ in
        StructField.Map.add field_name field_type acc
    | false -> acc
  ) scope_decl.Ast.scope_defs StructField.Map.empty in
  
  let struct_decl = format_struct_decl scope_name_str output_fields in
  
  (* 2. Separate internal variables and output variables *)
  let internal_vars = ref [] in
  let output_fields = ref [] in
  
  Ast.ScopeDef.Map.iter (fun scope_def def ->
    let var, _kind = scope_def in
    let var_name, _pos = var in
    let rules = def.Ast.scope_def_rules in
    if RuleName.Map.is_empty rules then ()
    else
      let _rule_id, rule = RuleName.Map.choose rules in
      let cons_expr = Expr.unbox rule.Ast.rule_cons in
      let var_str = ScopeVar.to_string var_name in
      match Mark.remove def.Ast.scope_def_io.io_output with
      | true ->
          (* Output variable: generate struct field assignment *)
          let field_assignment = Printf.sprintf "%s := %s" var_str (format_expr cons_expr) in
          output_fields := field_assignment :: !output_fields
      | false ->
          (* Internal variable: generate let binding *)
          let let_binding = Printf.sprintf "let %s := %s" var_str (format_expr cons_expr) in
          internal_vars := let_binding :: !internal_vars
  ) scope_decl.Ast.scope_defs;
  
  (* 3. Generate scope function with let bindings for internal vars *)
  let func_def = 
    if !internal_vars = [] then
      (* No internal variables, just struct construction *)
      Printf.sprintf "def %s_func : %s :=\n  { %s }"
        scope_name_str
        scope_name_str
        (String.concat ",\n    " (List.rev !output_fields))
    else
      (* Has internal variables, use let...in structure *)
      let lets = String.concat "\n  " (List.rev !internal_vars) in
      let struct_body = String.concat ",\n    " (List.rev !output_fields) in
      Printf.sprintf "def %s_func : %s :=\n  %s in\n  { %s }"
        scope_name_str
        scope_name_str
        lets
        struct_body
  in
  
  Printf.sprintf "%s\n\n%s" struct_decl func_def

(** Generate a complete Lean file from a desugared program *)
let generate_lean_code (prgm : Ast.program) : string =
  let header = "import CatalaRuntime\n\nopen CatalaRuntime\n" in
  
  (* Generate code for each scope in the program root *)
  let scope_code = ScopeName.Map.fold (fun scope_name scope_decl acc ->
    let code = format_scope scope_name scope_decl in
    code :: acc
  ) prgm.program_root.module_scopes [] in
  
  header ^ "\n" ^ (String.concat "\n\n" (List.rev scope_code))

(** {1 Plugin registration} *)

let run
    includes
    stdlib
    output
    options =
  let open Driver.Commands in
  let prg, _ctx =
    Driver.Passes.desugared options ~includes ~stdlib
  in

  Message.debug "Generating Lean4 code from desugared AST...";
  let lean_code = generate_lean_code prg in
  
  get_output_format options ~ext:"lean" output
  @@ fun _file fmt -> Format.fprintf fmt "%s@." lean_code

let term =
  let open Cmdliner.Term in
  const run
  $ Cli.Flags.include_dirs
  $ Cli.Flags.stdlib_dir
  $ Cli.Flags.output

let () =
  Driver.Plugin.register "lean4-desugared" term
    ~doc:
      "Generates Lean4 code from the Catala desugared AST. This backend \
       translates each scope into a Lean structure and function."

