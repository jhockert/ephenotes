#!/bin/bash
# Release Notes Generator for ephenotes
# Generates formatted release notes from git commits

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to categorize commits
categorize_commit() {
    local commit_msg=$1
    
    # Check commit message prefix
    if [[ $commit_msg =~ ^feat(\(.*\))?:\ .* ]]; then
        echo "features"
    elif [[ $commit_msg =~ ^fix(\(.*\))?:\ .* ]]; then
        echo "fixes"
    elif [[ $commit_msg =~ ^perf(\(.*\))?:\ .* ]]; then
        echo "performance"
    elif [[ $commit_msg =~ ^docs(\(.*\))?:\ .* ]]; then
        echo "documentation"
    elif [[ $commit_msg =~ ^style(\(.*\))?:\ .* ]]; then
        echo "style"
    elif [[ $commit_msg =~ ^refactor(\(.*\))?:\ .* ]]; then
        echo "refactor"
    elif [[ $commit_msg =~ ^test(\(.*\))?:\ .* ]]; then
        echo "tests"
    elif [[ $commit_msg =~ ^chore(\(.*\))?:\ .* ]]; then
        echo "chores"
    else
        echo "other"
    fi
}

# Function to clean commit message
clean_commit_message() {
    local msg=$1
    
    # Remove conventional commit prefix
    msg=$(echo "$msg" | sed -E 's/^(feat|fix|perf|docs|style|refactor|test|chore)(\(.*\))?:\ //')
    
    # Capitalize first letter
    msg="$(echo "${msg:0:1}" | tr '[:lower:]' '[:upper:]')${msg:1}"
    
    echo "$msg"
}

# Function to generate release notes
generate_release_notes() {
    local from_tag=$1
    local to_tag=${2:-HEAD}
    local output_file=${3:-}
    
    print_info "Generating release notes from $from_tag to $to_tag..."
    
    # Initialize arrays for different categories
    declare -A categories
    categories[features]=""
    categories[fixes]=""
    categories[performance]=""
    categories[documentation]=""
    categories[style]=""
    categories[refactor]=""
    categories[tests]=""
    categories[chores]=""
    categories[other]=""
    
    # Get commits
    while IFS= read -r commit; do
        local category=$(categorize_commit "$commit")
        local clean_msg=$(clean_commit_message "$commit")
        
        if [ -n "${categories[$category]}" ]; then
            categories[$category]="${categories[$category]}\n- $clean_msg"
        else
            categories[$category]="- $clean_msg"
        fi
    done < <(git log "$from_tag..$to_tag" --pretty=format:"%s" --no-merges)
    
    # Build release notes
    local notes=""
    
    # Add version header
    local version=$(echo "$to_tag" | sed 's/^v//')
    if [ "$to_tag" = "HEAD" ]; then
        version="Unreleased"
    fi
    
    notes+="# Release Notes - Version $version\n\n"
    notes+="**Release Date:** $(date +%Y-%m-%d)\n\n"
    
    # Add features
    if [ -n "${categories[features]}" ]; then
        notes+="## ✨ New Features\n\n"
        notes+="${categories[features]}\n\n"
    fi
    
    # Add fixes
    if [ -n "${categories[fixes]}" ]; then
        notes+="## 🐛 Bug Fixes\n\n"
        notes+="${categories[fixes]}\n\n"
    fi
    
    # Add performance improvements
    if [ -n "${categories[performance]}" ]; then
        notes+="## ⚡ Performance Improvements\n\n"
        notes+="${categories[performance]}\n\n"
    fi
    
    # Add refactoring
    if [ -n "${categories[refactor]}" ]; then
        notes+="## ♻️ Code Refactoring\n\n"
        notes+="${categories[refactor]}\n\n"
    fi
    
    # Add documentation
    if [ -n "${categories[documentation]}" ]; then
        notes+="## 📚 Documentation\n\n"
        notes+="${categories[documentation]}\n\n"
    fi
    
    # Add tests
    if [ -n "${categories[tests]}" ]; then
        notes+="## 🧪 Tests\n\n"
        notes+="${categories[tests]}\n\n"
    fi
    
    # Add other changes
    if [ -n "${categories[other]}" ]; then
        notes+="## 🔧 Other Changes\n\n"
        notes+="${categories[other]}\n\n"
    fi
    
    # Add footer
    notes+="---\n\n"
    notes+="**Full Changelog:** https://github.com/yourusername/ephenotes/compare/$from_tag...$to_tag\n"
    
    # Output notes
    if [ -n "$output_file" ]; then
        echo -e "$notes" > "$output_file"
        print_success "Release notes saved to $output_file"
    else
        echo -e "$notes"
    fi
}

