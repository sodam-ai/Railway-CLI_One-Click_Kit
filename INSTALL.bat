@echo off
chcp 949 >nul 2>&1
setlocal EnableDelayedExpansion
title Railway CLI - 설치 (Installer)

REM ============================================================
REM 관리자 권한이 필요 없습니다 (No administrator needed).
REM 설치는 모두 현재 사용자 폴더(%APPDATA%\npm 또는 %LOCALAPPDATA%)
REM 에만 이뤄지고, 사용자(User) PATH만 바꿉니다. 그래서 UAC 창을
REM 띄우지 않습니다.
REM ============================================================

REM ============================================================
REM DYNAMIC PATH SETUP
REM ============================================================
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
cd /d "%SCRIPT_DIR%"

REM Inject likely Railway install folders into this session's PATH
REM so freshly-installed tools become callable inside this script.
set "PATH=%LOCALAPPDATA%\Programs\Railway;%PATH%"
set "PATH=%APPDATA%\npm;%PATH%"

REM ============================================================
REM LOG FILE
REM ============================================================
set "LOG_FILE=%TEMP%\railway_install.log"
echo Railway CLI install log > "%LOG_FILE%"
echo Started: %DATE% %TIME% >> "%LOG_FILE%"
echo Script:  %~f0 >> "%LOG_FILE%"
echo Folder:  %SCRIPT_DIR% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

cls
echo.
echo +==========================================================+
echo ^|                                                          ^|
echo ^|              RAILWAY CLI - ONE CLICK INSTALL             ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo  이 도구는 Railway CLI를 컴퓨터에 설치합니다.
echo  This tool will install Railway CLI on your computer.
echo  (Railway = 내 앱을 인터넷(클라우드)에 올려 실행해 주는 서비스)
echo.
echo  현재 윈도우 사용자 (Current user):
echo    %USERNAME%
echo.
echo  키트 폴더 (This kit folder):
echo    %SCRIPT_DIR%
echo.
echo  기록 파일 (Log file):
echo    %LOG_FILE%
echo.
echo  잠시 후 시작합니다... (아무 키나 누르면 바로)  Starting now...
timeout /t 2 >nul 2>&1

REM ============================================================
REM PRE-CHECK - INTERNET REACHABILITY
REM ============================================================
echo.
echo ============================================================
echo  PRE-CHECK  -  Test internet connection
echo ============================================================
echo.

set "NET_OK=0"
ping -n 1 -w 3000 github.com >nul 2>&1
if %ERRORLEVEL% EQU 0 set "NET_OK=1"
if "%NET_OK%"=="0" ping -n 1 -w 3000 raw.githubusercontent.com >nul 2>&1
if "%NET_OK%"=="0" if %ERRORLEVEL% EQU 0 set "NET_OK=1"
if "%NET_OK%"=="1" echo    Internet : OK ^(GitHub is reachable^)
if "%NET_OK%"=="0" echo    Internet : [WARN] GitHub is NOT reachable from this PC.
if "%NET_OK%"=="0" echo               Install may fail. Check your network or proxy.
echo Internet reachability: NET_OK=!NET_OK! >> "%LOG_FILE%"

REM ============================================================
REM STEP 1 - CHECK FOR EXISTING INSTALLATION
REM ============================================================
echo.
echo ============================================================
echo  STEP 1 of 5  -  Check if Railway is already installed
echo ============================================================
echo.

where railway >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :NOT_YET_INSTALLED

REM Railway IS installed.  AUTOMATICALLY run `railway upgrade` - no prompt.
set "EXISTING_VER=unknown"
for /f "delims=" %%v in ('railway --version 2^>nul') do set "EXISTING_VER=%%v"
echo  Railway is already installed.
echo    Current version: !EXISTING_VER!
echo.
echo  Installed in:
for /f "delims=" %%p in ('where railway 2^>nul') do echo    %%p

REM Count UNIQUE install folders (informational warning only).
set "FIRST_DIR="
set "RW_MULTI=0"
for /f "delims=" %%p in ('where railway 2^>nul') do call :CHECK_UNIQUE_DIR "%%~dpp"
if "%RW_MULTI%"=="1" echo.
if "%RW_MULTI%"=="1" echo  [WARN] Railway is installed in MORE THAN ONE folder.
if "%RW_MULTI%"=="1" echo         Run UNINSTALL.bat first if you want a clean state.

