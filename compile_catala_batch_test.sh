#!/bin/bash

# Root of input tests
INPUT_ROOT="/home/pranav/Downloads/Pramaana_intern/catala-lean/tests/catala_test_cases"
OUTPUT_ROOT="/home/pranav/Downloads/loom_trial/loom/CaseStudies/Pramaana/Testcases"
#OUTPUT_ROOT="/home/pranav/Downloads/Catala_trials/tests_json"
COMPILER="_build/default/compiler/catala.exe"

# Find all tests/XX/good/*.catala_en files
find "$INPUT_ROOT" -type f -path "*.catala_en" | while read -r file; do
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
    "$COMPILER" lean4-desugared-test "$file" -o "$output_path" #lean4-desugared for standard compilation

    # Post-process: If the output file is tax_case_i.lean, replace "computation" on #eval lines
    out_basename=$(basename "$output_path" .lean)
    if [[ $out_basename =~ ^tax_case_([0-9]+)$ ]]; then
        num="${BASH_REMATCH[1]}"
        replacement="(testTaxCase${num} {}).computation"
        
        # Replace "computation" with the replacement string only on lines containing #eval
        sed -i "/#eval/s/computation/${replacement}/g" "$output_path"
        
        echo "  Post-processed: replaced 'computation' with '$replacement' on #eval lines"
    fi

done