# Function to generate store-specific release notes
generate_store_notes() {
    local from_tag=$1
    local to_tag=${2:-HEAD}
    local store=${3:-both}
    
    print_info "Generating $store store release notes..."
    
    # Get key changes (features and fixes only)
    local features=$(git log "$from_tag..$to_tag" --pretty=format:"%s" --no-merges | grep -E "^feat(\(.*\))?:" | sed -E 's/^feat(\(.*\))?:\ //' || true)
    local fixes=$(git log "$from_tag..$to_tag" --pretty=format:"%s" --no-merges | grep -E "^fix(\(.*\))?:" | sed -E 's/^fix(\(.*\))?:\ //' || true)
    
    local notes=""
    
    # App Store / Play Store have character limits
    # Keep it concise and user-friendly
    
    if [ -n "$features" ]; then
        notes+="What's New:\n"
        while IFS= read -r feature; do
            # Capitalize and add bullet
            feature="$(echo "${feature:0:1}" | tr '[:lower:]' '[:upper:]')${feature:1}"
            notes+="• $feature\n"
        done <<< "$features"
        notes+="\n"
    fi
    
    if [ -n "$fixes" ]; then
        notes+="Bug Fixes:\n"
        while IFS= read -r fix; do
            # Capitalize and add bullet
            fix="$(echo "${fix:0:1}" | tr '[:lower:]' '[:upper:]')${fix:1}"
            notes+="• $fix\n"
        done <<< "$fixes"
        notes+="\n"
    fi
    
    # Add generic footer
    notes+="Thank you for using ephenotes! We're constantly working to improve your note-taking experience."
    
    # Save to appropriate file
    case $store in
        appstore|ios)
            echo -e "$notes" > "ios/AppStore/release_notes.txt"
            print_success "App Store release notes saved to ios/AppStore/release_notes.txt"
            ;;
        playstore|android)
            echo -e "$notes" > "android/PlayStore/release_notes.txt"
            print_success "Play Store release notes saved to android/PlayStore/release_notes.txt"
            ;;
        both)
            echo -e "$notes" > "ios/AppStore/release_notes.txt"
            echo -e "$notes" > "android/PlayStore/release_notes.txt"
            print_success "Release notes saved to both stores"
            ;;
    esac
    
    # Check character count
    local char_count=$(echo -e "$notes" | wc -c)
    if [ $char_count -gt 4000 ]; then
        print_error "Release notes exceed 4000 characters ($char_count). Please shorten."
    else
        print_info "Release notes: $char_count characters (max 4000)"
    fi
}

# Main script
main() {
    print_info "ephenotes Release Notes Generator"
    echo ""
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository"
        exit 1
    fi
    
    # Parse command line arguments
    case "${1:-}" in
        full)
            # Generate full release notes
            local from_tag=${2:-}
            local to_tag=${3:-HEAD}
            local output_file=${4:-RELEASE_NOTES.md}
            
            if [ -z "$from_tag" ]; then
                # Get latest tag
                from_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
                if [ -z "$from_tag" ]; then
                    print_error "No tags found. Please specify a starting tag."
                    exit 1
                fi
            fi
            
            generate_release_notes "$from_tag" "$to_tag" "$output_file"
            ;;
        store)
            # Generate store-specific release notes
            local from_tag=${2:-}
            local to_tag=${3:-HEAD}
            local store=${4:-both}
            
            if [ -z "$from_tag" ]; then
                # Get latest tag
                from_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
                if [ -z "$from_tag" ]; then
                    print_error "No tags found. Please specify a starting tag."
                    exit 1
                fi
            fi
            
            generate_store_notes "$from_tag" "$to_tag" "$store"
            ;;
        help|--help|-h)
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  full [from_tag] [to_tag] [output_file]"
            echo "      Generate full release notes (default: RELEASE_NOTES.md)"
            echo ""
            echo "  store [from_tag] [to_tag] [store]"
            echo "      Generate store-specific release notes"
            echo "      store: appstore, playstore, or both (default: both)"
            echo ""
            echo "  help"
            echo "      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 full v1.0.0 v1.1.0"
            echo "      Generate release notes from v1.0.0 to v1.1.0"
            echo ""
            echo "  $0 store v1.0.0 HEAD both"
            echo "      Generate store release notes for both stores"
            echo ""
            echo "  $0 store v1.0.0 v1.1.0 appstore"
            echo "      Generate App Store release notes only"
            exit 0
            ;;
        *)
            print_error "Invalid command: ${1:-}"
            print_info "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
