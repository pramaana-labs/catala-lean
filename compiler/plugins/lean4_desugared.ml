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


(** {1 Keyword handling} *)

(** Lean 4 reserved keywords *)
let lean_keywords =
  [
    "def"; "theorem"; "axiom"; "inductive"; "structure"; "class";
    "instance"; "let"; "in"; "fun"; "match"; "if"; "then"; "else";
    "do"; "return"; "import"; "where"; "deriving"; "namespace"; "end";
    "section"; "variable"; "universe"; "open"; "export"; "private";
    "protected"; "noncomputable"; "unsafe"; "partial"; "mutual";
    "attribute"; "infix"; "infixl"; "infixr"; "prefix"; "postfix";
    "notation"; "macro"; "syntax"; "elab"; "command"; "builtin_initialize";
    "initialize"; "builtin_finalize"; "finalize"; "builtin_eval"; "eval";
    "check"; "check_failure"; "run_cmd"; "compile"; "compile_inductive";
    "compile_def"; "compile_axiom"; "compile_structure"; "compile_inductive";
    "all_goals"; "any_goals"; "focus"; "rotate_left"; "rotate_right";
    "repeat"; "try"; "first"; "solve1"; "trace"; "trace_state";
    "trace_message"; "assumption"; "contradiction"; "constructor"; "cases";
    "case"; "next"; "skip"; "sorry"; "admit"; "exact"; "apply"; "refine";
    "rw"; "simp"; "dsimp"; "unfold"; "fold"; "change"; "convert"; "congr";
    "ac_refl"; "cc"; "linarith"; "omega"; "finish"; "safe"; "norm_num";
    "norm_cast"; "push_cast"; "ring"; "ring_exp"; "abel"; "field_simp";
    "cancel_denoms"; "cancel_denoms"; "field"; "interval_cases"; "by_contra";
    "by_contradiction"; "by_cases"; "trivial"; "dec_trivial"; "tauto";
    "propext"; "ext"; "funext"; "use"; "exists"; "existsi"; "choose"; "obtain"; "from"; "have";
    "suffices"; "show"; "by"; "calc"; "trans"; "symm"; "congr_arg";
    "congr_fun"; "congr"; "refl"; "rfl"; "example"
  ]

(** Create a set of keywords for fast lookup *)
let lean_keywords_set = 
  List.fold_left (fun acc kw -> String.Set.add kw acc) String.Set.empty lean_keywords

(** Sanitize a name to avoid Lean keyword conflicts *)
let sanitize_name (name : string) : string =
  if String.Set.mem name lean_keywords_set then
    "_" ^ name 
  else
    name

(** {1 Phase 1: Variable collection and dependency analysis} *)

(** Information about a scope input variable *)
type input_info = {
  var_name: ScopeVar.t;
  var_type: typ;
  io_input: Runtime.io_input Mark.pos;
}

(** Information about a context variable (Reentrant input with default) *)
type context_var_info = {
  ctx_var_name: ScopeVar.t;
  ctx_var_type: typ;
  ctx_io_input: Runtime.io_input Mark.pos;
  ctx_default: (desugared, untyped) gexpr option;  (* Default value expression if defined *)
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
  is_sub_scope: bool;  (* True if this is a sub-scope variable *)
  sub_scope_name: ScopeName.t option;  (* The scope this variable calls, if is_sub_scope *)
}

(** Collect all input variables from a scope.
    Returns (input_info list * context_var_info list) where:
    - First list: regular input variables
    - Second list: context variables (Reentrant inputs with default values) *)
