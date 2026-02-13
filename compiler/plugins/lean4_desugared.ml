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
open Desugared.Dependency

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
    "case"; "next"; "skip"; "default"; "admit"; "exact"; "apply"; "refine";
    "rw"; "simp"; "dsimp"; "unfold"; "fold"; "change"; "convert"; "congr";
    "ac_refl"; "cc"; "linarith"; "omega"; "finish"; "safe"; "norm_num";
    "norm_cast"; "push_cast"; "ring"; "ring_exp"; "abel"; "field_simp";
    "cancel_denoms"; "cancel_denoms"; "field"; "interval_cases"; "by_contra";
    "by_contradiction"; "by_cases"; "trivial"; "dec_trivial"; "tauto";
    "propext"; "ext"; "funext"; "use"; "exists"; "existsi"; "choose"; "obtain"; "from"; "have";
    "suffices"; "show"; "by"; "calc"; "trans"; "symm"; "congr_arg";
    "congr_fun"; "congr"; "refl"; "rfl"; "example";
    (* Lean built-in names that conflict with common Catala identifiers *)
    "assert"; "sort"; "insert"; "type"; "Type"; "Prop"; "Set"; "List"; "Array";
    "Option"; "IO"; "Pure"; "Monad"; "Functor"; "Bind"; "true"; "false"; "not";
    "or"; "and"; "mod"; "decide"
  ]

(** Create a set of keywords for fast lookup *)
let lean_keywords_set = 
  List.fold_left (fun acc kw -> String.Set.add kw acc) String.Set.empty lean_keywords

(** Sanitize a name to avoid Lean keyword conflicts *)
let sanitize_name (name : string) : string =
  if String.length name = 0 then name
  else if String.Set.mem name lean_keywords_set then
    "_" ^ name 
  else if name.[0] = '\'' then 
    (* Replace leading apostrophe with 't' (e.g., 'a -> ta, 'b -> tb) *)
    "t" ^ String.sub name 1 (String.length name - 1)
  else
    name

(** Uncapitalize a potentially qualified name (e.g., "Module.ScopeName").
    Only the last component (after the final '.') is uncapitalized.
    For "Sections.IRCSimplified" -> "Sections.iRCSimplified" 
    For "ScopeName" -> "scopeName" *)
let uncapitalize_qualified_name (name : string) : string =
  match String.rindex_opt name '.' with
  | Some idx ->
      let prefix = String.sub name 0 (idx + 1) in
      let suffix = String.sub name (idx + 1) (String.length name - idx - 1) in
      prefix ^ String.uncapitalize_ascii suffix
  | None ->
      String.uncapitalize_ascii name

(** {1 Phase 1: Variable collection and dependency analysis} *)

(** Information about a scope input variable *)
type input_info = {
  var_name: ScopeVar.t;
  var_state: StateName.t option;  (* State of the variable, if any *)
  var_type: typ;
  io_input: Runtime.io_input Mark.pos;
}

(** Information about a context variable (Reentrant input with default) *)
type context_var_info = {
  ctx_var_name: ScopeVar.t;
  ctx_state: StateName.t option;  (* State of the variable, if any *)
  ctx_var_type: typ;
  ctx_io_input: Runtime.io_input Mark.pos;
  ctx_default: (desugared, untyped) gexpr option;  (* Default value expression if defined *)
}

