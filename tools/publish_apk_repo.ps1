param(
    [string]$ApkDir = "apk-repo\inbox",
    [string]$Repo = "muyang520/muyangcoursedescription",
    [string]$ReleaseTag = "apks-v1",
    [string]$Manifest = "apk-repo\apks.tsv",
    [string]$Aapt = "",
    [switch]$SkipUpload,
    [switch]$SkipCommit,
    [switch]$ReplaceManifest
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$apkPath = Join-Path $root $ApkDir
$manifestPath = Join-Path $root $Manifest
$script:GhPath = ""

function Find-Gh {
    $cmd = Get-Command gh -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    $candidates = @(
        "C:\Program Files\GitHub CLI\gh.exe",
        "C:\Program Files (x86)\GitHub CLI\gh.exe"
    )

    $wingetDir = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    if (Test-Path -LiteralPath $wingetDir) {
        $found = Get-ChildItem -LiteralPath $wingetDir -Recurse -Filter "gh.exe" -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($found) {
            return $found.FullName
        }
    }

    foreach ($path in $candidates) {
        if (Test-Path -LiteralPath $path) {
            return $path
        }
    }

    return ""
}

function Find-Aapt {
    param([string]$Explicit)

    if ($Explicit -and (Test-Path -LiteralPath $Explicit)) {
        return (Resolve-Path -LiteralPath $Explicit).Path
    }

    $candidates = @()
    foreach ($envName in "ANDROID_HOME", "ANDROID_SDK_ROOT") {
        $sdk = [Environment]::GetEnvironmentVariable($envName)
        if ($sdk) {
            $candidates += Join-Path $sdk "build-tools"
        }
    }
    $candidates += "D:\software\androidSDK\build-tools"

    foreach ($dir in $candidates) {
        if (Test-Path -LiteralPath $dir) {
            $found = Get-ChildItem -LiteralPath $dir -Recurse -Filter "aapt.exe" -ErrorAction SilentlyContinue |
                Sort-Object FullName -Descending |
                Select-Object -First 1
            if ($found) {
                return $found.FullName
            }
        }
    }

    return ""
}

function Read-ApkInfo {
    param(
        [string]$ApkFile,
        [string]$AaptPath
    )

    $info = @{
        Package = ""
        Label = ""
        VersionName = ""
        VersionCode = ""
    }

    if (-not $AaptPath) {
        return $info
    }

    $parseFile = $ApkFile
    $tempFile = ""
    try {
        # aapt on Windows may fail when the absolute path contains non-ASCII characters.
        $tempFile = Join-Path $env:TEMP ("muyang-aapt-" + [guid]::NewGuid().ToString("N") + ".apk")
        Copy-Item -LiteralPath $ApkFile -Destination $tempFile -Force
        $parseFile = $tempFile

        $badging = & $AaptPath dump badging $parseFile 2>$null
        foreach ($line in $badging) {
            if (-not $info.Package -and $line -match "package: name='([^']+)'") {
                $info.Package = $Matches[1]
                if ($line -match "versionName='([^']+)'") {
                    $info.VersionName = $Matches[1]
                }
                if ($line -match "versionCode='([^']+)'") {
                    $info.VersionCode = $Matches[1]
                }
            }
            if ($line -match "application-label-zh-CN:'([^']*)'") {
                $info.Label = $Matches[1]
            } elseif (-not $info.Label -and $line -match "application-label-zh:'([^']*)'") {
                $info.Label = $Matches[1]
            } elseif (-not $info.Label -and $line -match "application-label:'([^']*)'") {
                $info.Label = $Matches[1]
            }
        }
    } catch {
        Write-Warning "aapt parse failed: $ApkFile"
    } finally {
        if ($tempFile -and (Test-Path -LiteralPath $tempFile)) {
            Remove-Item -LiteralPath $tempFile -Force
        }
    }

    return $info
}

function Join-LabelVersion {
    param(
        [string]$Label,
        [string]$VersionName,
        [string]$VersionCode
    )

    $base = if ($Label) { $Label.Trim() } else { "" }
    $version = if ($VersionName) { $VersionName.Trim() } elseif ($VersionCode) { $VersionCode.Trim() } else { "" }

    if (-not $base) {
        return $version
    }
    if (-not $version) {
        return $base
    }
    if ($base -match [regex]::Escape($version)) {
        return $base
    }
    return "$base $version"
}

function Read-ManifestRows {
    param([string]$Path)

    $rows = [ordered]@{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $rows
    }

    Get-Content -Encoding UTF8 -LiteralPath $Path | ForEach-Object {
        $line = $_
        if ($line.Trim().Length -eq 0 -or $line.TrimStart().StartsWith("#")) {
            return
        }
        $parts = $line -split "`t", -1
        if ($parts.Count -ge 2) {
            $name = $parts[0]
            $rows[$name] = @{
                Name = $name
                Url = $parts[1]
                Sha = if ($parts.Count -ge 3) { $parts[2] } else { "" }
                Size = if ($parts.Count -ge 4) { $parts[3] } else { "" }
                Package = if ($parts.Count -ge 5) { $parts[4] } else { "" }
                Label = if ($parts.Count -ge 6) { $parts[5] } else { "" }
            }
        }
    }

    return $rows
}

function Write-ManifestRows {
    param(
        [string]$Path,
        [System.Collections.Specialized.OrderedDictionary]$Rows
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# name`turl`tsha256`tsize`tpackage`tlabel")
    $lines.Add("# Put APK files in GitHub Releases, then write release asset URLs here.")

    foreach ($key in $Rows.Keys) {
        $row = $Rows[$key]
        $lines.Add(($row.Name, $row.Url, $row.Sha, $row.Size, $row.Package, $row.Label) -join "`t")
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($Path, $lines, $utf8NoBom)
}

function Ensure-Gh {
    $script:GhPath = Find-Gh
    if (-not $script:GhPath) {
        throw "GitHub CLI(gh) is not installed. Install it first, reopen PowerShell, or run with -SkipUpload -SkipCommit."
    }
    & $script:GhPath auth status | Out-Host
}

function Ensure-Release {
    param(
        [string]$RepoName,
        [string]$Tag
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $script:GhPath release view $Tag --repo $RepoName --json tagName 1>$null 2>$null
        $viewCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }

    if ($viewCode -ne 0) {
        & $script:GhPath release create $Tag --repo $RepoName --title $Tag --notes "APK assets for Muyang Debug Helper."
        if ($LASTEXITCODE -ne 0) {
            throw "Create GitHub release failed: $Tag"
        }
    }
}

function Git-HasChanges {
    git diff --quiet -- $Manifest
    if ($LASTEXITCODE -ne 0) {
        return $true
    }
    return $false
}

if (-not (Test-Path -LiteralPath $apkPath)) {
    throw "APK directory not found: $apkPath"
}

$apks = Get-ChildItem -LiteralPath $apkPath -Filter "*.apk" | Sort-Object Name
if (-not $apks) {
    throw "No APK files found in: $apkPath"
}

$aaptPath = Find-Aapt -Explicit $Aapt
if ($aaptPath) {
    Write-Host "Using aapt: $aaptPath"
} else {
    Write-Warning "aapt.exe not found. Package name and label may be empty."
}

if (-not $SkipUpload) {
    Ensure-Gh
    Ensure-Release -RepoName $Repo -Tag $ReleaseTag
}

$rows = if ($ReplaceManifest) {
    [ordered]@{}
} else {
    Read-ManifestRows -Path $manifestPath
}

foreach ($apk in $apks) {
    $name = $apk.Name
    $sha = (Get-FileHash -Algorithm SHA256 -LiteralPath $apk.FullName).Hash.ToLowerInvariant()
    $url = "https://github.com/$Repo/releases/download/$ReleaseTag/" + [uri]::EscapeDataString($name)
    $info = Read-ApkInfo -ApkFile $apk.FullName -AaptPath $aaptPath
    $old = if ($rows.Contains($name)) { $rows[$name] } else { $null }
    $packageName = if ($info.Package) {
        $info.Package
    } elseif ($old -and $old.Package) {
        $old.Package
    } else {
        ""
    }
    $baseLabel = if ($info.Label) {
        $info.Label
    } else {
        [IO.Path]::GetFileNameWithoutExtension($name)
    }
    $label = Join-LabelVersion -Label $baseLabel -VersionName $info.VersionName -VersionCode $info.VersionCode

    Write-Host "APK: $name"
    Write-Host "  package: $packageName"
    Write-Host "  label: $label"
    if ($info.VersionName) {
        Write-Host "  version: $($info.VersionName)"
    }
    Write-Host "  sha256: $sha"

    if (-not $SkipUpload) {
        & $script:GhPath release upload $ReleaseTag $apk.FullName --repo $Repo --clobber
        if ($LASTEXITCODE -ne 0) {
            throw "Upload failed: $name"
        }
    }

    $rows[$name] = @{
        Name = $name
        Url = $url
        Sha = $sha
        Size = [string]$apk.Length
        Package = $packageName
        Label = $label
    }
}

Write-ManifestRows -Path $manifestPath -Rows $rows
Write-Host "Updated manifest: $manifestPath"

if (-not $SkipCommit) {
    git add -- $Manifest
    git add -- "apk-repo/README.md" "apk-repo/inbox/README.md" "tools/publish_apk_repo.ps1" "tools/build_apk_manifest.ps1" ".gitignore" "README.md"

    git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "No git changes to commit."
    } else {
        git commit -m "Update APK online repository"
        git push origin main
    }
}

Write-Host "Done."
