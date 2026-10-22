@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0quest-proximity.ps1" %*
exit /b %errorlevel%