(** Information about a variable's definition *)
type var_def_info = {
  var_name: ScopeVar.t;
  var_state: StateName.t option;  (* State of the variable, if any *)
  var_type: typ;
  is_output: bool;
  is_input_output: bool;  (* True if this variable is both input and output *)
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
    - Second list: context variables (Reentrant inputs with default values) and internal variables (NoInput with definitions) *)
let collect_inputs (scope_decl : Ast.scope) : (input_info list * context_var_info list) =
  (* Build set of sub-scope variables to exclude from inputs *)
  let sub_scope_vars = ScopeVar.Map.fold (fun var _scope acc ->
    ScopeVar.Set.add var acc
  ) scope_decl.Ast.scope_sub_scopes ScopeVar.Set.empty in
  
  Ast.ScopeDef.Map.fold (fun scope_def def (inputs_acc, context_acc) ->
    let var, kind = scope_def in
    let var_name, _pos = var in
    (* Extract state from kind *)
    let state = match kind with
      | Ast.ScopeDef.Var state -> state
      | Ast.ScopeDef.SubScopeInput _ -> None
    in
    (* Skip sub-scope variables - they are not inputs *)
    if ScopeVar.Set.mem var_name sub_scope_vars then
      (inputs_acc, context_acc)
    else
      match Mark.remove def.Ast.scope_def_io.io_input with
      | Runtime.NoInput ->
          (* NoInput variables (outputs and internals) are NOT placed in the input struct.
             They are computed as let bindings in the scope body, in dependency order.
             This allows internal variables to reference output variables correctly. *)
          (inputs_acc, context_acc)
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
            ctx_state = state;
            ctx_var_type = def.Ast.scope_def_typ;
            ctx_io_input = def.Ast.scope_def_io.io_input;
            ctx_default = default_expr;
          } in
          (inputs_acc, ctx_info :: context_acc)
      | _ ->
          let info = {
            var_name = var_name;
            var_state = state;
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
              var_state = state;
              var_type = sub_scope_output_type;
              is_output = (match Ast.ScopeDef.Map.find_opt ((var, Pos.void), Ast.ScopeDef.Var state) scope_decl.Ast.scope_defs with
                | Some scope_def -> Mark.remove scope_def.Ast.scope_def_io.io_output
                | None -> false);
              is_input_output = false;  (* Sub-scope variables are not input-output *)
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
                 (* Check if this is an input-output variable (both input and output) *)
                 let is_input = match Mark.remove scope_def.Ast.scope_def_io.io_input with
                   | Runtime.NoInput -> false
                   | _ -> true
                 in
                 let is_output = Mark.remove scope_def.Ast.scope_def_io.io_output in
                 let is_input_output = is_input && is_output in
                 
                 let is_context = match Mark.remove scope_def.Ast.scope_def_io.io_input with
                  | Runtime.Reentrant -> true
                  | _ -> false
                in
                 (* Include if has rules OR is an input-output variable OR is a context variable
                    (context variables need let bindings to unwrap Option from input struct) *)
                 if RuleName.Map.is_empty scope_def.Ast.scope_def_rules && not is_input_output && not is_context then None
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
                   
                   (* Get exception graph and build rule trees - input-output vars may not have exception graphs *)
                   let exc_graph = Ast.ScopeDef.Map.find_opt scope_def_key exc_graphs in
                   let rule_trees = match exc_graph with
                     | Some eg -> Scopelang.From_desugared.def_map_to_tree scope_def.Ast.scope_def_rules eg
                     | None -> []  (* Input-output variables without rules have no rule trees *)
                   in
                   
                   Some {
                     var_name = var;
                     var_state = state;
                     var_type = scope_def.Ast.scope_def_typ;
                     is_output = is_output;
                     is_input_output = is_input_output;
                     rules = scope_def.Ast.scope_def_rules;
                     dependencies = internal_deps;
                     exception_graph = (match exc_graph with Some eg -> eg | None -> Desugared.Dependency.ExceptionsDependencies.empty);
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
      let num_str = Runtime.integer_to_string num in
      (* Parenthesize negative numerators so Lean doesn't parse - as subtraction *)
      let num_str = if String.length num_str > 0 && num_str.[0] = '-' then "(" ^ num_str ^ ")" else num_str in
      Printf.sprintf "(Rat.mk %s %s)" num_str (Runtime.integer_to_string den)
  | LMoney m ->
      let cents = Runtime.money_to_cents m in
      let cents_str = Runtime.integer_to_string cents in
      (* Parenthesize negative values so Lean doesn't parse - as subtraction *)
      let cents_str = if String.length cents_str > 0 && cents_str.[0] = '-' then "(" ^ cents_str ^ ")" else cents_str in
      Printf.sprintf "(CatalaRuntime.Money.ofCents %s)" cents_str
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
  | TForAll binder ->
      (* Unwrap the forall binder and format the inner type.
         The type parameter is handled separately in top-level defs. *)
      let _, inner_ty = Bindlib.unmbind binder in
      format_typ inner_ty
  | TVar v -> sanitize_name (Bindlib.name_of v)  (* Use the type variable's name *)
  | TClosureEnv | TError | _ -> "Unit"
    (* For now, output Unit for complex types we don't fully support *)

(** Recursively collect unique type variable names from a type *)
let rec collect_type_vars (ty : typ) (acc : String.Set.t) : String.Set.t =
  match Mark.remove ty with
  | TVar v -> String.Set.add (sanitize_name (Bindlib.name_of v)) acc
  | TArrow (args, ret) ->
      let acc = List.fold_left (fun a t -> collect_type_vars t a) acc args in
      collect_type_vars ret acc
  | TTuple ts ->
      List.fold_left (fun a t -> collect_type_vars t a) acc ts
  | TOption t | TArray t | TDefault t ->
      collect_type_vars t acc
  | TForAll binder ->
      (* Unbind and collect from the body type *)
      let _, body_ty = Bindlib.unmbind binder in
      collect_type_vars body_ty acc
  | TLit _ | TStruct _ | TEnum _ | TClosureEnv | TError | _ -> acc

(** Collect unique type variables from a list of types *)
let collect_type_vars_from_list (tys : typ list) : string list =
  let var_set = List.fold_left (fun acc ty -> collect_type_vars ty acc) String.Set.empty tys in
  String.Set.elements var_set

(** Build a mapping from toplevel type's type variables to EAbs parameter type variables.
    This handles cases where Catala renames type variables during compilation. *)
let build_type_var_mapping (toplevel_ty : typ) (eabs_param_tys : typ list) : (string * string) list =
  (* Collect type vars from both sources *)
  let toplevel_vars = collect_type_vars_from_list [toplevel_ty] in
  let eabs_vars = collect_type_vars_from_list eabs_param_tys in
  (* Zip them together - assumes same order and count *)
  List.combine toplevel_vars eabs_vars

(** Simple string replacement that replaces whole words only *)
let replace_word (str : string) (old_word : string) (new_word : string) : string =
  if old_word = new_word then str
  else
    (* Check if character is a word boundary (delimiter) *)
    let is_delimiter c =
      match c with
      | ' ' | '(' | ')' | '[' | ']' | '{' | '}' | ',' -> true
      | _ -> false
    in
    (* Also check for multi-byte UTF-8 sequences that are delimiters *)
    let is_delimiter_at str pos =
      if pos >= String.length str then true
      else if is_delimiter str.[pos] then true
      else
        (* Check for × (U+00D7) and → (U+2192) *)
        let remaining = String.length str - pos in
        if remaining >= 2 && str.[pos] = '\xC3' && str.[pos+1] = '\x97' then true  (* × *)
        else if remaining >= 3 && str.[pos] = '\xE2' && str.[pos+1] = '\x86' && str.[pos+2] = '\x92' then true  (* → *)
        else false
    in
    let len = String.length str in
    let buf = Buffer.create len in
    let rec process i word_start =
      if i >= len then (
        (* Flush final word *)
        if i > word_start then
          let word = String.sub str word_start (i - word_start) in
          if word = old_word then Buffer.add_string buf new_word
          else Buffer.add_string buf word
      ) else if is_delimiter_at str i then (
        (* Flush current word *)
        if i > word_start then (
          let word = String.sub str word_start (i - word_start) in
          if word = old_word then Buffer.add_string buf new_word
          else Buffer.add_string buf word
        );
        (* Add delimiter *)
        Buffer.add_char buf str.[i];
        (* Skip multi-byte UTF-8 sequences *)
        let skip = 
          if i + 2 < len && str.[i] = '\xC3' then 2
          else if i + 3 < len && str.[i] = '\xE2' then 3
          else 1
        in
        for j = i + 1 to min (i + skip - 1) (len - 1) do
          Buffer.add_char buf str.[j]
        done;
        process (i + skip) (i + skip)
      ) else
        process (i + 1) word_start
    in
    process 0 0;
    Buffer.contents buf

(** Substitute type variable names in a formatted type string *)
let substitute_type_vars (type_str : string) (mappings : (string * string) list) : string =
  List.fold_left (fun str (old_name, new_name) ->
    replace_word str old_name new_name
  ) type_str mappings

(** Format a location (variable reference) to Lean code *)
let format_location 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)  (* Set to false when formatting input struct defaults *)
    ?(in_scope_body_context : bool = false)  (* Whether we're in scope body (subscope calls) *)
    ?(program_ctx : Shared_ast.decl_ctx option = None)  (* For detuplify *)
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
      (* Check if this is a variable that should be prefixed with "input." *)
      (* Only pure inputs (OnlyInput) are accessed via input.field.
         Context variables (Reentrant) are Option T in the struct, unwrapped
         in the scope body and passed as explicit params — accessed as local vars.
         Internal/output variables (NoInput) are let bindings in the scope body. *)
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
                let is_pure_input = match Mark.remove scope_def.Ast.scope_def_io.io_input with
                  | Runtime.OnlyInput -> true
                  | _ -> false  (* Reentrant: local var; NoInput: local var *)
                in
                if is_pure_input then
                  Printf.sprintf "input.%s" base_name
                else if in_scope_body_context then
                  (* In scope body (subscope calls): non-pure-input variables are let-bindings with _ prefix *)
                  "_" ^ base_name
                else
                  (* In leaf function bodies: non-pure-input variables are function parameters without _ prefix *)
                  base_name))
  | ToplevelVar { name; _ } ->
      (* Map Catala stdlib toplevel functions to Lean equivalents *)
      let topdef_name = TopdefName.to_string (Mark.remove name) in
      (match topdef_name with
      | "Integer_en.max" | "Integer_internal.max" -> "max"
      | "Integer_en.min" | "Integer_internal.min" -> "min"
      | _ -> sanitize_name topdef_name)

(** Check if an expression is a boolean operator (And, Or, Xor, Not) *)
let is_bool_operator (e : (desugared, untyped) gexpr) : bool =
  match Mark.remove e with
  | EAppOp { op; _ } ->
      (match Mark.remove op with
      | Op.And | Op.Or | Op.Xor | Op.Not -> true
      (* Comparison operators now return Bool (wrapped with decide) *)
      | Op.Lt | Op.Lte | Op.Gt | Op.Gte | Op.Eq -> true
      | _ -> false)
  | ELit (LBool _) -> true  (* Boolean literals are already Bool *)
  | EMatch _ -> true  (* Match expressions that return Bool shouldn't be wrapped with decide *)
  | EIfThenElse _ -> true  (* If-then-else expressions that return Bool *)
  | _ -> false

(** Format an expression to Lean code *)
let rec format_expr 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)  (* Set to false when formatting input struct defaults *)
    ?(in_scope_body_context : bool = false)  (* Set to true when formatting subscope calls in scope body *)
    ?(program_ctx : Shared_ast.decl_ctx option = None)  (* For looking up topdef types in detuplify *)
    (e : (desugared, untyped) gexpr) 
    : string =
  match Mark.remove e with
  | ELit l -> format_lit l
  | EVar v -> sanitize_name (Bindlib.name_of v)
  | EIfThenElse { cond; etrue; efalse } ->
      Printf.sprintf "(if %s then %s else %s)"
        (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context cond)
        (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context etrue)
        (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context efalse)
  | ETuple es ->
      let formatted = List.map (format_expr ~scope_defs ~use_input_prefix ~program_ctx) es in
      Printf.sprintf "(%s)" (String.concat ", " formatted)
  | ETupleAccess { e; index; size } ->
      (* Lean represents tuples as nested pairs: (a, b, c) = (a, (b, c)).
         To access element at 0-based index i in a tuple of size n:
         - index 0: .1
         - index 1 (if n=2): .2, (if n>2): .2.1
         - index i (if i=n-1): .2 repeated i times
         - index i (if i<n-1): .2 repeated i times then .1 *)
      let base = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context e in
      if index = 0 then
        Printf.sprintf "(%s).1" base
      else if index = size - 1 then
        (* Last element: just chain .2's *)
        let dots = String.concat "" (List.init index (fun _ -> ".2")) in
        Printf.sprintf "(%s)%s" base dots
      else
        (* Middle element: chain .2's then .1 *)
        let dots = String.concat "" (List.init index (fun _ -> ".2")) in
        Printf.sprintf "(%s)%s.1" base dots
  | EApp { f; args; tys } ->
      let f_str = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context f in
      (* Detuplify: convert single tuple argument to multiple curried arguments.
         Two-tier logic matching Expr.detuplify_application from shared_ast/expr.ml:
         
         Tier 1 (tys-based): When EApp.tys has length > 1, the surface desugaring
         (LetIn handler) explicitly marked this as a multi-arg call. Safe to detuplify
         all cases (ETuple splat, variable projection, let-bind+project).
         
         Tier 2 (ETuple+topdef): When tys is empty/length<=1 (regular FunCall),
         ONLY splat ETuple literals when the function is a ToplevelVar with arity > 1.
         Never apply variable projections here — the desugared AST may not have all
         arguments yet (e.g., implicit SourcePosition args are added in scopelang). *)
      let fmt_expr = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context in
      (* Helper: generate tuple projections for a given arity *)
      let make_projections arg_str arity =
        List.init arity (fun index ->
          if index = 0 then
            Printf.sprintf "(%s).1" arg_str
          else if index = arity - 1 then
            let dots = String.concat "" (List.init index (fun _ -> ".2")) in
            Printf.sprintf "(%s)%s" arg_str dots
          else
            let dots = String.concat "" (List.init index (fun _ -> ".2")) in
            Printf.sprintf "(%s)%s.1" arg_str dots
        )
      in
      (* Helper: look up topdef arity from program_ctx, excluding implicit args *)
      let topdef_arity_of_f =
        match Mark.remove f with
        | ELocation (ToplevelVar { name; _ }) ->
            (match program_ctx with
             | Some ctx ->
                 let topdef_name = Mark.remove name in
                 (match TopdefName.Map.find_opt topdef_name ctx.ctx_topdefs with
                  | Some (topdef_type, _vis) ->
                      (match Mark.remove topdef_type with
                       | TArrow (arg_tys, _) ->
                           let explicit_arg_tys = List.filter
                             (fun ty -> not (Pos.has_attr (Mark.get ty) ImplicitPosArg))
                             arg_tys
                           in
                           if List.length explicit_arg_tys > 1 then
                             Some (List.length explicit_arg_tys)
                           else None
                       | _ -> None)
                  | None -> None)
             | None -> None)
        | _ -> None
      in
      (* Filter out implicit position argument types from tys.
         After the typing pass, tys includes ALL param types including implicit
         SourcePosition args marked with ImplicitPosArg. But args only has
         explicit args — implicit args are inserted in scopelang, which we skip.
         So we must use only explicit tys to determine detuplification arity. *)
      let tys_explicit = List.filter
        (fun ty -> not (Pos.has_attr (Mark.get ty) ImplicitPosArg))
        tys
      in
      let arity_from_tys = List.length tys_explicit in
      (match args with
       | [single_arg] when arity_from_tys > 1 ->
           (* Tier 1: tys says multiple args expected (LetIn-derived application) *)
           (match Mark.remove single_arg with
            | ETuple es ->
                (* Literal tuple: splat elements as curried args *)
                let args_str = List.map fmt_expr es in
                Printf.sprintf "(%s %s)" f_str (String.concat " " args_str)
            | _ ->
                (* Variable or expression: generate tuple projections *)
                let arg_str = fmt_expr single_arg in
                let projected = make_projections arg_str arity_from_tys in
                Printf.sprintf "(%s %s)" f_str (String.concat " " projected))
       | [single_arg] ->
           (* Tier 2: tys empty or length 1 (regular FunCall) *)
           (match Mark.remove single_arg with
            | ETuple es when topdef_arity_of_f = Some (List.length es) ->
                (* ETuple literal AND topdef expects that many args: splat *)
                let args_str = List.map fmt_expr es in
                Printf.sprintf "(%s %s)" f_str (String.concat " " args_str)
            | _ ->
                (* Non-tuple arg or no matching topdef arity: format normally *)
                let args_str = List.map fmt_expr args in
                Printf.sprintf "(%s %s)" f_str (String.concat " " args_str))
       | _ ->
           (* Multiple args - format normally *)
           let args_str = List.map fmt_expr args in
           Printf.sprintf "(%s %s)" f_str (String.concat " " args_str))
  | EStruct { name = name; fields } ->
      let bindings = StructField.Map.bindings fields in
      let formatted_fields = List.map (fun (field, e) ->
        Printf.sprintf "%s := %s"
          (sanitize_name (StructField.to_string field))
          (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context e)
      ) bindings in
      Printf.sprintf "({ %s } : %s)" (String.concat ", " formatted_fields) (sanitize_name (StructName.to_string name))
  | EStructAccess { e; field; name = name } ->
      Printf.sprintf "(%s).%s" (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context e) (sanitize_name (StructField.to_string field))
  | EInj { e; cons; name } ->
      Printf.sprintf "(%s.%s %s)"
        (sanitize_name (EnumName.to_string name))
        (sanitize_name (EnumConstructor.to_string cons))
        (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context e)
  | EArray es ->
      let formatted = List.map (format_expr ~scope_defs ~use_input_prefix ~program_ctx) es in
      Printf.sprintf "[%s]" (String.concat ", " formatted)
  | EAppOp { op; args; tys = _ } ->
      format_operator ~scope_defs ~use_input_prefix ~in_scope_body_context ~program_ctx op args
  | EMatch { e = matched_expr; name = enum_name; cases } ->
      (* Pattern matching: match expr with | Case1 var => body1 | Case2 var => body2 *)
      let matched_str = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context matched_expr in
      let enum_name_str = sanitize_name (EnumName.to_string enum_name) in
      let cases_list = EnumConstructor.Map.bindings cases in
      let formatted_cases = List.map (fun (cons, case_expr) ->
        let cons_name = sanitize_name (EnumConstructor.to_string cons) in
        (* Each case is typically a lambda: fun (x : T) => body *)
        match Mark.remove case_expr with
        | EAbs { binder; tys = _; _ } ->
            let vars, body = Bindlib.unmbind binder in
            let params = Array.to_list vars in
            let param_names = List.map (fun var -> sanitize_name (Bindlib.name_of var)) params in
            let body_str = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context body in
            Printf.sprintf "| %s.%s %s => %s" 
              enum_name_str cons_name (String.concat " " param_names) body_str
        | _ ->
            (* Not a lambda - just format the expression directly *)
            let body_str = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context case_expr in
            Printf.sprintf "| %s.%s _ => %s" enum_name_str cons_name body_str
      ) cases_list in
      (* Generate match as single line to avoid indentation issues in struct literals *)
      Printf.sprintf "(match %s with %s)" matched_str (String.concat "" formatted_cases)
  | EAbs { binder; tys; _ } ->
      (* Lambda abstraction: fun (x : T) (y : U) => body 
         NOTE: Inline lambdas CANNOT have explicit type parameters in Lean.
         Type parameters {t : Type} are only valid in top-level def declarations.
         For polymorphic inline lambdas, Lean infers the types automatically. *)
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
        (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context body)
  | ELocation loc ->
      format_location ~scope_defs ~use_input_prefix ~in_scope_body_context ~program_ctx loc
  | EScopeCall { scope; args } ->
    (* EScopeCall represents calling a scope with INPUT values to get OUTPUT values.
       Generate: (scopeFunction ({ input_field := val, ... } : ScopeName_Input))
       where scopeFunction is the lowercase version of the scope name. *)
    let scope_name = sanitize_name (ScopeName.to_string scope) in
    let func_name = sanitize_name (uncapitalize_qualified_name scope_name) in
    let input_struct_name = scope_name ^ "_Input" in
    let args_values_list = ScopeVar.Map.fold
      (fun scope_var (_, gexpr) acc ->
         let s = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context gexpr in
         (sanitize_name (ScopeVar.to_string scope_var) ^ " := " ^ s) :: acc
      ) args []
    in 
    let args_string = String.concat ", " args_values_list in
    Printf.sprintf "(%s ({ %s } : %s))" func_name args_string input_struct_name
  | EDefault _ | EPureDefault _ | EEmpty | EErrorOnEmpty _ ->
      (* Default logic - will handle later *)
      "default -- default logic not yet implemented\n"
  | EDStructAmend _ ->
      "default -- struct amendment not yet implemented\n"
  | _ ->
      "default /-unsupported expression-/"

(** Format an operator and its arguments to Lean code *)
and format_operator 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)
    ?(in_scope_body_context : bool = false)
    ?(program_ctx : Shared_ast.decl_ctx option = None)  (* For detuplify *)
    (op : desugared operator Mark.pos) 
    (args : (desugared, untyped) gexpr list) 
    : string =
  let open Op in
  let binop sym =
    match args with
    | [arg1; arg2] ->
        Printf.sprintf "(%s %s %s)"
          (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg1) sym (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg2)
    | _ -> "default -- wrong number of args for binop"
  in
  (* Comparison operators return Prop in Lean 4, so wrap with decide to get Bool *)
  let compop sym =
    match args with
    | [arg1; arg2] ->
        Printf.sprintf "(decide (%s %s %s))"
          (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg1) sym (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg2)
    | _ -> "default -- wrong number of args for compop"
  in
  let unop sym =
    match args with
    | [arg] -> Printf.sprintf "(%s%s)" sym (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg)
    | _ -> "default -- wrong number of args for unop"
  in
  (* Helper to wrap with decide only if not a boolean operator or match expression *)
  let format_bool_arg arg =
    let formatted = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg in
    let skip_decide = is_bool_operator arg || 
      (match Mark.remove arg with EMatch _ -> true | _ -> false) in
    if skip_decide then formatted
    else Printf.sprintf "decide (%s)" formatted
  in
  match Mark.remove op with
  (* Overloaded operators in desugared AST *)
  | Add -> binop "+"
  | Sub -> binop "-"
  | Mult ->
      (* Use CatalaRuntime.multiply which handles all type combinations *)
      (match args with
      | [arg1; arg2] ->
          let arg1_str = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg1 in
          let arg2_str = format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg2 in
          Printf.sprintf "(CatalaRuntime.multiply %s %s)"
            arg1_str arg2_str
      | _ -> "default -- wrong number of args for Mult")
  | Div -> binop "/"
  | Minus -> unop "-"
  (* Comparison operators - wrap with decide to convert Prop to Bool *)
  | Lt -> compop "<"
  | Lte -> compop "≤"
  | Gt -> compop ">"
  | Gte -> compop "≥"
  | Eq -> compop "="
  (* Boolean operators - wrap base propositions with decide *)
  | And ->
      (match args with
      | [arg1; arg2] ->
          Printf.sprintf "(%s && %s)" (format_bool_arg arg1) (format_bool_arg arg2)
      | _ -> "default -- wrong number of args for And")
  | Or ->
      (match args with
      | [arg1; arg2] ->
          Printf.sprintf "(%s || %s)" (format_bool_arg arg1) (format_bool_arg arg2)
      | _ -> "default -- wrong number of args for Or")
  | Xor ->
      (match args with
      | [arg1; arg2] ->
          Printf.sprintf "(%s ^^ %s)" (format_bool_arg arg1) (format_bool_arg arg2)
      | _ -> "default -- wrong number of args for Xor")
  | Not ->
      (match args with
      | [arg] -> Printf.sprintf "(!%s)" (format_bool_arg arg)
      | _ -> "default -- wrong number of args for Not")
  (* Polymorphic operators *)
  | Length ->
      (match args with
       | [arg] -> Printf.sprintf "(%s).length" (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg)
       | _ -> "default -- wrong args for Length")
  | Map ->
      (match args with
        | [func; arr] ->
            Printf.sprintf "(List.map (%s) %s)"
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context func)
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arr)
        | _ -> "default -- wrong args for Map")
  | Filter ->
      (match args with
        | [pred; arr] ->
            Printf.sprintf "(List.filter (%s) %s)"
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context pred)
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arr)
        | _ -> "default -- wrong args for Filter")
  | Fold ->
      (match args with
        | [fn; init; arr] ->
            Printf.sprintf "(List.foldl (%s) %s %s)"
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context fn)
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context init)
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arr)
        | _ -> "default -- wrong args for Fold")
  | Concat ->
      (match args with
        | [arr1; arr2] ->
            Printf.sprintf "(%s ++ %s)"
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arr1)
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arr2)
        | _ -> "default -- wrong args for Concat")
  | Reduce ->
      (match args with
        | [fn; default; arr] ->
            (* Reduce: if array is empty, call default(); otherwise fold starting with first element.
               Add type annotation from the fold function's first parameter type to prevent
               backward type inference issues (e.g., Date+Duration where Lean infers Duration). *)
            let result_type_annotation = match Mark.remove fn with
              | EAbs { tys; _ } ->
                  (match tys with
                   | ty :: _ -> Printf.sprintf " : %s" (format_typ ty)
                   | _ -> "")
              | _ -> ""
            in
            Printf.sprintf "((match %s with | [] => %s () | x0 :: xn => List.foldl %s x0 xn)%s)"
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arr)
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context default)
              (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context fn)
              result_type_annotation
        | _ -> "default -- wrong args for Reduce")
  | Map2 ->
      "default -- map2 not yet implemented\n"
  (* Conversions *)
  | ToInt ->
      (match args with
       | [arg] -> Printf.sprintf "(Rat.floor %s)" (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg)
       | _ -> "default -- wrong args for ToInt")
  | ToRat ->
      (match args with
       | [arg] ->  Printf.sprintf "(CatalaRuntime.toRat %s)" (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg)
       | _ -> "default -- wrong args for ToRat")
  | ToMoney ->
      (match args with
       | [arg] -> Printf.sprintf "(CatalaRuntime.toMoney %s)" (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg)
       | _ -> "default -- wrong args for ToMoney")
  | Round ->
      (match args with
       | [arg] -> Printf.sprintf "(round %s)" (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg)
       | _ -> "default -- wrong args for Round")
  (* Other *)
  | Log _ -> (match args with [arg] -> format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context arg | _ -> "default -- log")
  | ToClosureEnv | FromClosureEnv -> "default -- closure env"
  | _ -> "default -- unsupported operator"


