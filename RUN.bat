@echo off
chcp 949 >nul 2>&1
setlocal EnableDelayedExpansion
title Railway CLI - 런처 (Launcher)

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
echo ^|           RAILWAY CLI  -  런처 (LAUNCHER)                ^|
echo +==========================================================+
echo   버전 Version : !RW_VER!
echo   설치 Method  : !RW_METHOD!
if "!RW_MULTI!"=="1" echo   [주의 WARN] Railway가 여러 폴더에 설치됨. UNINSTALL.bat으로 정리 권장.
echo.
echo   * 처음이면 순서대로:  7 프로젝트 시작  ->  13 배포  ->  18 로그
echo   * 모르겠으면 29(도움말),  나가려면 0.   번호 누르고 Enter!
echo.
echo   [ 계정  ACCOUNT ]
echo      1. 로그인 (브라우저)           Login (browser)
echo      2. 로그인 (브라우저 없이)      Login (no browser)
echo      3. 로그아웃                    Logout
echo      4. 내 계정 보기                Show current user
echo   [ 버전  VERSION ]
echo      5. 버전 보기                   Show version
echo      6. 업데이트                    Update Railway CLI
echo   [ 프로젝트  PROJECT ]
echo      7. 새 프로젝트 시작            Init new project
echo      8. 프로젝트에 연결            Link to project
echo      9. 연결 해제                   Unlink project
echo     10. 내 프로젝트 목록           List projects
echo     11. 프로젝트 상태              Project status
echo     12. 브라우저에서 열기          Open in browser
echo   [ 배포  DEPLOY ]
echo     13. 배포 - 인터넷에 올려 실행   Deploy (up)
echo     14. 다시 배포                   Redeploy
echo     15. 서비스 내리기  *주의*       Take down (asks YES)
echo     16. 서비스 선택                Select service
echo     17. DB/플러그인 추가           Add database/plugin
echo   [ 로그 / 접속  LOGS + SHELL ]
echo     18. 실시간 로그 보기           View logs (live)
echo     19. 빌드 로그 보기             View build logs
echo     20. 셸 열기                    Open shell
echo     21. 명령 실행                  Run command
echo     22. 서비스에 SSH 접속          SSH into service
echo     23. 플러그인에 접속            Connect to plugin
echo   [ 설정  CONFIG ]
echo     24. 환경변수 보기              Variables
echo     25. 환경 선택                  Environment
echo     26. 커스텀 도메인              Custom domain
echo     27. 볼륨 관리                  Volumes
echo   [ 도움말  HELP ]
echo     28. 문서 열기                  Open docs in browser
echo     29. 도움말 보기                Show help
echo     30. 직접 명령 입력 (고급)      Run custom command
echo.
echo      0. 끝내기  Quit   (q / exit)
echo.
set "CHOICE="
set /p "CHOICE=번호를 누르고 Enter (Pick a number): "

set "CHOICE=!CHOICE: =!"
if "!CHOICE!"=="" goto :MAIN_MENU
if /i "!CHOICE!"=="0"    goto :EXIT_OK
if /i "!CHOICE!"=="q"    goto :EXIT_OK
if /i "!CHOICE!"=="quit" goto :EXIT_OK
if /i "!CHOICE!"=="exit" goto :EXIT_OK
if "!CHOICE!"=="종료" goto :EXIT_OK
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
echo  [안내] '!CHOICE!' 는 메뉴에 없는 번호예요. 메뉴로 돌아갑니다 (not a valid choice).
timeout /t 2 >nul 2>&1
goto :MAIN_MENU

REM ====== ACCOUNT ======
:A_LOGIN
echo.
echo +-- Login (opens browser) ---------------------------------+
echo  Railway 계정으로 로그인합니다. 인터넷 브라우저가 열려요.
call railway login
goto :PAUSE_RETURN

:A_LOGIN_BL
echo.
echo +-- Login (no browser, paste token) -----------------------+
echo  브라우저 없이 로그인합니다. 화면에 나온 코드를 복사해 붙여넣어요.
call railway login --browserless
goto :PAUSE_RETURN

:A_LOGOUT
echo.
echo +-- Logout ------------------------------------------------+
echo  이 컴퓨터에서 Railway 계정 연결을 끊습니다(로그아웃).
call railway logout
goto :PAUSE_RETURN

:A_WHOAMI
echo.
echo +-- Show current Railway user -----------------------------+
echo  지금 어떤 계정으로 로그인돼 있는지 보여줍니다.
call railway whoami
goto :PAUSE_RETURN

REM ====== VERSION ======
:V_SHOW
echo.
echo +-- Show Railway CLI version ------------------------------+
echo  설치된 Railway 도구의 버전(번호)을 보여줍니다.
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
echo  Railway 도구를 최신 버전으로 올립니다.
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
echo  새 Railway 프로젝트를 만듭니다. 배포의 첫 단계예요.
call railway init
goto :PAUSE_RETURN

