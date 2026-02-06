#!/bin/bash
# Version Management Script for ephenotes
# Automates version bumping across all platform files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $version"
        print_info "Expected format: X.Y.Z (e.g., 1.0.0)"
        exit 1
    fi
}

# Function to get current version from pubspec.yaml
get_current_version() {
    grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f1
}

# Function to get current build number from pubspec.yaml
get_current_build_number() {
    grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f2
}

# Function to update pubspec.yaml
update_pubspec() {
    local version=$1
    local build_number=$2
    
    print_info "Updating pubspec.yaml..."
    
    # Backup original file
    cp pubspec.yaml pubspec.yaml.bak
    
    # Update version
    sed -i.tmp "s/^version: .*/version: $version+$build_number/" pubspec.yaml
    rm -f pubspec.yaml.tmp
    
    print_success "Updated pubspec.yaml to $version+$build_number"
}

# Function to update Android version
update_android_version() {
    local version=$1
    local build_number=$2
    
    print_info "Updating Android version..."
    
    local gradle_file="android/app/build.gradle.kts"
    
    if [ ! -f "$gradle_file" ]; then
        print_warning "Android build.gradle.kts not found, skipping..."
        return
    fi
    
    # Backup original file
    cp "$gradle_file" "$gradle_file.bak"
    
    # Update versionCode and versionName
    sed -i.tmp "s/versionCode = .*/versionCode = $build_number/" "$gradle_file"
    sed -i.tmp "s/versionName = .*/versionName = \"$version\"/" "$gradle_file"
    rm -f "$gradle_file.tmp"
    
    print_success "Updated Android version to $version ($build_number)"
}

# Function to update iOS version
update_ios_version() {
    local version=$1
    local build_number=$2
    
    print_info "Updating iOS version..."
    
    local plist_file="ios/Runner/Info.plist"
    
    if [ ! -f "$plist_file" ]; then
        print_warning "iOS Info.plist not found, skipping..."
        return
    fi
    
    # Backup original file
    cp "$plist_file" "$plist_file.bak"
    
    # Update CFBundleShortVersionString and CFBundleVersion
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$plist_file" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "$plist_file" 2>/dev/null || true
    
    print_success "Updated iOS version to $version ($build_number)"
}

# Function to generate changelog
generate_changelog() {
    local version=$1
    local previous_version=$2
    
    print_info "Generating changelog..."
    
    local changelog_file="CHANGELOG.md"
    local temp_file="CHANGELOG.tmp"
    
    # Create header for new version
    echo "## [$version] - $(date +%Y-%m-%d)" > "$temp_file"
    echo "" >> "$temp_file"
    
    # Get commits since last version
    if [ -n "$previous_version" ] && git rev-parse "v$previous_version" >/dev/null 2>&1; then
        echo "### Changes" >> "$temp_file"
        git log "v$previous_version"..HEAD --pretty=format:"- %s" >> "$temp_file"
        echo "" >> "$temp_file"
    else
        echo "### Changes" >> "$temp_file"
        echo "- Initial release" >> "$temp_file"
    fi
    
    echo "" >> "$temp_file"
    
    # Prepend to existing changelog
    if [ -f "$changelog_file" ]; then
        cat "$changelog_file" >> "$temp_file"
    fi
    
    mv "$temp_file" "$changelog_file"
    
    print_success "Generated changelog for version $version"
}

# Function to create git tag
create_git_tag() {
    local version=$1
    local message=$2
    
    print_info "Creating git tag v$version..."
    
    git tag -a "v$version" -m "$message"
    
    print_success "Created git tag v$version"
    print_info "Push tag with: git push origin v$version"
}

# Function to bump version
bump_version() {
    local bump_type=$1
    local current_version=$(get_current_version)
    local current_build=$(get_current_build_number)
    
    IFS='.' read -r major minor patch <<< "$current_version"
    
    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid bump type: $bump_type"
            print_info "Valid types: major, minor, patch"
            exit 1
            ;;
    esac
    
    local new_version="$major.$minor.$patch"
    local new_build=$((current_build + 1))
    
    echo "$new_version+$new_build"
}

# Function to restore backups
restore_backups() {
    print_warning "Restoring backup files..."
    
    [ -f pubspec.yaml.bak ] && mv pubspec.yaml.bak pubspec.yaml
    [ -f android/app/build.gradle.kts.bak ] && mv android/app/build.gradle.kts.bak android/app/build.gradle.kts
    [ -f ios/Runner/Info.plist.bak ] && mv ios/Runner/Info.plist.bak ios/Runner/Info.plist
    
    print_success "Restored backup files"
}

# Function to clean backups
clean_backups() {
    rm -f pubspec.yaml.bak
    rm -f android/app/build.gradle.kts.bak
    rm -f ios/Runner/Info.plist.bak
}

# Main script
main() {
    print_info "ephenotes Version Manager"
    echo ""
    
    # Check if we're in the project root
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Please run this script from the project root."
        exit 1
    fi
    
    local current_version=$(get_current_version)
    local current_build=$(get_current_build_number)
    
    print_info "Current version: $current_version+$current_build"
    echo ""
    
    # Parse command line arguments
    case "${1:-}" in
        bump)
            # Bump version automatically
            local bump_type=${2:-patch}
            local new_version_full=$(bump_version "$bump_type")
            local new_version=$(echo "$new_version_full" | cut -d'+' -f1)
            local new_build=$(echo "$new_version_full" | cut -d'+' -f2)
            
            print_info "Bumping $bump_type version: $current_version+$current_build → $new_version+$new_build"
            ;;
        set)
            # Set specific version
            local new_version=${2:-}
            local new_build=${3:-$((current_build + 1))}
            
            if [ -z "$new_version" ]; then
                print_error "Version not specified"
                print_info "Usage: $0 set <version> [build_number]"
                exit 1
            fi
            
            validate_version "$new_version"
            
            print_info "Setting version: $new_version+$new_build"
            ;;
        current)
            # Show current version
            print_success "Current version: $current_version+$current_build"
            exit 0
            ;;
        help|--help|-h)
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  bump [major|minor|patch]  Bump version automatically (default: patch)"
            echo "  set <version> [build]     Set specific version and build number"
            echo "  current                   Show current version"
            echo "  help                      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 bump patch             Bump patch version (1.0.0 → 1.0.1)"
            echo "  $0 bump minor             Bump minor version (1.0.0 → 1.1.0)"
            echo "  $0 bump major             Bump major version (1.0.0 → 2.0.0)"
            echo "  $0 set 1.2.3 42           Set version to 1.2.3+42"
            echo "  $0 current                Show current version"
            exit 0
            ;;
        *)
            print_error "Invalid command: ${1:-}"
            print_info "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
    
    # Trap errors to restore backups
    trap restore_backups ERR
    
    # Update all version files
    update_pubspec "$new_version" "$new_build"
    update_android_version "$new_version" "$new_build"
    update_ios_version "$new_version" "$new_build"
    
    # Generate changelog
    generate_changelog "$new_version" "$current_version"
    
    # Clean backup files
    clean_backups
    
    echo ""
    print_success "Version updated successfully!"
    print_info "New version: $new_version+$new_build"
    echo ""
    print_info "Next steps:"
    echo "  1. Review changes: git diff"
    echo "  2. Commit changes: git add . && git commit -m 'Bump version to $new_version'"
    echo "  3. Create tag: git tag -a v$new_version -m 'Release version $new_version'"
    echo "  4. Push changes: git push && git push --tags"
}

# Run main function
main "$@"
