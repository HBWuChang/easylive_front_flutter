@echo off
echo Stopping Caddy server...

REM 使用 taskkill 停止 caddy 进程
taskkill /f /im caddy.exe >nul 2>&1

if %errorlevel% equ 0 (
    echo Caddy server stopped successfully
) else (
    echo No Caddy process found or failed to stop
)

REM 额外检查，确保进程真的停止了
timeout /t 2 /nobreak >nul
tasklist /fi "imagename eq caddy.exe" 2>nul | find /i "caddy.exe" >nul
if %errorlevel% equ 0 (
    echo Warning: Caddy process may still be running
) else (
    echo Confirmed: Caddy process has stopped
)
