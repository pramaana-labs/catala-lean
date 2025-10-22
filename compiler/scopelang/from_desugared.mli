(* This file is part of the Catala compiler, a specification language for tax
   and social benefits computation rules. Copyright (C) 2020 Inria, contributor:
   Denis Merigoux <denis.merigoux@inria.fr>

   Licensed under the Apache License, Version 2.0 (the "License"); you may not
   use this file except in compliance with the License. You may obtain a copy of
   the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
   License for the specific language governing permissions and limitations under
   the License. *)

(** Translation from {!module: Desugared.Ast} to {!module: Scopelang.Ast} *)

val build_exceptions_graph :
  Desugared.Ast.program ->
  Desugared.Dependency.ExceptionsDependencies.t Desugared.Ast.ScopeDef.Map.t
(** This function builds all the exceptions dependency graphs for all variables
    of all scopes. *)

val translate_program :
  Desugared.Ast.program ->
  Desugared.Dependency.ExceptionsDependencies.t Desugared.Ast.ScopeDef.Map.t ->
  Shared_ast.untyped Ast.program
(** This functions returns the translated program as well as all the graphs of
    exceptions inferred for each scope variable of the program. *)

(** {1 Exports for backend code generation} *)

(** Intermediate representation for the exception tree of rules for a particular
    scope definition. *)
type rule_tree =
  | Leaf of Desugared.Ast.rule list
      (** Rules defining a base case piecewise. List is non-empty. *)
  | Node of rule_tree list * Desugared.Ast.rule list
      (** [Node (exceptions, base_case)] is a list of exceptions to a non-empty
          list of rules defining a base case piecewise. *)

val scope_to_exception_graphs :
  Desugared.Ast.scope ->
  Desugared.Dependency.ExceptionsDependencies.t Desugared.Ast.ScopeDef.Map.t
(** Builds exception dependency graphs for all variables in a single scope. *)

val def_map_to_tree :
  Desugared.Ast.rule Shared_ast.RuleName.Map.t ->
  Desugared.Dependency.ExceptionsDependencies.t ->
  rule_tree list
(** Transforms a flat list of rules into a tree, taking into account the
    priorities declared between rules. *)
