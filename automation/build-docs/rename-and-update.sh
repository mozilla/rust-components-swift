#!/bin/bash

# Set locale to UTF-8 to avoid illegal byte sequence errors
export LC_CTYPE=C
export LANG=C

STATIC_FILES_FOLDER_PATH="./docs-website"

# Find all files with colons in their names, rename them, and update references
find $STATIC_FILES_FOLDER_PATH -depth -name '*:*' \
| while IFS= read -r file; do
    # Generate the new name by replacing colons with underscores
    new_name="$(dirname "$file")/$(basename "$file" | tr ':' '_')"
    
    # Rename the file
    mv "$file" "$new_name"

    # Escape slashes and special characters for sed
    escaped_file=$(printf '%s\n' "$(basename "$file")" | sed 's/[][\\/.^$*]/\\&/g')
    escaped_new_name=$(printf '%s\n' "$(basename "$new_name")" | sed 's/[][\\/.^$*]/\\&/g')
    
    # Update only the specific references to the renamed file within the documentation
    grep -rl "$escaped_file" $STATIC_FILES_FOLDER_PATH \
    | xargs sed -i '' "s/$escaped_file/$escaped_new_name/g"
done