echo.
echo  Auto-updating to the latest version. No input needed.
echo  Running: railway upgrade
echo Auto-update started. Existing version: !EXISTING_VER! >> "%LOG_FILE%"
timeout /t 2 >nul 2>&1
echo  -----------------------------------------------------------
call railway upgrade
set "UPG_RC=%ERRORLEVEL%"
echo  -----------------------------------------------------------
echo railway upgrade exit code: %UPG_RC% >> "%LOG_FILE%"
if %UPG_RC% NEQ 0 goto :UPDATE_FAILED_FALLBACK

set "NEW_VER=unknown"
for /f "delims=" %%v in ('railway --version 2^>nul') do set "NEW_VER=%%v"
echo.
if "!NEW_VER!"=="!EXISTING_VER!" goto :UPDATE_NO_CHANGE

echo +==========================================================+
echo ^|                                                          ^|
echo ^|             UPDATE COMPLETE!                             ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo    Was: !EXISTING_VER!
echo    Now: !NEW_VER!
goto :UPDATE_FINAL

:UPDATE_NO_CHANGE
echo +==========================================================+
echo ^|                                                          ^|
echo ^|             ALREADY UP TO DATE                           ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo    Version: !EXISTING_VER!
echo    Your Railway CLI is already on the latest version.

:UPDATE_FINAL
echo.
echo  Run RUN.bat in this folder to use Railway easily.
echo  Install log: %LOG_FILE%
echo.
echo  This window can be closed safely now. Press any key to exit.
echo Update finished. !EXISTING_VER! to !NEW_VER! >> "%LOG_FILE%"
echo Finished: %DATE% %TIME% >> "%LOG_FILE%"
pause
exit /b 0

:UPDATE_FAILED_FALLBACK
echo.
echo  'railway upgrade' did not finish cleanly (exit %UPG_RC%).
echo  Falling back to a full reinstall via npm/binary download...
echo Update failed, falling back to full reinstall. >> "%LOG_FILE%"
goto :NO_EXISTING

:NOT_YET_INSTALLED
echo  [OK] Railway is not installed yet on this computer.
echo       Will proceed to install a fresh copy.
echo Railway not yet installed. Proceeding with fresh install. >> "%LOG_FILE%"

:NO_EXISTING

REM ============================================================
REM STEP 2 - DETECT AVAILABLE INSTALLER TOOLS
REM ============================================================
echo.
echo ============================================================
echo  STEP 2 of 5  -  Check available installer tools
echo ============================================================
echo.

set "HAS_NODE=0"
set "HAS_NPM=0"
set "HAS_POWERSHELL=0"
set "NODE_VER=none"
set "NPM_VER=none"
set "NODE_MAJOR=0"

where node >nul 2>&1
if %ERRORLEVEL% EQU 0 set "HAS_NODE=1"

where npm >nul 2>&1
if %ERRORLEVEL% EQU 0 set "HAS_NPM=1"

where powershell >nul 2>&1
if %ERRORLEVEL% EQU 0 set "HAS_POWERSHELL=1"

REM Read Node version using a flat (non-block) for loop
if "%HAS_NODE%"=="0" goto :SKIP_NODE_VER
for /f "delims=" %%v in ('node -v 2^>nul') do set "NODE_VER=%%v"
REM Strip leading 'v' then take first token before '.'
set "NODE_VER_TRIM=!NODE_VER:~1!"
for /f "tokens=1 delims=." %%a in ("!NODE_VER_TRIM!") do set "NODE_MAJOR=%%a"
:SKIP_NODE_VER

if "%HAS_NPM%"=="0" goto :SKIP_NPM_VER
for /f "delims=" %%v in ('npm -v 2^>nul') do set "NPM_VER=%%v"
:SKIP_NPM_VER

REM Display detected versions
if "%HAS_NODE%"=="1" echo    Node.js    : found !NODE_VER!  (major: !NODE_MAJOR!)
if "%HAS_NODE%"=="0" echo    Node.js    : not found
if "%HAS_NPM%"=="1"  echo    npm        : found v!NPM_VER!
if "%HAS_NPM%"=="0"  echo    npm        : not found
if "%HAS_POWERSHELL%"=="1" echo    PowerShell : found
if "%HAS_POWERSHELL%"=="0" echo    PowerShell : not found

REM Log detection results
echo Detection: HAS_NODE=%HAS_NODE% HAS_NPM=%HAS_NPM% HAS_POWERSHELL=%HAS_POWERSHELL% NODE=!NODE_VER! NPM=!NPM_VER! >> "%LOG_FILE%"

