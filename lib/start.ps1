# =====================================================================
#  Railway 원클릭 키트 - 시작하기 (한국어 안내판)
#  비개발자용: 지금 무엇을 눌러야 하는지 한 줄로 알려줍니다.
#  (INSTALL/RUN/UNINSTALL.bat 엔진을 한국어로 쉽게 안내합니다.)
# =====================================================================

$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$LibDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root   = Split-Path -Parent $LibDir
Set-Location $Root

# 다운로드 차단(Mark of the Web) 자동 해제 - 받은 파일이 윈도우에 막히지 않게
try { Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue } catch {}

function Has-Command([string]$name) {
    $c = Get-Command $name -ErrorAction SilentlyContinue
    return [bool]$c
}

function Get-RwVersion {
    if (-not (Has-Command 'railway')) { return $null }
    $v = (& railway --version 2>$null | Select-Object -First 1)
    if ($v) { $v = ($v -replace '^\s*railway\s+', '').Trim() }
    return $v
}

# 로그인 여부는 설정 파일로 빠르게(오프라인) 판단합니다. (정확한 확인은 '로그인 상태 확인' 메뉴)
# Railway 설정 위치: %USERPROFILE%\.railway\config.json
#   - 로그인되면 user.accessToken (또는 user.token) 에 값이 채워집니다.
#   - 로그아웃 상태면 그 값이 null 입니다.
function Is-LoggedIn {
    $cfg = Join-Path $env:USERPROFILE '.railway\config.json'
    if (-not (Test-Path $cfg)) { return $false }
    $txt = Get-Content -LiteralPath $cfg -Raw -ErrorAction SilentlyContinue
    if (-not $txt) { return $false }
    try {
        $o = $txt | ConvertFrom-Json
        if ($o.user) {
            if ($o.user.accessToken) { return $true }
            if ($o.user.token)       { return $true }
        }
        return $false
    } catch {
        if ($txt -match '"accessToken"\s*:\s*"[^"]+"') { return $true }
        if ($txt -match '"token"\s*:\s*"[^"]+"')       { return $true }
        return $false
    }
}

