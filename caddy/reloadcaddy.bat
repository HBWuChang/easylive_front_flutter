@echo off
echo Reloading Caddy server configuration...



REM 检查配置文件是否存在
if not exist caddy/caddyfile (
    echo Error: caddyfile not found
    pause
    exit /b 1
)

REM 重新加载配置
echo Reloading Caddy configuration...
caddy reload --config caddy/caddyfile

if %errorlevel% equ 0 (
    echo Caddy configuration reloaded successfully
) else (
    echo Error: Failed to reload Caddy configuration
)