REM Warn if Node version is too old (Railway CLI prefers Node 16+)
set "NPM_USABLE=%HAS_NPM%"
if "%HAS_NODE%"=="0" goto :SKIP_NODE_AGE_CHECK
if !NODE_MAJOR! LSS 16 echo.
if !NODE_MAJOR! LSS 16 echo    [WARN] Node 16 or newer is recommended for Railway CLI.
if !NODE_MAJOR! LSS 16 echo           You have Node !NODE_VER!. npm install may fail.
if !NODE_MAJOR! LSS 16 echo           Will try anyway, with binary download as backup.
:SKIP_NODE_AGE_CHECK

REM Decide overall plan
if "%HAS_NPM%"=="0" if "%HAS_POWERSHELL%"=="0" goto :NO_INSTALLER

echo.
echo  Installation plan:
if "%HAS_NPM%"=="1" echo    Method 1 (preferred): npm install -g @railway/cli
if "%HAS_NPM%"=="1" if "%HAS_POWERSHELL%"=="1" echo    Method 2 (fallback):  download from GitHub releases
if "%HAS_NPM%"=="0" if "%HAS_POWERSHELL%"=="1" echo    Method 1: download from GitHub releases (npm not available)

echo.
echo  Starting installation... (press any key to skip the wait)
timeout /t 2 >nul 2>&1

REM ============================================================
REM STEP 3 - INSTALL
REM ============================================================
echo.
echo ============================================================
echo  STEP 3 of 5  -  Install Railway CLI
echo ============================================================
echo.

set "INSTALL_OK=0"
set "INSTALL_METHOD=none"

if "%HAS_NPM%"=="1" goto :TRY_NPM
goto :TRY_BINARY

:TRY_NPM
echo  [Method 1] Installing with npm...
echo    Command: npm install -g @railway/cli --no-audit --no-fund
echo.
echo  This usually takes 30 to 90 seconds. Please wait while npm
echo  downloads and installs Railway. You will see npm's own output
echo  appear below. Do NOT close this window.
echo  -----------------------------------------------------------
echo. >> "%LOG_FILE%"
echo === npm install attempt at %TIME% === >> "%LOG_FILE%"
call npm install -g @railway/cli --no-audit --no-fund
set "NPM_RC=%ERRORLEVEL%"
echo  -----------------------------------------------------------
echo npm exit code: %NPM_RC% >> "%LOG_FILE%"
REM Log npm prefix (where global packages live) for future debugging
for /f "delims=" %%p in ('npm config get prefix 2^>nul') do echo npm prefix: %%p >> "%LOG_FILE%"
if %NPM_RC% NEQ 0 goto :NPM_FAILED
set "INSTALL_OK=1"
set "INSTALL_METHOD=npm"
echo  [OK] npm install succeeded.
goto :AFTER_INSTALL

:NPM_FAILED
echo  [WARN] npm install failed (exit code %NPM_RC%).
echo         Full log: %LOG_FILE%
echo         Trying next method...
echo.

:TRY_BINARY
if "%HAS_POWERSHELL%"=="0" goto :ALL_METHODS_FAILED
echo  [Method 2] Downloading Railway from GitHub releases...
echo.

REM Build the PowerShell installer script in TEMP via certutil decode
call :WRITE_INSTALLER_PS1
if not exist "%TEMP%\railway_bininst.ps1" goto :BINARY_WRITE_FAILED

echo === Binary install attempt at %TIME% === >> "%LOG_FILE%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\railway_bininst.ps1"
set "PS_RC=%ERRORLEVEL%"
echo Binary install exit code: %PS_RC% >> "%LOG_FILE%"
del "%TEMP%\railway_bininst.ps1" >nul 2>&1

if %PS_RC% NEQ 0 goto :BINARY_FAILED
set "INSTALL_OK=1"
set "INSTALL_METHOD=binary"
echo.
echo  [OK] Binary install succeeded.
goto :AFTER_INSTALL

:BINARY_WRITE_FAILED
echo  [ERROR] Could not write the PowerShell installer to TEMP.
echo          Check that %TEMP% is writable.
goto :ALL_METHODS_FAILED

:BINARY_FAILED
echo  [ERROR] Binary install failed (exit code %PS_RC%).
echo          See log: %LOG_FILE%
goto :ALL_METHODS_FAILED

