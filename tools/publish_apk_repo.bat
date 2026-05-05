@echo off
setlocal
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_apk_repo.ps1" %*
exit /b %errorlevel%