:P_LINK
echo.
echo +-- Link this folder to an existing Railway project -------+
echo  지금 이 폴더를 이미 있는 Railway 프로젝트에 연결합니다.
call railway link
goto :PAUSE_RETURN

:P_UNLINK
echo.
echo +-- Unlink this folder from its Railway project -----------+
echo  이 폴더와 Railway 프로젝트의 연결을 끊습니다.
call railway unlink
goto :PAUSE_RETURN

:P_LIST
echo.
echo +-- List your Railway projects ----------------------------+
echo  내 Railway 프로젝트 목록을 보여줍니다.
call railway list
goto :PAUSE_RETURN

:P_STATUS
echo.
echo +-- Show status of the linked project ---------------------+
echo  지금 연결된 프로젝트의 상태를 보여줍니다.
call railway status
goto :PAUSE_RETURN

:P_OPEN
echo.
echo +-- Open the linked project in your web browser -----------+
echo  연결된 프로젝트를 웹 브라우저에서 엽니다.
call railway open
goto :PAUSE_RETURN

REM ====== DEPLOY ======
:D_UP
echo.
echo +-- 배포: 이 폴더를 인터넷에 공개 (Deploy / up) -----------+
echo  이 폴더의 내용이 Railway 서버에 올라가 인터넷에 공개됩니다.
echo  먼저 7=새 프로젝트 또는 8=연결 로 프로젝트에 연결돼 있어야 해요.
echo  *주의* 진짜 공개합니다. This publishes your app to the internet.
echo  계속하려면 YES(대문자) 입력, 아니면 그냥 Enter로 취소.
echo  Type YES to confirm, anything else to cancel.
set "UP_CONFIRM="
set /p "UP_CONFIRM=확인 Confirm: "
if /i not "!UP_CONFIRM!"=="YES" goto :D_UP_CANCEL
call railway up
goto :PAUSE_RETURN

:D_UP_CANCEL
echo  취소되었습니다 (Cancelled).
goto :PAUSE_RETURN

:D_REDEPLOY
echo.
echo +-- 다시 배포 (Redeploy the most recent deployment) -------+
echo  최근에 올린 내용을 다시 인터넷에 공개(배포)합니다.
echo  *주의* 진짜 공개합니다. This re-publishes to the internet.
echo  계속하려면 YES(대문자) 입력, 아니면 그냥 Enter로 취소.
echo  Type YES to confirm, anything else to cancel.
set "RE_CONFIRM="
set /p "RE_CONFIRM=확인 Confirm: "
if /i not "!RE_CONFIRM!"=="YES" goto :D_REDEPLOY_CANCEL
call railway redeploy
goto :PAUSE_RETURN

:D_REDEPLOY_CANCEL
echo  취소되었습니다 (Cancelled).
goto :PAUSE_RETURN

:D_DOWN
echo.
echo +-- 서비스 내리기 (Take down the deployment) --------------+
echo  *주의* 실행 중인 서비스를 멈춥니다. This STOPS your live service.
echo  계속하려면 YES(대문자) 입력, 아니면 그냥 Enter로 취소.
echo  Type YES to confirm, anything else to cancel.
set "DOWN_CONFIRM="
set /p "DOWN_CONFIRM=확인 Confirm: "
if /i not "!DOWN_CONFIRM!"=="YES" goto :D_DOWN_CANCEL
call railway down
goto :PAUSE_RETURN

:D_DOWN_CANCEL
echo  취소되었습니다 (Cancelled).
goto :PAUSE_RETURN

:D_SERVICE
echo.
echo +-- Pick which service to use ----------------------------+
echo  서비스 = 프로젝트 안에서 실제로 돌아가는 한 덩어리예요. 그걸 고릅니다.
call railway service
goto :PAUSE_RETURN

:D_ADD
echo.
echo +-- Add a database or plugin to the project ---------------+
echo  프로젝트에 DB(데이터베이스)나 플러그인(추가 기능)을 붙입니다.
call railway add
goto :PAUSE_RETURN

REM ====== LOGS + SHELL ======
:L_LOGS
echo.
echo +-- View live deploy logs (Ctrl+C to stop) ----------------+
echo  로그 = 서버가 남기는 실행 기록이에요. 실시간으로 봅니다(멈춤: Ctrl+C).
call railway logs
goto :PAUSE_RETURN

:L_BUILD
echo.
echo +-- View build logs ---------------------------------------+
echo  빌드 = 배포 직전 준비 과정이에요. 그 과정의 기록을 봅니다.
call railway logs --build
goto :PAUSE_RETURN

