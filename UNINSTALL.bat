@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion
title Railway CLI - Uninstaller

REM ============================================================
REM AUTO-ELEVATE TO ADMINISTRATOR
REM ============================================================
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :NEED_ELEVATE
goto :AFTER_ELEVATE

:NEED_ELEVATE
echo Asking for administrator permission...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b 0

:AFTER_ELEVATE

REM ============================================================
REM DYNAMIC PATH SETUP
REM ============================================================
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
cd /d "%SCRIPT_DIR%"

set "PATH=%LOCALAPPDATA%\Programs\Railway;%PATH%"
set "PATH=%APPDATA%\npm;%PATH%"

set "LOG_FILE=%TEMP%\railway_uninstall.log"
echo Railway CLI uninstall log > "%LOG_FILE%"
echo Started: %DATE% %TIME% >> "%LOG_FILE%"

cls
echo.
echo +==========================================================+
echo ^|                                                          ^|
echo ^|            RAILWAY CLI - SAFE COMPLETE REMOVAL           ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo  This tool will completely remove Railway CLI from your computer.
echo.
echo  Current Windows user:
echo    %USERNAME%
echo.
echo  It will:
echo    1. Try to log you out of Railway (if possible).
echo    2. Remove the npm package @railway/cli (if installed via npm).
echo    3. Remove the scoop package railway (if installed via scoop).
echo    4. Remove the cargo binary railwayapp (if installed via cargo).
echo    5. Delete the binary install folder if it exists.
echo    6. Clean Railway folder out of your user PATH and system PATH.
echo    7. Delete Railway configuration folders.
echo.
echo  Log file:
echo    %LOG_FILE%
echo.
echo  Scanning now... (press any key to skip the wait)
timeout /t 2 >nul 2>&1

REM ============================================================
REM SCAN ALL railway.exe LOCATIONS
REM ============================================================
echo.
echo ============================================================
echo  SCAN  -  Find every railway.exe on this computer's PATH
echo ============================================================
echo.

set "RW_FOUND=0"
where railway >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :SCAN_DONE
set "RW_FOUND=1"
echo  Found Railway installations:
for /f "delims=" %%p in ('where railway 2^>nul') do echo    %%p
for /f "delims=" %%p in ('where railway 2^>nul') do echo Found: %%p >> "%LOG_FILE%"
echo.

:SCAN_DONE
if "%RW_FOUND%"=="0" echo  No 'railway' command currently visible on PATH.
if "%RW_FOUND%"=="0" echo  Will still check for leftover files.
if "%RW_FOUND%"=="0" echo.

REM Pre-scan package managers and known folders.  Track FOUND_ANY so we
REM can short-circuit when there is literally nothing to clean.
set "FOUND_ANY=%RW_FOUND%"
echo  Will check and clean these (only the ones that exist):
echo.
where npm >nul 2>&1
if %ERRORLEVEL% EQU 0 call npm list -g @railway/cli >nul 2>&1
if %ERRORLEVEL% EQU 0 echo    [Found] npm package: @railway/cli
if %ERRORLEVEL% EQU 0 set "FOUND_ANY=1"
where scoop >nul 2>&1
if %ERRORLEVEL% EQU 0 call scoop list railway >nul 2>&1
if %ERRORLEVEL% EQU 0 echo    [Found] scoop package: railway
if %ERRORLEVEL% EQU 0 set "FOUND_ANY=1"
where cargo >nul 2>&1
if %ERRORLEVEL% EQU 0 echo    [Found] cargo command (will try to uninstall railwayapp)
if %ERRORLEVEL% EQU 0 set "FOUND_ANY=1"
if exist "%LOCALAPPDATA%\Programs\Railway" echo    [Found] binary folder: %LOCALAPPDATA%\Programs\Railway
if exist "%LOCALAPPDATA%\Programs\Railway" set "FOUND_ANY=1"
if exist "%USERPROFILE%\.railway"          echo    [Found] config folder: %USERPROFILE%\.railway
if exist "%USERPROFILE%\.railway"          set "FOUND_ANY=1"
if exist "%APPDATA%\railway"               echo    [Found] config folder: %APPDATA%\railway
if exist "%APPDATA%\railway"               set "FOUND_ANY=1"
if exist "%LOCALAPPDATA%\railway"          echo    [Found] config folder: %LOCALAPPDATA%\railway
if exist "%LOCALAPPDATA%\railway"          set "FOUND_ANY=1"
echo.

if "%FOUND_ANY%"=="0" goto :NOTHING_FOUND

REM ============================================================
REM MASTER CONFIRMATION
REM ============================================================
echo  Are you SURE you want to remove Railway CLI?
echo    Type DELETE and press Enter to continue.
echo    Type anything else to cancel.
echo.
set "MASTER_CONFIRM="
set /p "MASTER_CONFIRM=Confirm: "
if /i not "!MASTER_CONFIRM!"=="DELETE" goto :USER_CANCEL