let collect_inputs (scope_decl : Ast.scope) : (input_info list * context_var_info list) =
  (* Build set of sub-scope variables to exclude from inputs *)
  let sub_scope_vars = ScopeVar.Map.fold (fun var _scope acc ->
    ScopeVar.Set.add var acc
  ) scope_decl.Ast.scope_sub_scopes ScopeVar.Set.empty in
  
  Ast.ScopeDef.Map.fold (fun scope_def def (inputs_acc, context_acc) ->
    let var, _kind = scope_def in
    let var_name, _pos = var in
    (* Skip sub-scope variables - they are not inputs *)
    if ScopeVar.Set.mem var_name sub_scope_vars then
      (inputs_acc, context_acc)
    else
      match Mark.remove def.Ast.scope_def_io.io_input with
      | Runtime.NoInput -> (inputs_acc, context_acc)
      | Runtime.Reentrant ->
          (* Extract default value from rules if present *)
          let default_expr = 
            if RuleName.Map.is_empty def.Ast.scope_def_rules then
              None
            else
              (* Get the first rule's consequence as the default value *)
              let _rule_name, rule = RuleName.Map.choose def.Ast.scope_def_rules in
              Some (Expr.unbox rule.Ast.rule_cons)
          in
          let ctx_info = {
            ctx_var_name = var_name;
            ctx_var_type = def.Ast.scope_def_typ;
            ctx_io_input = def.Ast.scope_def_io.io_input;
            ctx_default = default_expr;
          } in
          (inputs_acc, ctx_info :: context_acc)
      | _ ->
          let info = {
            var_name = var_name;
            var_type = def.Ast.scope_def_typ;
            io_input = def.Ast.scope_def_io.io_input;
          } in
          (info :: inputs_acc, context_acc)
  ) scope_decl.Ast.scope_defs ([], [])



let var_type (scope_def_key : Ast.ScopeDef.t) (scope_decl : Ast.scope) : typ =
  match Ast.ScopeDef.Map.find_opt scope_def_key scope_decl.Ast.scope_defs with
  | None -> raise (Invalid_argument "Scope definition not found")
  | Some scope_def -> scope_def.Ast.scope_def_typ

(** Collect variable information in dependency order using existing analysis *)
let collect_var_info_ordered 
    ?(program_ctx : Shared_ast.decl_ctx option = None)
    (scope_decl : Ast.scope)
    : (var_def_info list * input_info list * context_var_info list) =
  
  (* 1. Get dependency-ordered list of variables *)
  let scope_deps = Desugared.Dependency.build_scope_dependencies scope_decl in
  Desugared.Dependency.check_for_cycle scope_decl scope_deps;
  let scope_ordering = 
    Desugared.Dependency.correct_computation_ordering scope_deps in
  
  (* 2. Get exception graphs for all variables *)
  let exc_graphs = Scopelang.From_desugared.scope_to_exception_graphs scope_decl in
  
  (* 3. Collect inputs, context vars, and build input variable set *)
  let inputs, context_vars = collect_inputs scope_decl in
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
        (* Check if this is a sub-scope variable *)
        (match ScopeVar.Map.find_opt var scope_decl.Ast.scope_sub_scopes with
        | Some sub_scope_name ->
            (* This is a sub-scope variable - collect its input dependencies *)
            (* We need to include both:
               1. Dependencies of the SubScopeInput definitions (what they depend on)
               2. The SubScopeInput variables themselves (they need to be computed first) *)
            let sub_scope_input_deps = Ast.ScopeDef.Map.fold (fun def_key scope_def acc ->
              match def_key with
              | (v, _), Ast.ScopeDef.SubScopeInput { name; var_within_origin_scope = _ } ->
                  if ScopeVar.equal var v && ScopeName.equal name sub_scope_name then
                    (* This is an input to our sub-scope *)
                    (* First, add this SubScopeInput variable itself as a dependency *)
                    let acc = ScopeVar.Map.add v scope_def.Ast.scope_def_typ acc in
                    (* Then, collect dependencies from the rules that define this input *)
                    let all_deps = Desugared.Ast.free_variables scope_def.Ast.scope_def_rules in
                    let var_deps = Ast.ScopeDef.Map.fold (fun def_key _pos acc ->
                      match def_key with
                      | (v, _), Ast.ScopeDef.Var _ -> ScopeVar.Map.add v (var_type def_key) acc
                      | _ -> acc
                    ) all_deps acc in
                    var_deps
                  else acc
              | _ -> acc
            ) scope_decl.Ast.scope_defs ScopeVar.Map.empty in
            
            (* Remove input variables from dependencies (they're parameters) *)
            let internal_deps = ScopeVar.Map.filter (fun _v _t -> not (ScopeVar.Set.mem _v input_vars)) sub_scope_input_deps in
            
            (* Get the output type from the sub-scope's output struct *)
            (* The type should be the output struct type - try to get it from program context first *)
            let sub_scope_output_type = 
              match program_ctx with
              | Some ctx ->
                  (match ScopeName.Map.find_opt sub_scope_name ctx.ctx_scopes with
                  | Some scope_info -> Mark.add Pos.void (TStruct scope_info.out_struct_name)
                  | None -> 
                      (* Fallback: try scope_defs *)
                      (match Ast.ScopeDef.Map.find_opt ((var, Pos.void), Ast.ScopeDef.Var state) scope_decl.Ast.scope_defs with
                      | Some scope_def -> scope_def.Ast.scope_def_typ
                      | None ->
                          (* Last resort: construct struct name from scope name *)
                          let struct_name_str = sanitize_name (ScopeName.to_string sub_scope_name) in
                          Mark.add Pos.void (TStruct (StructName.fresh [] (struct_name_str, Pos.void)))))
              | None ->
                  (* No program context - try scope_defs *)
                  (match Ast.ScopeDef.Map.find_opt ((var, Pos.void), Ast.ScopeDef.Var state) scope_decl.Ast.scope_defs with
                  | Some scope_def -> scope_def.Ast.scope_def_typ
                  | None ->
                      (* Last resort: construct struct name from scope name *)
                      let struct_name_str = sanitize_name (ScopeName.to_string sub_scope_name) in
                      Mark.add Pos.void (TStruct (StructName.fresh [] (struct_name_str, Pos.void))))
            in
            
            Some {
              var_name = var;
              var_type = sub_scope_output_type;
              is_output = (match Ast.ScopeDef.Map.find_opt ((var, Pos.void), Ast.ScopeDef.Var state) scope_decl.Ast.scope_defs with
                | Some scope_def -> Mark.remove scope_def.Ast.scope_def_io.io_output
                | None -> false);
              rules = RuleName.Map.empty;  (* Sub-scope variables don't have rules *)
              dependencies = internal_deps;
              exception_graph = Desugared.Dependency.ExceptionsDependencies.empty;
              rule_trees = [];  (* Sub-scope variables don't have rule trees *)
              is_sub_scope = true;
              sub_scope_name = Some sub_scope_name;
            }
        | None ->
            (* Regular variable *)
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
                     is_sub_scope = false;
                     sub_scope_name = None;
                   }))
    | _ -> None
  ) scope_ordering in
  
  (var_defs, inputs, context_vars)

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
  | TStruct s -> sanitize_name (StructName.to_string s)
  | TEnum e -> sanitize_name (EnumName.to_string e)
  | TOption t ->
      Printf.sprintf "(Optional %s)" (format_typ t)
  | TArrow (args, ret) ->
      let all_types = args @ [ret] in
      let formatted = List.map format_typ all_types in
      Printf.sprintf "(%s)" (String.concat " → " formatted)
  | TArray t ->
      Printf.sprintf "(List %s)" (format_typ t)
  | TDefault t -> format_typ t
  | TForAll _ -> "TForall"
  | TVar _  | TClosureEnv -> "Unit"
    (* For now, output Unit for complex types we don't fully support *)

(** Format a location (variable reference) to Lean code *)
let format_location 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)  (* Set to false when formatting input struct defaults *)
    (loc : desugared glocation) 
    : string =
  match loc with
  | DesugaredScopeVar { name; state } ->
      let var_name = sanitize_name (ScopeVar.to_string (Mark.remove name)) in
      let base_name = match state with
        | None -> var_name
        | Some state_name -> 
            Printf.sprintf "%s_%s" var_name (sanitize_name (StateName.to_string state_name))
      in
      (* Check if this is an input variable that should be prefixed with "input." *)
      (* Only add prefix if use_input_prefix is true (not when formatting input struct defaults) *)
      if not use_input_prefix then
        base_name
      else
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
      sanitize_name (TopdefName.to_string (Mark.remove name))

(** Format an expression to Lean code *)
let rec format_expr 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)  (* Set to false when formatting input struct defaults *)
    (e : (desugared, untyped) gexpr) 
    : string =
  match Mark.remove e with
  | ELit l -> format_lit l
  | EVar v -> sanitize_name (Bindlib.name_of v)
  | EIfThenElse { cond; etrue; efalse } ->
      Printf.sprintf "(if %s then %s else %s)"
        (format_expr ~scope_defs ~use_input_prefix cond)
        (format_expr ~scope_defs ~use_input_prefix etrue)
        (format_expr ~scope_defs ~use_input_prefix efalse)
  | ETuple es ->
      let formatted = List.map (format_expr ~scope_defs ~use_input_prefix) es in
      Printf.sprintf "(%s)" (String.concat ", " formatted)
  | ETupleAccess { e; index; size = _ } ->
      (* Lean uses 1-indexed tuple access *)
      Printf.sprintf "(%s).%d" (format_expr ~scope_defs ~use_input_prefix e) (index + 1)
  | EApp { f; args; tys = _ } ->
      let f_str = format_expr ~scope_defs ~use_input_prefix f in
      let args_str = List.map (format_expr ~scope_defs ~use_input_prefix) args in
      Printf.sprintf "(%s %s)" f_str (String.concat " " args_str)
  | EStruct { name = _; fields } ->
      let bindings = StructField.Map.bindings fields in
      let formatted_fields = List.map (fun (field, e) ->
        Printf.sprintf "%s := %s"
          (sanitize_name (StructField.to_string field))
          (format_expr ~scope_defs ~use_input_prefix e)
      ) bindings in
      Printf.sprintf "{ %s }" (String.concat ", " formatted_fields)
  | EStructAccess { e; field; name = _ } ->
      Printf.sprintf "(%s).%s" (format_expr ~scope_defs ~use_input_prefix e) (sanitize_name (StructField.to_string field))
  | EInj { e; cons; name } ->
      Printf.sprintf "(%s.%s %s)"
        (sanitize_name (EnumName.to_string name))
        (sanitize_name (EnumConstructor.to_string cons))
        (format_expr ~scope_defs ~use_input_prefix e)
  | EArray es ->
      let formatted = List.map (format_expr ~scope_defs ~use_input_prefix) es in
      Printf.sprintf "[%s]" (String.concat ", " formatted)
  | EAppOp { op; args; tys = _ } ->
      format_operator ~scope_defs ~use_input_prefix op args
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
              (sanitize_name (Bindlib.name_of var)) 
              (format_typ ty)
      ) params tys in
      Printf.sprintf "(fun %s => %s)"
        (String.concat " " param_strs)
        (format_expr ~scope_defs ~use_input_prefix body)
  | ELocation loc ->
      format_location ~scope_defs ~use_input_prefix loc
  | EScopeCall { scope; args } ->
    let function_name = sanitize_name (String.uncapitalize_ascii (ScopeName.to_string scope)) in 
    let args_values_list = ScopeVar.Map.fold
    (fun scope_var (pos, gexpr) acc ->
       let s = format_expr gexpr in
       ((ScopeVar.to_string scope_var) ^ ":=" ^ s)  :: acc
    ) args []
    in 
    let args_string = String.concat "," args_values_list 
  in ("(" ^ function_name ^ " " ^ "{" ^ args_string ^ "}" ^ ")")    
    (* Scope calls handled, but not completely *)
  | EDefault _ | EPureDefault _ | EEmpty | EErrorOnEmpty _ ->
      (* Default logic - will handle later *)
      "sorry -- default logic not yet implemented\n"
  | EDStructAmend _ ->
      "sorry -- struct amendment not yet implemented\n"
  | _ ->
      "sorry /-unsupported expression-/"

(** Format an operator and its arguments to Lean code *)
and format_operator 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)
    (op : desugared operator Mark.pos) 
    (args : (desugared, untyped) gexpr list) 
    : string =
  let open Op in
  let binop sym =
    match args with
    | [arg1; arg2] ->
        Printf.sprintf "(%s %s %s)"
          (format_expr ~scope_defs ~use_input_prefix arg1) sym (format_expr ~scope_defs ~use_input_prefix arg2)
    | _ -> "sorry -- wrong number of args for binop"
  in
  let unop sym =
    match args with
    | [arg] -> Printf.sprintf "(%s%s)" sym (format_expr ~scope_defs ~use_input_prefix arg)
    | _ -> "sorry -- wrong number of args for unop"
  in
  match Mark.remove op with
  (* Overloaded operators in desugared AST *)
  | Add -> binop "+"
  | Sub -> binop "-"
  | Mult ->
      (* Use CatalaRuntime.multiply which handles all type combinations *)
      (match args with
      | [arg1; arg2] ->
          let arg1_str = format_expr ~scope_defs ~use_input_prefix arg1 in
          let arg2_str = format_expr ~scope_defs ~use_input_prefix arg2 in
          Printf.sprintf "(CatalaRuntime.multiply %s %s)"
            arg1_str arg2_str
      | _ -> "sorry -- wrong number of args for Mult")
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
       | [arg] -> Printf.sprintf "(%s).length" (format_expr ~scope_defs ~use_input_prefix arg)
       | _ -> "sorry -- wrong args for Length")
  | Map ->
      (match args with
        | [func; arr] ->
            Printf.sprintf "(List.map (%s) %s)"
              (format_expr ~scope_defs ~use_input_prefix func)
              (format_expr ~scope_defs ~use_input_prefix arr)
        | _ -> "sorry -- wrong args for Map")
  | Filter ->
      (match args with
        | [pred; arr] ->
            Printf.sprintf "(List.filter (%s) %s)"
              (format_expr ~scope_defs ~use_input_prefix pred)
              (format_expr ~scope_defs ~use_input_prefix arr)
        | _ -> "sorry -- wrong args for Filter")
  | Fold ->
      (match args with
        | [fn; init; arr] ->
            Printf.sprintf "(List.foldl (%s) %s %s)"
              (format_expr ~scope_defs ~use_input_prefix fn)
              (format_expr ~scope_defs ~use_input_prefix init)
              (format_expr ~scope_defs ~use_input_prefix arr)
        | _ -> "sorry -- wrong args for Fold")
  | Concat ->
      (match args with
        | [arr1; arr2] ->
            Printf.sprintf "(%s ++ %s)"
              (format_expr ~scope_defs ~use_input_prefix arr1)
              (format_expr ~scope_defs ~use_input_prefix arr2)
        | _ -> "sorry -- wrong args for Concat")
  | Reduce ->
      (match args with
        | [fn; default; arr] ->
            (* Reduce: if array is empty, call default(); otherwise fold starting with first element *)
            Printf.sprintf "(match %s with | [] => %s () | x0 :: xn => List.foldl %s x0 xn)"
              (format_expr ~scope_defs ~use_input_prefix arr)
              (format_expr ~scope_defs ~use_input_prefix default)
              (format_expr ~scope_defs ~use_input_prefix fn)
        | _ -> "sorry -- wrong args for Reduce")
  | Map2 ->
      "sorry -- map2 not yet implemented\n"
  (* Conversions *)
  | ToInt ->
      (match args with
       | [arg] -> Printf.sprintf "(Int.ofRat %s)" (format_expr ~scope_defs ~use_input_prefix arg)
       | _ -> "sorry -- wrong args for ToInt")
  | ToRat ->
      (match args with
       | [arg] -> Printf.sprintf "(Rat.ofInt %s)" (format_expr ~scope_defs ~use_input_prefix arg)
       | _ -> "sorry -- wrong args for ToRat")
  | ToMoney ->
      (match args with
       | [arg] -> Printf.sprintf "(CatalaRuntime.Money.ofInt %s)" (format_expr ~scope_defs ~use_input_prefix arg)
       | _ -> "sorry -- wrong args for ToMoney")
  | Round ->
      (match args with
       | [arg] -> Printf.sprintf "(round %s)" (format_expr ~scope_defs ~use_input_prefix arg)
       | _ -> "sorry -- wrong args for Round")
  (* Other *)
  | Log _ -> (match args with [arg] -> format_expr ~scope_defs ~use_input_prefix arg | _ -> "sorry -- log")
  | ToClosureEnv | FromClosureEnv -> "sorry -- closure env"
  | _ -> "sorry -- unsupported operator"


