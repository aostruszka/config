#!/usr/bin/env bash

# --- Configuration ---
DOTFILES_DIR="$HOME/.dotfiles"

# Associative array to map source file (relative to DOTFILES_DIR)
# to its target link path (absolute path, usually in $HOME).
declare -A LINK_MAP=(
    ["gitignore"]="$HOME/.gitignore"
    ["gitconfig"]="$HOME/.gitconfig"
    ["gitk"]="$HOME/.gitk"
    ["zshrc"]="$HOME/.zshrc"
    ["zprofile"]="$HOME/.zprofile"
    ["zshenv"]="$HOME/.zshenv"
    ["vimfiles"]="$HOME/.config/nvim"
    ["tmux.conf"]="$HOME/.tmux.conf"
    ["tmux-theme.conf"]="$HOME/.tmux-theme.conf"
)

# Color variables for TTY output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Functions ---

# Function to check the status of a potential symlink
# This function now echoes the status message to stdout,
# and returns the status code (0=OK, 1=MISMATCH, 2=COLLISION, 3=MISSING).
check_status() {
    local target="$1"
    local source_file="$2"
    local status_message

    if [[ -L "$target" ]]; then
        # Check if the existing symlink points to the correct source file
        if [[ "$(readlink "$target")" == "$source_file" ]]; then
            status_message="${GREEN}OK${NC}: Correct link exists"
            echo -e "$status_message"
            return 0 # Correctly linked
        else
            status_message="${YELLOW}MISMATCH${NC}: Existing link points to a different location: $(readlink "$target")"
            echo -e "$status_message"
            return 1 # Exists, but points elsewhere
        fi
    elif [[ -f "$target" || -d "$target" ]]; then
        status_message="${RED}COLLISION${NC}: Existing file or directory found (not a link)"
        echo -e "$status_message"
        return 2 # Collision (real file/directory)
    else
        status_message="${YELLOW}MISSING${NC}: Link does not exist"
        echo -e "$status_message"
        return 3 # Missing
    fi
}

# Function to create a symlink
create_symlink() {
    local target="$1"
    local source_file="$2"
    local collision_type="$3"
    local target_dir
    local backup_name
    local response

    # Ensure the target directory exists
    target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        echo -e "    ${YELLOW}Creating target directory: $target_dir${NC}"
        mkdir -p "$target_dir"
    fi

    if [[ "$collision_type" == "COLLISION" ]]; then
        echo -e "    ${RED}A file/directory already exists at $target.${NC}"
        read -r -p "    Do you want to backup the existing file and create the new link? (y/N): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            # Backup the existing file/directory
            backup_name="$target.bak.$(date +%Y%m%d%H%M%S)"
            mv "$target" "$backup_name"
            echo -e "    ${YELLOW}Existing file backed up to: $backup_name${NC}"
        else
            echo -e "    ${RED}Skipping link creation for $target.${NC}"
            return 1
        fi
    elif [[ "$collision_type" == "MISMATCH" ]]; then
        echo -e "    ${YELLOW}Existing link found (mismatch).${NC}"
        read -r -p "    Do you want to remove the existing link and create the new one? (y/N): " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm "$target"
            echo -e "    ${YELLOW}Existing link removed.${NC}"
        else
            echo -e "    ${RED}Skipping link creation for $target.${NC}"
            return 1
        fi
    fi

    # Create the link
    if ln -s "$source_file" "$target"; then
        echo -e "    ${GREEN}SUCCESS${NC}: Link created: $target -> $source_file"
        return 0
    else
        echo -e "    ${RED}ERROR${NC}: Failed to create link for $target."
        return 1
    fi
}

# --- Main Logic ---

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "${RED}Error:${NC} Dotfiles directory not found at $DOTFILES_DIR. Please update the DOTFILES_DIR variable."
    exit 1
fi

echo -e "\n--- Dotfile Symlink Manager ---"
echo "Source Dotfiles Directory: $DOTFILES_DIR"
echo "-------------------------------"

