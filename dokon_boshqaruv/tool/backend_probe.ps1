$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$config = Get-Content (Join-Path $PSScriptRoot '../config/production.json') -Raw | ConvertFrom-Json
$expected = 'https://dukonboshqaruv-production.up.railway.app/api/v1/'
if ($config.API_BASE_URL -ne $expected) { throw 'Unexpected API endpoint in release config.' }
$uri = [Uri]::new([Uri]$expected, 'auth/login/')
# Read-only route check: no credentials and no payment or sale writes.
$response = Invoke-WebRequest -Uri $uri -Method Get -SkipHttpErrorCheck -TimeoutSec 30
$status = [int]$response.StatusCode
if ($status -ne 405) { throw "Login route did not return its expected Method Not Allowed response: HTTP $status" }
$body = $response.Content | ConvertFrom-Json
if (-not $body.detail) { throw 'Login route did not return a DRF JSON detail.' }
$report = [ordered]@{
    api_base_url = $expected
    read_only_probe = $uri.AbsoluteUri
    http_status = $status
    tls_and_route_reachable = $true
    authenticated_login_tested = $false
}
$dist = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../dist'))
New-Item -ItemType Directory -Force $dist | Out-Null
$report | ConvertTo-Json | Set-Content (Join-Path $dist 'backend-check.json') -Encoding utf8
Write-Host 'Confirmed HTTPS backend and login API route. No authenticated login was performed.'