echo.
echo  Starting removal. This may take a minute...
echo Removal started: %DATE% %TIME% >> "%LOG_FILE%"

REM Phase result tracker (DONE/SKIP/WARN per phase)
set "R_LOGOUT=SKIP"
set "R_NPM=SKIP"
set "R_SCOOP=SKIP"
set "R_CARGO=SKIP"
set "R_BINDIR=SKIP"
set "R_PATH=SKIP"
set "R_CFG=SKIP"

REM ============================================================
REM PHASE 1 - LOGOUT (best effort)
REM ============================================================
echo.
echo ----- Phase 1 of 6: Logout from Railway ---------------------
where railway >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :PHASE1_DONE
call railway logout >nul 2>&1
set "R_LOGOUT=DONE"
echo  [OK] Logout attempted.
goto :PHASE1_NEXT

:PHASE1_DONE
echo  [SKIP] railway command not found.

:PHASE1_NEXT

REM ============================================================
REM PHASE 2 - REMOVE npm PACKAGE
REM ============================================================
echo.
echo ----- Phase 2 of 6: Remove npm package ----------------------
where npm >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :PHASE2_NONPM
echo  Running: npm uninstall -g @railway/cli
echo  This usually takes 5 to 20 seconds. Please wait...
echo  -----------------------------------------------------------
call npm uninstall -g @railway/cli
set "UNRC=%ERRORLEVEL%"
echo  -----------------------------------------------------------
echo npm uninstall exit code: %UNRC% >> "%LOG_FILE%"
if %UNRC% EQU 0 set "R_NPM=DONE"
if %UNRC% EQU 0 echo  [OK] npm uninstall finished.
if %UNRC% NEQ 0 echo  [SKIP] No npm package to remove ^(or already removed^).
goto :PHASE2_NEXT

:PHASE2_NONPM
echo  [SKIP] npm not available.

:PHASE2_NEXT

REM ============================================================
REM PHASE 3 - REMOVE scoop PACKAGE
REM ============================================================
echo.
echo ----- Phase 3 of 6: Remove scoop package --------------------
where scoop >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :PHASE3_NOSCOOP
echo  Running: scoop uninstall railway
echo  -----------------------------------------------------------
call scoop uninstall railway
set "SCRC=%ERRORLEVEL%"
echo  -----------------------------------------------------------
echo scoop uninstall exit code: %SCRC% >> "%LOG_FILE%"
if %SCRC% EQU 0 set "R_SCOOP=DONE"
if %SCRC% EQU 0 echo  [OK] scoop uninstall finished.
if %SCRC% NEQ 0 echo  [SKIP] No scoop package to remove ^(or already removed^).
goto :PHASE3_NEXT

:PHASE3_NOSCOOP
echo  [SKIP] scoop not available.

:PHASE3_NEXT

REM ============================================================
REM PHASE 4 - REMOVE cargo + binary folder
REM ============================================================
echo.
echo ----- Phase 4 of 6: Remove cargo install + binary folder ----
where cargo >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :PHASE4_NOCARGO
echo  Running: cargo uninstall railwayapp
echo  -----------------------------------------------------------
call cargo uninstall railwayapp
set "CGRC=%ERRORLEVEL%"
echo  -----------------------------------------------------------
echo cargo uninstall exit code: %CGRC% >> "%LOG_FILE%"
if %CGRC% EQU 0 set "R_CARGO=DONE"
if %CGRC% EQU 0 echo  [OK] cargo uninstall finished.
if %CGRC% NEQ 0 echo  [SKIP] No cargo install to remove ^(or already removed^).
goto :PHASE4_BIN

:PHASE4_NOCARGO
echo  [SKIP] cargo not available.

:PHASE4_BIN
set "BIN_DIR=%LOCALAPPDATA%\Programs\Railway"
if not exist "%BIN_DIR%" goto :PHASE4_NEXT
echo  Removing binary folder:
echo    %BIN_DIR%
rmdir /S /Q "%BIN_DIR%"
if exist "%BIN_DIR%" echo  [WARN] Some files in %BIN_DIR% could not be deleted.
if exist "%BIN_DIR%" set "R_BINDIR=WARN"
if not exist "%BIN_DIR%" echo  [OK] Binary folder removed.
if not exist "%BIN_DIR%" set "R_BINDIR=DONE"

:PHASE4_NEXT

REM ============================================================
REM PHASE 5 - CLEAN PATH (user + system)
REM ============================================================
echo.
echo ----- Phase 5 of 6: Clean Railway from PATH -----------------
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :PHASE5_NOPS

