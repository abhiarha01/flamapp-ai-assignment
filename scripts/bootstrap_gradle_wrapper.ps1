Param(
  [string]$Version = "8.7"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path "$PSScriptRoot\..\").Path
$wrapperDir = Join-Path $root 'gradle\wrapper'
$wrapperJar = Join-Path $wrapperDir 'gradle-wrapper.jar'
$temp = Join-Path $root '.gradle-bootstrap'

New-Item -ItemType Directory -Force -Path $wrapperDir | Out-Null
New-Item -ItemType Directory -Force -Path $temp | Out-Null

if (Test-Path $wrapperJar) {
  Write-Output "Gradle wrapper already present: $wrapperJar"
  exit 0
}

$zipName = "gradle-$Version-bin.zip"
$url = "https://services.gradle.org/distributions/$zipName"
$zipPath = Join-Path $temp $zipName

Write-Output "Downloading $url ..."
Invoke-WebRequest -UseBasicParsing -OutFile $zipPath -Uri $url

# Extract
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $temp, $true)

$cand1 = Join-Path $temp "gradle-$Version/lib/plugins/gradle-wrapper-$Version.jar"
$cand2 = Join-Path $temp "gradle-$Version/lib/gradle-wrapper-$Version.jar"

if (Test-Path $cand1) { Copy-Item $cand1 $wrapperJar }
elseif (Test-Path $cand2) { Copy-Item $cand2 $wrapperJar }
else { throw "Could not locate gradle-wrapper-$Version.jar in distribution" }

Write-Output "Bootstrapped $wrapperJar"