@echo off
setlocal
cd /d "%~dp0"
call "%~dp0tools\publish_apk_repo.bat" %*
exit /b %errorlevel%
