#!/usr/bin/env bash

# Script to compile all Lean files in Sara_lean/CatalaTests/ directory
# and produce a summary of compilation results

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_BASE_DIR="CatalaTests"
DEFAULT_PATTERN="*.lean"

# Initialize with defaults
BASE_DIR="$DEFAULT_BASE_DIR"
FILE_PATTERN="$DEFAULT_PATTERN"

# Print usage function
print_usage() {
    echo "Usage: $0 [-d DIRECTORY] [-p PATTERN] [-h]"
    echo ""
    echo "Options:"
    echo "  -d DIR      Directory to search for Lean files relative to Sara_lean/ (default: $DEFAULT_BASE_DIR)"
    echo "  -p PATTERN  Pattern to match files (default: $DEFAULT_PATTERN)"
    echo "  -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                           # Compile all .lean files in CatalaTests/"
    echo "  $0 -p 'variable_state/good/*.lean'           # Only files matching pattern"
    echo "  $0 -d CatalaTests/typing                     # All .lean files in typing/"
    echo "  $0 -d CatalaTests -p 'proof/good/*.lean'     # Custom directory and pattern"
    echo ""
}

# Parse command line arguments
while getopts "d:p:h" opt; do
    case $opt in
        d)
            BASE_DIR="$OPTARG"
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



# Check if directory exists
if [ ! -d "$BASE_DIR" ]; then
    echo -e "${RED}Error: Directory $BASE_DIR not found${NC}"
    exit 1
fi

# Initialize counters
total_files=0
total_success=0
total_failed=0

# Create temporary directory for logs and stats
LOG_DIR=$(mktemp -d)
STATS_FILE="$LOG_DIR/dir_stats.txt"
touch "$STATS_FILE"
echo "Compilation logs will be stored in: $LOG_DIR"
echo ""

# Find all .lean files
echo -e "${BLUE}=== Scanning for Lean files in $BASE_DIR ===${NC}"
echo -e "Using pattern: ${YELLOW}$FILE_PATTERN${NC}"
echo ""