(** {1 Phase 2: Lean code generation for method-per-variable} *)
(** Format a single rule body (justification and consequence) wrapped in D monad *)
let format_rule_body 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)
    (rule : Ast.rule) 
    : string =
  let just_expr = Expr.unbox rule.Ast.rule_just in
  let cons_expr = Expr.unbox rule.Ast.rule_cons in
  
  (* Format the consequence, wrapping in lambda if it has parameters from "depends on" *)
  let format_cons () =
    match rule.Ast.rule_parameter with
    | Some (params, _pos) ->
        (* Has parameters from "depends on" - wrap in fun *)
        let param_strs = List.map (fun ((var, _var_pos), param_ty) ->
          Printf.sprintf "(%s : %s)" (sanitize_name (Bindlib.name_of var)) (format_typ param_ty)
        ) params in
        Printf.sprintf "fun %s => %s" (String.concat " " param_strs) (format_expr ~scope_defs ~use_input_prefix cons_expr)
    | None ->
        (* No parameters - just format the expression *)
        format_expr ~scope_defs ~use_input_prefix cons_expr
  in
     
  (* Check if justification is always true (common case) *)
  match Mark.remove just_expr with
  | ELit (LBool true) ->
    (* Unconditional rule: just return the consequence wrapped in D *)
    Printf.sprintf ".ok (some (%s))" (format_cons ())
  | _ ->
    (* Conditional rule: if-then-else *)
    Printf.sprintf "if %s then .ok (some (%s)) else .ok none"
        (format_expr ~scope_defs ~use_input_prefix just_expr)
        (format_cons ())

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
        Printf.sprintf "%s_%s_%s" scope_name var_name (sanitize_name (LabelName.to_string label))
    | Ast.Unlabeled ->
        (match tree with 
        | Scopelang.From_desugared.Leaf base_rules ->
          Printf.sprintf "%s_%s_leaf_%d" scope_name var_name index 
        | Scopelang.From_desugared.Node (_,base_rules) ->
          Printf.sprintf "%s_%s_node_%d" scope_name var_name index)
        ) in 
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
              let var_name = sanitize_name (ScopeVar.to_string (Mark.remove name)) in
              Printf.sprintf "(%s : %s)" var_name type_name :: acc)
    | ToplevelVar _ -> acc  (* Skip toplevel vars for now *)
  ) dependencies [] in
  
  String.concat " " (input_param @ List.rev dep_params)

