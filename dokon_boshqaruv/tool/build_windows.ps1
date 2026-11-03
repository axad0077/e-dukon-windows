[CmdletBinding()]
param([string]$IsccPath = '', [switch]$SkipTests)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $IsWindows) { throw 'Windows runner kerak. Linux uchun GitHub Actions workflow faylidan foydalaning.' }
Set-Location (Join-Path $PSScriptRoot '..')
$appRoot = (Get-Location).Path
$dist = [IO.Path]::GetFullPath((Join-Path $appRoot '../dist'))
New-Item -ItemType Directory -Force $dist | Out-Null
function Invoke-Flutter {
    param([string[]]$FlutterArgs)
    & flutter @FlutterArgs
    if ($LASTEXITCODE -ne 0) { throw "Flutter buyrug'i bajarilmadi: $($FlutterArgs -join ' ')" }
}
Invoke-Flutter -FlutterArgs @('config', '--enable-windows-desktop')
Invoke-Flutter -FlutterArgs @('--version')
# Lockfile talablarini pasaytirmaymiz: Dart >=3.12, Flutter >=3.44.
Invoke-Flutter -FlutterArgs @('pub', 'get', '--enforce-lockfile')
Invoke-Flutter -FlutterArgs @('analyze', '--no-fatal-infos', '--no-fatal-warnings')
if (-not $SkipTests) { Invoke-Flutter -FlutterArgs @('test') }
Invoke-Flutter -FlutterArgs @('build', 'windows', '--release', '--dart-define-from-file=config/production.json')
$release = Join-Path $appRoot 'build/windows/x64/runner/Release'
foreach ($file in @('e-dukon.exe', 'flutter_windows.dll', 'data/icudtl.dat', 'data/flutter_assets')) {
    if (-not (Test-Path (Join-Path $release $file))) { throw "Build fayli yo'q: $file" }
}
# Copy the redistributable VC++ CRT next to the application (app-local deployment).
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
if (-not (Test-Path $vswhere)) { throw 'Visual Studio vswhere topilmadi.' }
$vs = (& $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | Select-Object -First 1)
if (-not $vs) { throw 'Visual Studio C++ vositalari topilmadi.' }
$crtDirs = @(Get-ChildItem (Join-Path $vs 'VC/Redist/MSVC') -Directory | Sort-Object Name -Descending | ForEach-Object {
    Get-ChildItem (Join-Path $_.FullName 'x64') -Directory -Filter 'Microsoft.VC*.CRT' -ErrorAction SilentlyContinue
})
if ($crtDirs.Count -eq 0) { throw 'Visual C++ redistributable CRT topilmadi.' }
Copy-Item (Join-Path $crtDirs[0].FullName '*.dll') $release -Force
foreach ($file in @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')) {
    if (-not (Test-Path (Join-Path $release $file))) { throw "VC++ DLL yo'q: $file" }
}
if (-not $IsccPath) {
    $compiler = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($compiler) { $IsccPath = $compiler.Source }
    else { $IsccPath = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6/ISCC.exe' }
}
if (-not (Test-Path $IsccPath)) { throw 'Inno Setup 6 o‘rnatilmagan.' }
$versionMatch = Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)'
if (-not $versionMatch) { throw 'pubspec.yaml version topilmadi.' }
$version = $versionMatch.Matches[0].Groups[1].Value
& $IsccPath "/DAppVersion=$version" "/DReleaseDir=$release" "/DOutputDir=$dist" 'windows/installer/setup.iss'
if ($LASTEXITCODE -ne 0) { throw 'Setup.exe yig‘ilmadi.' }
Compress-Archive -Path (Join-Path $release '*') -DestinationPath (Join-Path $dist 'e-dukon-Windows-portable.zip') -Force
Get-FileHash (Join-Path $dist 'e-dukon-Setup.exe') -Algorithm SHA256 |
    ForEach-Object { "$($_.Hash.ToLower())  e-dukon-Setup.exe" } |
    Set-Content (Join-Path $dist 'SHA256SUMS.txt') -Encoding ascii
Write-Host "Tayyor: $dist/e-dukon-Setup.exe"
