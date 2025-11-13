Param(
  [string]$Package = "com.flamapp.ai"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path "$PSScriptRoot\..\").Path
$destDir = Join-Path $root 'web\assets'
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

$src = "/sdcard/Android/data/$Package/files/processed_sample.png"
$dest = Join-Path $destDir 'processed_sample.png'

Write-Output "Pulling $src -> $dest"
& adb pull $src $dest | Out-Null
Write-Output "Done."