declare -a missing_links # Array to hold indices of links needing action

index=1
# Print status of all links and populate missing_links array
for source_path in "${!LINK_MAP[@]}"; do
    target_path="${LINK_MAP[$source_path]}"
    full_source="$DOTFILES_DIR/$source_path"

    # Check if source file exists before proceeding
    if [[ ! -e "$full_source" ]]; then
        echo -e "[$index] ${RED}SOURCE MISSING${NC}: $full_source (Skipped)"
        index=$((index+1))
        continue
    fi

    # Capture the output message and the exit status separately
    status_message=$(check_status "$target_path" "$full_source")
    status_code=$?
    
    # Print status
    printf "[%s] %s -> %s\n" "$index" "$target_path" "$status_message"

    # If status is NOT 'OK', add to the list for interactive creation
    if [[ $status_code -ne 0 ]]; then
        # Note: We include status_message with colors in the array for later display
        missing_links+=("$index:$target_path:$full_source:$status_message")
    fi

    index=$((index+1))
done

# Check if there are any links to create/fix
if [[ ${#missing_links[@]} -eq 0 ]]; then
    echo -e "\n${GREEN}All configured symlinks are correctly in place!${NC}"
    exit 0
fi

echo -e "\n--- Interactive Link Creation ---"

while true; do
    echo -e "\n-------------------------------------------------------------"
    echo "The following links need action (MISSING, MISMATCH, or COLLISION):"
    
    # Display the list of links that need action
    i=1
    declare -a current_selection_map=()
    for item in "${missing_links[@]}"; do
        IFS=':' read -r idx target_path full_source status_msg <<< "$item"
        # Extract just the short status (e.g., MISSING) for cleaner display
        raw_status_msg=$(echo "$status_msg" | sed 's/\x1b\[[0-9;]*m//g')
        display_status="${raw_status_msg%%:*}"
        printf "%s) %s (%s)\n" "$i" "$(basename "$target_path")" "$display_status"
        current_selection_map+=("$item")
        i=$((i+1))
    done

    # Single prompt now handles quit, all, or specific numbers
    read -r -p "Enter number(s) (e.g., 1 3), 'a' for all, or 'q' to quit: " selection

    if [[ "$selection" == "q" ]]; then
        echo "Exiting manager. Done."
        break
    elif [[ "$selection" == "a" ]]; then
        selection=$(seq 1 ${#current_selection_map[@]} | tr '\n' ' ')
    elif [[ -z "$selection" ]]; then
        echo "No selection made. Please choose a number, 'a', or 'q'."
        continue
    fi

    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le ${#current_selection_map[@]} ]]; then
            item="${current_selection_map[num-1]}"
            IFS=':' read -r idx target_path full_source status_msg <<< "$item"

            echo -e "\nAttempting to create/fix link for: $(basename "$target_path")"

            # Determine collision type based on the status message (stripped of colors)
            raw_status_msg=$(echo "$status_msg" | sed 's/\x1b\[[0-9;]*m//g')

            collision_type=""
            if [[ "$raw_status_msg" =~ COLLISION ]]; then
                collision_type="COLLISION"
            elif [[ "$raw_status_msg" =~ MISMATCH ]]; then
                collision_type="MISMATCH"
            fi

            if create_symlink "$target_path" "$full_source" "$collision_type"; then
                # Remove the successfully created/fixed link from the array
                # Find index of the item in the original missing_links array
                for k in "${!missing_links[@]}"; do
                    if [[ "${missing_links[k]}" == "$item" ]]; then
                        unset 'missing_links[k]'
                        break
                    fi
                done
                # Re-index the array
                missing_links=("${missing_links[@]}")
            fi
        else
            echo -e "${RED}Invalid selection number: $num${NC}"
        fi
    done

    # Check if all links have been handled
    if [[ ${#missing_links[@]} -eq 0 ]]; then
        echo -e "\n${GREEN}All links processed successfully! Exiting.${NC}"
        break
    fi
done

echo "-------------------------------------------------------------"
