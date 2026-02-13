(* Desugared AST Visualizer - Generates JSON representation *)

open Catala_utils
open Shared_ast
open Desugared.Ast

module Runtime = Catala_runtime

(** JSON representation *)
type json =
  | JNull
  | JBool of bool
  | JInt of int
  | JString of string
  | JList of json list
  | JObject of (string * json) list

(** Format JSON to output *)
let rec format_json fmt = function
  | JNull -> Format.fprintf fmt "null"
  | JBool b -> Format.fprintf fmt "%b" b
  | JInt i -> Format.fprintf fmt "%d" i
  | JString s -> Format.fprintf fmt "\"%s\"" (String.escaped s)
  | JList [] -> Format.fprintf fmt "[]"
  | JList items ->
      Format.fprintf fmt "[@[<v 1>@,%a@]@,]"
        (Format.pp_print_list
           ~pp_sep:(fun fmt () -> Format.fprintf fmt ",@,")
           format_json)
        items
  | JObject [] -> Format.fprintf fmt "{}"
  | JObject fields ->
      Format.fprintf fmt "{@[<v 1>@,%a@]@,}"
        (Format.pp_print_list
           ~pp_sep:(fun fmt () -> Format.fprintf fmt ",@,")
           (fun fmt (k, v) ->
             Format.fprintf fmt "\"%s\": %a" k format_json v))
        fields

(** Convert position to JSON *)
let pos_to_json (pos : Pos.t) : json =
  JObject [
    ("file", JString (Pos.get_file pos));
    ("start_line", JInt (Pos.get_start_line pos));
    ("end_line", JInt (Pos.get_end_line pos));
  ]

(** Convert literal to JSON *)
let lit_to_json (l : lit) : json =
  match l with
  | LBool b -> JObject [("type", JString "Bool"); ("value", JBool b)]
  | LInt i -> JObject [("type", JString "Int"); ("value", JString (Runtime.integer_to_string i))]
  | LUnit -> JObject [("type", JString "Unit")]
  | LRat r -> JObject [("type", JString "Rat"); ("value", JString (Q.to_string r))]
  | LMoney m -> JObject [("type", JString "Money"); ("value", JString (Runtime.integer_to_string (Runtime.money_to_cents m)))]
  | LDate d -> JObject [("type", JString "Date"); ("value", JString (Runtime.date_to_string d))]
  | LDuration d -> JObject [("type", JString "Duration"); ("value", JString (Runtime.duration_to_string d))]

(** Convert type to JSON *)
let rec typ_to_json (ty : typ) : json =
  match Mark.remove ty with
  | TLit TUnit -> JString "Unit"
  | TLit TBool -> JString "Bool"
  | TLit TInt -> JString "Int"
  | TLit TRat -> JString "Rat"
  | TLit TMoney -> JString "Money"
  | TLit TDate -> JString "Date"
  | TLit TDuration -> JString "Duration"
  | TLit TPos -> JString "Pos"
  | TArrow (args, ret) ->
      JObject [
        ("kind", JString "Arrow");
        ("args", JList (List.map typ_to_json args));
        ("return", typ_to_json ret);
      ]
  | TTuple ts ->
      JObject [
        ("kind", JString "Tuple");
        ("types", JList (List.map typ_to_json ts));
      ]
  | TStruct s ->
      JObject [
        ("kind", JString "Struct");
        ("name", JString (StructName.to_string s));
      ]
  | TEnum e ->
      JObject [
        ("kind", JString "Enum");
        ("name", JString (EnumName.to_string e));
      ]
  | TOption t ->
      JObject [
        ("kind", JString "Option");
        ("inner", typ_to_json t);
      ]
  | TArray t ->
      JObject [
        ("kind", JString "Array");
        ("inner", typ_to_json t);
      ]
  | TDefault t ->
      JObject [
        ("kind", JString "Default");
        ("inner", typ_to_json t);
      ]
  | _ -> JString "Other"

let operator_string (op : desugared operator Mark.pos) : string =
  let open Op in
  match Mark.remove op with
  | Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Lt -> "<"
  | Lte -> "≤"
  | Gt -> ">"
  | Gte -> "≥"
  | Eq -> "="
  | And -> "∧"
  | Or -> "∨"
  | Xor -> "⊕"
  | Not -> "¬"
  | Length -> "length"
  | Map -> "map"
  | Filter -> "filter"
  | Fold -> "fold"
  | Reduce -> "reduce"
  | Concat -> "concat"
  | Map2 -> "map2"
  | _ -> "Other"

