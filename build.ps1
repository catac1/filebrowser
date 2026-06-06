param(
    [string]$DeployPath = "G:\util\windows-amd64-filebrowser\filebrowser.exe",
    [switch]$Deploy
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$FrontendDir = Join-Path $RepoRoot "frontend"
$OutputExe = Join-Path $RepoRoot "filebrowser.exe"

Write-Host "Building frontend..."
Push-Location $FrontendDir
try {
    pnpm install
    pnpm run build
}
finally {
    Pop-Location
}

Write-Host "Building backend..."
Push-Location $RepoRoot
try {
    go build -o $OutputExe .
}
finally {
    Pop-Location
}

if ($Deploy) {
    Write-Host "Deploying to $DeployPath..."
    Copy-Item $OutputExe $DeployPath -Force
}

Write-Host "Build complete."
if ($Deploy) {
    Write-Host "Restart File Browser after replacing the executable."
}