call :WRITE_PATHREMOVE_PS1
if not exist "%TEMP%\railway_pathremove.ps1" goto :PHASE5_NOPSFILE

echo  Cleaning user PATH...
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\railway_pathremove.ps1" -RemovePath "%LOCALAPPDATA%\Programs\Railway" -Scope User
echo  Cleaning system PATH (admin required)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\railway_pathremove.ps1" -RemovePath "%LOCALAPPDATA%\Programs\Railway" -Scope Machine
del "%TEMP%\railway_pathremove.ps1" >nul 2>&1
set "R_PATH=DONE"
goto :PHASE5_NEXT

:PHASE5_NOPS
echo  [SKIP] PowerShell not available - cannot clean PATH automatically.
goto :PHASE5_NEXT

:PHASE5_NOPSFILE
echo  [SKIP] Could not write the PATH cleaner to TEMP.

:PHASE5_NEXT

REM ============================================================
REM PHASE 6 - REMOVE CONFIG FOLDERS
REM ============================================================
echo.
echo ----- Phase 6 of 6: Remove Railway config folders ----------
set "CFG_ANY=0"
if exist "%USERPROFILE%\.railway" set "CFG_ANY=1"
if exist "%APPDATA%\railway" set "CFG_ANY=1"
if exist "%LOCALAPPDATA%\railway" set "CFG_ANY=1"
call :REMOVE_FOLDER "%USERPROFILE%\.railway"
call :REMOVE_FOLDER "%APPDATA%\railway"
call :REMOVE_FOLDER "%LOCALAPPDATA%\railway"
if "%CFG_ANY%"=="1" set "R_CFG=DONE"

echo.
echo ============================================================
echo  Final check
echo ============================================================
echo.
where railway >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto :FINAL_CLEAN
echo  [WARN] 'railway' command is STILL on PATH:
for /f "delims=" %%p in ('where railway 2^>nul') do echo    %%p
echo         Try closing this window and opening a NEW Command Prompt.
echo         If still present, the file may need manual deletion.
goto :FINAL_END

:FINAL_CLEAN
echo  [OK] 'railway' command is no longer on PATH.

:FINAL_END
echo.
echo  Removal summary:
echo    Phase 1  Logout from Railway   : !R_LOGOUT!
echo    Phase 2  Remove npm package    : !R_NPM!
echo    Phase 3  Remove scoop package  : !R_SCOOP!
echo    Phase 4a Remove cargo install  : !R_CARGO!
echo    Phase 4b Remove binary folder  : !R_BINDIR!
echo    Phase 5  Clean Railway from PATH: !R_PATH!
echo    Phase 6  Remove config folders : !R_CFG!
echo.
echo +==========================================================+
echo ^|                                                          ^|
echo ^|             UNINSTALL COMPLETE                           ^|
echo ^|                                                          ^|
echo +==========================================================+
echo.
echo  Notes:
echo    - You may need to RESTART any open Command Prompt or PowerShell
echo      windows for PATH changes to take effect.
echo    - Project folders may contain a hidden '.railway' subfolder
echo      that stores the project link. These are NOT removed here.
echo      To find them yourself, run in any project folder:
echo          dir /A:D /B .railway
echo.
echo  Log file: %LOG_FILE%
echo.
echo  This window can be closed safely now. Press any key to exit.
echo.
echo Finished: %DATE% %TIME% >> "%LOG_FILE%"
pause
exit /b 0

:USER_CANCEL
echo.
echo  Cancelled. Nothing was removed.
echo.
echo User cancelled at master confirm. >> "%LOG_FILE%"
pause
exit /b 0

:NOTHING_FOUND
echo  [INFO] Nothing was found to remove.
echo         Railway appears to be already uninstalled, or was never installed
echo         on this user account.
echo.
echo  This window will close in 5 seconds. (press any key to close sooner)
echo Nothing found to remove. Exiting cleanly. >> "%LOG_FILE%"
timeout /t 5 >nul 2>&1
exit /b 0

REM ============================================================
REM Helper subroutine: REMOVE_FOLDER "<path>"
REM ============================================================
:REMOVE_FOLDER
set "FOLDER=%~1"
if not exist "%FOLDER%" goto :REMOVE_FOLDER_NONE
echo  Removing config folder:
echo    %FOLDER%
rmdir /S /Q "%FOLDER%"
if exist "%FOLDER%" echo  [WARN] Some files in %FOLDER% could not be deleted.
if not exist "%FOLDER%" echo  [OK] Removed.
goto :REMOVE_FOLDER_END

:REMOVE_FOLDER_NONE
echo  [SKIP] Folder does not exist: %FOLDER%

:REMOVE_FOLDER_END
exit /b 0

