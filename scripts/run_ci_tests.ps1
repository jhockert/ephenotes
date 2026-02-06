# CI Test Runner Script (PowerShell)
# Runs all test suites with proper reporting and error handling

$ErrorActionPreference = "Stop"

# Test counters
$script:TotalSuites = 0
$script:PassedSuites = 0
$script:FailedSuites = 0

# Function to print colored output
function Write-Status {
    param(
        [string]$Color,
        [string]$Message
    )
    
    $colorMap = @{
        'Red' = 'Red'
        'Green' = 'Green'
        'Yellow' = 'Yellow'
        'Blue' = 'Cyan'
    }
    
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

# Function to run a test suite
function Invoke-TestSuite {
    param(
        [string]$SuiteName,
        [string]$TestPath
    )
    
    $script:TotalSuites++
    
    Write-Status 'Blue' "`n=========================================="
    Write-Status 'Blue' "Running: $SuiteName"
    Write-Status 'Blue' "Path: $TestPath"
    Write-Status 'Blue' "==========================================`n"
    
    try {
        flutter test $TestPath --reporter expanded
        if ($LASTEXITCODE -eq 0) {
            Write-Status 'Green' "✅ $SuiteName`: PASSED"
            $script:PassedSuites++
            return $true
        } else {
            Write-Status 'Red' "❌ $SuiteName`: FAILED"
            $script:FailedSuites++
            return $false
        }
    } catch {
        Write-Status 'Red' "❌ $SuiteName`: FAILED"
        $script:FailedSuites++
        return $false
    }
}

# Main execution
function Main {
    Write-Status 'Blue' "╔════════════════════════════════════════╗"
    Write-Status 'Blue' "║   ephenotes CI Test Suite Runner      ║"
    Write-Status 'Blue' "╚════════════════════════════════════════╝"
    
    # Check Flutter installation
    Write-Status 'Yellow' "`n📋 Checking Flutter installation..."
    flutter --version
    
    # Install dependencies
    Write-Status 'Yellow' "`n📦 Installing dependencies..."
    flutter pub get
    
    # Run code analysis
    Write-Status 'Yellow' "`n🔍 Running code analysis..."
    flutter analyze --no-fatal-infos
    if ($LASTEXITCODE -eq 0) {
        Write-Status 'Green' "✅ Code analysis: PASSED"
    } else {
        Write-Status 'Red' "❌ Code analysis: FAILED"
        exit 1
    }
    
    # Check code formatting
    Write-Status 'Yellow' "`n📝 Checking code formatting..."
    dart format --set-exit-if-changed .
    if ($LASTEXITCODE -eq 0) {
        Write-Status 'Green' "✅ Code formatting: PASSED"
    } else {
        Write-Status 'Red' "❌ Code formatting: FAILED"
        Write-Status 'Yellow' "Run 'dart format .' to fix formatting issues"
        exit 1
    }
    
    # Run test suites
    Write-Status 'Yellow' "`n🧪 Running test suites...`n"
    
    # Track overall success
    $allPassed = $true
    
    # Unit tests
    if (-not (Invoke-TestSuite "Unit Tests" "test/unit/")) {
        $allPassed = $false
    }
    
    # Widget tests
    if (-not (Invoke-TestSuite "Widget Tests" "test/widget/")) {
        $allPassed = $false
    }
    
    # Property-based tests
    Write-Status 'Yellow' "`n⚠️  Property-based tests may take longer (100+ iterations per property)..."
    if (-not (Invoke-TestSuite "Property-Based Tests" "test/property/")) {
        $allPassed = $false
    }
    
    # Integration tests
    if (-not (Invoke-TestSuite "Integration Tests" "test/integration/")) {
        $allPassed = $false
    }
    
    # Accessibility tests
    if (-not (Invoke-TestSuite "Accessibility Tests" "test/accessibility/")) {
        $allPassed = $false
    }
    
    # Performance tests
    if (-not (Invoke-TestSuite "Performance Tests" "test/performance/")) {
        $allPassed = $false
    }
    
    # Generate coverage report
    Write-Status 'Yellow' "`n📊 Generating coverage report..."
    flutter test --coverage --reporter expanded
    
    # Check if lcov is available (typically not on Windows)
    $lcovAvailable = Get-Command lcov -ErrorAction SilentlyContinue
    if ($lcovAvailable) {
        Write-Status 'Yellow' "`n📈 Coverage summary:"
        lcov --summary coverage/lcov.info 2>&1 | Select-String -Pattern "lines|functions"
        
        # Extract coverage percentage
        $coverageOutput = lcov --summary coverage/lcov.info 2>&1 | Select-String -Pattern "lines"
        if ($coverageOutput) {
            $coverage = [regex]::Match($coverageOutput, '(\d+\.\d+)%').Groups[1].Value
            
            if ([double]$coverage -lt 60) {
                Write-Status 'Red' "❌ Coverage is below 60% threshold: $coverage%"
                $allPassed = $false
            } else {
                Write-Status 'Green' "✅ Coverage meets 60% threshold: $coverage%"
            }
        }
    } else {
        Write-Status 'Yellow' "⚠️  lcov not installed, skipping coverage threshold check"
        Write-Status 'Yellow' "Coverage report saved to: coverage/lcov.info"
    }
    
    # Print summary
    Write-Status 'Blue' "`n╔════════════════════════════════════════╗"
    Write-Status 'Blue' "║          Test Summary                  ║"
    Write-Status 'Blue' "╚════════════════════════════════════════╝"
    
    Write-Status 'Blue' "`nTotal Test Suites: $script:TotalSuites"
    Write-Status 'Green' "Passed: $script:PassedSuites"
    
    if ($script:FailedSuites -gt 0) {
        Write-Status 'Red' "Failed: $script:FailedSuites"
    }
    
    if ($allPassed) {
        Write-Status 'Green' "`n🎉 All tests passed! Ready for deployment."
        exit 0
    } else {
        Write-Status 'Red' "`n❌ Some tests failed. Please fix the issues before deploying."
        exit 1
    }
}

# Run main function
Main