# Handle both path patterns (with /) and simple name patterns
if [[ "$FILE_PATTERN" == */* ]]; then
    # Pattern contains path separator, use -path
    lean_files=$(find "$BASE_DIR" -type f -path "*/$FILE_PATTERN" | sort)
else
    # Simple filename pattern, use -name
    lean_files=$(find "$BASE_DIR" -type f -name "$FILE_PATTERN" | sort)
fi

file_count=$(echo "$lean_files" | grep -v '^$' | wc -l | tr -d ' ')

if [ -z "$lean_files" ] || [ "$file_count" -eq 0 ]; then
    echo -e "${RED}No Lean files found in $BASE_DIR${NC}"
    exit 1
fi

echo -e "Found ${YELLOW}${file_count}${NC} Lean files"
echo ""

# Function to update directory stats
update_dir_stats() {
    local dir_name="$1"
    local success="$2"
    
    # Check if directory already exists in stats
    if grep -q "^${dir_name}|" "$STATS_FILE"; then
        # Update existing entry
        local line=$(grep "^${dir_name}|" "$STATS_FILE")
        local total=$(echo "$line" | cut -d'|' -f2)
        local succ=$(echo "$line" | cut -d'|' -f3)
        local fail=$(echo "$line" | cut -d'|' -f4)
        
        total=$((total + 1))
        if [ "$success" -eq 1 ]; then
            succ=$((succ + 1))
        else
            fail=$((fail + 1))
        fi
        
        # Replace the line
        sed -i.bak "s|^${dir_name}|.*|${dir_name}|${total}|${succ}|${fail}|" "$STATS_FILE"
        rm -f "${STATS_FILE}.bak"
    else
        # Add new entry
        if [ "$success" -eq 1 ]; then
            echo "${dir_name}|1|1|0" >> "$STATS_FILE"
        else
            echo "${dir_name}|1|0|1" >> "$STATS_FILE"
        fi
    fi
}

# Compile each file
echo -e "${BLUE}=== Starting Compilation ===${NC}"
file_num=0
echo "$lean_files" | while IFS= read -r file; do
    file_num=$((file_num + 1))
    
    # Extract directory (relative to BASE_DIR)
    rel_path="${file#$BASE_DIR/}"
    dir_name=$(dirname "$rel_path")
    
    # Compile the file
    echo -ne "Compiling [$file_num/$file_count]: $file ... "
    
    # Create log file name
    log_file="$LOG_DIR/$(echo "$file" | tr '/' '_').log"
    
    # Compile and capture result
    if lake lean "$file" > "$log_file" 2>&1; then
        echo -e "${GREEN}✓${NC}"
        echo "success" >> "$LOG_DIR/results.txt"
        echo "$dir_name" >> "$LOG_DIR/success_dirs.txt"
    else
        echo -e "${RED}✗${NC}"
        echo "failed" >> "$LOG_DIR/results.txt"
        echo "$dir_name" >> "$LOG_DIR/failed_dirs.txt"
        # Save failed file for summary
        echo "$file" >> "$LOG_DIR/failed_files.txt"
    fi
done

# Calculate totals from results
total_files=$(wc -l < "$LOG_DIR/results.txt" | tr -d ' ')
total_success=$(grep -c "^success$" "$LOG_DIR/results.txt" 2>/dev/null || echo 0)
total_failed=$(grep -c "^failed$" "$LOG_DIR/results.txt" 2>/dev/null || echo 0)

echo ""
echo -e "${BLUE}=== Compilation Complete ===${NC}"
echo ""

# Build directory statistics
if [ -f "$LOG_DIR/success_dirs.txt" ] || [ -f "$LOG_DIR/failed_dirs.txt" ]; then
    # Combine all directory names and count occurrences
    cat "$LOG_DIR/success_dirs.txt" "$LOG_DIR/failed_dirs.txt" 2>/dev/null | sort | uniq > "$LOG_DIR/all_dirs.txt"
    
    # For each directory, count successes and failures
    while IFS= read -r dir_name; do
        total=$(cat "$LOG_DIR/success_dirs.txt" "$LOG_DIR/failed_dirs.txt" 2>/dev/null | grep -c "^${dir_name}$" || echo 0)
        success=$(grep -c "^${dir_name}$" "$LOG_DIR/success_dirs.txt" 2>/dev/null || echo 0)
        failed=$(grep -c "^${dir_name}$" "$LOG_DIR/failed_dirs.txt" 2>/dev/null || echo 0)
        echo "${dir_name}|${total}|${success}|${failed}" >> "$STATS_FILE"
    done < "$LOG_DIR/all_dirs.txt"
fi

# Print summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    COMPILATION SUMMARY                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Overall Results:${NC}"
echo -e "  Total files:       ${total_files}"
echo -e "  ${GREEN}Successful:        ${total_success}${NC}"
echo -e "  ${RED}Failed:            ${total_failed}${NC}"
if [ "$total_files" -gt 0 ]; then
    success_rate=$(echo "scale=1; ($total_success * 100) / $total_files" | bc)
    echo -e "  Success rate:      ${success_rate}%"
fi
echo ""

echo -e "${YELLOW}Results by Directory:${NC}"
echo ""

# Print header
printf "%-50s %8s %8s %8s %8s\n" "Directory" "Total" "Success" "Failed" "Rate"
echo "$(printf '%.0s─' {1..90})"

# Sort and print directory stats
if [ -f "$STATS_FILE" ] && [ -s "$STATS_FILE" ]; then
    sort "$STATS_FILE" | while IFS='|' read -r dir_name total success failed; do
        # Skip empty or malformed lines
        if [ -z "$total" ] || [ -z "$success" ] || [ -z "$failed" ]; then
            continue
        fi
        
        # Ensure values are numeric and total > 0
        if [ "$total" -gt 0 ] 2>/dev/null; then
            rate=$(echo "scale=1; ($success * 100) / $total" | bc)
            
            # Color code based on success rate
            if [ "$failed" -eq 0 ] 2>/dev/null; then
                color=$GREEN
            elif [ "$success" -eq 0 ] 2>/dev/null; then
                color=$RED
            else
                color=$YELLOW
            fi
            
            printf "${color}%-50s %8d %8d %8d %7s%%${NC}\n" "$dir_name" "$total" "$success" "$failed" "$rate"
        fi
    done
fi

echo ""

# Print failed files if any
if [ $total_failed -gt 0 ]; then
    echo -e "${RED}Failed files:${NC}"
    cat "$LOG_DIR/failed_files.txt" | while read -r failed_file; do
        echo "  - $failed_file"
    done
    echo ""
    echo -e "Detailed error logs are available in: ${YELLOW}$LOG_DIR${NC}"
else
    echo -e "${GREEN}All files compiled successfully!${NC}"
    # Clean up logs if everything succeeded
    rm -rf "$LOG_DIR"
fi

echo ""

# Exit with appropriate code
if [ $total_failed -gt 0 ]; then
    exit 1
else
    exit 0
fi