(** Convert expression to JSON - for desugared *)
let rec expr_to_json (e : expr) : json =
  match Mark.remove e with
  | ELit l ->
      JObject [
        ("node", JString "ELit");
        ("value", lit_to_json l);
      ]
  | EVar v ->
      JObject [
        ("node", JString "EVar");
        ("name", JString (Bindlib.name_of v));
      ]
  | EApp { f; args; _ } ->
      JObject [
        ("node", JString "EApp");
        ("function", expr_to_json f);
        ("args", JList (List.map expr_to_json args));
      ]
  | EAbs { binder; tys; _ } ->
      let vars, body = Bindlib.unmbind binder in
      JObject [
        ("node", JString "EAbs");
        ("params", JList (Array.to_list (Array.map (fun v -> JString (Bindlib.name_of v)) vars)));
        ("param_types", JList (List.map typ_to_json tys));
        ("body", expr_to_json body);
      ]
  | EIfThenElse { cond; etrue; efalse } ->
      JObject [
        ("node", JString "EIfThenElse");
        ("condition", expr_to_json cond);
        ("then", expr_to_json etrue);
        ("else", expr_to_json efalse);
      ]
  | ETuple es ->
      JObject [
        ("node", JString "ETuple");
        ("elements", JList (List.map expr_to_json es));
      ]
  | ETupleAccess { e; index; size } ->
      JObject [
        ("node", JString "ETupleAccess");
        ("tuple", expr_to_json e);
        ("index", JInt index);
        ("size", JInt size);
      ]
  | EInj { e; cons; name } ->
      JObject [
        ("node", JString "EInj");
        ("enum", JString (EnumName.to_string name));
        ("constructor", JString (EnumConstructor.to_string cons));
        ("value", expr_to_json e);
      ]
  | EMatch { e; cases; name } ->
      let cases_json = EnumConstructor.Map.fold
        (fun cons case_expr acc ->
          (EnumConstructor.to_string cons, expr_to_json case_expr) :: acc)
        cases []
      in
      JObject [
        ("node", JString "EMatch");
        ("enum", JString (EnumName.to_string name));
        ("scrutinee", expr_to_json e);
        ("cases", JObject cases_json);
      ]
  | EStruct { fields; name } ->
      let fields_json = StructField.Map.fold
        (fun field field_expr acc ->
          (StructField.to_string field, expr_to_json field_expr) :: acc)
        fields []
      in
      JObject [
        ("node", JString "EStruct");
        ("struct_name", JString (StructName.to_string name));
        ("fields", JObject fields_json);
      ]
  | EStructAccess { e; field; name } ->
      JObject [
        ("node", JString "EStructAccess");
        ("struct_name", JString (StructName.to_string name));
        ("struct", expr_to_json e);
        ("field", JString (StructField.to_string field));
      ]
  | EDStructAccess { e; field; _ } ->
      JObject [
        ("node", JString "EDStructAccess");
        ("struct", expr_to_json e);
        ("field", JString field);
      ]
  | EDStructAmend { e; fields; _ } ->
      let fields_json = Ident.Map.fold
        (fun field field_expr acc ->
          (field, expr_to_json field_expr) :: acc)
        fields []
      in
      JObject [
        ("node", JString "EDStructAmend");
        ("base", expr_to_json e);
        ("fields", JObject fields_json);
      ]
  | EArray es ->
      JObject [
        ("node", JString "EArray");
        ("elements", JList (List.map expr_to_json es));
      ]
  | ELocation loc ->
      let loc_json = match loc with
        | DesugaredScopeVar { name; state } ->
            JObject [
              ("kind", JString "DesugaredScopeVar");
              ("name", JString (ScopeVar.to_string (Mark.remove name)));
              ("state", match state with
                | None -> JNull
                | Some s -> JString (StateName.to_string s));
            ]
        | _ -> JString "OtherLocation"
      in
      JObject [
        ("node", JString "ELocation");
        ("location", loc_json);
      ]
  | EScopeCall { scope; args } ->
      let args_json = ScopeVar.Map.fold
        (fun var (_pos, arg_expr) acc ->
          (ScopeVar.to_string var, expr_to_json arg_expr) :: acc)
        args []
      in
      JObject [
        ("node", JString "EScopeCall");
        ("scope", JString (ScopeName.to_string scope));
        ("args", JObject args_json);
      ]
  | EDefault { excepts; just; cons } ->
      JObject [
        ("node", JString "EDefault");
        ("exceptions", JList (List.map expr_to_json excepts));
        ("justification", expr_to_json just);
        ("consequence", expr_to_json cons);
      ]
  | EPureDefault e ->
      JObject [
        ("node", JString "EPureDefault");
        ("value", expr_to_json e);
      ]
  | EEmpty ->
      JObject [("node", JString "EEmpty")]
  | EErrorOnEmpty e ->
      JObject [
        ("node", JString "EErrorOnEmpty");
        ("value", expr_to_json e);
      ]
  | EAppOp { op; args; _ } ->
      JObject [
        ("node", JString "EAppOp");
        ("operator", JString (operator_string op));
        ("args", JList (List.map expr_to_json args));
      ]
  | _ ->
      JObject [("node", JString "Unknown")]

