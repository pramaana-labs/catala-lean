(* This file is part of the Catala compiler, a specification language for tax
   and social benefits computation rules. Copyright (C) 2020 Inria,
   contributors: Denis Merigoux <denis.merigoux@inria.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not
   use this file except in compliance with the License. You may obtain a copy of
   the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
   License for the specific language governing permissions and limitations under
   the License. *)

(** Plugin to generate dependency graph JSON files from Catala programs *)

open Catala_utils
open Shared_ast

(** Generate scope dependency graphs from desugared AST *)
let generate_scope_deps includes stdlib output options =
  let open Driver.Commands in
  let prg, _ = Driver.Passes.desugared options ~includes ~stdlib in
  Message.debug "Building scope dependency graphs...";
  
  (* Build dependency graph for each scope *)
  let scope_graphs_json = 
    ScopeName.Map.fold
      (fun scope_name scope acc ->
        Message.debug "Building dependency graph for scope %a" ScopeName.format scope_name;
        let dep_graph = Desugared.Dependency.build_scope_dependencies scope in
        Desugared.Dependency.check_for_cycle scope dep_graph;
        let json = Desugared.Dependency.scope_dependencies_to_json dep_graph in
        (ScopeName.to_string scope_name, json) :: acc)
      prg.Desugared.Ast.program_root.module_scopes []
  in
  
  Message.debug "Converting to JSON...";
  let json = `Assoc scope_graphs_json in
  get_output_format options ~ext:"json" output
  @@ fun _filename fmt ->
  Format.fprintf fmt "%s@." (Yojson.Safe.pretty_to_string json)

(** Generate inter-scope dependency graph JSON (scopelang level) *)
let generate_inter_scope_deps includes stdlib output options =
  let open Driver.Commands in
  let prg = Driver.Passes.scopelang options ~includes ~stdlib in
  Message.debug "Building inter-scope dependency graph...";
  let dep_graph = Scopelang.Dependency.build_program_dep_graph prg in
  Message.debug "Checking for cycles...";
  Scopelang.Dependency.check_for_cycle_in_defs dep_graph;
  Message.debug "Converting to JSON...";
  let json = Scopelang.Dependency.inter_scope_dependencies_graph_to_json dep_graph in
  get_output_format options ~ext:"json" output
  @@ fun _filename fmt ->
  Format.fprintf fmt "%s@." (Yojson.Safe.pretty_to_string json)

(** Generate type dependency graph JSON *)
let generate_at_custom_checkpoint includes stdlib output ex_scope options =
  let open Driver.Commands in
  let prg, _ = Driver.Passes.desugared options ~includes ~stdlib in
  Message.debug "Building custom checkpoint...";
  let scope_uid = get_scope_uid prg.program_ctx ex_scope in
  let scope_opt = ScopeName.Map.find_opt scope_uid prg.program_root.module_scopes in
  match scope_opt with
  | Some scope ->
    let var_list, input_list = Lean4_desugared.collect_var_info_ordered scope in
    Message.debug "Variables: %d" (List.length var_list);
    Message.debug "Inputs: %d" (List.length input_list);
    get_output_format options ~ext:"txt" output
    @@ fun _filename fmt ->
    Format.fprintf fmt "Variables:@.";
    List.iter (fun (var: Lean4_desugared.var_def_info) ->
      Format.fprintf fmt "%s@." (ScopeVar.to_string var.var_name);
      let deps = ScopeVar.Set.of_list (ScopeVar.Map.keys var.dependencies) in
      let s = ScopeVar.Set.fold (fun sv acc -> (ScopeVar.to_string sv) ^ "; " ^ acc) deps "" in
      Format.fprintf fmt "--Dependencies: %s@.\n" s;
    ) var_list;
    Format.fprintf fmt "\n\n -------------------------------------- \n\nInputs:@.";
    List.iter (fun (input: Lean4_desugared.input_info) ->
      Format.fprintf fmt "%s@." (ScopeVar.to_string input.var_name);
    ) input_list;   
  | None ->
    Message.error "Scope %s not found" (ScopeName.to_string scope_uid);

(** CLI Terms *)
open Cmdliner

(* Scope dependency graphs command (desugared level - within each scope) *)
let scope_deps_term =
  let open Term in
  const generate_scope_deps
  $ Cli.Flags.include_dirs
  $ Cli.Flags.stdlib_dir
  $ Cli.Flags.output

(* Inter-scope dependency graph command (scopelang level - between scopes) *)
let inter_scope_deps_term =
  let open Term in
  const generate_inter_scope_deps
  $ Cli.Flags.include_dirs
  $ Cli.Flags.stdlib_dir
  $ Cli.Flags.output
  
(* Type dependency graph command *)
let custom_checkpoint_term =
  let open Term in
  const generate_at_custom_checkpoint
  $ Cli.Flags.include_dirs
  $ Cli.Flags.stdlib_dir
  $ Cli.Flags.output
  $ Cli.Flags.ex_scope
  
(** Register plugin commands *)
let () =
  Driver.Plugin.register "scope-deps" scope_deps_term
    ~doc:"Generate scope dependency graphs (within each scope)";
  Driver.Plugin.register "inter-scope-deps" inter_scope_deps_term
    ~doc:"Generate inter-scope dependency graph (between scopes)";
  Driver.Plugin.register "custom-checkpoint" custom_checkpoint_term
    ~doc:"Generate type dependency graph"

