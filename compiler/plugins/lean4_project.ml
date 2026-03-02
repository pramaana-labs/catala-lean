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

(** Lean4 project generator plugin.

    This plugin compiles a Catala source file into a self-contained Lean 4
    project directory. The directory contains:
    - The compiled Lean 4 source file (module name derived from the Catala
      filename)
    - CatalaRuntime.lean
    - Stdlib/ directory with stdlib Lean files
    - lakefile.toml
    - lean-toolchain *)

open Catala_utils

(** {1 Naming utilities} *)

(** Convert a snake_case or kebab-case stem into a PascalCase Lean module name.

    Examples:
    - [tax_case_1]      → [TaxCase1]
    - [flipkart-policy] → [FlipkartPolicy]
    - [salt]            → [Salt] *)
let stem_to_module_name stem =
  stem
  |> String.split_on_char '_'
  |> List.concat_map (String.split_on_char '-')
  |> List.filter (fun s -> s <> "")
  |> List.map (fun word ->
       if String.length word = 0 then ""
       else
         String.make 1 (Char.uppercase_ascii word.[0])
         ^ String.sub word 1 (String.length word - 1))
  |> String.concat ""

(** {1 Path utilities} *)

(** Infer the catala-lean project root from the compiler executable location.

    When built with [dune build catala], the executable lives at
    [_build/default/compiler/catala.exe]. Going up three levels from
    [exec_dir] reaches the workspace root. *)
let default_lean4_root () =
  Filename.dirname (Filename.dirname (Filename.dirname Cli.exec_dir))

(** Recursively create a directory and all missing parent directories. *)
let rec mkdirp dir =
  if Sys.file_exists dir then (
    if not (Sys.is_directory dir) then
      failwith
        (Printf.sprintf
           "lean4-project: path '%s' already exists and is not a directory"
           dir))
  else begin
    let parent = Filename.dirname dir in
    if parent <> dir then mkdirp parent;
    Unix.mkdir dir 0o755
  end

(** {1 File I/O utilities} *)

(** Copy a single binary file from [src] to [dst]. *)
let copy_file src dst =
  Message.debug "Copying %s" (Filename.basename src);
  let ic = open_in_bin src in
  let n = in_channel_length ic in
  let buf = Bytes.create n in
  really_input ic buf 0 n;
  close_in ic;
  let oc = open_out_bin dst in
  output_bytes oc buf;
  close_out oc

(** Copy all regular (non-directory) files from [src_dir] into [dst_dir].
    Does not recurse into subdirectories. *)
let copy_dir_files src_dir dst_dir =
  Array.iter
    (fun fname ->
      let src = Filename.concat src_dir fname in
      if not (Sys.is_directory src) then
        copy_file src (Filename.concat dst_dir fname))
    (Sys.readdir src_dir)

(** Write [content] to the file at [path], overwriting it if it exists. *)
let write_file path content =
  let oc = open_out path in
  output_string oc content;
  close_out oc

(** {1 Template generation} *)

(** Generate a [lakefile.toml] for the output project.

    [project_name] is a lowercase/snake_case identifier used as the Lake
    package name.  [module_name] is the PascalCase name of the compiled
    Lean 4 module (also used as the default build target). *)
let generate_lakefile project_name module_name =
  Printf.sprintf
    {|name = "%s"
version = "0.1.0"
defaultTargets = ["%s"]

[[lean_lib]]
name = "CatalaRuntime"
roots = ["CatalaRuntime"]

[[lean_lib]]
name = "Stdlib"

[[lean_lib]]
name = "%s"
|}
    project_name module_name module_name

(** Lean toolchain version pinned for generated projects. *)
let lean_toolchain_content = "leanprover/lean4:v4.26.0\n"

(** {1 Plugin entry point} *)

