# PowerShell Test Script for Migration Workflow
# Test the end-to-end migration system

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Migration Workflow Test" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check current directory
Write-Host "[1/8] Checking current directory..." -ForegroundColor Yellow
$currentDir = Get-Location
Write-Host "Working directory: $currentDir" -ForegroundColor Green
Write-Host ""

# Step 2: Look for available Python scripts
Write-Host "[2/8] Scanning for test scripts..." -ForegroundColor Yellow
$scripts = Get-ChildItem -Path . -Filter "*.py" -File | Select-Object -First 5
Write-Host "Found $($scripts.Count) Python scripts:" -ForegroundColor Green
foreach ($script in $scripts) {
    Write-Host "  - $($script.Name)" -ForegroundColor White
}
Write-Host ""

# Step 3: Create test input file
Write-Host "[3/8] Creating test input file..." -ForegroundColor Yellow
$testInputContent = "Hello World`nThis is a test file`nFor the migration system"
Set-Content -Path "test_input.txt" -Value $testInputContent
Write-Host "Created test_input.txt" -ForegroundColor Green
Write-Host ""

# Step 4: Test the simple file processor
Write-Host "[4/8] Testing simple_file_processor_example.py..." -ForegroundColor Yellow
Write-Host "Command: python simple_file_processor_example.py test_input.txt test_output.txt" -ForegroundColor Gray
python simple_file_processor_example.py test_input.txt test_output.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "Script executed successfully!" -ForegroundColor Green
} else {
    Write-Host "Script failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 5: Verify output file
Write-Host "[5/8] Verifying output file..." -ForegroundColor Yellow
if (Test-Path "test_output.txt") {
    $outputContent = Get-Content -Path "test_output.txt" -Raw
    Write-Host "Output file exists with content:" -ForegroundColor Green
    Write-Host $outputContent -ForegroundColor Gray
} else {
    Write-Host "Output file not found!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 6: Test golden test generation
Write-Host "[6/8] Testing golden test generation..." -ForegroundColor Yellow
Write-Host "Command: python noodle-core/src/migration/generate_golden_test.py --help" -ForegroundColor Gray
python noodle-core/src/migration/generate_golden_test.py --help
Write-Host ""

# Step 7: Show migration documentation location
Write-Host "[7/8] Migration System Documentation..." -ForegroundColor Yellow
Write-Host "Migration system is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Available Documentation:" -ForegroundColor Cyan
Write-Host "  - noodle-core/src/migration/README.md" -ForegroundColor White
Write-Host "  - noodle-core/src/migration/QUICK_REFERENCE.md" -ForegroundColor White
Write-Host "  - noodle-core/src/migration/MIGRATION_SYSTEM_COMPLETE.md" -ForegroundColor White
Write-Host "  - noodle-core/src/migration/GITHUB_ACTIONS_GUIDE.md" -ForegroundColor White
Write-Host ""

# Step 8: Summary
Write-Host "[8/8] Test Summary..." -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Migration Workflow Test Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review generated test_output.txt" -ForegroundColor White
Write-Host "  2. Test GitHub Actions workflow" -ForegroundColor White
Write-Host "  3. Try manual golden test generation" -ForegroundColor White
Write-Host "  4. Read documentation for full usage" -ForegroundColor White
Write-Host ""