(** Convert context_var_info to input_info *)
let context_to_input (ctx : context_var_info) : input_info = {
  var_name = ctx.ctx_var_name;
  var_type = ctx.ctx_var_type;
  io_input = ctx.ctx_io_input;
}

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
    (contexts : context_var_info list)
    (tree : Scopelang.From_desugared.rule_tree)
    (index : int)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string list * Ast.LocationSet.t =  (* Returns list: child methods + this method *)
 
  (* Check if var_name is a context variable - if so, don't generate functions *)
  let is_context_var_name = List.exists (fun ctx ->
    sanitize_name (ScopeVar.to_string ctx.ctx_var_name) = var_name
  ) contexts in
  if is_context_var_name then
    ([], Ast.LocationSet.empty)
  else
  
  (* Combine inputs and contexts for method params *)
  let all_inputs = inputs @ (List.map context_to_input contexts) in
  
  match tree with
  | Scopelang.From_desugared.Leaf base_rules ->
      (* Leaf: just format the base rules as piecewise defaults *)
      let method_name = format_tree_method_name scope_name var_name tree index in
      let dependencies = rules_locations_used base_rules in
      let params = format_method_params all_inputs scope_name dependencies scope_defs in
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
      [method_def], dependencies
      
  | Scopelang.From_desugared.Node (exception_trees, base_rules) ->
      (* Node: generate methods for exceptions, then this node's method *)
      
      (* Recursively generate exception methods *)
      let exception_methods = List.mapi (fun i exc_tree ->
        let methods, _dependencies = format_rule_tree_method scope_name var_name var_type inputs contexts exc_tree (index * 10 + i) scope_defs in
        methods, _dependencies
      ) exception_trees in
      let all_exception_methods = List.concat (List.map fst exception_methods) in
      let all_dependencies = List.fold_left (
        fun acc (_, dependencies) -> Ast.LocationSet.union acc dependencies
        ) Ast.LocationSet.empty exception_methods in
      
      (* Generate this node's method *)
      let method_name = format_tree_method_name scope_name var_name tree index in
      let params = format_method_params all_inputs scope_name all_dependencies scope_defs in
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
      
      (* Call exception methods - need to pass all their dependencies *)
      let exception_calls = List.mapi (fun i (_exc_methods, exc_deps) ->
        let exc_method_name = format_tree_method_name scope_name var_name (List.nth exception_trees i) (index * 10 + i) in
        let exc_params = format_method_params all_inputs scope_name exc_deps scope_defs in
        (* Extract just the parameter names from the formatted params *)
        let param_names = 
          if exc_params = "" then ""
          else
            (* Parse params like "(input : Type)" to extract "input" *)
            let rec extract_params str acc =
              let len = String.length str in
              (* Find the next opening paren *)
              let rec find_paren pos =
                if pos >= len then None
                else if str.[pos] = '(' then Some pos
                else find_paren (pos + 1)
              in
              match find_paren 0 with
              | None -> List.rev acc
              | Some start ->
                  (* Find the closing paren *)
                  let rec find_close pos =
                    if pos >= len then len
                    else if str.[pos] = ')' then pos
                    else find_close (pos + 1)
                  in
                  let close = find_close (start + 1) in
                  (* Extract content between parens *)
                  let content = String.sub str (start + 1) (close - start - 1) in
                  (* Find colon to separate name from type *)
                  let rec find_colon pos =
                    if pos >= String.length content then String.length content
                    else if content.[pos] = ':' then pos
                    else find_colon (pos + 1)
                  in
                  let colon_pos = find_colon 0 in
                  let name = String.trim (String.sub content 0 colon_pos) in
                  (* Continue with the rest of the string *)
                  let rest_start = min (close + 1) len in
                  let rest = String.sub str rest_start (len - rest_start) in
                  extract_params rest (name :: acc)
            in
            let names = extract_params exc_params [] in
            String.concat " " names
        in
        Printf.sprintf "%s %s" exc_method_name param_names
      ) exception_methods in
      
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
      all_exception_methods @ [method_def], all_dependencies

(** Generate all methods for a variable's rule trees *)
let format_var_methods
    (scope_name : string)
    (var_def : var_def_info)
    (inputs : input_info list)
    (contexts : context_var_info list)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string list =
  let var_name_str = sanitize_name (ScopeVar.to_string var_def.var_name) in
  List.concat (List.mapi (fun i tree ->
    let methods, _deps = format_rule_tree_method scope_name var_name_str var_def.var_type inputs contexts tree i scope_defs in
    methods
  ) var_def.rule_trees)

(** Generate input struct for a scope *)
let format_input_struct 
    (scope_name : string) 
    (inputs : input_info list) 
    (contexts: context_var_info list)
    (sub_scopes : ScopeName.t ScopeVar.Map.t)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string =
    (* First, all the subscope fields are created pointing to the input structure of the subscopes. Then, all the fields are arranged in 
    topological order of dependencies and initialized appropriately. *)
  let has_sub_scopes = not (ScopeVar.Map.is_empty sub_scopes) in
  if inputs = [] && contexts = [] && not has_sub_scopes then ""
  else
    (* Format sub-scope fields first: var_name : subscope_name_Input *)
    let formatted_subscope_fields = ScopeVar.Map.fold (fun var sub_scope_name acc ->
      let var_name = sanitize_name (ScopeVar.to_string var) in
      let sub_scope_input_type = Printf.sprintf "%s_Input" 
        (sanitize_name (ScopeName.to_string sub_scope_name)) in
      Printf.sprintf "  %s : %s" var_name sub_scope_input_type :: acc
    ) sub_scopes [] in
    
    let formatted_input_fields = List.map (fun (input : input_info) ->
      Printf.sprintf "  %s : %s"
        (sanitize_name (ScopeVar.to_string input.var_name))
        (format_typ input.var_type)
    ) inputs in
    
    (* Sort context variables by dependency order *)
    (* Build set of context variable names for quick lookup *)
    let context_var_set = List.fold_left (fun acc ctx ->
      ScopeVar.Set.add ctx.ctx_var_name acc
    ) ScopeVar.Set.empty contexts in
    
    (* Get dependencies for a context variable (other context vars it depends on) *)
    let get_ctx_deps (ctx : context_var_info) : ScopeVar.Set.t =
      match ctx.ctx_default with
      | None -> ScopeVar.Set.empty
      | Some expr ->
          let locs = Ast.locations_used expr in
          Ast.LocationSet.fold (fun (loc, _pos) acc ->
            match loc with
            | DesugaredScopeVar { name; _ } ->
                let var = Mark.remove name in
                if ScopeVar.Set.mem var context_var_set then
                  ScopeVar.Set.add var acc
                else acc
            | _ -> acc
          ) locs ScopeVar.Set.empty
    in
    
    (* Topological sort of context variables *)
    let rec topo_sort remaining sorted =
      if remaining = [] then List.rev sorted
      else
        (* Find a variable with no unsatisfied dependencies *)
        let sorted_set = List.fold_left (fun acc ctx ->
          ScopeVar.Set.add ctx.ctx_var_name acc
        ) ScopeVar.Set.empty sorted in
        let (ready, not_ready) = List.partition (fun ctx ->
          let deps = get_ctx_deps ctx in
          ScopeVar.Set.subset deps sorted_set
        ) remaining in
        match ready with
        | [] -> 
            (* Cycle or all remaining have deps - just add them in order *)
            List.rev sorted @ remaining
        | _ -> topo_sort not_ready (List.rev ready @ sorted)
    in
    let sorted_contexts = topo_sort contexts [] in
    
    let formatted_context_fields = List.map (fun (ctx : context_var_info) ->
      let var_name = sanitize_name (ScopeVar.to_string ctx.ctx_var_name) in
      let var_type = format_typ ctx.ctx_var_type in
      let scope_def_key = ((ctx.ctx_var_name, Pos.void), Ast.ScopeDef.Var None) in
      
      (* Get rules and build default value with exception handling (similar to line 752-821) *)
      (* Note: use_input_prefix:false because we're defining the input struct itself *)
      let format_default_with_exceptions () =
        match Ast.ScopeDef.Map.find_opt scope_def_key scope_defs with
        | None -> 
            (match ctx.ctx_default with
            | Some expr -> Some (format_expr ~use_input_prefix:false expr)
            | None -> None)
        | Some scope_def ->
            if RuleName.Map.is_empty scope_def.Ast.scope_def_rules then
              (match ctx.ctx_default with
              | Some expr -> Some (format_expr ~use_input_prefix:false expr)
              | None -> None)
            else
              let rules_list = RuleName.Map.bindings scope_def.Ast.scope_def_rules in
              (* Separate base case rules from exception rules *)
              let base_rules = List.filter_map (fun (_, rule) ->
                match rule.Ast.rule_exception with
                | Ast.BaseCase -> Some rule
                | _ -> None
              ) rules_list in
              let exception_rules = List.filter_map (fun (_, rule) ->
                match rule.Ast.rule_exception with
                | Ast.BaseCase -> None
                | _ -> Some rule
              ) rules_list in
              
              (* Build local_default from base cases (similar to line 752-765) *)
              let local_default = match base_rules with
                | [] -> "sorry /- no base case -/"
                | [single_rule] ->
                    let just_expr = Expr.unbox single_rule.Ast.rule_just in
                    let cons_expr = Expr.unbox single_rule.Ast.rule_cons in
                    (match Mark.remove just_expr with
                    | ELit (LBool true) -> format_expr ~scope_defs:(Some scope_defs) ~use_input_prefix:false cons_expr
                    | _ -> Printf.sprintf "(if %s then %s else sorry)"
                             (format_expr ~scope_defs:(Some scope_defs) ~use_input_prefix:false just_expr) 
                             (format_expr ~scope_defs:(Some scope_defs) ~use_input_prefix:false cons_expr))
                | multiple_rules ->
                    let rule_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs) ~use_input_prefix:false) multiple_rules in
                    Printf.sprintf "(match processExceptions [%s] with | .ok (some r) => r | _ => sorry)"
                      (String.concat ", " rule_bodies)
              in
              
              (* If there are exceptions, use processExceptions pattern (similar to line 821) *)
              if List.length exception_rules > 0 then
                let exception_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs) ~use_input_prefix:false) exception_rules in
                Some (Printf.sprintf "(match processExceptions [%s] with | .ok none => %s | .ok (some r) => r | .error _ => sorry)"
                  (String.concat ", " exception_bodies) local_default)
              else
                Some local_default
      in
      
      (* Check if the type is a function type (depends on) *)
      match Mark.remove ctx.ctx_var_type with
      | TArrow (arg_types, _ret_type) ->
          (* Function type - look up actual parameter names from scope_def_parameters *)
          let param_names = match Ast.ScopeDef.Map.find_opt scope_def_key scope_defs with
            | Some scope_def ->
                (match scope_def.Ast.scope_def_parameters with
                | Some (params, _pos) ->
                    (* Use actual parameter names from Catala "depends on" *)
                    List.map (fun ((name, _name_pos), param_ty) ->
                      Printf.sprintf "(%s : %s)" (sanitize_name name) (format_typ param_ty)
                    ) params
                | None ->
                    (* No parameters info - use placeholder names *)
                    List.mapi (fun i arg_ty ->
                      Printf.sprintf "(arg%d : %s)" i (format_typ arg_ty)
                    ) arg_types)
            | None ->
                (* scope_def not found - use placeholder names *)
                List.mapi (fun i arg_ty ->
                  Printf.sprintf "(arg%d : %s)" i (format_typ arg_ty)
                ) arg_types
          in
          let params_str = String.concat " " param_names in
          (match format_default_with_exceptions () with
          | Some default_str -> Printf.sprintf "  %s : %s := fun %s => %s" var_name var_type params_str default_str
          | None -> Printf.sprintf "  %s : %s" var_name var_type)
      | _ ->
          (* Not a function type - use regular formatting *)
          (match format_default_with_exceptions () with
          | Some default_str -> Printf.sprintf "  %s : %s := %s" var_name var_type default_str
          | None -> Printf.sprintf "  %s : %s" var_name var_type)
    ) sorted_contexts in
    Printf.sprintf "structure %s_Input where\n%s\n"
      scope_name
      (String.concat "\n" (formatted_subscope_fields @ formatted_input_fields @ formatted_context_fields))

(** Format a struct declaration to Lean code *)
let format_struct_decl (name : string) (fields : typ StructField.Map.t) : string =
  let field_list = StructField.Map.bindings fields in
  let formatted_fields = List.map (fun (field, ty) ->
    Printf.sprintf "  %s : %s"
      (sanitize_name (StructField.to_string field))
      (format_typ ty)
  ) field_list in
  Printf.sprintf "structure %s where\n%s"
    name
    (String.concat "\n" formatted_fields)

(* Format a enum declaration to lean code *)
(* TODO: Remove redundant unit declarations *)
let format_enum_decl (name: string) (fields: typ EnumConstructor.Map.t) : string = 
  let constructor_list = EnumConstructor.Map.bindings fields in 
  let num_forall_ty = List.fold_left (fun acc (field, ty) ->
    match Mark.remove ty with 
    | TForAll _ -> acc + 1
    | _ -> acc
    ) 0 constructor_list
    in 
    if num_forall_ty = 0 then 
      (let formatted_fields =  (List.map (fun (field, ty) ->
      Printf.sprintf " | %s : %s -> %s"
      (sanitize_name (EnumConstructor.to_string field))
      (format_typ ty)
      name 
      ) constructor_list )
      in
      Printf.sprintf "inductive %s : Type where\n%s"
        name
        (String.concat "\n" formatted_fields))
    else 
      (let formatted_fields = (List.map (fun (field, ty) ->
      Printf.sprintf " | %s : %s -> %s TForall"
      (sanitize_name (EnumConstructor.to_string field))
      (format_typ ty)
      name 
      ) constructor_list)
      in 
      Printf.sprintf "inductive %s (TForall:Type) : Type where\n%s"
        name
        (String.concat "\n" formatted_fields))

let format_toplevel
?(program_ctx : Shared_ast.decl_ctx option = None)
(toplevel_name: TopdefName.t)
(toplevel_decl: Ast.topdef)
: string =
  let toplevel_name_str = sanitize_name (TopdefName.to_string toplevel_name) in 
  Printf.sprintf "/- %s is a toplevel decl, not handled -/" (toplevel_name_str)

(** Generate Lean code for a scope using method-per-rule architecture *)
let format_scope 
    ?(program_ctx : Shared_ast.decl_ctx option = None)
    (scope_name : ScopeName.t) 
    (scope_decl : Ast.scope) 
    : string =
  let scope_name_str = sanitize_name (ScopeName.to_string scope_name) in
  
  (* 1. Collect variable information in dependency order *)
  let var_defs, inputs, context_vars = collect_var_info_ordered ~program_ctx scope_decl in
  
  (* 2. Generate input struct (if any inputs) *)
  let input_struct = format_input_struct scope_name_str inputs context_vars scope_decl.Ast.scope_sub_scopes scope_decl.Ast.scope_defs in
  (* 3. Generate all methods for all variables *)
  let all_methods = List.concat (List.map (fun var_def ->
    format_var_methods scope_name_str var_def inputs context_vars scope_decl.Ast.scope_defs
  ) var_defs) in
  
  (* 4. Generate output struct *)
  let output_vars = List.filter (fun v -> v.is_output) var_defs in
  let output_fields = List.fold_left (fun acc var_def ->
    let field_name = StructField.fresh (sanitize_name (ScopeVar.to_string var_def.var_name), Pos.void) in
    StructField.Map.add field_name var_def.var_type acc
  ) StructField.Map.empty output_vars in
  
  let output_struct = format_struct_decl scope_name_str output_fields in

  (* 5. Generate main scope function that calls methods *)
  (* Use lowercase for function name to avoid conflict with struct name *)
  let scope_func_name = sanitize_name (String.uncapitalize_ascii scope_name_str) in
  let has_input = inputs <> [] in
  let has_context = context_vars <> [] in
  let input_param = if (has_input || has_context) then Printf.sprintf "(input : %s_Input)" scope_name_str else "" in
  
  (* Helper to check if a variable is a context variable (but not if it's also an output) *)
  let is_context_var var_name =
    List.exists (fun ctx -> ScopeVar.equal ctx.ctx_var_name var_name) context_vars 
  in
  
  (* Helper to get method call for a variable *)
  let get_method_call var_def =
    if var_def.is_sub_scope then
      (* Sub-scope variable: call the sub-scope function *)
      (match var_def.sub_scope_name with
      | Some sub_scope_name ->
          let sub_scope_name_str = sanitize_name (ScopeName.to_string sub_scope_name) in
          let func_name = sanitize_name (String.uncapitalize_ascii sub_scope_name_str) in
          
          (* Collect sub-scope input arguments from SubScopeInput definitions *)
          (* Track if we have any inputs defined (even with no rules) vs no inputs at all *)
          let sub_scope_inputs, has_any_inputs = Ast.ScopeDef.Map.fold (fun def_key scope_def (acc, has_inputs) ->
            match def_key with
            | (v, _), Ast.ScopeDef.SubScopeInput { name; var_within_origin_scope } ->
                if ScopeVar.equal var_def.var_name v && ScopeName.equal name sub_scope_name then
                  (* Check if this is actually an input (not an output) *)
                  match Mark.remove scope_def.Ast.scope_def_io.io_input with
                  | Runtime.NoInput -> (acc, has_inputs)  (* Skip outputs *)
                  | _ ->
                      (* This is an input to our sub-scope - get its value from the rule *)
                      let input_var_name = sanitize_name (ScopeVar.to_string var_within_origin_scope) in
                      (* Get the value from the SubScopeInput definition's rules *)
                      if RuleName.Map.is_empty scope_def.Ast.scope_def_rules then
                        (* No rules - input exists but no value assigned, will use default *)
                        (acc, true)
                      else
                        (* Get the first rule and format its consequence *)
                        let rule = snd (RuleName.Map.choose scope_def.Ast.scope_def_rules) in
                        let cons_expr = Expr.unbox rule.Ast.rule_cons in
                        let input_value = format_expr ~scope_defs:(Some scope_decl.Ast.scope_defs) cons_expr in
                        (Printf.sprintf "%s := %s" input_var_name input_value :: acc, true)
                else (acc, has_inputs)
            | _ -> (acc, has_inputs)
          ) scope_decl.Ast.scope_defs ([], false) in
          
          if has_any_inputs then Printf.sprintf "%s { %s }" func_name (String.concat ", " (List.rev sub_scope_inputs))
          else Printf.sprintf "%s" func_name
      | None -> "sorry -- sub-scope name missing")
    else
      (* Regular variable: call the method *)
      let var_name = sanitize_name (ScopeVar.to_string var_def.var_name) in
      let method_name = match var_def.rule_trees with
        | tree :: _ -> format_tree_method_name scope_name_str var_name tree 0
        | [] -> var_name ^ "_undefined"
      in
      (* Pass input and required internal vars as dependencies, excluding context vars *)
      let dep_params = ScopeVar.Map.fold (fun dep_var _dep_ty acc ->
        if is_context_var dep_var then
          acc  (* Skip context variables - they're accessed via input struct *)
        else
          let dep_name = sanitize_name (ScopeVar.to_string dep_var) in
          dep_name :: acc
      ) var_def.dependencies [] in
      let all_params = (if (has_input||has_context) then ["input"] else []) @ List.rev dep_params in
      Printf.sprintf "%s %s" method_name (String.concat " " all_params)
  in
  
  (* Build let bindings for ALL variables in dependency order, excluding context variables *)
  let all_bindings = List.filter_map (fun var_def ->
    (* Skip context variables - they're already in the input struct with defaults *)
    if is_context_var var_def.var_name then
      None
    else
      let var_name = sanitize_name (ScopeVar.to_string var_def.var_name) in
      let call = get_method_call var_def in
      if var_def.is_sub_scope then
        (* Sub-scope variables return the struct directly, no D monad *)
        Some (Printf.sprintf "let %s := %s" var_name call)
      else
        (* Regular variables return D monad *)
        Some (Printf.sprintf "let %s := match %s with | .ok (some val) => val | _ => sorry "
          var_name call)
  ) var_defs in
  (* Build output struct field assignments by just referencing the variables *)
  let output_assignments = List.map (fun var_def ->
    let var_name = sanitize_name (ScopeVar.to_string var_def.var_name) in
    if is_context_var var_def.var_name then
      Printf.sprintf "%s := input.%s" var_name var_name
    else
      Printf.sprintf "%s := %s" var_name var_name
  ) output_vars in
  
  (* Assemble the main function *)
  let func_def =
    if output_assignments = [] then
      (* No variables at all (shouldn't happen, but handle it) *)
      Printf.sprintf "def %s %s : %s :=\n  {  }"
        scope_func_name
        input_param
        scope_name_str
    else
      (* Generate let bindings for all variables, then construct struct *)
      Printf.sprintf "def %s %s : %s :=\n  %s\n  { %s }"
        scope_func_name
        input_param
        scope_name_str
        (String.concat "\n  " all_bindings)
        (String.concat ",\n    " output_assignments)
  in
  
  (* 6. Assemble all parts *)
  let parts = List.filter (fun s -> s <> "") [
    input_struct;
    String.concat "\n" all_methods;
    output_struct;
    func_def
  ] in
  String.concat "\n" parts

(** Generate a complete Lean file from a desugared program *)
let generate_lean_code (prgm : Ast.program) : string =
  let header = "import CaseStudies.Pramaana.CatalaRuntime\n\nopen CatalaRuntime\n" in
  
  (* Collect scope input and output struct names to avoid generating them twice *)
  (* (they're generated in format_scope) *)
  let scope_structs = ScopeName.Map.fold (fun _scope_name scope_info acc ->
    acc
    |> StructName.Set.add scope_info.in_struct_name
    |> StructName.Set.add scope_info.out_struct_name
  ) prgm.program_ctx.ctx_scopes StructName.Set.empty in
  
  (* Generate all struct declarations from the context, excluding scope structs *)
  let struct_code = StructName.Map.fold (fun struct_name fields acc ->
    (* Skip scope input/output structs - they're generated separately in format_scope *)
    if StructName.Set.mem struct_name scope_structs then
      acc
    else if ((StructName.to_string struct_name) = "Period_en.Period" || (StructName.to_string struct_name) = "Date_en.MonthOfYear") then
      acc
    else
      let code = format_struct_decl (sanitize_name (StructName.to_string struct_name)) fields in
      code :: acc
  ) prgm.program_ctx.ctx_structs [] in 

  let enum_code = EnumName.Map.fold (fun enum_name fields acc ->
    let code = format_enum_decl (sanitize_name (EnumName.to_string enum_name)) fields in
    code :: acc
  ) prgm.program_ctx.ctx_enums [] in 
  
  (* Generate code for each scope in the program root *)
  let scope_code = ScopeName.Map.fold (fun scope_name scope_decl acc ->
    let code = format_scope ~program_ctx:(Some prgm.program_ctx) scope_name scope_decl in
    code :: acc
  ) prgm.program_root.module_scopes [] in

  let toplevel_function_code = TopdefName.Map.fold (fun topdef_name topdef_decl acc -> 
    let code = format_toplevel ~program_ctx:(Some prgm.program_ctx) topdef_name topdef_decl in 
    code :: acc
  ) prgm.program_root.module_topdefs [] in 

  
  (* Combine: header, enums,structs, then scopes *)
  let all_parts = List.filter (fun s -> s <> "") [
    header;
    String.concat "\n\n" (List.rev enum_code);
    String.concat "\n\n" (List.rev struct_code);
    String.concat "\n\n" (List.rev toplevel_function_code);
    String.concat "\n\n" (List.rev scope_code)
  ] in
  String.concat "\n\n" all_parts

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

