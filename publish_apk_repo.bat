@echo off
setlocal
cd /d "%~dp0"
set "MUYANG_BAT_SELF_PAUSE=0"
if not defined MUYANG_NO_PAUSE set "MUYANG_BAT_SELF_PAUSE=1"
set "MUYANG_NO_PAUSE=1"
call "%~dp0tools\publish_apk_repo.bat" %*
set "RC=%errorlevel%"
if "%MUYANG_BAT_SELF_PAUSE%"=="1" (
    echo.
    echo Exit code: %RC%
    pause
)
exit /b %RC%
