#!/bin/bash

# Get the script's directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RELATIVE_ROOT=$(basename "$PROJECT_ROOT")

# Output file goes in the same directory as the script
OUTPUT_FILE="$SCRIPT_DIR/project_code_summary.txt"
SCRIPT_NAME=$(basename "$0")

# Reset output file
> "$OUTPUT_FILE"

echo "Scanning project directory: $PROJECT_ROOT"
echo "Summary output will be in: $RELATIVE_ROOT/scripts/global/$(basename "$OUTPUT_FILE")"
echo

# Initialize counter
counter=1

cd "$PROJECT_ROOT"
find . -type f ! -path "*/.git/*" | while read -r file; do
  # Skip this script and the output file itself
  [[ "$file" == *"$SCRIPT_NAME" ]] && continue
  [[ "$file" == "./scripts/global/$(basename "$OUTPUT_FILE")" ]] && continue

  # Skip git-ignored files
  if git check-ignore -q "$file"; then
    continue
  fi

  REL_PATH="${file#./}"

  {
    echo "----------------------------------------------"
    echo "$counter.  $REL_PATH"
    echo "----------------------------------------------"
    echo ""

    if [ -s "$file" ]; then
      cat "$file"
    else
      echo "[EMPTY FILE]"
    fi

    echo -e "\n"
  } >> "$OUTPUT_FILE"

  ((counter++))
done

echo "Project summary written to: $RELATIVE_ROOT/scripts/global/$(basename "$OUTPUT_FILE")"