(** Convert ScopeDef kind to JSON *)
let scope_def_kind_to_json (kind : ScopeDef.kind) : json =
  match kind with
  | Var None -> JObject [("kind", JString "Var"); ("state", JNull)]
  | Var (Some state) -> 
      JObject [
        ("kind", JString "Var");
        ("state", JString (StateName.to_string state));
      ]
  | SubScopeInput { name; var_within_origin_scope } ->
      JObject [
        ("kind", JString "SubScopeInput");
        ("scope", JString (ScopeName.to_string name));
        ("var", JString (ScopeVar.to_string var_within_origin_scope));
      ]

(** Convert rule to JSON *)
let rule_to_json (r : rule) : json =
  let exception_json = match r.rule_exception with
    | BaseCase -> JString "BaseCase"
    | ExceptionToLabel (label, _) -> 
        JObject [("kind", JString "ExceptionToLabel"); ("label", JString (LabelName.to_string label))]
    | ExceptionToRule (rule, _) ->
        JObject [("kind", JString "ExceptionToRule"); ("rule", JString (RuleName.to_string rule))]
  in
  let label_json = match r.rule_label with
    | Unlabeled -> JString "Unlabeled"
    | ExplicitlyLabeled (label, _) -> JString (LabelName.to_string label)
  in
  (* Extract from boxed expression *)
  let just_expr_box, just_mark = r.rule_just in
  let just_expr = Bindlib.unbox just_expr_box in
  let cons_expr_box, cons_mark = r.rule_cons in
  let cons_expr = Bindlib.unbox cons_expr_box in
  JObject [
    ("rule_id", JString (RuleName.to_string r.rule_id));
    ("rule_just", expr_to_json (just_expr, just_mark));
    ("rule_cons", expr_to_json (cons_expr, cons_mark));
    ("rule_exception", exception_json);
    ("rule_label", label_json);
  ]

(** Convert scope_def to JSON *)
let scope_def_to_json (sd : scope_def) : json =
  let rules_json = RuleName.Map.fold
    (fun name rule acc ->
      (RuleName.to_string name, rule_to_json rule) :: acc)
    sd.scope_def_rules []
  in
  let io_input_str = match Mark.remove sd.scope_def_io.io_input with
    | Runtime.OnlyInput -> "OnlyInput"
    | Runtime.NoInput -> "NoInput"
    | Runtime.Reentrant -> "Reentrant"
  in
  JObject [
    ("scope_def_rules", JObject rules_json);
    ("scope_def_typ", typ_to_json sd.scope_def_typ);
    ("scope_def_parameters", JNull);  (* TODO: Add parameter serialization *)
    ("scope_def_is_condition", JBool sd.scope_def_is_condition);
    ("scope_def_io", JObject [
      ("io_output", JBool (Mark.remove sd.scope_def_io.io_output));
      ("io_input", JString io_input_str);
    ]);
  ]