:ALL_METHODS_FAILED
echo.
echo +==========================================================+
echo ^|                  INSTALLATION FAILED                     ^|
echo +==========================================================+
echo.
echo  All install methods failed.
echo  Log file: %LOG_FILE%
echo.
echo  Please try one of these:
echo    1. Install Node.js (16 or newer) from https://nodejs.org/
echo       then run INSTALL.bat again.
echo    2. Download Railway manually from:
echo       https://github.com/railwayapp/cli/releases/latest
echo.
echo All methods failed. Final result: FAILED >> "%LOG_FILE%"
pause
exit /b 3

:NO_INSTALLER
echo.
echo +==========================================================+
echo ^|                  CANNOT INSTALL                          ^|
echo +==========================================================+
echo.
echo  [ERROR] No installer tool was found on this computer.
echo.
echo  You need either:
echo    - Node.js 16+ from https://nodejs.org/  ^(easiest^)
echo    - or Windows PowerShell ^(built into Windows 10/11^)
echo.
echo  Please install Node.js, then run INSTALL.bat again.
echo.
echo No installer tool available. Final result: FAILED >> "%LOG_FILE%"
pause
exit /b 2

REM ============================================================
REM STEP 4 - UPDATE PATH
REM ============================================================
:AFTER_INSTALL
echo.
echo ============================================================
echo  STEP 4 of 5  -  Add Railway to your PATH
echo ============================================================
echo.

REM Refresh current session PATH so STEP 5 can find the new exe
set "PATH=%LOCALAPPDATA%\Programs\Railway;%PATH%"
set "PATH=%APPDATA%\npm;%PATH%"

if "%INSTALL_METHOD%"=="npm" goto :PATH_NPM
goto :PATH_BINARY

:PATH_NPM
echo  npm installs Railway into:
echo    %APPDATA%\npm
echo  Making sure that folder is on your user PATH...
call :WRITE_PATHADD_PS1
if not exist "%TEMP%\railway_pathadd.ps1" goto :PATH_NPM_NOPS
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\railway_pathadd.ps1" -AddPath "%APPDATA%\npm"
del "%TEMP%\railway_pathadd.ps1" >nul 2>&1
goto :STEP_VERIFY

:PATH_NPM_NOPS
echo  [WARN] Could not write the PATH updater to TEMP.
echo         If 'railway' is not found later, add this to PATH manually:
echo           %APPDATA%\npm
goto :STEP_VERIFY

:PATH_BINARY
echo  Adding Railway folder to your user PATH (persistent)...
call :WRITE_PATHADD_PS1
if not exist "%TEMP%\railway_pathadd.ps1" goto :PATH_BINARY_NOPS
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\railway_pathadd.ps1" -AddPath "%LOCALAPPDATA%\Programs\Railway"
del "%TEMP%\railway_pathadd.ps1" >nul 2>&1
goto :STEP_VERIFY

:PATH_BINARY_NOPS
echo  [WARN] Could not write the PATH updater to TEMP.
echo         Please add this folder to your PATH manually:
echo           %LOCALAPPDATA%\Programs\Railway
goto :STEP_VERIFY

REM ============================================================
REM STEP 5 - VERIFY
REM ============================================================
:STEP_VERIFY
echo.
echo ============================================================
echo  STEP 5 of 5  -  Check that Railway works
echo ============================================================
echo.

where railway >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :HAVE_RAILWAY
echo  [안내] 아직 이 창에서는 'railway' 명령이 안 보입니다 (정상입니다).
echo  [WARN] 'railway' not found in THIS window yet (this is normal).
echo         창을 모두 닫고 '시작하기.bat'을 새로 여세요.
echo         Please CLOSE this window and open 시작하기.bat again.
echo         (직접 확인하려면 / to check:  railway --version)
goto :END_OK

:HAVE_RAILWAY
set "FINAL_VER=unknown"
for /f "delims=" %%v in ('railway --version 2^>nul') do set "FINAL_VER=%%v"
echo  Installed version:
echo    !FINAL_VER!
echo.
echo  Location:
for /f "delims=" %%p in ('where railway 2^>nul') do echo    %%p
echo.
echo  Install method: !INSTALL_METHOD!
echo  [OK] Railway CLI is working in this window!

