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

(** {1 Phase 1: Variable collection and dependency analysis} *)

(** Information about a scope input variable *)
type input_info = {
  var_name: ScopeVar.t;
  var_type: typ;
  io_input: Runtime.io_input Mark.pos;
}

(** Information about a variable's definition *)
type var_def_info = {
  var_name: ScopeVar.t;
  var_type: typ;
  is_output: bool;
  rules: Ast.rule RuleName.Map.t;
  dependencies: typ ScopeVar.Map.t;  (* Variables this depends on *)
  exception_graph: Desugared.Dependency.ExceptionsDependencies.t;
  rule_trees: Scopelang.From_desugared.rule_tree list;
}

(** Collect all input variables from a scope *)
let collect_inputs (scope_decl : Ast.scope) : input_info list =
  Ast.ScopeDef.Map.fold (fun scope_def def acc ->
    let var, _kind = scope_def in
    let var_name, _pos = var in
    match Mark.remove def.Ast.scope_def_io.io_input with
    | Runtime.NoInput -> acc
    | _ ->
        let input = {
          var_name = var_name;
          var_type = def.Ast.scope_def_typ;
          io_input = def.Ast.scope_def_io.io_input;
        } in
        input :: acc
  ) scope_decl.Ast.scope_defs []

let var_type (scope_def_key : Ast.ScopeDef.t) (scope_decl : Ast.scope) : typ =
  match Ast.ScopeDef.Map.find_opt scope_def_key scope_decl.Ast.scope_defs with
  | None -> raise (Invalid_argument "Scope definition not found")
  | Some scope_def -> scope_def.Ast.scope_def_typ

(** Collect variable information in dependency order using existing analysis *)
let collect_var_info_ordered (scope_decl : Ast.scope)
    : (var_def_info list * input_info list) =
  
  (* 1. Get dependency-ordered list of variables *)
  let scope_deps = Desugared.Dependency.build_scope_dependencies scope_decl in
  Desugared.Dependency.check_for_cycle scope_decl scope_deps;
  let scope_ordering = 
    Desugared.Dependency.correct_computation_ordering scope_deps in
  
  (* 2. Get exception graphs for all variables *)
  let exc_graphs = Scopelang.From_desugared.scope_to_exception_graphs scope_decl in
  
  (* 3. Collect inputs and build input variable set *)
  let inputs = collect_inputs scope_decl in
  let input_vars = List.fold_left (fun acc (inp: input_info) ->
    ScopeVar.Set.add inp.var_name acc
  ) ScopeVar.Set.empty inputs in
  let var_type (scope_def_key : Ast.ScopeDef.t): typ =
    (match Ast.ScopeDef.Map.find_opt scope_def_key scope_decl.Ast.scope_defs with
    | None -> raise (Invalid_argument "Scope definition not found")
    | Some scope_def -> scope_def.Ast.scope_def_typ) in
  
  (* 4. Process variables in dependency order *)
  let var_defs = List.filter_map (function
    | Desugared.Dependency.Vertex.Var (var, state) ->
        let scope_def_key = ((var, Pos.void), Ast.ScopeDef.Var state) in
        (match Ast.ScopeDef.Map.find_opt scope_def_key scope_decl.Ast.scope_defs with
         | None -> None
         | Some scope_def ->
             if RuleName.Map.is_empty scope_def.Ast.scope_def_rules then None
             else
               (* Get dependencies using existing function *)
               let all_deps = Desugared.Ast.free_variables scope_def.Ast.scope_def_rules in
               
               (* Filter to only variable dependencies *)
               let var_deps = Ast.ScopeDef.Map.fold (fun def_key _pos acc ->
                 match def_key with
                 | (v, _), Ast.ScopeDef.Var _ -> ScopeVar.Map.add v (var_type def_key) acc
                 | _ -> acc
               ) all_deps ScopeVar.Map.empty in
               
               (* Remove input variables from dependencies (they're parameters) *)
               let internal_deps = ScopeVar.Map.filter (fun _v _t -> not (ScopeVar.Set.mem _v input_vars)) var_deps in
               
               (* Get exception graph and build rule trees *)
               let exc_graph = Ast.ScopeDef.Map.find scope_def_key exc_graphs in
               let rule_trees = Scopelang.From_desugared.def_map_to_tree 
                 scope_def.Ast.scope_def_rules exc_graph in
               
               Some {
                 var_name = var;
                 var_type = scope_def.Ast.scope_def_typ;
                 is_output = Mark.remove scope_def.Ast.scope_def_io.io_output;
                 rules = scope_def.Ast.scope_def_rules;
                 dependencies = internal_deps;
                 exception_graph = exc_graph;
                 rule_trees = rule_trees;
               })
    | _ -> None
  ) scope_ordering in
  
  (var_defs, inputs)

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
let format_location 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None) 
    (loc : desugared glocation) 
    : string =
  match loc with
  | DesugaredScopeVar { name; state } ->
      let var_name = ScopeVar.to_string (Mark.remove name) in
      let base_name = match state with
        | None -> var_name
        | Some state_name -> 
            Printf.sprintf "%s_%s" var_name (StateName.to_string state_name)
      in
      (* Check if this is an input variable that should be prefixed with "input." *)
      (match scope_defs with
      | None -> base_name  (* No context, just return the name *)
      | Some defs ->
          let scope_def_key = (name, Ast.ScopeDef.Var state) in
          (match Ast.ScopeDef.Map.find_opt scope_def_key defs with
          | None -> base_name  (* Not found, return as is *)
          | Some scope_def ->
              let is_input = match Mark.remove scope_def.Ast.scope_def_io.io_input with
                | Runtime.NoInput -> false
                | _ -> true
              in
              if is_input then
                Printf.sprintf "input.%s" base_name
              else
                base_name))
  | ToplevelVar { name; _ } ->
      TopdefName.to_string (Mark.remove name)

(** Format an expression to Lean code *)
let rec format_expr 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    (e : (desugared, untyped) gexpr) 
    : string =
  match Mark.remove e with
  | ELit l -> format_lit l
  | EVar v -> Bindlib.name_of v
  | EIfThenElse { cond; etrue; efalse } ->
      Printf.sprintf "(if %s then %s else %s)"
        (format_expr ~scope_defs cond)
        (format_expr ~scope_defs etrue)
        (format_expr ~scope_defs efalse)
  | ETuple es ->
      let formatted = List.map (format_expr ~scope_defs) es in
      Printf.sprintf "(%s)" (String.concat ", " formatted)
  | ETupleAccess { e; index; size = _ } ->
      (* Lean uses 1-indexed tuple access *)
      Printf.sprintf "(%s).%d" (format_expr ~scope_defs e) (index + 1)
  | EApp { f; args; tys = _ } ->
      let f_str = format_expr ~scope_defs f in
      let args_str = List.map (format_expr ~scope_defs) args in
      Printf.sprintf "(%s %s)" f_str (String.concat " " args_str)
  | EStruct { name = _; fields } ->
      let bindings = StructField.Map.bindings fields in
      let formatted_fields = List.map (fun (field, e) ->
        Printf.sprintf "%s := %s"
          (StructField.to_string field)
          (format_expr ~scope_defs e)
      ) bindings in
      Printf.sprintf "{ %s }" (String.concat ", " formatted_fields)
  | EStructAccess { e; field; name = _ } ->
      Printf.sprintf "(%s).%s" (format_expr ~scope_defs e) (StructField.to_string field)
  | EInj { e; cons; name } ->
      Printf.sprintf "(%s.%s %s)"
        (EnumName.to_string name)
        (EnumConstructor.to_string cons)
        (format_expr ~scope_defs e)
  | EArray es ->
      let formatted = List.map (format_expr ~scope_defs) es in
      Printf.sprintf "#[%s]" (String.concat ", " formatted)
  | EAppOp { op; args; tys = _ } ->
      format_operator ~scope_defs op args
  | EMatch _ ->
      (* Pattern matching - complex, will handle later *)
      "sorry -- match not yet implemented\n"
  | EAbs { binder; tys; _ } ->
      (* Lambda abstraction: fun (x : T) (y : U) => body *)
      let vars, body = Bindlib.unmbind binder in
      let params = Array.to_list vars in
      let param_strs = List.map2 (fun var ty ->
        match Mark.remove ty with
        | TLit TUnit -> 
            (* Unit parameter: fun () => body *)
            "()"
        | _ ->
            (* Typed parameter: fun (x : Type) => body *)
            Printf.sprintf "(%s : %s)" 
              (Bindlib.name_of var) 
              (format_typ ty)
      ) params tys in
      Printf.sprintf "fun %s => %s"
        (String.concat " " param_strs)
        (format_expr ~scope_defs body)
  | ELocation loc ->
      format_location ~scope_defs loc
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
and format_operator 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    (op : desugared operator Mark.pos) 
    (args : (desugared, untyped) gexpr list) 
    : string =
  let open Op in
  let binop sym =
    match args with
    | [arg1; arg2] ->
        Printf.sprintf "(%s %s %s)"
          (format_expr ~scope_defs arg1) sym (format_expr ~scope_defs arg2)
    | _ -> "sorry -- wrong number of args for binop"
  in
  let unop sym =
    match args with
    | [arg] -> Printf.sprintf "(%s%s)" sym (format_expr ~scope_defs arg)
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
       | [arg] -> Printf.sprintf "(%s).size" (format_expr ~scope_defs arg)
       | _ -> "sorry -- wrong args for Length")
  | Map | Filter | Fold | Reduce | Concat | Map2 ->
      "sorry -- array operations not yet fully implemented"
  (* Conversions *)
  | ToInt ->
      (match args with
       | [arg] -> Printf.sprintf "(Int.ofRat %s)" (format_expr ~scope_defs arg)
       | _ -> "sorry -- wrong args for ToInt")
  | ToRat ->
      (match args with
       | [arg] -> Printf.sprintf "(Rat.ofInt %s)" (format_expr ~scope_defs arg)
       | _ -> "sorry -- wrong args for ToRat")
  | ToMoney ->
      (match args with
       | [arg] -> Printf.sprintf "(CatalaRuntime.Money.ofInt %s)" (format_expr ~scope_defs arg)
       | _ -> "sorry -- wrong args for ToMoney")
  | Round ->
      (match args with
       | [arg] -> Printf.sprintf "(round %s)" (format_expr ~scope_defs arg)
       | _ -> "sorry -- wrong args for Round")
  (* Other *)
  | Log _ -> (match args with [arg] -> format_expr ~scope_defs arg | _ -> "sorry -- log")
  | ToClosureEnv | FromClosureEnv -> "sorry -- closure env"
  | _ -> "sorry -- unsupported operator"


(** {1 Phase 2: Lean code generation for method-per-variable} *)
(** Format a single rule body (justification and consequence) wrapped in D monad *)
let format_rule_body 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    (rule : Ast.rule) 
    : string =
  let just_expr = Expr.unbox rule.Ast.rule_just in
  let cons_expr = Expr.unbox rule.Ast.rule_cons in
     
  (* Check if justification is always true (common case) *)
  match Mark.remove just_expr with
  | ELit (LBool true) ->
    (* Unconditional rule: just return the consequence wrapped in D *)
    Printf.sprintf ".ok (some (%s))" (format_expr ~scope_defs cons_expr)
  | _ ->
    (* Conditional rule: if-then-else *)
    Printf.sprintf "if %s then .ok (some (%s)) else .ok none"
        (format_expr ~scope_defs just_expr)
        (format_expr ~scope_defs cons_expr)

(** Extract all variable locations used in a list of rules *)
let rules_locations_used (rules : Ast.rule list) : Ast.LocationSet.t =
  List.fold_left (fun acc rule ->
    let just_locs = Ast.locations_used (Expr.unbox rule.Ast.rule_just) in
    let cons_locs = Ast.locations_used (Expr.unbox rule.Ast.rule_cons) in
    Ast.LocationSet.union acc (Ast.LocationSet.union just_locs cons_locs)
  ) Ast.LocationSet.empty rules

(** Generate a unique method name for a rule tree node *)

let format_tree_method_name 
    (scope_name : string)
    (var_name : string)
    (tree : Scopelang.From_desugared.rule_tree)
    (index : int)
    : string =
  let format_rule_method_name (rule : Ast.rule) : string =
    (match rule.Ast.rule_label with
    | Ast.ExplicitlyLabeled (label, _) ->
        Printf.sprintf "%s_%s_%s" scope_name var_name (LabelName.to_string label)
    | Ast.Unlabeled ->
        Printf.sprintf "%s_%s_leaf_%d" scope_name var_name index) in
  match tree with
  | Scopelang.From_desugared.Leaf base_rules ->
      (* Use label from first rule if available *)
      (match List.hd base_rules with
       | rule -> (format_rule_method_name rule))
  | Scopelang.From_desugared.Node (_, base_rules) ->
      (match List.hd base_rules with
       | rule -> (format_rule_method_name rule))

(** Generate parameters from input struct and dependencies *)
let format_method_params
    (inputs : input_info list)
    (scope_name : string)
    (dependencies : Ast.LocationSet.t)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string =
  let input_param = 
    if inputs = [] then []
    else [Printf.sprintf "(input : %s_Input)" scope_name]
  in
  let var_type (scope_def_key : Ast.ScopeDef.t): typ =
    (match Ast.ScopeDef.Map.find_opt scope_def_key scope_defs with
    | None -> raise (Invalid_argument "Scope definition not found")
    | Some scope_def -> scope_def.Ast.scope_def_typ) in
  
  (* Extract variable dependencies from locations, excluding input variables *)
  let dep_params = Ast.LocationSet.fold (fun (loc, _pos) acc ->
    match loc with
    | DesugaredScopeVar { name; state } ->
        let scope_def_key = (name, Ast.ScopeDef.Var state) in
        (match Ast.ScopeDef.Map.find_opt scope_def_key scope_defs with
        | None -> acc  (* Variable not found, skip *)
        | Some scope_def ->
            (* Check if this is an input variable *)
            let is_input = match Mark.remove scope_def.Ast.scope_def_io.io_input with
              | Runtime.NoInput -> false
              | _ -> true
            in
            if is_input then
              acc  (* Input variables are accessed via input struct, not separate params *)
            else
              let type_name = format_typ scope_def.Ast.scope_def_typ in
              let var_name = ScopeVar.to_string (Mark.remove name) in
              Printf.sprintf "(%s : %s)" var_name type_name :: acc)
    | ToplevelVar _ -> acc  (* Skip toplevel vars for now *)
  ) dependencies [] in
  
  String.concat " " (input_param @ List.rev dep_params)

(** Generate a Lean method from a rule tree node.
    Each node becomes its own method that:
    1. Computes local "default" from base rules
    2. Calls processExceptions with exception child methods
    3. Returns the combined result
*)
let rec format_rule_tree_method
    (scope_name : string)
    (var_name : string)
    (var_type : typ)
    (inputs : input_info list)
    (tree : Scopelang.From_desugared.rule_tree)
    (index : int)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string list =  (* Returns list: child methods + this method *)
  
  match tree with
  | Scopelang.From_desugared.Leaf base_rules ->
      (* Leaf: just format the base rules as piecewise defaults *)
      let method_name = format_tree_method_name scope_name var_name tree index in
      let dependencies = rules_locations_used base_rules in
      let params = format_method_params inputs scope_name dependencies scope_defs in
      let return_type = Printf.sprintf "D %s" (format_typ var_type) in
      
      let body = match base_rules with
        | [] -> ".ok none"
        | [single_rule] -> format_rule_body ~scope_defs:(Some scope_defs) single_rule
        | multiple_rules ->
            (* Multiple piecewise rules in leaf *)
            let rule_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs)) multiple_rules in
            Printf.sprintf "processExceptions [%s]" (String.concat ", " rule_bodies)
      in
      
      let method_def = Printf.sprintf "def %s %s : %s :=\n  %s\n" 
        method_name params return_type body in
      [method_def]
      
  | Scopelang.From_desugared.Node (exception_trees, base_rules) ->
      (* Node: generate methods for exceptions, then this node's method *)
      
      (* Recursively generate exception methods *)
      let exception_methods = List.mapi (fun i exc_tree ->
        format_rule_tree_method scope_name var_name var_type inputs exc_tree (index * 10 + i) scope_defs
      ) exception_trees in
      let all_exception_methods = List.concat exception_methods in
      
      (* Generate this node's method *)
      let method_name = format_tree_method_name scope_name var_name tree index in
      let dependencies = rules_locations_used base_rules in
      let params = format_method_params inputs scope_name dependencies scope_defs in
      let return_type = Printf.sprintf "D %s" (format_typ var_type) in
      
      (* Build local default from base rules *)
      let local_default = match base_rules with
        | [] -> "none"
        | [single_rule] ->
            let just_expr = Expr.unbox single_rule.Ast.rule_just in
            let cons_expr = Expr.unbox single_rule.Ast.rule_cons in
            (match Mark.remove just_expr with
             | ELit (LBool true) -> Printf.sprintf "some (%s)" (format_expr ~scope_defs:(Some scope_defs) cons_expr)
             | _ -> Printf.sprintf "if %s then some (%s) else none"
                      (format_expr ~scope_defs:(Some scope_defs) just_expr) (format_expr ~scope_defs:(Some scope_defs) cons_expr))
        | multiple_rules ->
            (* Multiple piecewise rules - process them first *)
            let rule_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs)) multiple_rules in
            Printf.sprintf "match processExceptions [%s] with | .ok r => r | .error e => none"
              (String.concat ", " rule_bodies)
      in
      
      (* Call exception methods *)
      let exception_calls = List.mapi (fun i exc_tree ->
        let exc_method_name = format_tree_method_name scope_name var_name exc_tree (index * 10 + i) in
        Printf.sprintf "%s %s" exc_method_name 
          (if params = "" then "" else "input")  (* Pass same params *)
      ) exception_trees in
      
      let body = 
        if exception_calls = [] then
          Printf.sprintf ".ok (%s)" local_default
        else
          Printf.sprintf 
            "match processExceptions [%s] with\n    | .ok none => .ok (%s)\n    | .ok (some r) => .ok (some r)\n    | .error e => .error e"
            (String.concat ", " exception_calls)
            local_default
      in
      
      let method_def = Printf.sprintf "def %s %s : %s :=\n  %s\n"
        method_name params return_type body in
      
      (* Return all exception methods plus this method *)
      all_exception_methods @ [method_def]