function Pause-Key {
    Write-Host ''
    Write-Host '  계속하려면 아무 키나 누르세요...' -ForegroundColor DarkGray
    [void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# ---------------------------------------------------------------------
#  공용 메뉴: 위/아래 화살표로 고르고 Enter, 또는 번호키.
#  화살표 입력을 못 받는 환경이면 자동으로 '번호 입력' 방식으로 폴백.
#   - $Title       : 제목 한 줄
#   - $StatusLines : @{ Text; Color(선택); Back(선택) } 배열 (상태/안내 줄)
#   - $Items       : @{ Key; Text; Color; Mark } 배열
#   - $RecKey      : 처음 커서를 올려둘(추천) 항목 Key
# ---------------------------------------------------------------------
function Show-Menu {
    param([string]$Title, [array]$StatusLines, [array]$Items, [string]$RecKey = '1')
    $idx = 0
    for ($i = 0; $i -lt $Items.Count; $i++) { if ($Items[$i].Key -eq $RecKey) { $idx = $i; break } }

    while ($true) {
        Clear-Host
        Write-Host ''
        Write-Host '  ============================================' -ForegroundColor Cyan
        Write-Host ("     {0}" -f $Title) -ForegroundColor Cyan
        Write-Host '  ============================================' -ForegroundColor Cyan
        foreach ($s in $StatusLines) {
            if     ($s.Back)  { Write-Host $s.Text -ForegroundColor $s.Color -BackgroundColor $s.Back }
            elseif ($s.Color) { Write-Host $s.Text -ForegroundColor $s.Color }
            else              { Write-Host $s.Text }
        }
        Write-Host ''
        Write-Host '   위/아래 화살표로 고르고 Enter, 또는 번호키를 누르세요' -ForegroundColor DarkCyan
        Write-Host '  --------------------------------------------' -ForegroundColor DarkCyan
        Write-Host ''
        for ($i = 0; $i -lt $Items.Count; $i++) {
            $it = $Items[$i]
            $sel = ($i -eq $idx)
            $bullet = if ($sel) { ' > ' } else { '   ' }
            $line = ("{0}[{1}] {2}{3}" -f $bullet, $it.Key, $it.Text, $it.Mark)
            if ($sel) { Write-Host $line -ForegroundColor Black -BackgroundColor $it.Color }
            else      { Write-Host $line -ForegroundColor $it.Color }
        }
        Write-Host ''

        try {
            $k = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        } catch {
            $typed = Read-Host '   번호를 입력하고 Enter'
            if ($null -eq $typed) { $typed = '' }
            $m = $Items | Where-Object { $_.Key -eq $typed.Trim() }
            if ($m) { return $m.Key } else { continue }
        }

        $vk = $k.VirtualKeyCode
        if     ($vk -eq 38) { $idx--; if ($idx -lt 0) { $idx = $Items.Count - 1 } }   # 위 화살표
        elseif ($vk -eq 40) { $idx++; if ($idx -ge $Items.Count) { $idx = 0 } }       # 아래 화살표
        elseif ($vk -eq 13) { return $Items[$idx].Key }                               # Enter
        else {
            $ch = ("{0}" -f $k.Character).Trim()
            if ($ch -ne '') {
                $m = $Items | Where-Object { $_.Key -eq $ch }
                if ($m) { return $m.Key }
            }
        }
    }
}

# ---------------------------------------------------------------------
#  자주 쓰는 작업 (왕초보용 쉬운 메뉴) - 무서운 30개 cmd 대신 여기서 고르기
#   - 배포/재배포는 실행 전 YES 한 번 더 확인(실수 공개 방지)
#   - [8] 전체 30기능은 RUN.bat(고급)로 보존
# ---------------------------------------------------------------------
function Show-CommonTasks {
    if (-not (Has-Command 'railway')) {
        Write-Host ''
        Write-Host '  아직 설치가 안 되어 있어요. 먼저 홈에서 [1] 설치 부터 해주세요.' -ForegroundColor Yellow
        Pause-Key; return
    }
    $go = $true
    while ($go) {
        $logged = Is-LoggedIn
        $st = @()
        $st += @{ Text = '' }
        if ($logged) { $st += @{ Text = '   - Railway 로그인 : 되어 있음  [OK]'; Color = 'Green' } }
        else         { $st += @{ Text = '   - Railway 로그인 : 안 됨  (배포 전 홈 [2] 로그인 필요)'; Color = 'Yellow' } }
        $st += @{ Text = '' }
        $st += @{ Text = '  배포 = 이 폴더를 인터넷에 공개. 실행 직전 YES를 한 번 더 물어봐요.'; Color = 'Gray' }

        $items = @(
            @{ Key = '1'; Text = '프로젝트 시작     (새 프로젝트 만들기)';        Color = 'White';      Mark = '' },
            @{ Key = '2'; Text = '프로젝트 연결     (이미 있는 프로젝트에 연결)'; Color = 'White';      Mark = '' },
            @{ Key = '3'; Text = '배포하기          (이 폴더를 인터넷에 공개)';   Color = 'Green';      Mark = '   <- 공개! YES 확인' },
            @{ Key = '4'; Text = '다시 배포         (최근 내용을 다시 공개)';     Color = 'Green';      Mark = '' },
            @{ Key = '5'; Text = '실시간 로그 보기  (서버 기록, 멈춤은 Ctrl+C)';  Color = 'White';      Mark = '' },
            @{ Key = '6'; Text = '프로젝트 상태     (지금 연결/배포 상태)';       Color = 'White';      Mark = '' },
            @{ Key = '7'; Text = '환경변수 보기     (설정값 목록)';               Color = 'White';      Mark = '' },
            @{ Key = '8'; Text = '전체 30기능 열기  (고급, 새 검은 창)';          Color = 'DarkYellow'; Mark = '' },
            @{ Key = '0'; Text = '뒤로 (홈으로)';                                Color = 'DarkGray';   Mark = '' }
        )
        $c = Show-Menu -Title 'Railway - 자주 쓰는 작업' -StatusLines $st -Items $items -RecKey '3'
        if ($null -eq $c) { $c = '' }
        $c = $c.Trim()

        if ((@('1','2','3','4','5','6','7') -contains $c) -and -not $logged) {
            Write-Host ''
            Write-Host '  아직 로그인 전이에요. 홈으로 가서 [2] 로그인 먼저 해주세요.' -ForegroundColor Yellow
            Pause-Key
            continue
        }

        switch ($c) {
            '1' { Write-Host ''; Write-Host '  새 Railway 프로젝트를 만듭니다.' -ForegroundColor Gray; & railway init; Pause-Key }
            '2' { Write-Host ''; Write-Host '  이 폴더를 이미 있는 프로젝트에 연결합니다.' -ForegroundColor Gray; & railway link; Pause-Key }
            '3' {
                Write-Host ''
                Write-Host '  *주의* 이 폴더의 내용이 인터넷에 진짜 공개됩니다.' -ForegroundColor Yellow
                Write-Host '  먼저 1=프로젝트 시작 또는 2=연결 이 되어 있어야 해요.' -ForegroundColor Gray
                $yes = Read-Host '  공개하려면 대문자로 YES 입력 (아니면 그냥 Enter)'
                if ($yes -cne 'YES') { Write-Host '  취소했습니다.' -ForegroundColor Gray; Pause-Key }
                else { Write-Host ''; & railway up; Pause-Key }
            }
            '4' {
                Write-Host ''
                Write-Host '  *주의* 최근에 올린 내용을 다시 인터넷에 공개합니다.' -ForegroundColor Yellow
                $yes = Read-Host '  다시 공개하려면 대문자로 YES 입력 (아니면 그냥 Enter)'
                if ($yes -cne 'YES') { Write-Host '  취소했습니다.' -ForegroundColor Gray; Pause-Key }
                else { Write-Host ''; & railway redeploy; Pause-Key }
            }
            '5' { Write-Host ''; Write-Host '  실시간 로그입니다. 멈추려면 Ctrl+C.' -ForegroundColor Gray; & railway logs; Pause-Key }
            '6' { Write-Host ''; Write-Host '  ==== 프로젝트 상태 ====' -ForegroundColor Cyan; Write-Host ''; & railway status; Pause-Key }
            '7' { Write-Host ''; Write-Host '  ==== 환경변수 ====' -ForegroundColor Cyan; Write-Host ''; & railway variables; Pause-Key }
            '8' {
                Start-Process -FilePath (Join-Path $Root 'RUN.bat')
                Write-Host ''
                Write-Host '  전체 기능 창(새 검은 창)을 열었어요. 이 창은 그대로 두세요.' -ForegroundColor Gray
                Pause-Key
            }
            '0' { $go = $false }
            default {
                Write-Host ''
                Write-Host '  그 번호는 없어요. 0~8 중에서 골라주세요.' -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    }
}

# ---------------------------------------------------------------------
#  인터넷 연결 빠른 점검 (최대 4초) - railway.com 443 포트로 접속 시도
# ---------------------------------------------------------------------
function Test-Internet {
    try {
        $c = New-Object System.Net.Sockets.TcpClient
        $iar = $c.BeginConnect('railway.com', 443, $null, $null)
        $ok = $iar.AsyncWaitHandle.WaitOne(4000, $false)
        $res = ($ok -and $c.Connected)
        if ($c.Connected) { try { $c.EndConnect($iar) } catch {} }
        $c.Close()
        return [bool]$res
    } catch { return $false }
}

# 현재 창의 PATH를 레지스트리에서 다시 읽어옴 (방금 설치한 railway가 안 보일 때)
function Refresh-SessionPath {
    try {
        $m = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        $u = [Environment]::GetEnvironmentVariable('Path', 'User')
        $env:Path = (@($m, $u) | Where-Object { $_ }) -join ';'
        return $true
    } catch { return $false }
}

# ---------------------------------------------------------------------
#  내 상태 점검 / 문제 해결 (왕초보가 막혔을 때 한 곳에서 진단 + 해결)
# ---------------------------------------------------------------------
function Show-Diagnose {
    $go = $true
    while ($go) {
        Clear-Host
        Write-Host ''
        Write-Host '  ============================================' -ForegroundColor Cyan
        Write-Host '     내 상태 점검 / 문제 해결  (막혔을 때 여기!)' -ForegroundColor Cyan
        Write-Host '  ============================================' -ForegroundColor Cyan
        Write-Host ''
        $hasNode = Has-Command 'node'
        $hasRw   = Has-Command 'railway'
        $rwVer   = Get-RwVersion
        $logged  = $false
        if ($hasRw) { $logged = Is-LoggedIn }

        if ($hasNode) { Write-Host '   [OK]   Node.js (필수 부품)  : 있음' -ForegroundColor Green }
        else          { Write-Host '   [참고] Node.js (필수 부품)  : 없음  ->  없어도 되지만 nodejs.org 의 LTS 를 깔면 가장 매끄러워요' -ForegroundColor Yellow }

        if ($hasRw) { Write-Host ("   [OK]   Railway CLI          : 있음 (v{0})" -f $rwVer) -ForegroundColor Green }
        else        { Write-Host '   [필요] Railway CLI          : 없음  ->  홈으로 가서 [1] 설치 / 업데이트 를 누르세요' -ForegroundColor Yellow }

        if ($hasRw) {
            $where = @()
            foreach ($w in (& where.exe railway 2>$null)) { if ($w) { $where += $w } }
            if ($where.Count -ge 1) { Write-Host ('   [OK]   설치 위치            : ' + $where[0]) -ForegroundColor Green }
            if ($where.Count -ge 2) { Write-Host '   [참고] 여러 곳에 설치됨    ->  깔끔히 하려면 홈 [6] 제거 후 다시 [1] 설치' -ForegroundColor Yellow }
        } else {
            Write-Host '   [참고] 방금 설치했는데 "없음" 이면  ->  아래 [2] PATH 새로고침 을 눌러보세요' -ForegroundColor Gray
        }

        if ($hasRw) {
            if ($logged) { Write-Host '   [OK]   Railway 로그인       : 되어 있음' -ForegroundColor Green }
            else         { Write-Host '   [필요] Railway 로그인       : 안 됨  ->  홈으로 가서 [2] 로그인 을 누르세요' -ForegroundColor Yellow }
        }

        Write-Host '   ...인터넷 연결 확인 중 (최대 4초)...' -ForegroundColor DarkGray
        if (Test-Internet) { Write-Host '   [OK]   인터넷 연결          : 됨' -ForegroundColor Green }
        else               { Write-Host '   [참고] 인터넷 연결          : 안 됨  ->  와이파이/랜선/회사 방화벽을 확인하세요. 설치/배포가 실패할 수 있어요' -ForegroundColor Yellow }

        Write-Host ''
        if (-not $hasRw)      { Write-Host '  >> 지금 할 일: 홈으로 가서 [1] 설치 / 업데이트.' -ForegroundColor White -BackgroundColor DarkGreen }
        elseif (-not $logged) { Write-Host '  >> 지금 할 일: 홈으로 가서 [2] 로그인.' -ForegroundColor White -BackgroundColor DarkGreen }
        else                  { Write-Host '  >> 좋아요, 준비 끝! 홈 [5] 자주 쓰는 작업 에서 배포/로그 하세요.' -ForegroundColor White -BackgroundColor DarkGreen }

        Write-Host ''
        Write-Host '  --------------------------------------------' -ForegroundColor DarkCyan
        Write-Host '   [1] 설치 / 업데이트 다시 하기' -ForegroundColor White
        Write-Host '   [2] PATH 새로고침   (방금 깔았는데 "없음" 일 때)' -ForegroundColor White
        Write-Host '   [3] 다시 점검' -ForegroundColor White
        Write-Host '   [0] 뒤로 (홈으로)' -ForegroundColor DarkGray
        Write-Host ''
        $f = Read-Host '   번호를 누르고 Enter'
        if ($null -eq $f) { $f = '' }
        switch ($f.Trim()) {
            '1' {
                Write-Host ''
                Write-Host '  설치 창(검은 창)이 열립니다. 끝나면 돌아와 [3] 다시 점검 하세요.' -ForegroundColor Gray
                Start-Process -FilePath (Join-Path $Root 'INSTALL.bat')
                Pause-Key
            }
            '2' {
                if (Refresh-SessionPath) { Write-Host ''; Write-Host '  PATH 를 새로고침했어요. [3] 다시 점검 으로 확인하세요.' -ForegroundColor Green }
                else                     { Write-Host ''; Write-Host '  새로고침 실패. 이 창을 닫고 시작하기.bat 를 다시 실행해 주세요.' -ForegroundColor Yellow }
                Pause-Key
            }
            '0' { $go = $false }
            default { }
        }
    }
}

# =====================================================================
#  메인 메뉴 (한 화면, 한 번에 고르기 - 진입 단계 최소화)
#   - 가장 흔한 작업(설치/로그인/상태/프로젝트)을 홈에서 바로 1번에 실행
#   - 배포/로그/환경변수 등 30가지 전부는 [5] 전체 기능 메뉴(RUN.bat)에 보존
# =====================================================================
$running = $true
while ($running) {
    $hasNode = Has-Command 'node'
    $hasRw   = Has-Command 'railway'
    $rwVer   = Get-RwVersion
    $logged  = $false
    if ($hasRw) { $logged = Is-LoggedIn }

    # 상태 표시 줄
    $status = @()
    $status += @{ Text = '' }
    $status += @{ Text = '  [지금 내 컴퓨터 상태]' }
    if ($hasNode) { $status += @{ Text = '   - Node.js (필수 부품)   : 있음  [OK]'; Color = 'Green' } }
    else          { $status += @{ Text = '   - Node.js (필수 부품)   : 없음  (있으면 더 매끄러움)'; Color = 'Yellow' } }
    if ($hasRw)   { $status += @{ Text = ("   - Railway CLI           : 있음 (v{0})  [OK]" -f $rwVer); Color = 'Green' } }
    else          { $status += @{ Text = '   - Railway CLI           : 없음  [설치 필요]'; Color = 'Yellow' } }
    if ($hasRw) {
        if ($logged) { $status += @{ Text = '   - Railway 로그인        : 되어 있음  [OK]'; Color = 'Green' } }
        else         { $status += @{ Text = '   - Railway 로그인        : 안 됨  [로그인 필요]'; Color = 'Yellow' } }
    }
    $status += @{ Text = '' }
    # 지금 할 일 한 줄 (가장 중요)
    if (-not $hasRw) {
        $status += @{ Text = '  >> 지금 할 일: [1] 설치 / 업데이트 를 누르세요.'; Color = 'White'; Back = 'DarkGreen' }
    } elseif (-not $logged) {
        $status += @{ Text = '  >> 지금 할 일: [2] 로그인 을 누르세요.'; Color = 'White'; Back = 'DarkGreen' }
    } else {
        $status += @{ Text = '  >> 준비 끝! [5] 자주 쓰는 작업 에서 배포/로그를 쉽게 하세요.'; Color = 'White'; Back = 'DarkGreen' }
    }

    if (-not $hasRw) { $recKey = '1' } elseif (-not $logged) { $recKey = '2' } else { $recKey = '5' }
    $cInstall = if (-not $hasRw)              { 'Green' } else { 'Gray' }
    $cLogin   = if ($hasRw -and -not $logged) { 'Green' } else { 'Gray' }
    $cUse     = if ($hasRw -and $logged)      { 'Green' } else { 'White' }

    $items = @(
        @{ Key = '1'; Text = '설치 / 업데이트   (Railway CLI 깔기·최신화)';       Color = $cInstall;  Mark = $(if ($recKey -eq '1') { '   <- 지금 이것!' } else { '' }) },
        @{ Key = '2'; Text = '로그인            (브라우저로 Railway 계정 연결)';  Color = $cLogin;    Mark = $(if ($recKey -eq '2') { '   <- 지금 이것!' } else { '' }) },
        @{ Key = '3'; Text = '로그인 상태 확인  (지금 누구로 로그인됐는지)';       Color = 'White';    Mark = '' },
        @{ Key = '4'; Text = '내 프로젝트 보기  (로그인 필요)';                    Color = $cUse;      Mark = $(if ($recKey -eq '4') { '   <- 둘러보기' } else { '' }) },
        @{ Key = '5'; Text = '자주 쓰는 작업    (배포·로그·상태 등 쉬운 메뉴)';     Color = 'White';    Mark = $(if ($recKey -eq '5') { '   <- 여기서 하세요' } else { '' }) },
        @{ Key = '6'; Text = '제거하기          (깨끗이 지우기, 내 코드는 안 지움)'; Color = 'Red';    Mark = '   (주의)' },
        @{ Key = '7'; Text = '사용설명서        (왕초보 가이드 열기)';             Color = 'White';    Mark = '' },
        @{ Key = '8'; Text = 'Railway 대시보드  (웹에서 내 프로젝트 관리)';        Color = 'White';    Mark = '' },
        @{ Key = '9'; Text = '내 상태 점검      (막혔을 때! 문제 해결·자가진단)';   Color = 'Cyan';     Mark = '' },
        @{ Key = '0'; Text = '끝내기';                                            Color = 'DarkGray'; Mark = '' }
    )

    $choice = Show-Menu -Title 'Railway 원클릭 키트 - 시작하기' -StatusLines $status -Items $items -RecKey $recKey
    if ($null -eq $choice) { $choice = '' }

    switch ($choice.Trim()) {
        '1' {
            Write-Host ''
            Write-Host '  설치 창(검은 창)이 열립니다. 자동으로 진행되니 잠시 기다려 주세요.' -ForegroundColor Gray
            Write-Host '  이 키트는 관리자 권한이 필요 없습니다 - 관리자 허용 창은 뜨지 않아요.' -ForegroundColor Gray
            if (-not $hasNode) {
                Write-Host '  Node.js(필수 부품)가 없어도 키트가 다른 방법을 자동 시도합니다.' -ForegroundColor Yellow
                Write-Host '  (가장 매끄럽게 깔려면 nodejs.org 에서 LTS 설치 후, 다시 [1] 설치.)' -ForegroundColor Yellow
            }
            Start-Process -FilePath (Join-Path $Root 'INSTALL.bat')
            Write-Host ''
            Write-Host '  설치가 끝나면 이 창으로 돌아와 아무 키나 누르세요. 상태를 다시 확인합니다.' -ForegroundColor Gray
            Pause-Key
        }
        '2' {
            if (-not $hasRw) {
                Write-Host ''
                Write-Host '  아직 설치가 안 되어 있어요. 먼저 [1] 설치 부터 해주세요.' -ForegroundColor Yellow
                Pause-Key
            } else {
                Write-Host ''
                Write-Host '  인터넷 브라우저가 열립니다. 거기서 로그인 / 권한 허용(Authorize) 하세요.' -ForegroundColor Gray
                Write-Host '  (브라우저에서 끝내면 이 창으로 돌아옵니다.)' -ForegroundColor Gray
                Write-Host ''
                & railway login
                Pause-Key
            }
        }
        '3' {
            if (-not $hasRw) {
                Write-Host ''
                Write-Host '  아직 설치가 안 되어 있어요. 먼저 [1] 설치 부터 해주세요.' -ForegroundColor Yellow
                Pause-Key
            } else {
                Write-Host ''
                Write-Host '  ==== 로그인 상태 ====' -ForegroundColor Cyan
                Write-Host ''
                & railway whoami
                Pause-Key
            }
        }
        '4' {
            if (-not $hasRw) {
                Write-Host ''
                Write-Host '  아직 설치가 안 되어 있어요. 먼저 [1] 설치 부터 해주세요.' -ForegroundColor Yellow
                Pause-Key
            } elseif (-not $logged) {
                Write-Host ''
                Write-Host '  아직 로그인 전이에요. 먼저 [2] 로그인 부터 해주세요.' -ForegroundColor Yellow
                Pause-Key
            } else {
                Write-Host ''
                Write-Host '  ==== 내 프로젝트 목록 ====' -ForegroundColor Cyan
                Write-Host ''
                & railway list
                Pause-Key
            }
        }
        '5' {
            Show-CommonTasks
        }
        '6' {
            Write-Host ''
            Write-Host '  제거 창을 엽니다. 정말 지울지 한 번 더 물어봅니다(DELETE 입력).' -ForegroundColor Gray
            Start-Process -FilePath (Join-Path $Root 'UNINSTALL.bat')
            Pause-Key
        }
        '7' {
            $guide = Join-Path $Root '사용설명서.md'
            if (Test-Path $guide) { Start-Process $guide }
            else { Start-Process (Join-Path $Root 'README.md') }
            Pause-Key
        }
        '8' {
            Start-Process 'https://railway.app/dashboard'
            Pause-Key
        }
        '9' {
            Show-Diagnose
        }
        '0' { $running = $false }
        default {
            Write-Host ''
            Write-Host '  그 번호는 메뉴에 없어요. 0~9 중에서 골라주세요.' -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}

Clear-Host
Write-Host ''
Write-Host '  안녕히 가세요! 좋은 하루 되세요.' -ForegroundColor Cyan
Write-Host ''
Start-Sleep -Seconds 1