let run includes stdlib (output : Global.raw_file option) lean4_root_opt options =
  (* ── 1. Compile Catala → Lean 4 code ─────────────────────────────────── *)
  let prg, _ctx = Driver.Passes.desugared options ~includes ~stdlib in
  let prg_scopelang = Driver.Passes.scopelang options ~includes ~stdlib in
  Message.debug "Generating Lean4 code from desugared AST...";
  let lean_code = Lean4_desugared.generate_lean_code prg prg_scopelang in

  (* ── 2. Resolve paths ─────────────────────────────────────────────────── *)
  let src_file = Global.input_src_file options.Global.input_src in
  (* Output directory: explicit -o value, or stem of the input file *)
  let output_dir =
    match output with
    | Some rf -> (rf :> string)
    | None -> File.remove_extension src_file
  in
  (* Module name derived from the bare filename stem *)
  let stem = Filename.basename (File.remove_extension src_file) in
  let module_name = stem_to_module_name stem in
  let project_name = stem in
  let lean_filename = module_name ^ ".lean" in
  (* Support files root *)
  let lean4_root =
    match lean4_root_opt with Some r -> r | None -> default_lean4_root ()
  in

  (* ── 3. Create output directory ───────────────────────────────────────── *)
  mkdirp output_dir;
  Message.debug "Output directory: %s" output_dir;

  (* ── 4. Write compiled Lean 4 source ──────────────────────────────────── *)
  write_file (Filename.concat output_dir lean_filename) lean_code;
  Message.debug "Written %s" lean_filename;

  (* ── 5. Copy CatalaRuntime.lean ───────────────────────────────────────── *)
  let runtime_src =
    Filename.concat lean4_root
      (Filename.concat "runtimes" (Filename.concat "lean4" "CatalaRuntime.lean"))
  in
  copy_file runtime_src (Filename.concat output_dir "CatalaRuntime.lean");
  Message.debug "Copied CatalaRuntime.lean";

  (* ── 6. Create Stdlib/ and populate it ───────────────────────────────── *)
  let stdlib_dst = Filename.concat output_dir "Stdlib" in
  mkdirp stdlib_dst;
  (* Core stdlib .lean files from stdlib/lean4/ *)
  let stdlib_lean4_src =
    Filename.concat lean4_root (Filename.concat "stdlib" "lean4")
  in
  copy_dir_files stdlib_lean4_src stdlib_dst;
  (* Stdlib.lean aggregator from Sara_lean/Stdlib/ *)
  let stdlib_lean_src =
    Filename.concat lean4_root
      (Filename.concat "Sara_lean" (Filename.concat "Stdlib" "Stdlib.lean"))
  in
  copy_file stdlib_lean_src (Filename.concat stdlib_dst "Stdlib.lean");
  Message.debug "Populated Stdlib/";

  (* ── 7. Generate lakefile.toml ────────────────────────────────────────── *)
  write_file
    (Filename.concat output_dir "lakefile.toml")
    (generate_lakefile project_name module_name);
  Message.debug "Written lakefile.toml";

  (* ── 8. Generate lean-toolchain ───────────────────────────────────────── *)
  write_file
    (Filename.concat output_dir "lean-toolchain")
    lean_toolchain_content;
  Message.debug "Written lean-toolchain";

  Message.result "Lean4 project written to %s" output_dir

(** {1 CLI term and plugin registration} *)

let term =
  let open Cmdliner in
  let lean4_root =
    Arg.(
      value
      & opt (some string) None
      & info ["lean4-root"] ~docv:"DIR"
          ~doc:
            "Path to the catala-lean project root, used to locate \
             $(b,CatalaRuntime.lean) and the stdlib Lean files. When omitted \
             the compiler infers this path from its own executable location \
             (works correctly for local $(b,dune build) invocations).")
  in
  Term.(
    const run
    $ Cli.Flags.include_dirs
    $ Cli.Flags.stdlib_dir
    $ Cli.Flags.output
    $ lean4_root)

let () =
  Driver.Plugin.register "lean4-project" term
    ~doc:
      "Generates a self-contained Lean4 project directory from a Catala \
       source file. The directory contains the compiled Lean4 code, \
       CatalaRuntime.lean, a Stdlib/ directory, a lakefile.toml, and a \
       lean-toolchain file."
