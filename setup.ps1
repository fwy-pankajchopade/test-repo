# setup.ps1 — One-time setup for Level 4 Bug Fix Workflow on Windows
# Run from PowerShell: .\setup.ps1

Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   ⚡ Level 4 Workflow Setup (Windows)    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Ensure required directories exist
New-Item -ItemType Directory -Force -Path "context" | Out-Null
New-Item -ItemType Directory -Force -Path "outputs" | Out-Null
New-Item -ItemType Directory -Force -Path "tickets" | Out-Null
Write-Host "✅ Directories ensured: context/ outputs/ tickets/" -ForegroundColor Green

# Step 2: Get current workflow directory
$WorkflowDir = (Get-Location).Path

# Step 3: Add PowerShell functions to profile (idempotent)
$ProfilePath = $PROFILE.CurrentUserAllHosts
$Marker = "# Level 4 Bug Fix Workflow"

# Create profile if it doesn't exist
if (-not (Test-Path $ProfilePath)) {
    New-Item -ItemType File -Force -Path $ProfilePath | Out-Null
    Write-Host "✅ Created PowerShell profile: $ProfilePath" -ForegroundColor Green
}

$ProfileContent = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue

if ($ProfileContent -and $ProfileContent.Contains($Marker)) {
    Write-Host "✅ Functions already present in PowerShell profile (skipping)" -ForegroundColor Green
} else {
    $FunctionsBlock = @"

$Marker
function bugfix {
    param([string]`$TicketId, [string]`$FileName)
    bash "$WorkflowDir/scripts/run-bug.sh" `$TicketId `$FileName
}
function featfix {
    param([string]`$TicketId, [string]`$ServiceName)
    bash "$WorkflowDir/scripts/run-feature.sh" `$TicketId `$ServiceName
}
function reviewfix {
    param([string]`$TicketId)
    bash "$WorkflowDir/scripts/run-review.sh" `$TicketId
}
function postmerge {
    param([string]`$TicketId)
    bash "$WorkflowDir/scripts/post-merge.sh" `$TicketId
}
"@
    Add-Content -Path $ProfilePath -Value $FunctionsBlock
    Write-Host "✅ Functions added to PowerShell profile: $ProfilePath" -ForegroundColor Green
}

# Step 4: Dependency check
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🔍 Dependency Check" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# Check bash (Git Bash / WSL)
if (Get-Command bash -ErrorAction SilentlyContinue) {
    Write-Host "✅ bash found: $(bash --version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
} else {
    Write-Host "❌ bash not found. Install Git for Windows: https://git-scm.com/download/win" -ForegroundColor Red
}

# Check gh CLI
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "✅ gh CLI found: $(gh --version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
    # Check copilot extension
    $extensions = gh extension list 2>&1
    if ($extensions -match "copilot") {
        Write-Host "✅ gh copilot extension installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  gh copilot extension not found." -ForegroundColor Yellow
        Write-Host "    Run: gh extension install github/gh-copilot" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ gh CLI not found. Install: https://cli.github.com" -ForegroundColor Red
}

# Check IntelliJ idea command
if (Get-Command idea -ErrorAction SilentlyContinue) {
    Write-Host "✅ IntelliJ 'idea' command found" -ForegroundColor Green
} else {
    Write-Host "⚠️  IntelliJ 'idea' command not in PATH." -ForegroundColor Yellow
    Write-Host "    In IntelliJ: Tools → Create Command-line Launcher" -ForegroundColor Yellow
}

# Step 5: Done
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   ✅ Setup Complete!                     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  IMPORTANT: Reload your PowerShell profile:" -ForegroundColor Yellow
Write-Host "  . `$PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "  Then use these commands:" -ForegroundColor Yellow
Write-Host "  bugfix   BUG-123 PaymentService.java" -ForegroundColor White
Write-Host "  featfix  FEAT-456 payment-service" -ForegroundColor White
Write-Host "  reviewfix BUG-123" -ForegroundColor White
Write-Host "  postmerge BUG-123" -ForegroundColor White
Write-Host ""
