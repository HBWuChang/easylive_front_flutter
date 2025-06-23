@echo off
echo Starting Caddy server in background...
echo Current directory: %cd%
echo Configuration file: caddyfile



REM 检查配置文件是否存在
if not exist caddy/caddyfile (
    echo Error: caddyfile not found
    echo Please make sure caddyfile exists in the current directory
    pause
    exit /b 1
)

REM 检查 Caddy 是否已经在运行
tasklist /fi "imagename eq caddy.exe" 2>nul | find /i "caddy.exe" >nul
if %errorlevel% equ 0 (
    echo Caddy is already running
    pause
    exit /b 0
)

REM 在后台启动 Caddy 服务器
echo Starting Caddy in background with configuration file: caddyfile
start "" caddy start --config caddy/caddyfile

REM 等待一下让服务启动
timeout /t 3 /nobreak >nul

REM 检查是否启动成功
tasklist /fi "imagename eq caddy.exe" 2>nul | find /i "caddy.exe" >nul
if %errorlevel% equ 0 (
    echo Caddy server started successfully in background
    echo Server is listening on port 7068
) else (
    echo Error: Failed to start Caddy server
)
