#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$State,
    [Parameter(Position = 1)]
    [string]$Target
)

$ErrorActionPreference = 'Stop'

switch -CaseSensitive ($State) {
    'on' { $action = 'com.oculus.vrpowermanager.automation_disable' }
    'off' { $action = 'com.oculus.vrpowermanager.prox_close' }
    default {
        Write-Host 'Usage: .\quest-proximity.cmd on|off [IP:port] (or .\quest-proximity.ps1 on|off [IP:port])'
        exit 2
    }
}

$useWireless = $PSBoundParameters.ContainsKey('Target')
if ($useWireless -and $Target -notmatch '^[^\s]+:[0-9]+$') {
    Write-Host 'Wireless target must be IP:port, for example 192.168.1.50:5555.'
    exit 2
}

# If there is no ADB in this path then get it from PATH.
$adbPath = Join-Path -Path $PSScriptRoot -ChildPath 'adb.exe'
if (-not (Test-Path -LiteralPath $adbPath -PathType Leaf)) {
    $adbCommand = Get-Command -Name 'adb.exe' -CommandType Application -ErrorAction SilentlyContinue
    if ($null -eq $adbCommand) {
        Write-Host 'ADB is missing. Download Android SDK Platform Tools for Windows:'
        Write-Host 'https://developer.android.com/tools/releases/platform-tools'
        Write-Host 'Extract the whole download in this folder.'
        exit 1
    }
    $adbPath = $adbCommand.Source
}

# Use USB by default, or connect to and select the requested wireless headset.
$adbArguments = @('-d')
if ($useWireless) {
    & $adbPath connect $Target
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Could not connect to $Target. Enable wireless ADB over USB first and check the headset IP and network."
        exit 1
    }
    $adbArguments = @('-s', $Target)
}

& $adbPath @adbArguments shell am broadcast -a $action
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host "Could not set the proximity sensor to $State."
    if ($useWireless) {
        Write-Host 'Enable wireless ADB over USB first, check the headset IP, and make sure the PC and headset are on the same local network.'
        Write-Host 'Accept any debugging authorization prompt in the headset.'
    }
    else {
        Write-Host 'Connect your headset over USB, enable Developer Mode, and accept "Allow USB debugging" in the headset.'
        Write-Host 'If multiple USB ADB devices are connected, disconnect the others and retry.'
    }
    exit 1
}

Write-Host ''
Write-Host "Proximity sensor $State request sent."
if ($State -eq 'off') {
    Write-Host 'Change is not permanent and this script will need to be run again after headset reboot.'
}
exit 0