:END_OK
echo.
echo +==========================================================+
echo ^|                                                          ^|
echo ^|          설치 완료!  INSTALLATION COMPLETE!              ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo  다음에 할 일 (What to do next):
echo    1. 이 폴더의 '시작하기.bat'을 실행하면 한국어로 쉽게 사용할 수 있어요.
echo       Run 시작하기.bat (or RUN.bat) in this folder.
echo    2. 또는 새 명령창에서 직접 (or type in a new window):  railway login
echo.
echo  나중에 지우려면 UNINSTALL.bat 실행.  To remove later, run UNINSTALL.bat.
echo.
echo  기록 파일 (Install log): %LOG_FILE%
echo.
echo  이제 이 창을 닫아도 됩니다. 아무 키나 누르면 종료.
echo  This window can be closed safely now. Press any key to exit.
echo Install method: %INSTALL_METHOD% >> "%LOG_FILE%"
echo Final result: SUCCESS >> "%LOG_FILE%"
echo Finished: %DATE% %TIME% >> "%LOG_FILE%"
pause
exit /b 0

REM ============================================================
REM Helper subroutine: count unique parent directories.
REM Called from a `for /f` loop with each `where railway` result's
REM parent directory (`%%~dpp`).  Sets RW_MULTI=1 when at least two
REM DIFFERENT folders are seen.  Uses FIRST_DIR as the anchor.
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

REM ============================================================
REM Helper subroutine: write the PowerShell binary installer
REM to %TEMP%\railway_bininst.ps1 via certutil -decode
REM ============================================================
:WRITE_INSTALLER_PS1
set "B64FILE=%TEMP%\railway_bininst.b64"
set "PS1FILE=%TEMP%\railway_bininst.ps1"
if exist "%B64FILE%" del "%B64FILE%" >nul 2>&1
if exist "%PS1FILE%" del "%PS1FILE%" >nul 2>&1

