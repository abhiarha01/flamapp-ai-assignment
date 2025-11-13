Param(
  [string]$Version = "4.10.0"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path "$PSScriptRoot\..\").Path
$sdkDir = Join-Path $root 'third_party\OpenCV-android-sdk'
$libsOut = Join-Path $root 'app\libs'
$jniLibs = Join-Path $root 'app\src\main\jniLibs'
$temp = Join-Path $root '.opencv-download'

New-Item -ItemType Directory -Force -Path $temp, $libsOut, $jniLibs | Out-Null

if (-not (Test-Path $sdkDir)) {
  $zip = "opencv-$Version-android-sdk.zip"
  $url = "https://github.com/opencv/opencv/releases/download/$Version/$zip"
  Write-Output "Downloading $url ..."
  $zipPath = Join-Path $temp $zip
  Invoke-WebRequest -UseBasicParsing -OutFile $zipPath -Uri $url
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $temp, $true)
  $extracted = Get-ChildItem $temp -Directory | Where-Object { $_.Name -like 'opencv-*-android-sdk' } | Select-Object -First 1
  Move-Item $extracted.FullName $sdkDir
}

# Copy AAR
$aarSrc = Join-Path $sdkDir 'sdk\java'
$aar = Get-ChildItem $aarSrc -Filter *.aar | Select-Object -First 1
Copy-Item $aar.FullName (Join-Path $libsOut 'opencv.aar') -Force

# Copy JNI libs
$abis = @('arm64-v8a','armeabi-v7a','x86_64')
foreach ($abi in $abis) {
  $dst = Join-Path $jniLibs $abi
  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  $src1 = Join-Path $sdkDir "sdk\native\libs\$abi"
  $src2 = Join-Path $sdkDir "sdk\native\3rdparty\libs\$abi"
  if (Test-Path $src1) { Copy-Item (Join-Path $src1 '*.so') $dst -Force -ErrorAction SilentlyContinue }
  if (Test-Path $src2) { Copy-Item (Join-Path $src2 '*.so') $dst -Force -ErrorAction SilentlyContinue }
}

# Write opencv.dir to local.properties
$localProps = Join-Path $root 'local.properties'
$line = "opencv.dir=$sdkDir"
if (Test-Path $localProps) {
  (Get-Content $localProps) -replace '^opencv.dir=.*$', $line | Set-Content $localProps
} else {
  Add-Content -Path $localProps -Value $line
}

Write-Output "OpenCV SDK setup complete."