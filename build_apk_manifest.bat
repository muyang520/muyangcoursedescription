@echo off
setlocal
cd /d "%~dp0"
call "%~dp0tools\build_apk_manifest.bat" %*
exit /b %errorlevel%
