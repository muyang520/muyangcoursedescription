param(
    [string]$BaseUrl = "https://github.com/muyang520/muyangcoursedescription/releases/download/apks-v1",
    [string]$ApkDir = "apk-repo\inbox",
    [string]$OutFile = "apk-repo\apks.tsv"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$apkPath = Join-Path $root $ApkDir
$outPath = Join-Path $root $OutFile

if (-not (Test-Path -LiteralPath $apkPath)) {
    throw "APK directory not found: $apkPath"
}

$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("# name`turl`tsha256`tsize`tpackage`tlabel")
$rows.Add("# Put APK files in GitHub Releases, then write release asset URLs here.")

Get-ChildItem -LiteralPath $apkPath -Filter "*.apk" | Sort-Object Name | ForEach-Object {
    $name = $_.Name
    $url = $BaseUrl.TrimEnd("/") + "/" + [uri]::EscapeDataString($name)
    $sha = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash.ToLowerInvariant()
    $rows.Add(($name, $url, $sha, $_.Length, "", "") -join "`t")
}

Set-Content -Encoding UTF8 -LiteralPath $outPath -Value $rows
Write-Host "Built manifest: $outPath"
