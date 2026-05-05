@echo off
setlocal
cd /d "%~dp0.."
set "MUYANG_BAT_SELF_PAUSE=0"
if not defined MUYANG_NO_PAUSE set "MUYANG_BAT_SELF_PAUSE=1"
if not defined MUYANG_PROXY_PORT set "MUYANG_PROXY_PORT=7890"
set "HTTP_PROXY=http://127.0.0.1:%MUYANG_PROXY_PORT%"
set "HTTPS_PROXY=http://127.0.0.1:%MUYANG_PROXY_PORT%"
set "ALL_PROXY=http://127.0.0.1:%MUYANG_PROXY_PORT%"
set "http_proxy=%HTTP_PROXY%"
set "https_proxy=%HTTPS_PROXY%"
set "all_proxy=%ALL_PROXY%"
set "NO_PROXY=localhost,127.0.0.1,::1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_apk_manifest.ps1" %*
set "RC=%errorlevel%"
if "%MUYANG_BAT_SELF_PAUSE%"=="1" (
    echo.
    echo Exit code: %RC%
    pause
)
exit /b %RC%