>"%B64FILE%" echo JEVycm9yQWN0aW9uUHJlZmVyZW5jZSA9ICdTdG9wJwp0cnkgeyBbQ29uc29sZV06
>>"%B64FILE%" echo Ok91dHB1dEVuY29kaW5nID0gW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6VVRGOCB9
>>"%B64FILE%" echo IGNhdGNoIHt9CltOZXQuU2VydmljZVBvaW50TWFuYWdlcl06OlNlY3VyaXR5UHJv
>>"%B64FILE%" echo dG9jb2wgPSBbTmV0LlNlY3VyaXR5UHJvdG9jb2xUeXBlXTo6VGxzMTIKCldyaXRl
>>"%B64FILE%" echo LUhvc3QgJyAgWzEvNF0gQ2hlY2tpbmcgZm9yIHRhciBjb21tYW5kLi4uJwokdGFy
>>"%B64FILE%" echo Q21kID0gR2V0LUNvbW1hbmQgdGFyIC1FcnJvckFjdGlvbiBTaWxlbnRseUNvbnRp
>>"%B64FILE%" echo bnVlCmlmICgtbm90ICR0YXJDbWQpIHsKICAgIFdyaXRlLUhvc3QgJyAgW0VSUk9S
>>"%B64FILE%" echo XSB0YXIgY29tbWFuZCBub3QgZm91bmQgb24gdGhpcyBzeXN0ZW0uJwogICAgV3Jp
>>"%B64FILE%" echo dGUtSG9zdCAnICAgICAgICAgIFdpbmRvd3MgMTAgKEFwcmlsIDIwMTgsIGJ1aWxk
>>"%B64FILE%" echo IDE3MDYzKSBvciBsYXRlciBpcyByZXF1aXJlZC4nCiAgICBXcml0ZS1Ib3N0ICcg
>>"%B64FILE%" echo ICAgICAgICAgUGxlYXNlIHVzZSB0aGUgbnBtIGluc3RhbGwgbWV0aG9kIGluc3Rl
>>"%B64FILE%" echo YWQsIG9yIHVwZ3JhZGUgV2luZG93cy4nCiAgICBleGl0IDEwCn0KCldyaXRlLUhv
>>"%B64FILE%" echo c3QgJyAgWzIvNF0gRmluZGluZyBsYXRlc3QgUmFpbHdheSByZWxlYXNlIHRhZy4u
>>"%B64FILE%" echo LicKJHJlcSA9IFtTeXN0ZW0uTmV0Lkh0dHBXZWJSZXF1ZXN0XTo6Q3JlYXRlKCdo
>>"%B64FILE%" echo dHRwczovL2dpdGh1Yi5jb20vcmFpbHdheWFwcC9jbGkvcmVsZWFzZXMvbGF0ZXN0
>>"%B64FILE%" echo JykKJHJlcS5BbGxvd0F1dG9SZWRpcmVjdCA9ICRmYWxzZQokcmVxLk1ldGhvZCA9
>>"%B64FILE%" echo ICdIRUFEJwokcmVxLlVzZXJBZ2VudCA9ICdyYWlsd2F5LWluc3RhbGxlcicKJHJl
>>"%B64FILE%" echo cS5UaW1lb3V0ID0gMzAwMDAKJGxvYyA9ICRudWxsCnRyeSB7CiAgICAkcmVzcCA9
>>"%B64FILE%" echo ICRyZXEuR2V0UmVzcG9uc2UoKQogICAgJGxvYyA9ICRyZXNwLkhlYWRlcnNbJ0xv
>>"%B64FILE%" echo Y2F0aW9uJ10KICAgICRyZXNwLkNsb3NlKCkKfSBjYXRjaCB7CiAgICBXcml0ZS1I
>>"%B64FILE%" echo b3N0ICgnICBbRVJST1JdIEdpdEh1YiByZXF1ZXN0IGZhaWxlZDogJyArICRfLkV4
>>"%B64FILE%" echo Y2VwdGlvbi5NZXNzYWdlKQogICAgZXhpdCAxMQp9CmlmICgtbm90ICRsb2MpIHsK
>>"%B64FILE%" echo ICAgIFdyaXRlLUhvc3QgJyAgW0VSUk9SXSBObyBMb2NhdGlvbiBoZWFkZXIgZnJv
>>"%B64FILE%" echo bSBHaXRIdWIgcmVkaXJlY3QuJwogICAgZXhpdCAxMgp9CiR0YWcgPSAkbG9jLlNw
>>"%B64FILE%" echo bGl0KCcvJylbLTFdCldyaXRlLUhvc3QgKCcgICAgICAgICBMYXRlc3QgdGFnOiAn
>>"%B64FILE%" echo ICsgJHRhZykKJHZlciA9ICR0YWcuVHJpbVN0YXJ0KCd2JykKCiRhc3NldE5hbWUg
>>"%B64FILE%" echo PSAncmFpbHdheS12JyArICR2ZXIgKyAnLXg4Nl82NC1wYy13aW5kb3dzLW1zdmMu
>>"%B64FILE%" echo dGFyLmd6JwokYXNzZXRVcmwgPSAnaHR0cHM6Ly9naXRodWIuY29tL3JhaWx3YXlh
>>"%B64FILE%" echo cHAvY2xpL3JlbGVhc2VzL2Rvd25sb2FkLycgKyAkdGFnICsgJy8nICsgJGFzc2V0
>>"%B64FILE%" echo TmFtZQokdGVtcERpciA9IEpvaW4tUGF0aCAkZW52OlRFTVAgKCdyYWlsd2F5X2Rs
>>"%B64FILE%" echo XycgKyBbR3VpZF06Ok5ld0d1aWQoKS5Ub1N0cmluZygnTicpKQpOZXctSXRlbSAt
>>"%B64FILE%" echo SXRlbVR5cGUgRGlyZWN0b3J5IC1QYXRoICR0ZW1wRGlyIC1Gb3JjZSB8IE91dC1O
>>"%B64FILE%" echo dWxsCiR0YXJQYXRoID0gSm9pbi1QYXRoICR0ZW1wRGlyICRhc3NldE5hbWUKCldy
>>"%B64FILE%" echo aXRlLUhvc3QgKCcgIFszLzRdIERvd25sb2FkaW5nICcgKyAkYXNzZXROYW1lICsg
>>"%B64FILE%" echo JyAuLi4nKQp0cnkgewogICAgSW52b2tlLVdlYlJlcXVlc3QgLVVyaSAkYXNzZXRV
>>"%B64FILE%" echo cmwgLU91dEZpbGUgJHRhclBhdGggLVVzZUJhc2ljUGFyc2luZyAtVXNlckFnZW50
>>"%B64FILE%" echo ICdyYWlsd2F5LWluc3RhbGxlcicgLVRpbWVvdXRTZWMgMTgwCn0gY2F0Y2ggewog
>>"%B64FILE%" echo ICAgV3JpdGUtSG9zdCAoJyAgW0VSUk9SXSBEb3dubG9hZCBmYWlsZWQ6ICcgKyAk
>>"%B64FILE%" echo Xy5FeGNlcHRpb24uTWVzc2FnZSkKICAgIFJlbW92ZS1JdGVtICR0ZW1wRGlyIC1S
>>"%B64FILE%" echo ZWN1cnNlIC1Gb3JjZSAtRXJyb3JBY3Rpb24gU2lsZW50bHlDb250aW51ZQogICAg
>>"%B64FILE%" echo ZXhpdCAxMwp9CgpXcml0ZS1Ib3N0ICcgIFs0LzRdIEV4dHJhY3RpbmcgYW5kIGlu
>>"%B64FILE%" echo c3RhbGxpbmcuLi4nClB1c2gtTG9jYXRpb24gJHRlbXBEaXIKdHJ5IHsKICAgICYg
>>"%B64FILE%" echo dGFyIC14emYgJHRhclBhdGggMj4mMSB8IE91dC1OdWxsCiAgICBpZiAoJExBU1RF
>>"%B64FILE%" echo WElUQ09ERSAtbmUgMCkgeyB0aHJvdyAndGFyIGV4dHJhY3Rpb24gZmFpbGVkJyB9
>>"%B64FILE%" echo Cn0gY2F0Y2ggewogICAgUG9wLUxvY2F0aW9uCiAgICBXcml0ZS1Ib3N0ICgnICBb
>>"%B64FILE%" echo RVJST1JdIEV4dHJhY3QgZmFpbGVkOiAnICsgJF8uRXhjZXB0aW9uLk1lc3NhZ2Up
>>"%B64FILE%" echo CiAgICBSZW1vdmUtSXRlbSAkdGVtcERpciAtUmVjdXJzZSAtRm9yY2UgLUVycm9y
>>"%B64FILE%" echo QWN0aW9uIFNpbGVudGx5Q29udGludWUKICAgIGV4aXQgMTQKfQpQb3AtTG9jYXRp
>>"%B64FILE%" echo b24KCiRleGUgPSBHZXQtQ2hpbGRJdGVtIC1QYXRoICR0ZW1wRGlyIC1SZWN1cnNl
>>"%B64FILE%" echo IC1GaWx0ZXIgJ3JhaWx3YXkuZXhlJyB8IFNlbGVjdC1PYmplY3QgLUZpcnN0IDEK
>>"%B64FILE%" echo aWYgKC1ub3QgJGV4ZSkgewogICAgV3JpdGUtSG9zdCAnICBbRVJST1JdIHJhaWx3
>>"%B64FILE%" echo YXkuZXhlIG5vdCBmb3VuZCBpbnNpZGUgdGhlIGRvd25sb2FkZWQgYXJjaGl2ZS4n
>>"%B64FILE%" echo CiAgICBSZW1vdmUtSXRlbSAkdGVtcERpciAtUmVjdXJzZSAtRm9yY2UgLUVycm9y
>>"%B64FILE%" echo QWN0aW9uIFNpbGVudGx5Q29udGludWUKICAgIGV4aXQgMTUKfQoKJGluc3RhbGxE
>>"%B64FILE%" echo aXIgPSBKb2luLVBhdGggJGVudjpMT0NBTEFQUERBVEEgJ1Byb2dyYW1zXFJhaWx3
>>"%B64FILE%" echo YXknCmlmICgtbm90IChUZXN0LVBhdGggJGluc3RhbGxEaXIpKSB7CiAgICBOZXct
>>"%B64FILE%" echo SXRlbSAtSXRlbVR5cGUgRGlyZWN0b3J5IC1QYXRoICRpbnN0YWxsRGlyIC1Gb3Jj
>>"%B64FILE%" echo ZSB8IE91dC1OdWxsCn0KCnRyeSB7CiAgICBDb3B5LUl0ZW0gLVBhdGggJGV4ZS5G
>>"%B64FILE%" echo dWxsTmFtZSAtRGVzdGluYXRpb24gKEpvaW4tUGF0aCAkaW5zdGFsbERpciAncmFp
>>"%B64FILE%" echo bHdheS5leGUnKSAtRm9yY2UKfSBjYXRjaCB7CiAgICBXcml0ZS1Ib3N0ICgnICBb
>>"%B64FILE%" echo RVJST1JdIENvdWxkIG5vdCBjb3B5IHJhaWx3YXkuZXhlOiAnICsgJF8uRXhjZXB0
>>"%B64FILE%" echo aW9uLk1lc3NhZ2UpCiAgICBSZW1vdmUtSXRlbSAkdGVtcERpciAtUmVjdXJzZSAt
>>"%B64FILE%" echo Rm9yY2UgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUKICAgIGV4aXQgMTYK
>>"%B64FILE%" echo fQpSZW1vdmUtSXRlbSAkdGVtcERpciAtUmVjdXJzZSAtRm9yY2UgLUVycm9yQWN0
>>"%B64FILE%" echo aW9uIFNpbGVudGx5Q29udGludWUKCldyaXRlLUhvc3QgKCcgICAgICAgICBJbnN0
>>"%B64FILE%" echo YWxsZWQgdG86ICcgKyAoSm9pbi1QYXRoICRpbnN0YWxsRGlyICdyYWlsd2F5LmV4
>>"%B64FILE%" echo ZScpKQpleGl0IDAK

