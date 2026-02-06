#!/bin/bash

# CI Test Runner Script
# Runs all test suites with proper reporting and error handling

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to run a test suite
run_test_suite() {
    local suite_name=$1
    local test_path=$2
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    print_status "$BLUE" "\n=========================================="
    print_status "$BLUE" "Running: $suite_name"
    print_status "$BLUE" "Path: $test_path"
    print_status "$BLUE" "==========================================\n"
    
    if flutter test "$test_path" --reporter expanded; then
        print_status "$GREEN" "✅ $suite_name: PASSED"
        PASSED_SUITES=$((PASSED_SUITES + 1))
        return 0
    else
        print_status "$RED" "❌ $suite_name: FAILED"
        FAILED_SUITES=$((FAILED_SUITES + 1))
        return 1
    fi
}

# Main execution
main() {
    print_status "$BLUE" "╔════════════════════════════════════════╗"
    print_status "$BLUE" "║   ephenotes CI Test Suite Runner      ║"
    print_status "$BLUE" "╚════════════════════════════════════════╝"
    
    # Check Flutter installation
    print_status "$YELLOW" "\n📋 Checking Flutter installation..."
    flutter --version
    
    # Install dependencies
    print_status "$YELLOW" "\n📦 Installing dependencies..."
    flutter pub get
    
    # Run code analysis
    print_status "$YELLOW" "\n🔍 Running code analysis..."
    if flutter analyze --no-fatal-infos; then
        print_status "$GREEN" "✅ Code analysis: PASSED"
    else
        print_status "$RED" "❌ Code analysis: FAILED"
        exit 1
    fi
    
    # Check code formatting
    print_status "$YELLOW" "\n📝 Checking code formatting..."
    if dart format --set-exit-if-changed .; then
        print_status "$GREEN" "✅ Code formatting: PASSED"
    else
        print_status "$RED" "❌ Code formatting: FAILED"
        print_status "$YELLOW" "Run 'dart format .' to fix formatting issues"
        exit 1
    fi
    
    # Run test suites
    print_status "$YELLOW" "\n🧪 Running test suites...\n"
    
    # Track overall success
    ALL_PASSED=true
    
    # Unit tests
    if ! run_test_suite "Unit Tests" "test/unit/"; then
        ALL_PASSED=false
    fi
    
    # Widget tests
    if ! run_test_suite "Widget Tests" "test/widget/"; then
        ALL_PASSED=false
    fi
    
    # Property-based tests
    print_status "$YELLOW" "\n⚠️  Property-based tests may take longer (100+ iterations per property)..."
    if ! run_test_suite "Property-Based Tests" "test/property/"; then
        ALL_PASSED=false
    fi
    
    # Integration tests
    if ! run_test_suite "Integration Tests" "test/integration/"; then
        ALL_PASSED=false
    fi
    
    # Accessibility tests
    if ! run_test_suite "Accessibility Tests" "test/accessibility/"; then
        ALL_PASSED=false
    fi
    
    # Performance tests
    if ! run_test_suite "Performance Tests" "test/performance/"; then
        ALL_PASSED=false
    fi
    
    # Generate coverage report
    print_status "$YELLOW" "\n📊 Generating coverage report..."
    flutter test --coverage --reporter expanded
    
    if command -v lcov &> /dev/null; then
        print_status "$YELLOW" "\n📈 Coverage summary:"
        lcov --summary coverage/lcov.info 2>&1 | grep -E "lines|functions"
        
        # Extract coverage percentage
        COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | cut -d'%' -f1)
        
        if (( $(echo "$COVERAGE < 60" | bc -l) )); then
            print_status "$RED" "❌ Coverage is below 60% threshold: $COVERAGE%"
            ALL_PASSED=false
        else
            print_status "$GREEN" "✅ Coverage meets 60% threshold: $COVERAGE%"
        fi
    else
        print_status "$YELLOW" "⚠️  lcov not installed, skipping coverage threshold check"
    fi
    
    # Print summary
    print_status "$BLUE" "\n╔════════════════════════════════════════╗"
    print_status "$BLUE" "║          Test Summary                  ║"
    print_status "$BLUE" "╚════════════════════════════════════════╝"
    
    print_status "$BLUE" "\nTotal Test Suites: $TOTAL_SUITES"
    print_status "$GREEN" "Passed: $PASSED_SUITES"
    
    if [ $FAILED_SUITES -gt 0 ]; then
        print_status "$RED" "Failed: $FAILED_SUITES"
    fi
    
    if [ "$ALL_PASSED" = true ]; then
        print_status "$GREEN" "\n🎉 All tests passed! Ready for deployment."
        exit 0
    else
        print_status "$RED" "\n❌ Some tests failed. Please fix the issues before deploying."
        exit 1
    fi
}

# Run main function
main
