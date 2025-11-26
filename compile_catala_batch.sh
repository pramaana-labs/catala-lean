#!/bin/bash

# Root of input tests
INPUT_ROOT="/home/pranav/Downloads/Pramaana_intern/catala-lean/tests"
OUTPUT_ROOT="/home/pranav/Downloads/loom_trial/loom/CaseStudies/Pramaana/Catala_Translations"
#OUTPUT_ROOT="/home/pranav/Downloads/Catala_trials/tests_json"

COMPILER="_build/default/compiler/catala.exe"

# Find all tests/XX/good/*.catala_en files
find "$INPUT_ROOT" -type f -path "*/good/*.catala_en" | while read -r file; do
    # file = tests/XX/good/filename.catala_en

    # Remove "tests/" prefix
    relative="${file#$INPUT_ROOT/}"     # => XX/good/filename.catala_en

    # Replace .catala_en → .lean
    out_file="${relative%.catala_en}.lean" #change to lean for standard compilation

    # Prepend Lean_files/
    output_path="$OUTPUT_ROOT/$out_file"

    # Ensure output directory exists
    mkdir -p "$(dirname "$output_path")"

    echo "Compiling: $file  →  $output_path"

    # Run compiler
    "$COMPILER" lean4-desugared "$file" -o "$output_path" #lean4-desugared for standard compilation
done