(** Generate all methods for a variable's rule trees *)
let format_var_methods
    (scope_name : string)
    (var_def : var_def_info)
    (inputs : input_info list)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string list =
  let var_name_str = ScopeVar.to_string var_def.var_name in
  List.concat (List.mapi (fun i tree ->
    format_rule_tree_method scope_name var_name_str var_def.var_type inputs tree i scope_defs
  ) var_def.rule_trees)

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
      let just_expr = Expr.unbox rule.Ast.rule_just in
      let cons_expr = Expr.unbox rule.Ast.rule_cons in
      let var_str = ScopeVar.to_string var_name in
      
      (* Check if justification is just 'true' (unconditional rule) *)
      let is_unconditional = match Mark.remove just_expr with
        | ELit (LBool true) -> true
        | _ -> false
      in
      
      let value_expr = 
        if is_unconditional then
          format_expr cons_expr
        else
          (* Conditional rule: wrap in if-then-else *)
          Printf.sprintf "(if %s then %s else sorry \"undefined conditional value\")"
            (format_expr just_expr)
            (format_expr cons_expr)
      in
      
      match Mark.remove def.Ast.scope_def_io.io_output with
      | true ->
          (* Output variable: generate struct field assignment *)
          let field_assignment = Printf.sprintf "%s := %s" var_str value_expr in
          output_fields := field_assignment :: !output_fields
      | false ->
          (* Internal variable: generate let binding *)
          let let_binding = Printf.sprintf "let %s := %s" var_str value_expr in
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