(** {1 Phase 2: Lean code generation for method-per-variable} *)

(** Format a rule's consequence expression, wrapping in lambda if it has parameters.
    This helper ensures function parameters from "depends on" are properly handled.
    @param skip_lambda_wrap If true, don't wrap in lambda even if rule has parameters
                            (used when top-level lambda wrapping is done elsewhere) *)
let format_rule_consequence 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)
    ?(skip_lambda_wrap : bool = false)
    ?(in_scope_body_context : bool = false)
    ?(program_ctx : Shared_ast.decl_ctx option = None)  (* For detuplify *)
    (rule : Ast.rule) 
    : string =
  let cons_expr = Expr.unbox rule.Ast.rule_cons in
  match rule.Ast.rule_parameter with
  | Some (params, _pos) when not skip_lambda_wrap ->
      (* Has parameters from "depends on" - wrap in lambda *)
      let param_strs = List.map (fun ((var, _var_pos), param_ty) ->
        Printf.sprintf "(%s : %s)" (sanitize_name (Bindlib.name_of var)) (format_typ param_ty)
      ) params in
      Printf.sprintf "fun %s => %s" 
        (String.concat " " param_strs) 
        (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context cons_expr)
  | _ ->
      (* No parameters OR skip_lambda_wrap=true - just format the expression *)
      format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context cons_expr