REM ============================================================
REM Helper subroutine: write the PowerShell PATH cleaner
REM ============================================================
:WRITE_PATHREMOVE_PS1
set "B64FILE=%TEMP%\railway_pathremove.b64"
set "PS1FILE=%TEMP%\railway_pathremove.ps1"
if exist "%B64FILE%" del "%B64FILE%" >nul 2>&1
if exist "%PS1FILE%" del "%PS1FILE%" >nul 2>&1

>"%B64FILE%" echo cGFyYW0oW3N0cmluZ10kUmVtb3ZlUGF0aCwgW3N0cmluZ10kU2NvcGUgPSAnVXNl
>>"%B64FILE%" echo cicpCiRFcnJvckFjdGlvblByZWZlcmVuY2UgPSAnU3RvcCcKdHJ5IHsgW0NvbnNv
>>"%B64FILE%" echo bGVdOjpPdXRwdXRFbmNvZGluZyA9IFtTeXN0ZW0uVGV4dC5FbmNvZGluZ106OlVU
>>"%B64FILE%" echo RjggfSBjYXRjaCB7fQppZiAoW3N0cmluZ106OklzTnVsbE9yRW1wdHkoJFJlbW92
>>"%B64FILE%" echo ZVBhdGgpKSB7CiAgICBXcml0ZS1Ib3N0ICcgIFtFUlJPUl0gUmVtb3ZlUGF0aCBh
>>"%B64FILE%" echo cmd1bWVudCBpcyBlbXB0eS4nCiAgICBleGl0IDEKfQokcCA9IFtFbnZpcm9ubWVu
>>"%B64FILE%" echo dF06OkdldEVudmlyb25tZW50VmFyaWFibGUoJ1BhdGgnLCAkU2NvcGUpCmlmICgk
>>"%B64FILE%" echo bnVsbCAtZXEgJHAgLW9yICRwLkxlbmd0aCAtZXEgMCkgewogICAgV3JpdGUtSG9z
>>"%B64FILE%" echo dCAoJyAgW1NLSVBdICcgKyAkU2NvcGUgKyAnIFBBVEggaXMgZW1wdHkuJykKICAg
>>"%B64FILE%" echo IGV4aXQgMAp9CiR0YXJnZXQgPSAkUmVtb3ZlUGF0aC5UcmltRW5kKCdcJykuVG9M
>>"%B64FILE%" echo b3dlcigpCiRrZXB0ID0gQCgpCiRyZW1vdmVkQ291bnQgPSAwCmZvcmVhY2ggKCRw
>>"%B64FILE%" echo YXJ0IGluICRwLlNwbGl0KCc7JykpIHsKICAgIGlmICgkcGFydC5MZW5ndGggLWVx
>>"%B64FILE%" echo IDApIHsgY29udGludWUgfQogICAgaWYgKCRwYXJ0LlRyaW1FbmQoJ1wnKS5Ub0xv
>>"%B64FILE%" echo d2VyKCkgLWVxICR0YXJnZXQpIHsKICAgICAgICAkcmVtb3ZlZENvdW50ID0gJHJl
>>"%B64FILE%" echo bW92ZWRDb3VudCArIDEKICAgIH0gZWxzZSB7CiAgICAgICAgJGtlcHQgPSAka2Vw
>>"%B64FILE%" echo dCArICRwYXJ0CiAgICB9Cn0KaWYgKCRyZW1vdmVkQ291bnQgLWVxIDApIHsKICAg
>>"%B64FILE%" echo IFdyaXRlLUhvc3QgKCcgIFtTS0lQXSAnICsgJFJlbW92ZVBhdGggKyAnIHdhcyBu
>>"%B64FILE%" echo b3QgaW4gJyArICRTY29wZSArICcgUEFUSC4nKQogICAgZXhpdCAwCn0KJG5ld1Ag
>>"%B64FILE%" echo PSBbc3RyaW5nXTo6Sm9pbignOycsICRrZXB0KQpbRW52aXJvbm1lbnRdOjpTZXRF
>>"%B64FILE%" echo bnZpcm9ubWVudFZhcmlhYmxlKCdQYXRoJywgJG5ld1AsICRTY29wZSkKV3JpdGUt
>>"%B64FILE%" echo SG9zdCAoJyAgW09LXSBSZW1vdmVkIGZyb20gJyArICRTY29wZSArICcgUEFUSCAo
>>"%B64FILE%" echo JyArICRyZW1vdmVkQ291bnQgKyAnIGVudHJ5L2VudHJpZXMpOiAnICsgJFJlbW92
>>"%B64FILE%" echo ZVBhdGgpCmV4aXQgMAo=

certutil -decode "%B64FILE%" "%PS1FILE%" >nul 2>&1
del "%B64FILE%" >nul 2>&1
exit /b 0
