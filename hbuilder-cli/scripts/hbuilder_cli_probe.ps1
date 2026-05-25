param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$SkipHelp
)

$ErrorActionPreference = "Stop"

function Test-UniAppProject {
    param([string]$Path)

    $manifestRoot = Join-Path $Path "manifest.json"
    $pagesRoot = Join-Path $Path "pages.json"
    $manifestSrc = Join-Path $Path "src\manifest.json"
    $pagesSrc = Join-Path $Path "src\pages.json"
    $uniModules = Join-Path $Path "uni_modules"
    $packageJson = Join-Path $Path "package.json"

    [ordered]@{
        path = $Path
        manifestJson = (Test-Path -LiteralPath $manifestRoot)
        pagesJson = (Test-Path -LiteralPath $pagesRoot)
        srcManifestJson = (Test-Path -LiteralPath $manifestSrc)
        srcPagesJson = (Test-Path -LiteralPath $pagesSrc)
        uniModules = (Test-Path -LiteralPath $uniModules)
        packageJson = (Test-Path -LiteralPath $packageJson)
        looksLikeUniApp = ((Test-Path -LiteralPath $manifestRoot) -and (Test-Path -LiteralPath $pagesRoot)) -or ((Test-Path -LiteralPath $manifestSrc) -and (Test-Path -LiteralPath $pagesSrc))
    }
}

function Remove-AnsiCodes {
    param([string]$Text)

    if ($null -eq $Text) {
        return $null
    }

    $Text -replace "$([char]27)\[[0-9;]*m", ""
}

$knownPaths = @(
    "D:\hbuilder\cli.exe",
    "D:\HBuilderX\cli.exe",
    "C:\HBuilderX\cli.exe",
    "C:\Program Files\HBuilderX\cli.exe",
    "C:\Program Files (x86)\HBuilderX\cli.exe",
    (Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) "Programs\HBuilderX\cli.exe")
)

$existingPath = $knownPaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
$versionOutput = $null
$helpStatus = "not-run"
$helpFirstLine = $null
$errorMessage = $null

if ($existingPath) {
    try {
        $versionOutput = Remove-AnsiCodes ((& $existingPath "version" 2>&1) -join "`n")
        if (-not $SkipHelp) {
            $helpOutput = Remove-AnsiCodes ((& $existingPath "--help" 2>&1) -join "`n")
            $helpStatus = "ok"
            $helpFirstLine = ($helpOutput -split "`r?`n" | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First 1)
        }
    }
    catch {
        $helpStatus = "error"
        $errorMessage = $_.Exception.Message
    }
}
else {
    $errorMessage = "HBuilderX CLI was not found in common install locations."
}

[ordered]@{
    found = [bool]$existingPath
    path = $existingPath
    searchedPaths = $knownPaths
    version = $versionOutput
    helpStatus = $helpStatus
    helpFirstLine = $helpFirstLine
    error = $errorMessage
    project = (Test-UniAppProject -Path (Resolve-Path -LiteralPath $ProjectPath).Path)
} | ConvertTo-Json -Depth 4
