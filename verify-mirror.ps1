# Mirror Sync Verification Tool
# Compares latest commit on 'main' between origin and mirror repos.

$ErrorActionPreference = "Stop"

$OriginUrl = "https://github.com/Adnanshahria/Facebook-Font-Formatter.git"
$MirrorUrl = "https://github.com/as-personal-projects/SocialFont.git"
$Branch    = "main"

function Get-RemoteHead {
    param([string]$RepoUrl, [string]$BranchName)
    try {
        $output = git ls-remote $RepoUrl "refs/heads/$BranchName" 2>&1
        if ($LASTEXITCODE -ne 0) { return $null }
        $sha = ($output -split "\s+")[0]
        return $sha
    } catch {
        return $null
    }
}

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "          Mirror Sync Verification Tool                " -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Fetching latest commit from ORIGIN ($Branch)..." -ForegroundColor Yellow
$originSha = Get-RemoteHead -RepoUrl $OriginUrl -BranchName $Branch

Write-Host "[2/2] Fetching latest commit from MIRROR ($Branch)..." -ForegroundColor Yellow
$mirrorSha = Get-RemoteHead -RepoUrl $MirrorUrl -BranchName $Branch

Write-Host ""
Write-Host "------------------------------------------------------" -ForegroundColor DarkGray

Write-Host -NoNewline "  Origin  (Facebook-Font-Formatter): "
if ($originSha) {
    Write-Host $originSha -ForegroundColor White
} else {
    Write-Host "UNREACHABLE or branch not found" -ForegroundColor Red
}

Write-Host -NoNewline "  Mirror  (SocialFont):              "
if ($mirrorSha) {
    Write-Host $mirrorSha -ForegroundColor White
} else {
    Write-Host "UNREACHABLE or branch not found" -ForegroundColor Red
}

Write-Host "------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

if (-not $originSha -or -not $mirrorSha) {
    Write-Host "WARNING: Could not compare -- one or both repos are unreachable." -ForegroundColor Red
    Write-Host "  Make sure both repos exist and are accessible." -ForegroundColor DarkGray
    exit 1
}

if ($originSha -eq $mirrorSha) {
    Write-Host "SYNCED -- Both repos point to the same commit on '$Branch'." -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Host "OUT OF SYNC -- The repos have different HEAD commits on '$Branch'." -ForegroundColor Red
    Write-Host "  This can happen if:" -ForegroundColor DarkGray
    Write-Host "    - The GitHub Actions mirror workflow has not run yet" -ForegroundColor DarkGray
    Write-Host "    - The workflow failed (check Actions tab on GitHub)" -ForegroundColor DarkGray
    Write-Host "    - Someone pushed directly to the mirror repo" -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}
