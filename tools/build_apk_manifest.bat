@echo off
setlocal
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_apk_manifest.ps1" %*
exit /b %errorlevel%
