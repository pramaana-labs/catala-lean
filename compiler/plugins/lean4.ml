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

(** Minimal Lean 4 backend for Catala - basic features only *)

open Catala_utils
open Shared_ast
open Lcalc.Ast

module Runtime = Catala_runtime

let lean_keywords =
  [
    "def"; "theorem"; "axiom"; "inductive"; "structure"; "class";
    "instance"; "let"; "in"; "fun"; "match"; "if"; "then"; "else";
    "do"; "return"; "import"; "where"; "deriving";
  ]

let renaming =
  Renaming.program ()
    ~reserved:lean_keywords
    ~skip_constant_binders:false
    ~constant_binder_name:None
    ~namespaced_fields:true
    ~namespaced_constrs:true
    ~prefix_module:false
    ~modnames_conflict:false

(** Format a variable *)
let format_var (fmt : Format.formatter) (v : 'm Var.t) : unit =
  Format.pp_print_string fmt (Bindlib.name_of v)

(** Format a literal - simplified *)
let format_lit (fmt : Format.formatter) (l : lit Mark.pos) : unit =
  match Mark.remove l with
  | LBool true -> Format.pp_print_string fmt "true"
  | LBool false -> Format.pp_print_string fmt "false"
  | LInt i -> Format.fprintf fmt "(%s : Int)" (Runtime.integer_to_string i)
  | LUnit -> Format.pp_print_string fmt "()"
  | _ -> Format.pp_print_string fmt "sorry -- unsupported literal"

(** Format types - simplified *)
let rec format_typ (fmt : Format.formatter) (ty : typ) : unit =
  match Mark.remove ty with
  | TLit TUnit -> Format.pp_print_string fmt "Unit"
  | TLit TBool -> Format.pp_print_string fmt "Bool"
  | TLit TInt -> Format.pp_print_string fmt "Int"
  | TArrow (args, ret) ->
      Format.fprintf fmt "(%a)"
        (Format.pp_print_list
           ~pp_sep:(fun fmt () -> Format.fprintf fmt " → ")
           format_typ)
        (args @ [ret])
  | _ -> Format.pp_print_string fmt "Unit -- unsupported type"

(** Format expressions - simplified *)
let rec format_expr (_ctx : decl_ctx) (fmt : Format.formatter) (e : 'm expr) : unit =
  match Mark.remove e with
  | EVar v -> format_var fmt v
  | ELit l -> format_lit fmt (Mark.add (Expr.pos e) l)
  | EApp { f; args; _ } ->
      Format.fprintf fmt "(%a %a)"
        (format_expr _ctx) f
        (Format.pp_print_list
           ~pp_sep:(fun fmt () -> Format.fprintf fmt " ")
           (format_expr _ctx))
        args
  | EAbs { binder; tys; _ } ->
      let vars, body = Bindlib.unmbind binder in
      Format.fprintf fmt "(fun ";
      Array.iteri
        (fun i var ->
          if i > 0 then Format.fprintf fmt " ";
          Format.fprintf fmt "(%a : %a)"
            format_var var
            format_typ (List.nth tys i))
        vars;
      Format.fprintf fmt " => %a)" (format_expr _ctx) body
  | EIfThenElse { cond; etrue; efalse } ->
      Format.fprintf fmt "(if %a then %a else %a)"
        (format_expr _ctx) cond
        (format_expr _ctx) etrue
        (format_expr _ctx) efalse
  | ETuple es ->
      (* Tuples in Lean use simple comma syntax *)
      Format.fprintf fmt "(%a)"
        (Format.pp_print_list
           ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
           (format_expr _ctx))
        es
  | ETupleAccess { e; index; _ } ->
      (* Tuple access in Lean is .1, .2, etc (1-indexed) *)
      Format.fprintf fmt "(%a).%d" (format_expr _ctx) e (index + 1)
  | EInj { e; cons; _ } ->
      (* Map Catala option constructors to Lean's Option type *)
      let cons_name = EnumConstructor.to_string cons in
      let lean_cons = 
        if cons_name = "None_1" || cons_name = "None" then "none"
        else if cons_name = "Some_1" || cons_name = "Some" then "some"
        else cons_name  (* fallback to original name *)
      in
      Format.fprintf fmt "(Option.%s %a)" lean_cons (format_expr _ctx) e
  | EMatch { e; cases; _ } ->
      Format.fprintf fmt "(match %a with@," (format_expr _ctx) e;
      EnumConstructor.Map.iter
        (fun cons case_expr ->
          (* Match case expressions are wrapped in EAbs, unwrap them *)
          match Mark.remove case_expr with
          | EAbs { binder; _ } ->
              let xs, body = Bindlib.unmbind binder in
              (* Map Catala option constructors to Lean's Option type *)
              let cons_name = EnumConstructor.to_string cons in
              let lean_cons = 
                if cons_name = "None_1" || cons_name = "None" then "none"
                else if cons_name = "Some_1" || cons_name = "Some" then "some"
                else cons_name
              in
              (* Option.none takes no args, Option.some takes args *)
              if lean_cons = "none" then
                Format.fprintf fmt "| Option.%s => %a@,"
                  lean_cons
                  (format_expr _ctx) body
              else
                Format.fprintf fmt "| Option.%s %a => %a@,"
                  lean_cons
                  (Format.pp_print_list
                     ~pp_sep:(fun fmt () -> Format.fprintf fmt " ")
                     format_var)
                  (Array.to_list xs)
                  (format_expr _ctx) body
          | _ -> 
              (* Fallback if not wrapped in lambda *)
              let cons_name = EnumConstructor.to_string cons in
              let lean_cons = 
                if cons_name = "None_1" || cons_name = "None" then "none"
                else if cons_name = "Some_1" || cons_name = "Some" then "some"
                else cons_name
              in
              Format.fprintf fmt "| Option.%s x => %a@,"
                lean_cons
                (format_expr _ctx) case_expr)
        cases;
      Format.fprintf fmt ")"
  | EStruct { fields; _ } ->
      (* Check if this is a tuple-like struct (fields named elt_0, elt_1, ...) *)
      let bindings = StructField.Map.bindings fields in
      let is_tuple_struct = 
        List.for_all (fun (field, _) ->
          let name = StructField.to_string field in
          String.starts_with ~prefix:"elt_" name
        ) bindings
      in
      if is_tuple_struct then
        (* Format as tuple *)
        Format.fprintf fmt "(%a)"
          (Format.pp_print_list
             ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
             (fun fmt (_, e) -> format_expr _ctx fmt e))
          bindings
      else
        (* Format as struct *)
        Format.fprintf fmt "{ %a }"
          (Format.pp_print_list
             ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
             (fun fmt (field, e) ->
               Format.fprintf fmt "%s := %a"
                 (StructField.to_string field)
                 (format_expr _ctx) e))
          bindings
  | EStructAccess { e; field; _ } ->
      (* Check if this is tuple element access (elt_0, elt_1, ...) *)
      let field_name = StructField.to_string field in
      if String.starts_with ~prefix:"elt_" field_name then
        (* Extract the number and use tuple access (1-indexed in Lean) *)
        let index_str = String.sub field_name 4 (String.length field_name - 4) in
        let index = int_of_string index_str + 1 in  (* Convert to 1-indexed *)
        Format.fprintf fmt "(%a).%d" (format_expr _ctx) e index
      else
        (* Regular struct field access *)
        Format.fprintf fmt "(%a).%s" (format_expr _ctx) e field_name
  | EFatalError _ ->
      Format.fprintf fmt "(panic! \"Error\")"
  | EPos _ ->
      Format.pp_print_string fmt "()" (* Position markers - ignore *)
  | EAppOp { op; args; _ } ->
      format_operator _ctx fmt op args
  | EAssert _ ->
      Format.pp_print_string fmt "()" (* Assertions - ignore for now *)
  | EExternal _ ->
      Format.pp_print_string fmt "sorry -- EExternal"
  | EArray _ ->
      Format.pp_print_string fmt "sorry -- EArray"
  | _ ->
      Format.pp_print_string fmt "sorry -- unknown expression"

(** Format operators - simplified *)
and format_operator (_ctx : decl_ctx) (fmt : Format.formatter) (op : lcalc operator Mark.pos) (args : 'm expr list) : unit =
  let binop s =
    match args with
    | [arg1; arg2] ->
        Format.fprintf fmt "(%a %s %a)"
          (format_expr _ctx) arg1 s (format_expr _ctx) arg2
    | _ -> Format.pp_print_string fmt "sorry"
  in
  let unop s =
    match args with
    | [arg] -> Format.fprintf fmt "(%s%a)" s (format_expr _ctx) arg
    | _ -> Format.pp_print_string fmt "sorry"
  in
  match Mark.remove op with
  | Log _ -> (match args with [arg] -> format_expr _ctx fmt arg | _ -> Format.pp_print_string fmt "sorry")
  | Add_int_int -> binop "+"
  | Sub_int_int -> binop "-"
  | Mult_int_int -> binop "*"
  | Div_int_int -> binop "/"
  | Lt_int_int -> binop "<"
  | Lte_int_int -> binop "≤"
  | Gt_int_int -> binop ">"
  | Gte_int_int -> binop "≥"
  | Eq_int_int | Eq_boo_boo -> binop "="
  | Eq -> binop "="
  | And -> binop "∧"
  | Or -> binop "∨"
  | Not -> unop "¬"
  | Minus_int -> unop "-"
  | _ -> Format.pp_print_string fmt "sorry -- unsupported operator"

(** Format scope body expression *)
let format_scope_body_expr
    (ctx : decl_ctx)
    (fmt : Format.formatter)
    (scope_lets : 'm expr scope_body_expr) : unit =
  let last_e =
    BoundList.iter
      ~f:(fun scope_let_var scope_let ->
        Format.fprintf fmt "  let %a : %a := %a@,"
          format_var scope_let_var
          format_typ scope_let.scope_let_typ
          (format_expr ctx) scope_let.scope_let_expr)
      scope_lets
  in
  (* Output the return expression with proper indentation *)
  Format.fprintf fmt "  %a" (format_expr ctx) last_e

(** Format a simple struct declaration *)
let format_simple_struct_decl (fmt : Format.formatter) (name : StructName.t) (ctx : decl_ctx) : unit =
  try
    let fields = StructName.Map.find name ctx.ctx_structs in
    if StructField.Map.is_empty fields then
      Format.fprintf fmt "structure %s where@.@." (StructName.to_string name)
    else begin
      Format.fprintf fmt "structure %s where@." (StructName.to_string name);
      StructField.Map.iter
        (fun field typ ->
          Format.fprintf fmt "  %s : %a@."
            (StructField.to_string field)
            format_typ typ)
        fields;
      Format.fprintf fmt "@."
    end
  with Not_found -> ()

(** Format entire program - simplified *)
let format_program (fmt : Format.formatter) (p : 'm program) (_type_ordering : TypeIdent.t list) : unit =
  Format.fprintf fmt "-- Generated by Catala compiler (Lean 4 backend - minimal)@,";
  Format.fprintf fmt "-- Note: Only basic integer/boolean operations supported@,@,";

  (* Output code items *)
  ignore (BoundList.iter p.code_items ~f:(fun _var item ->
      match item with
      | ScopeDef (name, body) ->
          (* Output input and output struct definitions *)
          format_simple_struct_decl fmt body.scope_body_input_struct p.decl_ctx;
          format_simple_struct_decl fmt body.scope_body_output_struct p.decl_ctx;
          
          (* Output scope function - use lowercase to avoid collision with struct *)
          let scope_input_var, scope_body_expr = Bindlib.unbind body.scope_body_expr in
          let scope_func_name = String.uncapitalize_ascii (ScopeName.base name) in
          Format.fprintf fmt "def %s (%a : %s) : %s :=@,"
            scope_func_name
            format_var scope_input_var
            (StructName.to_string body.scope_body_input_struct)
            (StructName.to_string body.scope_body_output_struct);
          Format.fprintf fmt "  @[<v>%a@]@,@,"
            (format_scope_body_expr p.decl_ctx) scope_body_expr
      | Topdef (name, typ, _vis, e) ->
          Format.fprintf fmt "def %s : %a :=@,  %a@,@,"
            (TopdefName.base name)
            format_typ typ
            (format_expr p.decl_ctx) e))

(** Main entry point *)
let run
    includes
    stdlib
    output
    optimize
    check_invariants
    closure_conversion
    options =
  let open Driver.Commands in
  let prg, type_ordering, _ =
    Driver.Passes.lcalc options ~includes ~stdlib ~optimize ~check_invariants
      ~autotest:false ~typed:Expr.typed ~closure_conversion
      ~keep_special_ops:false ~monomorphize_types:true ~expand_ops:true
      ~renaming:(Some renaming)
  in

  Message.debug "Compiling program into Lean 4...";
  get_output_format options ~ext:"lean" output
  @@ fun _filename fmt -> format_program fmt prg type_ordering

let term =
  let open Cmdliner.Term in
  const run
  $ Cli.Flags.include_dirs
  $ Cli.Flags.stdlib_dir
  $ Cli.Flags.output
  $ Cli.Flags.optimize
  $ Cli.Flags.check_invariants
  $ Cli.Flags.closure_conversion

let () =
  Driver.Plugin.register "lean4" term
    ~doc:"Generates Lean 4 code from Catala (minimal backend - integers and booleans only)"
