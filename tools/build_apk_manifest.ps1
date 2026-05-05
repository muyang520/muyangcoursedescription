param(
    [string]$BaseUrl = "https://github.com/muyang520/muyangcoursedescription/releases/download/apks-v1",
    [string]$ApkDir = "apk-repo\inbox",
    [string]$OutFile = "apk-repo\apks.tsv",
    [string]$Aapt = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$apkPath = Join-Path $root $ApkDir
$outPath = Join-Path $root $OutFile

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

    $tempFile = ""
    try {
        $tempFile = Join-Path $env:TEMP ("muyang-aapt-" + [guid]::NewGuid().ToString("N") + ".apk")
        Copy-Item -LiteralPath $ApkFile -Destination $tempFile -Force

        $badging = & $AaptPath dump badging $tempFile 2>$null
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

function Get-LabelFromFileName {
    param(
        [string]$FileName,
        [string]$VersionName,
        [string]$VersionCode
    )

    $label = [IO.Path]::GetFileNameWithoutExtension($FileName)
    foreach ($version in @($VersionName, $VersionCode)) {
        if ($version) {
            $label = $label -replace ("[\s_.-]*" + [regex]::Escape($version) + "$"), ""
        }
    }
    $label = ($label -replace "[_-]+", " ").Trim()
    if ($label) {
        return $label
    }
    return [IO.Path]::GetFileNameWithoutExtension($FileName)
}

function Get-SafeAssetName {
    param(
        [string]$FileName,
        [string]$PackageName,
        [string]$VersionName,
        [string]$VersionCode
    )

    if ($FileName -match "^[A-Za-z0-9._-]+$") {
        return $FileName
    }

    $ext = [IO.Path]::GetExtension($FileName)
    if (-not $ext) {
        $ext = ".apk"
    }

    $version = if ($VersionName) { $VersionName.Trim() } elseif ($VersionCode) { $VersionCode.Trim() } else { "" }
    $base = if ($PackageName) { $PackageName.Trim() } else { [IO.Path]::GetFileNameWithoutExtension($FileName) }
    if ($version -and $base -notmatch [regex]::Escape($version)) {
        $base = "{0}_{1}" -f $base, $version
    }

    $safe = ($base -replace "[^A-Za-z0-9._-]+", "_").Trim([char[]]"._-")
    if (-not $safe) {
        $safe = "apk"
    }
    return "$safe$ext"
}

if (-not (Test-Path -LiteralPath $apkPath)) {
    throw "APK directory not found: $apkPath"
}

$aaptPath = Find-Aapt -Explicit $Aapt
if ($aaptPath) {
    Write-Host "Using aapt: $aaptPath"
} else {
    Write-Warning "aapt.exe not found. Package name and label may be empty."
}

$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("# name`turl`tsha256`tsize`tpackage`tlabel")
$rows.Add("# Put APK files in GitHub Releases, then write release asset URLs here.")

Get-ChildItem -LiteralPath $apkPath -Filter "*.apk" | Sort-Object Name | ForEach-Object {
    $name = $_.Name
    $info = Read-ApkInfo -ApkFile $_.FullName -AaptPath $aaptPath
    $assetName = Get-SafeAssetName -FileName $name -PackageName $info.Package -VersionName $info.VersionName -VersionCode $info.VersionCode
    $baseLabel = if ($info.Label) {
        $info.Label
    } else {
        Get-LabelFromFileName -FileName $name -VersionName $info.VersionName -VersionCode $info.VersionCode
    }
    $label = Join-LabelVersion -Label $baseLabel -VersionName $info.VersionName -VersionCode $info.VersionCode
    $url = $BaseUrl.TrimEnd("/") + "/" + [uri]::EscapeDataString($assetName)
    $sha = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
    $rows.Add(($assetName, $url, $sha, $_.Length, $info.Package, $label) -join "`t")
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($outPath, $rows, $utf8NoBom)
Write-Host "Built manifest: $outPath"