(** Format a single rule body (justification and consequence) wrapped in Option *)
let format_rule_body 
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(use_input_prefix : bool = true)
    ?(skip_lambda_wrap : bool = false)
    ?(in_scope_body_context : bool = false)
    ?(program_ctx : Shared_ast.decl_ctx option = None)  (* For detuplify *)
    (rule : Ast.rule)
    : string =
  let just_expr = Expr.unbox rule.Ast.rule_just in
  
  (* Check if justification is always true (common case) *)
  match Mark.remove just_expr with
  | ELit (LBool true) ->
    (* Unconditional rule: just return the consequence wrapped in some *)
    Printf.sprintf "some (%s)" (format_rule_consequence ~scope_defs ~use_input_prefix ~skip_lambda_wrap ~in_scope_body_context ~program_ctx rule)
  | _ ->
    (* Conditional rule: if-then-else *)
    Printf.sprintf "if %s then some (%s) else none"
        (format_expr ~scope_defs ~use_input_prefix ~program_ctx ~in_scope_body_context just_expr)
        (format_rule_consequence ~scope_defs ~use_input_prefix ~skip_lambda_wrap ~in_scope_body_context ~program_ctx rule)

(** Extract all variable locations used in a list of rules *)
let rules_locations_used (rules : Ast.rule list) : Ast.LocationSet.t =
  List.fold_left (fun acc rule ->
    let just_locs = Ast.locations_used (Expr.unbox rule.Ast.rule_just) in
    let cons_locs = Ast.locations_used (Expr.unbox rule.Ast.rule_cons) in
    Ast.LocationSet.union acc (Ast.LocationSet.union just_locs cons_locs)
  ) Ast.LocationSet.empty rules

(** Collect all rules from a rule tree (including nested children) *)
let rec collect_rules_from_tree (tree : Scopelang.From_desugared.rule_tree) : Ast.rule list =
  match tree with
  | Scopelang.From_desugared.Leaf rules -> rules
  | Scopelang.From_desugared.Node (children, base_rules) ->
      base_rules @ List.concat (List.map collect_rules_from_tree children)


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

(** Generate parameters from input struct and dependencies.
    ~has_input_struct controls whether (input : Scope_Input) is included.
    This should be true when there are pure inputs OR context variables
    (since context vars are Option T fields in the _Input struct). *)
let format_method_params
    ?(has_input_struct : bool = false)
    (_inputs : input_info list)
    (scope_name : string)
    (dependencies : Ast.LocationSet.t)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string =
  let input_param = 
    if has_input_struct then [Printf.sprintf "(input : %s_Input)" scope_name]
    else []
  in
  
  (* Extract variable dependencies from locations, excluding pure input variables.
     Only OnlyInput vars are accessed via input.field in the struct.
     Reentrant (context) vars are Option T in the struct, unwrapped in scope body
     and passed as explicit params. NoInput vars are let bindings in scope body. *)
  let dep_params = Ast.LocationSet.fold (fun (loc, _pos) acc ->
    match loc with
    | DesugaredScopeVar { name; state } ->
        let scope_def_key = (name, Ast.ScopeDef.Var state) in
        (match Ast.ScopeDef.Map.find_opt scope_def_key scope_defs with
        | None -> acc  (* Variable not found, skip *)
        | Some scope_def ->
            let is_pure_input = match Mark.remove scope_def.Ast.scope_def_io.io_input with
              | Runtime.OnlyInput -> true
              | _ -> false  (* Reentrant and NoInput are explicit params *)
            in
            if is_pure_input then
              acc  (* Pure inputs are accessed via input struct *)
            else
              let type_name = format_typ scope_def.Ast.scope_def_typ in
              (* Use state-qualified name to match let-bindings in scope body *)
              let base_name = sanitize_name (ScopeVar.to_string (Mark.remove name)) in
              let var_name = match state with
                | None -> base_name
                | Some st -> Printf.sprintf "%s_%s" base_name (sanitize_name (StateName.to_string st))
              in
              Printf.sprintf "(%s : %s)" var_name type_name :: acc)
    | ToplevelVar _ -> acc  (* Skip toplevel vars for now *)
  ) dependencies [] in
  
  String.concat " " (input_param @ List.rev dep_params)

