@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion
title Railway CLI - Launcher

REM ============================================================
REM DYNAMIC PATH SETUP
REM ============================================================
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
cd /d "%SCRIPT_DIR%"

REM Inject likely Railway install folders into this session's PATH
set "PATH=%LOCALAPPDATA%\Programs\Railway;%PATH%"
set "PATH=%APPDATA%\npm;%PATH%"

REM Also re-read the persistent user PATH via PowerShell so that anything
REM newly added by INSTALL.bat is visible without restarting the shell.
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :SKIP_PATH_REFRESH
for /f "usebackq tokens=*" %%a in (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','User')"`) do set "USER_PATH=%%a"
if defined USER_PATH set "PATH=%USER_PATH%;%PATH%"
set "USER_PATH="
:SKIP_PATH_REFRESH
where railway >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :NOT_INSTALLED

REM Capture version and primary install location for the header
set "RW_VER=unknown"
for /f "delims=" %%v in ('railway --version 2^>nul') do set "RW_VER=%%v"
set "RW_PATH=unknown"
for /f "delims=" %%p in ('where railway 2^>nul') do (
    if "!RW_PATH!"=="unknown" set "RW_PATH=%%p"
)

REM Count UNIQUE install folders (npm creates multiple wrapper files
REM in one folder, so file-count is misleading - check parent dirs).
set "FIRST_DIR="
set "RW_MULTI=0"
for /f "delims=" %%p in ('where railway 2^>nul') do call :CHECK_UNIQUE_DIR "%%~dpp"

REM Detect install method (rough heuristic based on path)
set "RW_METHOD=unknown"
echo !RW_PATH! | findstr /i /c:"\\npm\\" >nul && set "RW_METHOD=npm"
echo !RW_PATH! | findstr /i /c:"\\Programs\\Railway" >nul && set "RW_METHOD=binary"
echo !RW_PATH! | findstr /i /c:"\\scoop\\" >nul && set "RW_METHOD=scoop"

:MAIN_MENU
cls
echo.
echo +==========================================================+
echo ^|                                                          ^|
echo ^|              RAILWAY CLI - LAUNCHER                      ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo  Version : !RW_VER!
echo  Method  : !RW_METHOD!
echo  Path    : !RW_PATH!
if "!RW_MULTI!"=="1" echo  [WARN] Railway is installed in more than one folder.
if "!RW_MULTI!"=="1" echo         Use UNINSTALL.bat to clean up duplicates.
echo.
echo  +-------- ACCOUNT --------+    +-------- PROJECT --------+
echo  ^|  1. Login (browser)     ^|    ^|  7. Init new project    ^|
echo  ^|  2. Login (no browser)  ^|    ^|  8. Link to project     ^|
echo  ^|  3. Logout              ^|    ^|  9. Unlink project      ^|
echo  ^|  4. Show current user   ^|    ^| 10. List projects       ^|
echo  +-------------------------+    ^| 11. Project status      ^|
echo                                  ^| 12. Open in browser     ^|
echo  +-------- VERSION --------+    +-------------------------+
echo  ^|  5. Show version        ^|
echo  ^|  6. Update Railway CLI  ^|    +-------- DEPLOY ---------+
echo  +-------------------------+    ^| 13. Deploy (up)         ^|
echo                                  ^| 14. Redeploy            ^|
echo  +------ LOGS + SHELL -----+    ^| 15. Take down            ^|
echo  ^| 18. View logs (live)    ^|    ^| 16. Select service      ^|
echo  ^| 19. View build logs     ^|    ^| 17. Add database/plugin ^|
echo  ^| 20. Open shell          ^|    +-------------------------+
echo  ^| 21. Run command         ^|
echo  ^| 22. SSH into service    ^|    +-------- CONFIG ---------+
echo  ^| 23. Connect to plugin   ^|    ^| 24. Variables           ^|
echo  +-------------------------+    ^| 25. Environment         ^|
echo                                  ^| 26. Custom domain       ^|
echo  +--------- HELP ----------+    ^| 27. Volumes             ^|
echo  ^| 28. Open docs in browser^|    +-------------------------+
echo  ^| 29. Show help           ^|
echo  ^| 30. Run custom command  ^|       0. Quit (also: q, exit)
echo  +-------------------------+
echo.
set "CHOICE="
set /p "CHOICE=Pick a number and press Enter: "

if "!CHOICE!"=="" goto :MAIN_MENU
if /i "!CHOICE!"=="0"    goto :EXIT_OK
if /i "!CHOICE!"=="q"    goto :EXIT_OK
if /i "!CHOICE!"=="quit" goto :EXIT_OK
if /i "!CHOICE!"=="exit" goto :EXIT_OK
if "!CHOICE!"=="1"  goto :A_LOGIN
if "!CHOICE!"=="2"  goto :A_LOGIN_BL
if "!CHOICE!"=="3"  goto :A_LOGOUT
if "!CHOICE!"=="4"  goto :A_WHOAMI
if "!CHOICE!"=="5"  goto :V_SHOW
if "!CHOICE!"=="6"  goto :V_UPDATE
if "!CHOICE!"=="7"  goto :P_INIT
if "!CHOICE!"=="8"  goto :P_LINK
if "!CHOICE!"=="9"  goto :P_UNLINK
if "!CHOICE!"=="10" goto :P_LIST
if "!CHOICE!"=="11" goto :P_STATUS
if "!CHOICE!"=="12" goto :P_OPEN
if "!CHOICE!"=="13" goto :D_UP
if "!CHOICE!"=="14" goto :D_REDEPLOY
if "!CHOICE!"=="15" goto :D_DOWN
if "!CHOICE!"=="16" goto :D_SERVICE
if "!CHOICE!"=="17" goto :D_ADD
if "!CHOICE!"=="18" goto :L_LOGS
if "!CHOICE!"=="19" goto :L_BUILD
if "!CHOICE!"=="20" goto :L_SHELL
if "!CHOICE!"=="21" goto :L_RUN
if "!CHOICE!"=="22" goto :L_SSH
if "!CHOICE!"=="23" goto :L_CONNECT
if "!CHOICE!"=="24" goto :C_VARS
if "!CHOICE!"=="25" goto :C_ENV
if "!CHOICE!"=="26" goto :C_DOMAIN
if "!CHOICE!"=="27" goto :C_VOLUME
if "!CHOICE!"=="28" goto :H_DOCS
if "!CHOICE!"=="29" goto :H_HELP
if "!CHOICE!"=="30" goto :H_CUSTOM
echo.
echo  [WARN] '!CHOICE!' is not a valid choice. Returning to menu...
timeout /t 2 >nul 2>&1
goto :MAIN_MENU

REM ====== ACCOUNT ======
:A_LOGIN
echo.
echo +-- Login (opens browser) ---------------------------------+
call railway login
goto :PAUSE_RETURN

:A_LOGIN_BL
echo.
echo +-- Login (no browser, paste token) -----------------------+
call railway login --browserless
goto :PAUSE_RETURN

:A_LOGOUT
echo.
echo +-- Logout ------------------------------------------------+
call railway logout
goto :PAUSE_RETURN

:A_WHOAMI
echo.
echo +-- Show current Railway user -----------------------------+
call railway whoami
goto :PAUSE_RETURN

REM ====== VERSION ======
:V_SHOW
echo.
echo +-- Show Railway CLI version ------------------------------+
call railway --version
echo.
echo Location:
for /f "delims=" %%p in ('where railway 2^>nul') do echo   %%p
echo.
echo Tip: To update to the newest version, pick option 6.
goto :PAUSE_RETURN

:V_UPDATE
echo.
echo +-- Update Railway CLI to latest version ------------------+
echo  Trying 'railway upgrade' first...
call railway upgrade
if %ERRORLEVEL% EQU 0 goto :V_UPDATE_DONE
echo.
echo  'railway upgrade' did not work. Trying npm method...
where npm >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :V_UPDATE_NONPM
call npm install -g @railway/cli
if %ERRORLEVEL% EQU 0 goto :V_UPDATE_DONE
echo.
echo  [WARN] Update failed. You can re-run INSTALL.bat to reinstall.
goto :V_UPDATE_REFRESH

:V_UPDATE_NONPM
echo  [WARN] npm not found. Please re-run INSTALL.bat to update.

:V_UPDATE_DONE
echo.
echo  [OK] Update finished.

:V_UPDATE_REFRESH
REM Refresh cached version and path for the menu
set "RW_VER=unknown"
for /f "delims=" %%v in ('railway --version 2^>nul') do set "RW_VER=%%v"
set "RW_PATH=unknown"
for /f "delims=" %%p in ('where railway 2^>nul') do (
    if "!RW_PATH!"=="unknown" set "RW_PATH=%%p"
)
set "FIRST_DIR="
set "RW_MULTI=0"
for /f "delims=" %%p in ('where railway 2^>nul') do call :CHECK_UNIQUE_DIR "%%~dpp"
goto :PAUSE_RETURN

REM ====== PROJECT ======
:P_INIT
echo.
echo +-- Create a new Railway project --------------------------+
call railway init
goto :PAUSE_RETURN

:P_LINK
echo.
echo +-- Link this folder to an existing Railway project -------+
call railway link
goto :PAUSE_RETURN

:P_UNLINK
echo.
echo +-- Unlink this folder from its Railway project -----------+
call railway unlink
goto :PAUSE_RETURN

:P_LIST
echo.
echo +-- List your Railway projects ----------------------------+
call railway list
goto :PAUSE_RETURN

:P_STATUS
echo.
echo +-- Show status of the linked project ---------------------+
call railway status
goto :PAUSE_RETURN

:P_OPEN
echo.
echo +-- Open the linked project in your web browser -----------+
call railway open
goto :PAUSE_RETURN

REM ====== DEPLOY ======
:D_UP
echo.
echo +-- Deploy current folder to Railway (up) -----------------+
call railway up
goto :PAUSE_RETURN

:D_REDEPLOY
echo.
echo +-- Redeploy the most recent deployment -------------------+
call railway redeploy
goto :PAUSE_RETURN

:D_DOWN
echo.
echo +-- Take down the current deployment ----------------------+
echo  This will STOP your live service.
echo  Type YES to confirm, or anything else to cancel.
set "DOWN_CONFIRM="
set /p "DOWN_CONFIRM=Confirm: "
if /i not "!DOWN_CONFIRM!"=="YES" goto :D_DOWN_CANCEL
call railway down
goto :PAUSE_RETURN

:D_DOWN_CANCEL
echo  Cancelled.
goto :PAUSE_RETURN

:D_SERVICE
echo.
echo +-- Pick which service to use ----------------------------+
call railway service
goto :PAUSE_RETURN

:D_ADD
echo.
echo +-- Add a database or plugin to the project ---------------+
call railway add
goto :PAUSE_RETURN

REM ====== LOGS + SHELL ======
:L_LOGS
echo.
echo +-- View live deploy logs (Ctrl+C to stop) ----------------+
call railway logs
goto :PAUSE_RETURN

:L_BUILD
echo.
echo +-- View build logs ---------------------------------------+
call railway logs --build
goto :PAUSE_RETURN

:L_SHELL
echo.
echo +-- Open a shell with Railway env loaded ------------------+
call railway shell
goto :PAUSE_RETURN

:L_RUN
echo.
echo +-- Run a command with Railway env loaded -----------------+
echo  Example: node index.js
echo.
set "RUN_CMD="
set /p "RUN_CMD=Command to run: "
if "!RUN_CMD!"=="" goto :L_RUN_CANCEL
call railway run !RUN_CMD!
goto :PAUSE_RETURN

:L_RUN_CANCEL
echo  No command entered. Cancelled.
goto :PAUSE_RETURN

:L_SSH
echo.
echo +-- SSH into a running service ----------------------------+
call railway ssh
goto :PAUSE_RETURN

:L_CONNECT
echo.
echo +-- Connect to a database plugin --------------------------+
call railway connect
goto :PAUSE_RETURN

REM ====== CONFIG ======
:C_VARS
echo.
echo +-- Show environment variables ----------------------------+
call railway variables
goto :PAUSE_RETURN

:C_ENV
echo.
echo +-- Pick environment (production, staging, etc.) ----------+
call railway environment
goto :PAUSE_RETURN

:C_DOMAIN
echo.
echo +-- Manage custom domain for the service ------------------+
call railway domain
goto :PAUSE_RETURN

:C_VOLUME
echo.
echo +-- Manage persistent volumes -----------------------------+
call railway volume
goto :PAUSE_RETURN

REM ====== HELP ======
:H_DOCS
echo.
echo +-- Open Railway docs in your browser ---------------------+
call railway docs
goto :PAUSE_RETURN

:H_HELP
echo.
echo +-- Show Railway CLI help ---------------------------------+
call railway help
goto :PAUSE_RETURN

:H_CUSTOM
echo.
echo +-- Run any railway command -------------------------------+
echo  Type the arguments WITHOUT the word 'railway'.
echo  Example: status --json
echo  Type just Enter to cancel.
echo.
set "CUSTOM_ARGS="
set /p "CUSTOM_ARGS=railway "
if "!CUSTOM_ARGS!"=="" goto :H_CUSTOM_CANCEL
call railway !CUSTOM_ARGS!
goto :PAUSE_RETURN

:H_CUSTOM_CANCEL
echo  No command entered. Cancelled.
goto :PAUSE_RETURN

REM ====== SHARED PAUSE/RETURN ======
:PAUSE_RETURN
echo.
echo ----------------------------------------------------------
echo  Press any key to return to the menu...
pause >nul
goto :MAIN_MENU

REM ====== NOT INSTALLED ======
:NOT_INSTALLED
cls
echo.
echo +==========================================================+
echo ^|                                                          ^|
echo ^|         RAILWAY CLI IS NOT INSTALLED                     ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo  We could not find the 'railway' command in this window.
echo.
echo  Two possible causes:
echo    1. Railway is NOT installed yet.
echo       -^> Please run INSTALL.bat (in this folder) first.
echo.
echo    2. Railway IS installed but this window has an OLD PATH.
echo       -^> Close this window and open RUN.bat again.
echo.
pause
exit /b 1

REM ====== CLEAN EXIT ======
:EXIT_OK
echo.
echo  Good bye!
echo.
exit /b 0

REM ============================================================
REM Helper subroutine: count unique parent directories.
REM Sets RW_MULTI=1 when at least two DIFFERENT folders are seen
REM across the `where railway` results.
REM ============================================================
:CHECK_UNIQUE_DIR
set "_DIR=%~1"
if "%_DIR:~-1%"=="\" set "_DIR=%_DIR:~0,-1%"
if not defined FIRST_DIR goto :CHECK_UNIQUE_FIRST
if /i not "%_DIR%"=="%FIRST_DIR%" set "RW_MULTI=1"
exit /b 0

:CHECK_UNIQUE_FIRST
set "FIRST_DIR=%_DIR%"
exit /b 0