certutil -decode "%B64FILE%" "%PS1FILE%" >nul 2>&1
del "%B64FILE%" >nul 2>&1
exit /b 0

REM ============================================================
REM Helper subroutine: write the PowerShell PATH-add script
REM ============================================================
:WRITE_PATHADD_PS1
set "B64FILE=%TEMP%\railway_pathadd.b64"
set "PS1FILE=%TEMP%\railway_pathadd.ps1"
if exist "%B64FILE%" del "%B64FILE%" >nul 2>&1
if exist "%PS1FILE%" del "%PS1FILE%" >nul 2>&1

>"%B64FILE%" echo cGFyYW0oW3N0cmluZ10kQWRkUGF0aCkKJEVycm9yQWN0aW9uUHJlZmVyZW5jZSA9
>>"%B64FILE%" echo ICdTdG9wJwp0cnkgeyBbQ29uc29sZV06Ok91dHB1dEVuY29kaW5nID0gW1N5c3Rl
>>"%B64FILE%" echo bS5UZXh0LkVuY29kaW5nXTo6VVRGOCB9IGNhdGNoIHt9CmlmIChbc3RyaW5nXTo6
>>"%B64FILE%" echo SXNOdWxsT3JFbXB0eSgkQWRkUGF0aCkpIHsKICAgIFdyaXRlLUhvc3QgJyAgW0VS
>>"%B64FILE%" echo Uk9SXSBBZGRQYXRoIGFyZ3VtZW50IGlzIGVtcHR5LicKICAgIGV4aXQgMQp9CiRw
>>"%B64FILE%" echo ID0gW0Vudmlyb25tZW50XTo6R2V0RW52aXJvbm1lbnRWYXJpYWJsZSgnUGF0aCcs
>>"%B64FILE%" echo ICdVc2VyJykKaWYgKCRudWxsIC1lcSAkcCkgeyAkcCA9ICcnIH0KJGV4aXN0cyA9
>>"%B64FILE%" echo ICRmYWxzZQpmb3JlYWNoICgkcGFydCBpbiAkcC5TcGxpdCgnOycpKSB7CiAgICBp
>>"%B64FILE%" echo ZiAoJHBhcnQuVHJpbUVuZCgnXCcpIC1pZXEgJEFkZFBhdGguVHJpbUVuZCgnXCcp
>>"%B64FILE%" echo KSB7ICRleGlzdHMgPSAkdHJ1ZTsgYnJlYWsgfQp9CmlmICgkZXhpc3RzKSB7CiAg
>>"%B64FILE%" echo ICBXcml0ZS1Ib3N0ICcgIFtPS10gUEFUSCBhbHJlYWR5IGNvbnRhaW5zIHRoZSBS
>>"%B64FILE%" echo YWlsd2F5IGZvbGRlci4nCn0gZWxzZSB7CiAgICAkbmV3UCA9ICRwLlRyaW1FbmQo
>>"%B64FILE%" echo JzsnKQogICAgaWYgKCRuZXdQLkxlbmd0aCAtZ3QgMCkgeyAkbmV3UCA9ICRuZXdQ
>>"%B64FILE%" echo ICsgJzsnICsgJEFkZFBhdGggfSBlbHNlIHsgJG5ld1AgPSAkQWRkUGF0aCB9CiAg
>>"%B64FILE%" echo ICBbRW52aXJvbm1lbnRdOjpTZXRFbnZpcm9ubWVudFZhcmlhYmxlKCdQYXRoJywg
>>"%B64FILE%" echo JG5ld1AsICdVc2VyJykKICAgIFdyaXRlLUhvc3QgKCcgIFtPS10gQWRkZWQgdG8g
>>"%B64FILE%" echo dXNlciBQQVRIOiAnICsgJEFkZFBhdGgpCiAgICBXcml0ZS1Ib3N0ICcgICAgICAg
>>"%B64FILE%" echo T3BlbiBhIE5FVyBDb21tYW5kIFByb21wdCB0byBzZWUgdGhlIGNoYW5nZS4nCn0K
>>"%B64FILE%" echo ZXhpdCAwCg==

certutil -decode "%B64FILE%" "%PS1FILE%" >nul 2>&1
del "%B64FILE%" >nul 2>&1
exit /b 0
