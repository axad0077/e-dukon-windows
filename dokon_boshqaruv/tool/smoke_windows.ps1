$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$installer = Join-Path $root 'dist/e-dukon-Setup.exe'
# Dedicated clean CI install, not a customer's existing profile.
$target = Join-Path $env:RUNNER_TEMP 'e-dukon-install-smoke'
if (-not $env:CI -or -not $env:RUNNER_TEMP) { throw 'Faqat izolyatsiyalangan CI runnerda ishlating.' }
$p = Start-Process $installer -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART',"/DIR=`"$target`"") -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Installer kodi: $($p.ExitCode)" }
$app = $null
try {
    $app = Start-Process (Join-Path $target 'e-dukon.exe') -WorkingDirectory $target -PassThru
    Start-Sleep -Seconds 8
    $app.Refresh()
    if ($app.HasExited) { throw "Ilova ishga tushib yopildi. Kod: $($app.ExitCode)" }
    if ($app.MainWindowHandle -eq 0) { throw 'Windows oynasi ochilmadi.' }
    Write-Host 'Installer va boshlangich oyna smoke tekshiruvidan otdi. Savdo funksiyalari bu tekshiruvga kirmaydi.'
} finally {
    if ($app -and -not $app.HasExited) { Stop-Process -Id $app.Id -Force }
    $uninstaller = Join-Path $target 'unins000.exe'
    if (Test-Path $uninstaller) {
        $uninstall = Start-Process $uninstaller -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART') -Wait -PassThru
        if ($uninstall.ExitCode -ne 0) { throw "Uninstall kodi: $($uninstall.ExitCode)" }
    }
}