:L_SHELL
echo.
echo +-- Open a shell with Railway env loaded ------------------+
echo  쉘 = 명령을 직접 치는 검은 창이에요. Railway 설정이 들어간 채 열려요.
call railway shell
goto :PAUSE_RETURN

:L_RUN
echo.
echo +-- Railway 환경으로 명령 실행 (Run a command) ------------+
echo  예시 Example: node index.js
echo.
set "RUN_CMD="
set /p "RUN_CMD=실행할 명령 (Command to run): "
if "!RUN_CMD!"=="" goto :L_RUN_CANCEL
call railway run !RUN_CMD!
goto :PAUSE_RETURN

:L_RUN_CANCEL
echo  입력이 없어 취소했습니다 (No command entered).
goto :PAUSE_RETURN

:L_SSH
echo.
echo +-- SSH into a running service ----------------------------+
echo  SSH = 인터넷 너머의 내 서버 안으로 직접 들어가 다루는 기능이에요.
call railway ssh
goto :PAUSE_RETURN

:L_CONNECT
echo.
echo +-- Connect to a database plugin --------------------------+
echo  프로젝트에 붙은 DB(데이터베이스)에 직접 연결합니다.
call railway connect
goto :PAUSE_RETURN

REM ====== CONFIG ======
:C_VARS
echo.
echo +-- Show environment variables ----------------------------+
echo  환경변수 = 비밀번호, 키 같은 설정값을 코드와 분리해 보관하는 곳이에요.
call railway variables
goto :PAUSE_RETURN

:C_ENV
echo.
echo +-- Pick environment (production, staging, etc.) ----------+
echo  환경 = 실제용/연습용 등 공간 구분이에요(production=실제). 그걸 고릅니다.
call railway environment
goto :PAUSE_RETURN

:C_DOMAIN
echo.
echo +-- Manage custom domain for the service ------------------+
echo  도메인 = 내 서비스의 인터넷 주소예요. 직접 정한 주소를 관리합니다.
call railway domain
goto :PAUSE_RETURN

:C_VOLUME
echo.
echo +-- Manage persistent volumes -----------------------------+
echo  볼륨 = 서버를 다시 배포해도 지워지지 않는 저장 공간이에요.
call railway volume
goto :PAUSE_RETURN

REM ====== HELP ======
:H_DOCS
echo.
echo +-- Open Railway docs in your browser ---------------------+
echo  Railway 공식 설명 문서를 웹 브라우저에서 엽니다.
call railway docs
goto :PAUSE_RETURN

:H_HELP
echo.
echo +-- Show Railway CLI help ---------------------------------+
echo  Railway 도구의 도움말(사용법)을 보여줍니다.
call railway help
goto :PAUSE_RETURN

:H_CUSTOM
echo.
echo +-- 직접 명령 입력 (Run any railway command) --------------+
echo  'railway' 는 빼고 그 뒷부분만 입력하세요.
echo  Type the part AFTER the word 'railway'.
echo  예시 Example: status --json
echo  그냥 Enter 치면 취소 (Just press Enter to cancel).
echo.
set "CUSTOM_ARGS="
set /p "CUSTOM_ARGS=railway "
if "!CUSTOM_ARGS!"=="" goto :H_CUSTOM_CANCEL
call railway !CUSTOM_ARGS!
goto :PAUSE_RETURN

:H_CUSTOM_CANCEL
echo  입력이 없어 취소했습니다 (No command entered).
goto :PAUSE_RETURN

REM ====== SHARED PAUSE/RETURN ======
:PAUSE_RETURN
echo.
echo ----------------------------------------------------------
echo  아무 키나 누르면 메뉴로 돌아갑니다 (Press any key for menu)...
pause >nul
goto :MAIN_MENU

REM ====== NOT INSTALLED ======
:NOT_INSTALLED
cls
echo.
echo +==========================================================+
echo ^|         RAILWAY CLI IS NOT INSTALLED                     ^|
echo +==========================================================+
echo.
echo  Railway CLI가 아직 설치되어 있지 않아요.
echo  이 창에서 'railway' 명령을 찾지 못했습니다.
echo  (We could not find the 'railway' command in this window.)
echo.
echo  두 가지 경우입니다 (Two possible causes):
echo    1. 아직 설치 전 -^> 먼저 '시작하기.bat' 또는 INSTALL.bat 실행.
echo       Not installed yet: run 시작하기.bat first.
echo.
echo    2. 설치는 됐지만 이 창이 옛 PATH를 봅니다.
echo       창을 닫고 '시작하기.bat'을 새로 여세요.
echo       Installed but old PATH: close and reopen 시작하기.bat.
echo.
pause
exit /b 1

REM ====== CLEAN EXIT ======
:EXIT_OK
echo.
echo  안녕히 가세요! (Good bye!)
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