(** Convert scope to JSON *)
let scope_to_json (s : scope) : json =
  let defs_json = ScopeDef.Map.fold
    (fun (var, kind) def acc ->
      let key = Format.asprintf "%a" ScopeDef.format (var, kind) in
      (key, scope_def_to_json def) :: acc)
    s.scope_defs []
  in
  
  let vars_json = ScopeVar.Map.fold
    (fun var var_or_states acc ->
      let states_json = match var_or_states with
        | WholeVar -> JString "WholeVar"
        | States states -> JObject [
            ("kind", JString "States");
            ("states", JList (List.map (fun s -> JString (StateName.to_string s)) states))
          ]
      in
      (ScopeVar.to_string var, states_json) :: acc)
    s.scope_vars []
  in

  let sub_scopes_json = ScopeVar.Map.fold
    (fun var scope_name acc ->
      (ScopeVar.to_string var, JString (ScopeName.to_string scope_name)) :: acc)
    s.scope_sub_scopes []
  in

  let assertions_json = AssertionName.Map.fold
    (fun name assertion acc ->
      let assertion_box, assertion_mark = assertion in
      let assertion_expr = Bindlib.unbox assertion_box in
      (AssertionName.to_string name, expr_to_json (assertion_expr, assertion_mark)) :: acc)
    s.scope_assertions []
  in

  JObject [
    ("scope_vars", JObject vars_json);
    ("scope_sub_scopes", JObject sub_scopes_json);
    ("scope_uid", JString (ScopeName.to_string s.scope_uid));
    ("scope_defs", JObject defs_json);
    ("scope_assertions", JObject assertions_json);
    ("scope_options", JList []);  (* TODO: Add scope_options serialization *)
    ("scope_meta_assertions", JList []);  (* TODO: Add meta_assertions serialization *)
    ("scope_visibility", JString (match s.scope_visibility with Public -> "Public" | Private -> "Private"));
  ]

(** Convert topdef to JSON *)
let topdef_to_json (td : topdef) : json =
  JObject [
    ("topdef_expr", match td.topdef_expr with
      | None -> JNull
      | Some e -> expr_to_json e);
    ("topdef_type", typ_to_json td.topdef_type);
    ("topdef_arg_names", JList (List.map (fun (name, _) -> JString name) td.topdef_arg_names));
    ("topdef_visibility", JString (match td.topdef_visibility with Public -> "Public" | Private -> "Private"));
    ("topdef_external", JBool td.topdef_external);
  ]

(** Convert modul to JSON *)
let modul_to_json (m : modul) : json =
  let scopes_json = ScopeName.Map.fold
    (fun name scope acc ->
      (ScopeName.to_string name, scope_to_json scope) :: acc)
    m.module_scopes []
  in
  
  let topdefs_json = TopdefName.Map.fold
    (fun name topdef acc ->
      (TopdefName.to_string name, topdef_to_json topdef) :: acc)
    m.module_topdefs []
  in

  JObject [
    ("module_scopes", JObject scopes_json);
    ("module_topdefs", JObject topdefs_json);
  ]

(** Convert program to JSON *)
let program_to_json (p : program) : json =
  (* Collect struct information from context *)
  let structs_json = StructName.Map.fold
    (fun name fields acc ->
      let fields_json = StructField.Map.fold
        (fun field typ acc -> (StructField.to_string field, typ_to_json typ) :: acc)
        fields []
      in
      (StructName.to_string name, JObject fields_json) :: acc)
    p.program_ctx.ctx_structs []
  in
  
  let enums_json = EnumName.Map.fold
    (fun name constrs acc ->
      let constrs_json = EnumConstructor.Map.fold
        (fun cons typ acc -> (EnumConstructor.to_string cons, typ_to_json typ) :: acc)
        constrs []
      in
      (EnumName.to_string name, JObject constrs_json) :: acc)
    p.program_ctx.ctx_enums []
  in

  let modules_json = ModuleName.Map.fold
    (fun name modul acc ->
      (ModuleName.to_string name, modul_to_json modul) :: acc)
    p.program_modules []
  in

  let lang_str = match p.program_lang with
    | Global.En -> "en"
    | Global.Fr -> "fr"
    | Global.Pl -> "pl"
  in
  JObject [
    ("program_module_name", match p.program_module_name with
      | None -> JNull
      | Some (name, _) -> JString (ModuleName.to_string name));
    ("program_ctx", JObject [
      ("ctx_structs", JObject structs_json);
      ("ctx_enums", JObject enums_json);
    ]);
    ("program_modules", JObject modules_json);
    ("program_root", modul_to_json p.program_root);
    ("program_lang", JString lang_str);
  ]

(** Main visualization function *)
let visualize includes stdlib output options =
  let open Driver.Commands in
  let prg, _ = Driver.Passes.desugared options ~includes ~stdlib in
  Message.debug "Generating desugared AST visualization...";
  get_output_format options ~ext:"json" output
  @@ fun _filename fmt -> format_json fmt (program_to_json prg)

(** CLI Term *)
let term =
  let open Cmdliner.Term in
  const visualize
  $ Cli.Flags.include_dirs
  $ Cli.Flags.stdlib_dir
  $ Cli.Flags.output

(** Register plugin *)
let () =
  Driver.Plugin.register "visualize-desugared" term
    ~doc:"Visualize Desugared AST as JSON"

