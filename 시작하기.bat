@echo off
chcp 65001 >nul
title Railway CLI Kit - Start Here (Korean)
cd /d "%~dp0"

REM ============================================
REM   Korean guide launcher. All Korean text lives
REM   in lib\start.ps1 (UTF-8 BOM) so cmd never
REM   mangles it. This .bat stays ASCII on purpose.
REM ============================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lib\start.ps1"
if %errorlevel% NEQ 0 (
    echo.
    echo [!] Could not open the Korean guide.
    echo     You can still use INSTALL.bat / RUN.bat / UNINSTALL.bat directly.
    echo.
    pause
)
exit /b 0