(** Convert context_var_info to input_info *)
let context_to_input (ctx : context_var_info) : input_info = {
  var_name = ctx.ctx_var_name;
  var_state = ctx.ctx_state;
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
    ?(program_ctx : Shared_ast.decl_ctx option = None)
    (scope_name : string)
    (var_name : string)
    (var_type : typ)
    (inputs : input_info list)
    (contexts : context_var_info list)
    (tree : Scopelang.From_desugared.rule_tree)
    (index : int)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string list * Ast.LocationSet.t =  (* Returns list: child methods + this method *)
 
  (* Context variables now need leaf functions generated for computing their defaults
     in the scope body. Do NOT skip them. *)

  (* Only pure inputs go in all_inputs for the (input : Scope_Input) parameter.
     Context vars are Option T in the struct, so leaf functions access their
     unwrapped values as explicit parameters instead. *)
  let all_inputs = inputs in
  let has_input_struct = inputs <> [] || contexts <> [] in
  
  match tree with
  | Scopelang.From_desugared.Leaf base_rules ->
      (* Leaf: just format the base rules as piecewise defaults *)
      let method_name = format_tree_method_name scope_name var_name tree index in
      let dependencies = rules_locations_used base_rules in
      let params = format_method_params ~has_input_struct all_inputs scope_name dependencies scope_defs in
      let return_type = Printf.sprintf "Option %s" (format_typ var_type) in
      
      (* Check if rules have function parameters (from "depends on").
         If so, we need to add those params to the leaf function signature
         and use skip_lambda_wrap, wrapping the entire body in a lambda.
         This ensures function params (like x) are in scope for guard conditions. *)
      let has_rule_params = match base_rules with
        | [] -> false
        | rule :: _ ->
            (match rule.Ast.rule_parameter with Some _ -> true | None -> false)
      in
      
      let body, func_params_str = 
        if has_rule_params then
          (* Function-type variable: extract param names, use skip_lambda_wrap *)
          let func_params = match base_rules with
            | rule :: _ ->
                (match rule.Ast.rule_parameter with
                | Some (params, _pos) ->
                    List.map (fun ((var, _var_pos), param_ty) ->
                      Printf.sprintf "(%s : %s)" (sanitize_name (Bindlib.name_of var)) (format_typ param_ty)
                    ) params
                | None -> [])
            | [] -> []
          in
          let inner_body = match base_rules with
            | [] -> "none"
            | [single_rule] -> format_rule_body ~scope_defs:(Some scope_defs) ~skip_lambda_wrap:true ~program_ctx single_rule
            | multiple_rules ->
                let rule_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs) ~skip_lambda_wrap:true ~program_ctx) multiple_rules in
                Printf.sprintf "processExceptions [%s]" (String.concat ", " rule_bodies)
          in
          (* Wrap the inner body in some(fun params => match ... with | some r => r | _ => default) *)
          let params_str = String.concat " " func_params in
          let wrapped = Printf.sprintf "some (fun %s => match %s with | some r => r | _ => default)" params_str inner_body in
          (wrapped, " " ^ params_str)
        else
          let body = match base_rules with
            | [] -> "none"
            | [single_rule] -> format_rule_body ~scope_defs:(Some scope_defs) ~program_ctx single_rule
            | multiple_rules ->
                let rule_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs) ~program_ctx) multiple_rules in
                Printf.sprintf "processExceptions [%s]" (String.concat ", " rule_bodies)
          in
          (body, "")
      in
      let _ = func_params_str in  (* params are embedded in the lambda, not in the def signature *)
      
      let method_def = Printf.sprintf "def %s %s : %s :=\n  %s\n" 
        method_name params return_type body in
      [method_def], dependencies
      
  | Scopelang.From_desugared.Node (exception_trees, base_rules) ->
      (* Node: generate methods for exceptions, then this node's method *)
      
      (* Recursively generate exception methods *)
      let exception_methods = List.mapi (fun i exc_tree ->
        let methods, _dependencies = format_rule_tree_method scope_name var_name var_type inputs contexts exc_tree (index * 10 + i) scope_defs ~program_ctx in
        methods, _dependencies
      ) exception_trees in
      let all_exception_methods = List.concat (List.map fst exception_methods) in
      (* Include dependencies from BOTH exception trees AND base rules.
         Base rules may reference variables not in exception trees. *)
      let base_dependencies = rules_locations_used base_rules in
      let all_dependencies = List.fold_left (
        fun acc (_, dependencies) -> Ast.LocationSet.union acc dependencies
        ) base_dependencies exception_methods in
      
      (* Generate this node's method *)
      let method_name = format_tree_method_name scope_name var_name tree index in
      let params = format_method_params ~has_input_struct all_inputs scope_name all_dependencies scope_defs in
      let return_type = Printf.sprintf "Option %s" (format_typ var_type) in
      
      (* Check if base rules have function parameters (from "depends on") *)
      let has_rule_params = match base_rules with
        | [] -> false
        | rule :: _ ->
            (match rule.Ast.rule_parameter with Some _ -> true | None -> false)
      in
      
      (* Build local default from base rules *)
      let local_default = match base_rules with
        | [] -> "none"
        | [single_rule] ->
            let just_expr = Expr.unbox single_rule.Ast.rule_just in
            let cons_expr = Expr.unbox single_rule.Ast.rule_cons in
            if has_rule_params then
              (* Function-type: wrap the cons expression in a lambda *)
              let func_params = (match single_rule.Ast.rule_parameter with
                | Some (params, _pos) ->
                    List.map (fun ((var, _var_pos), param_ty) ->
                      Printf.sprintf "(%s : %s)" (sanitize_name (Bindlib.name_of var)) (format_typ param_ty)
                    ) params
                | None -> []) in
              let params_str = String.concat " " func_params in
              let cons_str = format_expr ~scope_defs:(Some scope_defs) cons_expr in
              (match Mark.remove just_expr with
               | ELit (LBool true) -> Printf.sprintf "some (fun %s => %s)" params_str cons_str
               | _ -> Printf.sprintf "if %s then some (fun %s => %s) else none"
                        (format_expr ~scope_defs:(Some scope_defs) just_expr) params_str cons_str)
            else
              (match Mark.remove just_expr with
               | ELit (LBool true) -> Printf.sprintf "some (%s)" (format_expr ~scope_defs:(Some scope_defs) cons_expr)
               | _ -> Printf.sprintf "if %s then some (%s) else none"
                        (format_expr ~scope_defs:(Some scope_defs) just_expr) (format_expr ~scope_defs:(Some scope_defs) cons_expr))
        | multiple_rules ->
            (* Multiple piecewise rules - process them first *)
            if has_rule_params then
              let rule_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs) ~skip_lambda_wrap:true ~program_ctx) multiple_rules in
              let func_params = match multiple_rules with
                | rule :: _ ->
                    (match rule.Ast.rule_parameter with
                    | Some (params, _pos) ->
                        List.map (fun ((var, _var_pos), param_ty) ->
                          Printf.sprintf "(%s : %s)" (sanitize_name (Bindlib.name_of var)) (format_typ param_ty)
                        ) params
                    | None -> [])
                | [] -> []
              in
              let params_str = String.concat " " func_params in
              Printf.sprintf "some (fun %s => match (processExceptions [%s]) with | some r => r | _ => default)"
                params_str (String.concat ", " rule_bodies)
            else
              let rule_bodies = List.map (format_rule_body ~scope_defs:(Some scope_defs) ~program_ctx) multiple_rules in
              Printf.sprintf "(processExceptions [%s])"
                (String.concat ", " rule_bodies)
      in
      
      (* Call exception methods - need to pass all their dependencies *)
      let exception_calls = List.mapi (fun i (_exc_methods, exc_deps) ->
        let exc_method_name = format_tree_method_name scope_name var_name (List.nth exception_trees i) (index * 10 + i) in
        let exc_params = format_method_params ~has_input_struct all_inputs scope_name exc_deps scope_defs in
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
          local_default
        else
          Printf.sprintf 
            "(match processExceptions [%s] with    | none => %s    | some r => some r)"
            (String.concat ", " exception_calls)
            local_default
      in
      
      let method_def = Printf.sprintf "def %s %s : %s :=\n  %s\n"
        method_name params return_type body in
      
      (* Return all exception methods plus this method *)
      all_exception_methods @ [method_def], all_dependencies

(** Generate all methods for a variable's rule trees *)
let format_var_methods
    ?(program_ctx : Shared_ast.decl_ctx option = None)
    (scope_name : string)
    (var_def : var_def_info)
    (inputs : input_info list)
    (contexts : context_var_info list)
    (scope_defs : Ast.scope_def Ast.ScopeDef.Map.t)
    : string list =
  (* Use state-qualified name for method naming to avoid collisions between states *)
  let var_name_str = 
    let base = sanitize_name (ScopeVar.to_string var_def.var_name) in
    match var_def.var_state with
    | None -> base
    | Some state_name -> Printf.sprintf "%s_%s" base (sanitize_name (StateName.to_string state_name))
  in
  
  (* For input-output variables with no rule trees, generate a simple passthrough method *)
  if var_def.is_input_output && var_def.rule_trees = [] then
    let method_name = Printf.sprintf "%s_%s" scope_name var_name_str in
    let return_type = Printf.sprintf "Option %s" (format_typ var_def.var_type) in
    let has_inputs = inputs <> [] || contexts <> [] in
    let input_param = if has_inputs then Printf.sprintf "(input : %s_Input)" scope_name else "" in
    (* Context variables are Option T in the struct, so input.field is already Option T.
       Pure input variables are T, so we need to wrap in some. *)
    let is_context_io = List.exists (fun ctx -> 
      ScopeVar.equal ctx.ctx_var_name var_def.var_name &&
      ctx.ctx_state = var_def.var_state
    ) contexts in
    let body = 
      if is_context_io then 
        Printf.sprintf "input.%s" var_name_str  (* Already Option T *)
      else
        Printf.sprintf "some input.%s" var_name_str  (* T -> Option T *)
    in
    [Printf.sprintf "def %s %s : %s :=\n  %s\n" method_name input_param return_type body]
  else
    (* Normal case: generate methods from rule trees *)
    List.concat (List.mapi (fun i tree ->
      let methods, _deps = format_rule_tree_method scope_name var_name_str var_def.var_type inputs contexts tree i scope_defs ~program_ctx in
      methods
    ) var_def.rule_trees)

(** Format a rule tree as an Option expression (inline, for use in input struct defaults).
    This follows the same logic as format_rule_tree_method but generates inline expressions
    instead of method definitions.
    - Leaf nodes: return Option from base rules
    - Node nodes: recursively process exception trees, combine with processExceptions
    @param skip_lambda_wrap If true, don't wrap individual rules in lambdas
                            (for function variables where top-level lambda is added after) *)
let rec format_rule_tree_inline
    ?(scope_defs : Ast.scope_def Ast.ScopeDef.Map.t option = None)
    ?(skip_lambda_wrap : bool = false)
    ?(program_ctx : Shared_ast.decl_ctx option = None)
    (tree : Scopelang.From_desugared.rule_tree)
    : string =
  match tree with
  | Scopelang.From_desugared.Leaf base_rules ->
      (* Leaf: format base rules as Option *)
      (match base_rules with
      | [] -> "none"
      | [single_rule] -> format_rule_body ~scope_defs ~use_input_prefix:false ~skip_lambda_wrap ~program_ctx single_rule
      | multiple_rules ->
          let rule_bodies = List.map (format_rule_body ~scope_defs ~use_input_prefix:false ~skip_lambda_wrap ~program_ctx) multiple_rules in
          Printf.sprintf "processExceptions [%s]" (String.concat ", " rule_bodies))
  | Scopelang.From_desugared.Node (exception_trees, base_rules) ->
      (* Node: process exceptions first, then fall back to base rules *)
      (* Build local_default as Option value *)
      let local_default = match base_rules with
        | [] -> "none"
        | [single_rule] ->
            let just_expr = Expr.unbox single_rule.Ast.rule_just in
            let cons_expr = Expr.unbox single_rule.Ast.rule_cons in
            (match Mark.remove just_expr with
            | ELit (LBool true) -> Printf.sprintf "some (%s)" (format_expr ~scope_defs ~use_input_prefix:false ~program_ctx cons_expr)
            | _ -> Printf.sprintf "if %s then some (%s) else none"
                     (format_expr ~scope_defs ~use_input_prefix:false ~program_ctx just_expr) 
                     (format_expr ~scope_defs ~use_input_prefix:false ~program_ctx cons_expr))
        | multiple_rules ->
            let rule_bodies = List.map (format_rule_body ~scope_defs ~use_input_prefix:false ~skip_lambda_wrap ~program_ctx) multiple_rules in
            Printf.sprintf "(processExceptions [%s])"
              (String.concat ", " rule_bodies)
      in
      (* Recursively format exception trees as Option expressions *)
      let exception_calls = List.map (format_rule_tree_inline ~scope_defs ~skip_lambda_wrap ~program_ctx) exception_trees in
      if exception_calls = [] then
        local_default
      else
        (* Exceptions take priority: try exceptions first, then fall back to local default *)
        Printf.sprintf "(match processExceptions [%s] with | none => %s | some r => some r)"
          (String.concat ", " exception_calls) local_default

(** Generate input struct for a scope *)
let format_input_struct 
    ?(all_scopes : Ast.scope ScopeName.Map.t = ScopeName.Map.empty)
    ?(program_ctx : Shared_ast.decl_ctx option = None)
    (scope_name : string) 
    (inputs : input_info list) 
    (contexts: context_var_info list)
    (scope_decl : Ast.scope)
    : string =
    (* First, all the subscope fields are created pointing to the input structure of the subscopes. Then, all the fields are arranged in 
    topological order of dependencies using existing dependency checks and initialized appropriately. *)
  let sub_scopes = scope_decl.Ast.scope_sub_scopes in
  let scope_defs = scope_decl.Ast.scope_defs in
  (* Get exception graphs for all variables in this scope *)
  let exc_graphs = Scopelang.From_desugared.scope_to_exception_graphs scope_decl in
    (* Format regular input fields first (they have no dependencies) *)
  let formatted_input_fields = List.map (fun (input : input_info) ->
    let base_name = sanitize_name (ScopeVar.to_string input.var_name) in
    (* Apply state suffix if present (same logic as format_location) *)
    let var_name = match input.var_state with
      | None -> base_name
      | Some state_name -> Printf.sprintf "%s_%s" base_name (sanitize_name (StateName.to_string state_name))
    in
    Printf.sprintf "  %s : %s" var_name (format_typ input.var_type)
    ) inputs in
    
    (* Use build_scope_dependencies and correct_computation_ordering for dependency order *)
    let scope_deps = build_scope_dependencies scope_decl in
    let ordered_vertices = correct_computation_ordering scope_deps in
    
    (* Build a map from (var_name, state) to context_var_info for quick lookup *)
    (* Key is a string combining var name and optional state *)
    let make_context_key var state =
      let base = ScopeVar.to_string var in
      match state with
      | None -> base
      | Some s -> Printf.sprintf "%s_%s" base (StateName.to_string s)
    in
    let context_var_map = List.fold_left (fun acc ctx ->
      let key = make_context_key ctx.ctx_var_name ctx.ctx_state in
      String.Map.add key ctx acc
    ) String.Map.empty contexts in
    
    (* Helper to get the state-qualified field name for a subscope input variable.
       When the subscope variable has states, the _Input struct field uses the first
       state's name (e.g., foo_bar for foo with states bar/baz/fizz). *)
    let subscope_input_field_name sub_scope_name var_within_origin_scope =
      let base_name = sanitize_name (ScopeVar.to_string var_within_origin_scope) in
      match ScopeName.Map.find_opt sub_scope_name all_scopes with
      | Some sub_scope_decl ->
          (match ScopeVar.Map.find_opt var_within_origin_scope sub_scope_decl.Ast.scope_vars with
          | Some (Ast.States (first_state :: _)) ->
              Printf.sprintf "%s_%s" base_name (sanitize_name (StateName.to_string first_state))
          | _ -> base_name)
      | None -> base_name
    in
    
    (* Helper to format a subscope field *)
    let format_subscope_field var sub_scope_name =
      let var_name = sanitize_name (ScopeVar.to_string var) in
      let sub_scope_name_str = sanitize_name (ScopeName.to_string sub_scope_name) in
      let func_name = sanitize_name (uncapitalize_qualified_name sub_scope_name_str) in
      
      (* Collect sub-scope input arguments from SubScopeInput definitions (same as get_method_call) *)
      let sub_scope_inputs, has_any_inputs = Ast.ScopeDef.Map.fold (fun def_key scope_def (inp_acc, has_inputs) ->
        match def_key with
        | (v, _), Ast.ScopeDef.SubScopeInput { name; var_within_origin_scope } ->
            if ScopeVar.equal var v && ScopeName.equal name sub_scope_name then
              (* Check if this is actually an input (not an output) *)
              match Mark.remove scope_def.Ast.scope_def_io.io_input with
              | Runtime.NoInput -> (inp_acc, has_inputs)  (* Skip outputs *)
              | Runtime.Reentrant ->
                  (* Context input to sub-scope: wrap value in some (field is Option T) *)
                  let input_var_name = subscope_input_field_name sub_scope_name var_within_origin_scope in
                  if RuleName.Map.is_empty scope_def.Ast.scope_def_rules then
                    (inp_acc, true)
                  else
                    let rule = snd (RuleName.Map.choose scope_def.Ast.scope_def_rules) in
                    let input_value = format_rule_consequence ~scope_defs:(Some scope_defs) ~use_input_prefix:false ~program_ctx rule in
                    (Printf.sprintf "%s := some (%s)" input_var_name input_value :: inp_acc, true)
              | _ ->
                  (* Pure input to sub-scope: pass value directly *)
                  let input_var_name = subscope_input_field_name sub_scope_name var_within_origin_scope in
                  if RuleName.Map.is_empty scope_def.Ast.scope_def_rules then
                    (inp_acc, true)
                  else
                    let rule = snd (RuleName.Map.choose scope_def.Ast.scope_def_rules) in
                    let input_value = format_rule_consequence ~scope_defs:(Some scope_defs) ~use_input_prefix:false ~program_ctx rule in
                    (Printf.sprintf "%s := %s" input_var_name input_value :: inp_acc, true)
            else (inp_acc, has_inputs)
        | _ -> (inp_acc, has_inputs)
      ) scope_defs ([], false) in
      
      (* Format the field with initialization *)
        Printf.sprintf "  %s : %s := %s { %s }" var_name sub_scope_name_str func_name (String.concat ", " (List.rev sub_scope_inputs))
     
    in
    
    (* Helper to format a context variable field as Option T := none.
       Context variable defaults are computed in the scope body, not in the struct.
       This avoids dependency issues where defaults reference internal/output variables. *)
    let format_context_field (ctx : context_var_info) =
      let base_name = sanitize_name (ScopeVar.to_string ctx.ctx_var_name) in
      let var_name = match ctx.ctx_state with
        | None -> base_name
        | Some state_name -> Printf.sprintf "%s_%s" base_name (sanitize_name (StateName.to_string state_name))
      in
      let var_type = format_typ ctx.ctx_var_type in
      Printf.sprintf "  %s : Option %s := none" var_name var_type
    in
    
    (* Process all vertices in dependency order - only context variables go in the struct.
       Subscopes are NOT included in the _Input struct because:
       1. Callers never provide subscope results as inputs
       2. They're computed in the scope body (via all_bindings)
       3. Including them causes function name shadowing issues *)
    let formatted_dependent_fields = List.filter_map (fun vertex ->
      match vertex with
      | Vertex.Var (var, state) ->
          (* Skip subscope variables -- they're computed in the scope body *)
          if ScopeVar.Map.mem var sub_scopes then None
          else
            (* Check if this is a context variable (use both var and state for lookup) *)
            let key = make_context_key var state in
            (match String.Map.find_opt key context_var_map with
            | Some ctx -> Some (format_context_field ctx)
            | None -> None)
      | Vertex.Assertion _ -> None  (* Ignore assertions *)
    ) ordered_vertices in
    
    Printf.sprintf "structure %s_Input where\n%s\n"
      scope_name
      (String.concat "\n" (formatted_input_fields @ formatted_dependent_fields))

(** Check if a type contains function types (TArrow) recursively *)
let rec contains_function_type (ty : typ) : bool =
  match Mark.remove ty with
  | TArrow _ -> true
  | TTuple tys -> List.exists contains_function_type tys
  | TOption t | TArray t | TDefault t -> contains_function_type t
  | TStruct _ | TEnum _ | TAbstract _ -> false  (* Can't recurse into named types without context *)
  | TForAll binder ->
      let _, body_ty = Bindlib.unmbind binder in
      contains_function_type body_ty
  | _ -> false

(** Check if any field in a struct contains function types *)
let struct_has_function_fields (fields : typ StructField.Map.t) : bool =
  StructField.Map.exists (fun _ ty -> contains_function_type ty) fields

(** Check if any constructor in an enum contains function types *)
let enum_has_function_fields (constructors : typ EnumConstructor.Map.t) : bool =
  EnumConstructor.Map.exists (fun _ ty -> contains_function_type ty) constructors

(** Check if a type lacks DecidableEq — i.e., it contains function types
    or references structs/enums that contain function types.
    @param ctx_structs Optional map of struct definitions for deep checking *)
let rec type_lacks_decidable_eq 
    ?(ctx_structs : typ StructField.Map.t StructName.Map.t option = None)
    (ty : typ) : bool =
  match Mark.remove ty with
  | TArrow _ -> true
  | TStruct struct_name ->
      (* Look up the struct's fields to check if it would derive DecidableEq *)
      (match ctx_structs with
       | Some structs ->
           (match StructName.Map.find_opt struct_name structs with
            | Some fields -> StructField.Map.exists (fun _ fty -> type_lacks_decidable_eq ~ctx_structs fty) fields
            | None -> true)  (* Unknown struct: assume no DecidableEq *)
       | None -> true)  (* No context: assume no DecidableEq *)
  | TTuple tys -> List.exists (type_lacks_decidable_eq ~ctx_structs) tys
  | TOption t | TArray t | TDefault t -> type_lacks_decidable_eq ~ctx_structs t
  | TEnum _ | TAbstract _ -> false  (* Enums may or may not; assume ok for now *)
  | TForAll binder ->
      let _, body_ty = Bindlib.unmbind binder in
      type_lacks_decidable_eq ~ctx_structs body_ty
  | _ -> false

(** Check if an enum should skip DecidableEq derivation *)
let enum_lacks_decidable_eq ?(ctx_structs : typ StructField.Map.t StructName.Map.t option = None)
    (constructors : typ EnumConstructor.Map.t) : bool =
  EnumConstructor.Map.exists (fun _ ty -> type_lacks_decidable_eq ~ctx_structs ty) constructors

(** Check if a struct's fields lack DecidableEq support *)
let struct_lacks_decidable_eq ?(ctx_structs : typ StructField.Map.t StructName.Map.t option = None)
    (fields : typ StructField.Map.t) : bool =
  StructField.Map.exists (fun _ ty -> type_lacks_decidable_eq ~ctx_structs ty) fields

(** Format a struct declaration to Lean code *)
let format_struct_decl ?(ctx_structs : typ StructField.Map.t StructName.Map.t option = None) (name : string) (fields : typ StructField.Map.t) : string =
  let field_list = StructField.Map.bindings fields in
  let formatted_fields = List.map (fun (field, ty) ->
    Printf.sprintf "  %s : %s"
      (sanitize_name (StructField.to_string field))
      (format_typ ty)
  ) field_list in
  (* Derive DecidableEq for structs whose fields all support it.
     Structs with function-type fields only derive Inhabited. *)
  let deriving =
    if struct_lacks_decidable_eq ~ctx_structs fields then "deriving Inhabited"
    else "deriving Inhabited, DecidableEq"
  in
  Printf.sprintf "structure %s where\n%s\n%s"
    name
    (String.concat "\n" formatted_fields)
    deriving

(* Format a enum declaration to lean code *)
(* TODO: Remove redundant unit declarations *)
let format_enum_decl ?(ctx_structs : typ StructField.Map.t StructName.Map.t option = None) (name: string) (fields: typ EnumConstructor.Map.t) : string = 
  let constructor_list = EnumConstructor.Map.bindings fields in 
  let num_forall_ty = List.fold_left (fun acc (field, ty) ->
    match Mark.remove ty with 
    | TForAll _ -> acc + 1
    | _ -> acc
    ) 0 constructor_list
    in 
    (* Derive DecidableEq for enums whose constructor arguments all support it.
       Skip if any constructor carries a function type or a struct type (structs
       only derive Inhabited, so DecidableEq derivation would fail transitively). *)
    let lacks_eq = enum_lacks_decidable_eq ~ctx_structs fields in
    let deriving = if lacks_eq then "deriving Inhabited"
                   else "deriving Inhabited, DecidableEq" in
    if num_forall_ty = 0 then 
      (let formatted_fields =  (List.map (fun (field, ty) ->
      Printf.sprintf " | %s : %s -> %s"
      (sanitize_name (EnumConstructor.to_string field))
      (format_typ ty)
      name 
      ) constructor_list )
      in
      Printf.sprintf "inductive %s : Type where\n%s\n%s"
        name
        (String.concat "\n" formatted_fields)
        deriving)
    else 
      (let formatted_fields = (List.map (fun (field, ty) ->
      Printf.sprintf " | %s : %s -> %s TForall"
      (sanitize_name (EnumConstructor.to_string field))
      (format_typ ty)
      name 
      ) constructor_list)
      in 
      Printf.sprintf "inductive %s (TForall:Type) : Type where\n%s\n%s"
        name
        (String.concat "\n" formatted_fields)
        deriving)

let format_toplevel
    ?(program_ctx = None)
    toplevel_name
    toplevel_decl =
  let _ = program_ctx in
  let toplevel_name_str = sanitize_name (TopdefName.to_string toplevel_name) in
  
  (* Check if the body is a polymorphic lambda (EAbs with type variables) *)
  match toplevel_decl.Ast.topdef_expr with
  | Some expr ->
      (match Mark.remove expr with
      | EAbs { binder; tys; _ } ->
          (* Lambda abstraction - extract parameters *)
          let vars, body = Bindlib.unmbind binder in
          let params = Array.to_list vars in
          
          (* Collect unique type variables from parameter types *)
          let type_vars = collect_type_vars_from_list tys in
          
          if type_vars = [] then
            (* No type variables - simple lambda, keep as is *)
            let type_str = format_typ toplevel_decl.Ast.topdef_type in
            let body_str = format_expr ~program_ctx expr in
            Printf.sprintf "def %s : %s := %s" toplevel_name_str type_str body_str
          else
            (* Has type variables - generate def with implicit type parameters *)
            let type_param_strs = List.concat_map (fun tv -> [Printf.sprintf "{%s : Type}" tv; Printf.sprintf "[Inhabited %s]" tv]) type_vars in
            let param_strs = List.map2 (fun var ty ->
              match Mark.remove ty with
              | TLit TUnit -> "()"
              | _ ->
                  Printf.sprintf "(%s : %s)" 
                    (sanitize_name (Bindlib.name_of var))
                    (format_typ ty)
            ) params tys in
            let all_params = type_param_strs @ param_strs in
            let body_str = format_expr ~program_ctx body in
            (* Extract return type from the toplevel type.
               For polymorphic functions with TForAll, unwrap to get the arrow type's return type.
               Then substitute type variable names to match those from EAbs.tys. *)
            let return_type_str = 
              match Mark.remove toplevel_decl.Ast.topdef_type with
              | TForAll binder ->
                  let _, inner = Bindlib.unmbind binder in
                  (match Mark.remove inner with
                   | TArrow (toplevel_param_tys, ret) ->
                       (* Build mapping from toplevel type vars to EAbs type vars *)
                       let var_mapping = build_type_var_mapping 
                         (Mark.add (Mark.get toplevel_decl.Ast.topdef_type) (TArrow (toplevel_param_tys, ret)))
                         tys in
                       let ret_str = format_typ ret in
                       substitute_type_vars ret_str var_mapping
                   | other_ty -> format_typ (Mark.add (Mark.get toplevel_decl.Ast.topdef_type) other_ty))
              | TArrow (toplevel_param_tys, ret) ->
                  let var_mapping = build_type_var_mapping 
                    (Mark.add (Mark.get toplevel_decl.Ast.topdef_type) (TArrow (toplevel_param_tys, ret)))
                    tys in
                  let ret_str = format_typ ret in
                  substitute_type_vars ret_str var_mapping
              | _ -> format_typ toplevel_decl.Ast.topdef_type
            in
            Printf.sprintf "def %s %s : %s := %s" 
              toplevel_name_str 
              (String.concat " " all_params)
              return_type_str
              body_str
      | _ ->
          (* Not a lambda - format as expression *)
          let type_str = format_typ toplevel_decl.Ast.topdef_type in
          let body_str = format_expr ~program_ctx expr in
          Printf.sprintf "def %s : %s := %s" toplevel_name_str type_str body_str)
  | None ->
      (* No expression - external or undefined *)
      let type_str = format_typ toplevel_decl.Ast.topdef_type in
      Printf.sprintf "def %s : %s := default /- external or undefined -/" toplevel_name_str type_str

 

(** Generate Lean code for a scope using method-per-rule architecture *)
let format_scope 
    ?(program_ctx : Shared_ast.decl_ctx option = None)
    ?(all_scopes : Ast.scope ScopeName.Map.t = ScopeName.Map.empty)
    (scope_name : ScopeName.t) 
    (scope_decl : Ast.scope) 
    : string =
  let scope_name_str = sanitize_name (ScopeName.to_string scope_name) in
  
  (* 1. Collect variable information in dependency order *)
  let var_defs, inputs, context_vars = collect_var_info_ordered ~program_ctx scope_decl in
  
  (* 2. Generate input struct (if any inputs) *)
  let input_struct = format_input_struct ~all_scopes ~program_ctx scope_name_str inputs context_vars scope_decl in
  (* 3. Generate all methods for all variables *)
  let all_methods = List.concat (List.map (fun var_def ->
    format_var_methods scope_name_str var_def inputs context_vars scope_decl.Ast.scope_defs ~program_ctx
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
  let scope_func_name = sanitize_name (uncapitalize_qualified_name scope_name_str) in
  let has_input = inputs <> [] in
  let has_context = context_vars <> [] in
  let input_param = Printf.sprintf "(input : %s_Input)" scope_name_str in
  
  (* Helper to check if a specific (variable, state) pair is a context variable *)
  let is_context_var_specific var_name var_state =
    List.exists (fun ctx -> 
      ScopeVar.equal ctx.ctx_var_name var_name &&
      Option.equal StateName.equal ctx.ctx_state var_state
    ) context_vars 
  in
  
  (* Helper to check if ANY state of a variable is a context variable.
     Used for dependency filtering: if any state of a dep var is in the input struct,
     all its states are accessed via input struct, so we skip it from dep_params. *)
  let is_context_var_any_state var_name =
    List.exists (fun ctx -> ScopeVar.equal ctx.ctx_var_name var_name) context_vars 
  in
  
  (* Helper to compute state-qualified variable name *)
  let state_qualified_name var_name var_state =
    let base = sanitize_name (ScopeVar.to_string var_name) in
    match var_state with
    | None -> base
    | Some state_name -> Printf.sprintf "%s_%s" base (sanitize_name (StateName.to_string state_name))
  in
  
  (* Helper to get state-qualified subscope input field name *)
  let subscope_input_field_name sub_scope_name var_within_origin_scope =
    let base_name = sanitize_name (ScopeVar.to_string var_within_origin_scope) in
    match ScopeName.Map.find_opt sub_scope_name all_scopes with
    | Some sub_scope_decl ->
        (match ScopeVar.Map.find_opt var_within_origin_scope sub_scope_decl.Ast.scope_vars with
        | Some (Ast.States (first_state :: _)) ->
            Printf.sprintf "%s_%s" base_name (sanitize_name (StateName.to_string first_state))
        | _ -> base_name)
    | None -> base_name
  in
  
  (* Helper to get method call for a variable *)
  let get_method_call var_def =
    if var_def.is_sub_scope then
      (* Sub-scope variable: call the sub-scope function *)
      (match var_def.sub_scope_name with
      | Some sub_scope_name ->
          let sub_scope_name_str = sanitize_name (ScopeName.to_string sub_scope_name) in
          let func_name = sanitize_name (uncapitalize_qualified_name sub_scope_name_str) in
          
          (* Collect sub-scope input arguments from SubScopeInput definitions *)
          (* Track if we have any inputs defined (even with no rules) vs no inputs at all *)
          let sub_scope_inputs, has_any_inputs = Ast.ScopeDef.Map.fold (fun def_key scope_def (acc, has_inputs) ->
            match def_key with
            | (v, _), Ast.ScopeDef.SubScopeInput { name; var_within_origin_scope } ->
                if ScopeVar.equal var_def.var_name v && ScopeName.equal name sub_scope_name then
                  (* Check if this is actually an input (not an output) *)
                  match Mark.remove scope_def.Ast.scope_def_io.io_input with
                  | Runtime.NoInput -> (acc, has_inputs)  (* Skip outputs *)
                  | Runtime.Reentrant ->
                      (* Context input to sub-scope: wrap value in some (field is Option T) *)
                      let input_var_name = subscope_input_field_name sub_scope_name var_within_origin_scope in
                      if RuleName.Map.is_empty scope_def.Ast.scope_def_rules then
                        (acc, true)
                      else
                        let rule = snd (RuleName.Map.choose scope_def.Ast.scope_def_rules) in
                        let input_value = format_rule_consequence ~scope_defs:(Some scope_decl.Ast.scope_defs) ~use_input_prefix:true ~in_scope_body_context:true ~program_ctx rule in
                        (Printf.sprintf "%s := some (%s)" input_var_name input_value :: acc, true)
                  | _ ->
                      (* Pure input to sub-scope: pass value directly *)
                      let input_var_name = subscope_input_field_name sub_scope_name var_within_origin_scope in
                      if RuleName.Map.is_empty scope_def.Ast.scope_def_rules then
                        (acc, true)
                      else
                        let rule = snd (RuleName.Map.choose scope_def.Ast.scope_def_rules) in
                        let input_value = format_rule_consequence ~scope_defs:(Some scope_decl.Ast.scope_defs) ~use_input_prefix:true ~in_scope_body_context:true ~program_ctx rule in
                        (Printf.sprintf "%s := %s" input_var_name input_value :: acc, true)
                else (acc, has_inputs)
            | _ -> (acc, has_inputs)
          ) scope_decl.Ast.scope_defs ([], false) in
          
          Printf.sprintf "%s { %s }" func_name (String.concat ", " (List.rev sub_scope_inputs))
      | None -> "default -- sub-scope name missing")
    else
      (* Regular variable: call the method *)
      (* Use state-qualified name for method naming to avoid collisions between states *)
      let qualified_var_name = state_qualified_name var_def.var_name var_def.var_state in
      
      (* Helper to compute non-pure-input dependency parameter names from a set of locations.
         Add _ prefix to match let-binding names in scope body. *)
      let dep_param_names_from_locs loc_deps =
        Ast.LocationSet.fold (fun (loc, _pos) acc ->
          match loc with
          | DesugaredScopeVar { name; state } ->
              let scope_def_key = (name, Ast.ScopeDef.Var state) in
              (match Ast.ScopeDef.Map.find_opt scope_def_key scope_decl.Ast.scope_defs with
              | None -> acc
              | Some scope_def ->
                  let is_pure_input = match Mark.remove scope_def.Ast.scope_def_io.io_input with
                    | Runtime.OnlyInput -> true
                    | _ -> false
                  in
                  if is_pure_input then acc
                  else
                    let base_name = sanitize_name (ScopeVar.to_string (Mark.remove name)) in
                    let var_name = match state with
                      | None -> base_name
                      | Some st -> Printf.sprintf "%s_%s" base_name (sanitize_name (StateName.to_string st))
                    in
                    ("_" ^ var_name) :: acc)
          | ToplevelVar _ -> acc
        ) loc_deps []
      in
      
      let input_prefix = if (has_input||has_context) then ["input"] else [] in
      
      (* Generate a call string for a single tree with its specific dependencies *)
      let call_for_tree tree index =
        let tree_rules = collect_rules_from_tree tree in
        let tree_deps = rules_locations_used tree_rules in
        let dep_names = dep_param_names_from_locs tree_deps in
        let method_name = format_tree_method_name scope_name_str qualified_var_name tree index in
        let all_params = input_prefix @ List.rev dep_names in
        Printf.sprintf "%s %s" method_name (String.concat " " all_params)
      in
      
      match var_def.rule_trees with
      | [] ->
          (* No rule trees - input-output passthrough or undefined *)
          let method_name =
            if var_def.is_input_output then
              Printf.sprintf "%s_%s" scope_name_str qualified_var_name
            else
              qualified_var_name ^ "_undefined"
          in
          let all_params = input_prefix in
          Printf.sprintf "%s %s" method_name (String.concat " " all_params)
      | [single_tree] ->
          (* Single tree: just call it with its deps *)
          call_for_tree single_tree 0
      | multiple_trees ->
          (* Multiple trees: combine via processExceptions *)
          let calls = List.mapi (fun i tree -> call_for_tree tree i) multiple_trees in
          Printf.sprintf "processExceptions [%s]" (String.concat ", " calls)
  in
  
  (* Build let bindings for ALL variables in dependency order, excluding context variables.
     Add _ prefix to binding names to avoid shadowing scope function names. *)
  let all_bindings = List.filter_map (fun var_def ->
    let binding_name = "_" ^ (state_qualified_name var_def.var_name var_def.var_state) in
    let base_name = state_qualified_name var_def.var_name var_def.var_state in
    let is_context = is_context_var_specific var_def.var_name var_def.var_state in
    if var_def.is_sub_scope then
      (* Sub-scope variables return the struct directly *)
      Some (Printf.sprintf "let %s := %s" binding_name (get_method_call var_def))
    else if is_context then
      (* Context variable: unwrap Option from input struct, or compute default via leaf function *)
      if var_def.rule_trees = [] && not var_def.is_input_output then
        (* Context variable with no rules and no default: just unwrap from input or use default *)
        Some (Printf.sprintf "let %s := match input.%s with | some v => v | none => default "
          binding_name base_name)
      else
        let call = get_method_call var_def in
        Some (Printf.sprintf "let %s := match input.%s with | some v => v | none => match %s with | some val => val | _ => default "
          binding_name base_name call)
    else
      (* Internal/output variable: compute via leaf function call *)
      Some (Printf.sprintf "let %s := match %s with | some val => val | _ => default " binding_name (get_method_call var_def))
  ) var_defs in
  (* Build output struct field assignments by referencing local let-binding variables.
     All variables (context, internal, output) are now let bindings in the scope body with _ prefix. *)
  let output_assignments = List.map (fun var_def ->
    let base_var_name = sanitize_name (ScopeVar.to_string var_def.var_name) in
    let binding_name = "_" ^ (state_qualified_name var_def.var_name var_def.var_state) in
    Printf.sprintf "%s := %s" base_var_name binding_name
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
let generate_lean_code (prgm : Ast.program) (prg_scopelang : 'm Scopelang.Ast.program) : string =
  let header = "import CatalaRuntime\n\nimport Stdlib\n\nopen CatalaRuntime" in
  
  (* Collect scope input and output struct names to avoid generating them twice *)
  (* (they're generated in format_scope) *)
  (* Since we now generate ALL scopes (local + imported/unfolded), skip all scope structs *)
  let program_dep_graph = Scopelang.Dependency.build_program_dep_graph prg_scopelang in 
  let defs_ordering = Scopelang.Dependency.get_defs_ordering program_dep_graph in 
  let scope_structs = ScopeName.Map.fold (fun _scope_name scope_info acc ->
    (* Skip all scope input/output structs - they're generated in format_scope *)
    acc
    |> StructName.Set.add scope_info.in_struct_name
    |> StructName.Set.add scope_info.out_struct_name
  ) prgm.program_ctx.ctx_scopes StructName.Set.empty in
  
  (* Get topologically sorted list of types (structs and enums together) respecting dependencies *)
  let type_ordering = Scopelang.Dependency.check_type_cycles 
    prgm.program_ctx.ctx_abstract_types
    prgm.program_ctx.ctx_structs
    prgm.program_ctx.ctx_enums in
  
  (* Types to skip - they are defined elsewhere (e.g., in stdlib) *)
  let skip_types = ["Date_en.Month"; "Period_en.Period"; "Date_en.MonthOfYear"; "Optional"; "MonthYear_en.Date_en.Month"; "MonthYear_en.MonthYear"] in
  
  (* Generate struct and enum declarations in dependency order *)
  let type_code = List.filter_map (fun type_id ->
    match type_id with
    | TypeIdent.Struct struct_name ->
        let struct_name_str = StructName.to_string struct_name in
        (* Skip scope input/output structs and types defined elsewhere *)
        if StructName.Set.mem struct_name scope_structs || List.mem struct_name_str skip_types then
          None
        else
          (match StructName.Map.find_opt struct_name prgm.program_ctx.ctx_structs with
          | Some fields ->
              Some (format_struct_decl ~ctx_structs:(Some prgm.program_ctx.ctx_structs) (sanitize_name struct_name_str) fields)
          | None -> None)
    | TypeIdent.Enum enum_name ->
        let enum_name_str = EnumName.to_string enum_name in
        (* Skip types defined elsewhere *)
        if List.mem enum_name_str skip_types then
          None
        else
          (match EnumName.Map.find_opt enum_name prgm.program_ctx.ctx_enums with
          | Some fields ->
              Some (format_enum_decl ~ctx_structs:(Some prgm.program_ctx.ctx_structs) (sanitize_name enum_name_str) fields)
          | None -> None)
    | _ -> None
  ) type_ordering in
  
  (* Helper: find a scope by name in a module's scopes *)
  let find_scope_in_module scope_name_str module_scopes =
    ScopeName.Map.fold (fun sn scope_decl acc ->
      match acc with
      | Some _ -> acc
      | None ->
          if ScopeName.to_string sn = scope_name_str then Some (sn, scope_decl)
          else None
    ) module_scopes None
  in
  
  (* Helper: find a scope by name in program_root and all program_modules (unfold imports) *)
  let find_scope_anywhere scope_name_str =
    (* First try program_root *)
    match find_scope_in_module scope_name_str prgm.program_root.module_scopes with
    | Some result -> Some result
    | None ->
        (* Then try all imported modules in program_modules *)
        ModuleName.Map.fold (fun _mod_name modul acc ->
          match acc with
          | Some _ -> acc
          | None -> find_scope_in_module scope_name_str modul.Ast.module_scopes
        ) prgm.program_modules None
  in
  
  (* Helper: find a topdef by name in a module's topdefs *)
  let find_topdef_in_module topdef_name_str module_topdefs =
    TopdefName.Map.fold (fun tn topdef_decl acc ->
      match acc with
      | Some _ -> acc
      | None ->
          if TopdefName.to_string tn = topdef_name_str then Some (tn, topdef_decl)
          else None
    ) module_topdefs None
  in
  
  (* Helper: find a topdef by name in program_root and all program_modules (unfold imports) *)
  let find_topdef_anywhere topdef_name_str =
    (* First try program_root *)
    match find_topdef_in_module topdef_name_str prgm.program_root.module_topdefs with
    | Some result -> Some result
    | None ->
        (* Then try all imported modules in program_modules *)
        ModuleName.Map.fold (fun _mod_name modul acc ->
          match acc with
          | Some _ -> acc
          | None -> find_topdef_in_module topdef_name_str modul.Ast.module_topdefs
        ) prgm.program_modules None
  in
  
  (* Stdlib module prefixes to skip (already imported via "import Stdlib") *)
  let stdlib_prefixes = [
    "Stdlib_en."; "Date_en."; "Date_internal."; "List_en."; "List_internal.";
    "Duration_en."; "MonthYear_en."; "Period_en."; "Period_internal.";
    "Money_en."; "Money_internal."; "Integer_en."; "Decimal_en."; "Decimal_internal."
  ] in
  let is_stdlib_topdef name_str = 
    List.exists (fun prefix -> String.length name_str >= String.length prefix && 
                                String.sub name_str 0 (String.length prefix) = prefix) stdlib_prefixes 
  in
  
  (* Build a map of all scope declarations for subscope variable state resolution *)
  let all_scopes =
    let root_scopes = prgm.program_root.module_scopes in
    ModuleName.Map.fold (fun _mod_name modul acc ->
      ScopeName.Map.union (fun _k _v1 v2 -> Some v2) acc modul.Ast.module_scopes
    ) prgm.program_modules root_scopes
  in
  
  (* Generate code for scopes and topdefs in dependency order, tracking generated scopes *)
  let (scope_code, toplevel_function_code, scope_func_names, generated_scope_names) = 
    List.fold_left (fun (scopes_acc, topdefs_acc, func_names_acc, generated_scopes) vertex ->
      match vertex with
      | Scopelang.Dependency.Scope (scope_name, _module_opt) -> 
          (* Find this scope in program_root or any imported module *)
          let scope_name_str = ScopeName.to_string scope_name in
          (match find_scope_anywhere scope_name_str with
          | Some (sn, scope_decl) ->
              let code = format_scope ~program_ctx:(Some prgm.program_ctx) ~all_scopes sn scope_decl in
              (* Generate the function name (lowercase version of scope name) *)
              let func_name = sanitize_name (uncapitalize_qualified_name (sanitize_name (ScopeName.to_string sn))) in
              (code :: scopes_acc, topdefs_acc, func_name :: func_names_acc, 
               ScopeName.Set.add sn generated_scopes)
          | None -> (scopes_acc, topdefs_acc, func_names_acc, generated_scopes))
      | Scopelang.Dependency.Topdef topdef_name ->
          (* Skip stdlib topdefs - they're already imported via "import Stdlib" *)
          let topdef_name_str = TopdefName.to_string topdef_name in
          if is_stdlib_topdef topdef_name_str then
            (scopes_acc, topdefs_acc, func_names_acc, generated_scopes)
          else
            (match find_topdef_anywhere topdef_name_str with
            | Some (tn, topdef_decl) ->
                let code = format_toplevel ~program_ctx:(Some prgm.program_ctx) tn topdef_decl in
                (scopes_acc, code :: topdefs_acc, func_names_acc, generated_scopes)
            | None -> (scopes_acc, topdefs_acc, func_names_acc, generated_scopes))
    ) ([], [], [], ScopeName.Set.empty) defs_ordering 
  in
  
  (* Generate ALL remaining scopes from imported modules that weren't in defs_ordering.
     This ensures subscope scopes that aren't in the direct dependency chain are still generated. *)
  let (additional_scope_code, additional_scope_func_names) = 
    ModuleName.Map.fold (fun _mod_name modul (scopes_acc, func_names_acc) ->
      ScopeName.Map.fold (fun sn scope_decl (inner_scopes_acc, inner_func_names_acc) ->
        if ScopeName.Set.mem sn generated_scope_names then
          (* Already generated via defs_ordering *)
          (inner_scopes_acc, inner_func_names_acc)
        else
          (* Generate this scope that was missing from defs_ordering *)
          let code = format_scope ~program_ctx:(Some prgm.program_ctx) ~all_scopes sn scope_decl in
          let func_name = sanitize_name (uncapitalize_qualified_name (sanitize_name (ScopeName.to_string sn))) in
          (code :: inner_scopes_acc, func_name :: inner_func_names_acc)
      ) modul.Ast.module_scopes (scopes_acc, func_names_acc)
    ) prgm.program_modules ([], [])
  in
  
  (* Combine scope code from defs_ordering and additional scopes *)
  let all_scope_code = scope_code @ additional_scope_code in
  let all_scope_func_names = scope_func_names @ additional_scope_func_names in
  
  (* Generate #eval! statements for each scope *)
  let eval_statements = List.map (fun func_name ->
    Printf.sprintf "#reduce %s {}" func_name
  ) (List.rev all_scope_func_names) in
  
  (* Combine: header, types, topdefs, then scopes *)
  let all_parts = List.filter (fun s -> s <> "") [
    header;
    String.concat "\n\n" type_code;
    String.concat "\n\n" (List.rev toplevel_function_code);
    String.concat "\n\n" (List.rev all_scope_code);
    (* String.concat "\n" eval_statements *)
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

  let prg_scopelang = 
    Driver.Passes.scopelang options ~includes ~stdlib
  in 

  Message.debug "Generating Lean4 code from desugared AST...";
  let lean_code = generate_lean_code prg prg_scopelang in
  
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
