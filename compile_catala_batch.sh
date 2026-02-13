#!/bin/bash

# Default root of input tests
DEFAULT_INPUT_ROOT="/Users/kaushikraghavan/Projects/catala-lean/tests"
DEFAULT_FILE_PATTERN="*/good/*.catala_en"
OUTPUT_ROOT="/Users/kaushikraghavan/Projects/catala-lean/Sara_lean/CatalaTests"
#OUTPUT_ROOT="/home/pranav/Downloads/Catala_trials/tests_json"

COMPILER="_build/default/compiler/catala.exe"

# Initialize with defaults
INPUT_DIRECTORY="$DEFAULT_INPUT_ROOT"
FILE_PATTERN="$DEFAULT_FILE_PATTERN"

# Print usage function
print_usage() {
    echo "Usage: $0 [-d INPUT_DIRECTORY] [-p FILE_PATTERN] [-h]"
    echo ""
    echo "Options:"
    echo "  -d DIR      Directory to search for Catala files (default: $DEFAULT_INPUT_ROOT)"
    echo "  -p PATTERN  Pattern to match files (default: $DEFAULT_FILE_PATTERN)"
    echo "  -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Use defaults"
    echo "  $0 -d tests                           # Custom directory, default pattern"
    echo "  $0 -p '*.catala_en'                   # Default directory, all .catala_en files"
    echo "  $0 -d tests/arithmetic                # Specific directory, default pattern"
    echo "  $0 -d tests -p '*/good/*.catala_en'   # Custom directory and pattern"
    echo "  $0 -p '*/bad/*.catala_en' -d tests    # Order doesn't matter"
    echo ""
}

# Parse command line arguments
while getopts "d:p:h" opt; do
    case $opt in
        d)
            INPUT_DIRECTORY="$OPTARG"
            ;;
        p)
            FILE_PATTERN="$OPTARG"
            ;;
        h)
            print_usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            print_usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            print_usage
            exit 1
            ;;
    esac
done

# Check if input directory exists
if [ ! -d "$INPUT_DIRECTORY" ]; then
    echo "Error: Directory '$INPUT_DIRECTORY' not found"
    exit 1
fi

echo "Compiling Catala files from: $INPUT_DIRECTORY"
echo "Using pattern: $FILE_PATTERN"
echo "Output directory: $OUTPUT_ROOT"
echo ""

# Find all matching files
# Handle both path patterns (with /) and simple name patterns
if [[ "$FILE_PATTERN" == */* ]]; then
    # Pattern contains path separator, use -path
    find "$INPUT_DIRECTORY" -type f -path "*/$FILE_PATTERN"
else
    # Simple filename pattern, use -name
    find "$INPUT_DIRECTORY" -type f -name "$FILE_PATTERN"
fi | while read -r file; do
    # file = tests/XX/good/filename.catala_en

    # Remove input directory prefix
    relative="${file#$INPUT_DIRECTORY/}"     # => XX/good/filename.catala_en

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

