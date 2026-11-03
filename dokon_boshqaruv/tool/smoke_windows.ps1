$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $env:CI -or -not $env:RUNNER_TEMP) { throw 'This check requires an isolated CI runner.' }
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$dist = Join-Path $root 'dist'
$installer = Join-Path $dist 'e-dukon-Setup.exe'
$target = Join-Path $env:RUNNER_TEMP 'e-dukon-install-smoke-032'
$p = Start-Process $installer -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART',"/DIR=`"$target`"") -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Installer exit code: $($p.ExitCode)" }
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class AppWindowCheck {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int x, int y, int w, int h, bool repaint);
}
'@
$app = $null
try {
    # A shortcut or file manager can start an app with an unrelated working directory.
    $app = Start-Process (Join-Path $target 'e-dukon.exe') -WorkingDirectory $env:RUNNER_TEMP -PassThru
    Start-Sleep -Seconds 12
    $app.Refresh()
    if ($app.HasExited) { throw "Application exited early: $($app.ExitCode)" }
    if ($app.MainWindowHandle -eq 0) { throw 'Application window was not created.' }
    if ($app.MainWindowTitle -ne 'e-dukon | Windows 0.3.2') { throw "Unexpected executable window: $($app.MainWindowTitle)" }
    [AppWindowCheck]::ShowWindow($app.MainWindowHandle, 9) | Out-Null
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    [AppWindowCheck]::MoveWindow($app.MainWindowHandle, 0, 0, [Math]::Min(1200,$bounds.Width), [Math]::Min(850,$bounds.Height), $true) | Out-Null
    [AppWindowCheck]::SetForegroundWindow($app.MainWindowHandle) | Out-Null
    Start-Sleep -Seconds 3
    $bitmap = [System.Drawing.Bitmap]::new($bounds.Width,$bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($bounds.Location,[System.Drawing.Point]::Empty,$bounds.Size)
        $bitmap.Save((Join-Path $dist 'windows-startup.png'),[System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose() }
    [ordered]@{
        app_version = '0.3.2+8'
        window_title = $app.MainWindowTitle
        exe_path = $app.Path
        launch_from_unrelated_working_directory = $true
        screenshot = 'windows-startup.png'
        full_authenticated_workflows_tested = $false
    } | ConvertTo-Json | Set-Content (Join-Path $dist 'windows-startup-check.json') -Encoding utf8
    Write-Host 'Installed application window captured for visual review; launched from an unrelated directory.'
} finally {
    if ($app -and -not $app.HasExited) { Stop-Process -Id $app.Id -Force }
    $uninstaller = Join-Path $target 'unins000.exe'
    if (Test-Path $uninstaller) {
        $u = Start-Process $uninstaller -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART') -Wait -PassThru
        if ($u.ExitCode -ne 0) { throw "Uninstaller exit code: $($u.ExitCode)" }
    }
}
