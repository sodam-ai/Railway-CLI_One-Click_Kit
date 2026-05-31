# Railway CLI 원클릭 키트

> Windows에서 Railway CLI를 클릭 한 번으로 설치·실행·제거하는 배치 파일 키트

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078d4.svg)](https://www.microsoft.com/windows)
[![Node](https://img.shields.io/badge/Node.js-16%2B-green.svg)](https://nodejs.org/)

**[English README →](./README_EN.md)**

---

## 소개

Railway는 앱을 클라우드에 쉽게 배포할 수 있는 플랫폼입니다.  
이 키트는 Railway CLI를 처음 접하는 분도 명령어 없이 `.bat` 파일 더블클릭만으로 설치부터 배포까지 모든 작업을 할 수 있도록 만들었습니다.

---

## 포함된 파일

| 파일 | 역할 |
|------|------|
| `INSTALL.bat` | Railway CLI 설치 — npm 또는 바이너리 직접 다운로드로 자동 설치 |
| `RUN.bat` | 30개 메뉴 대화형 실행기 — 로그인·배포·로그·환경변수 등 |
| `UNINSTALL.bat` | Railway CLI 완전 제거 — npm·scoop·cargo·바이너리·PATH·설정 6단계 |

---

## 요구사항

| 항목 | 내용 |
|------|------|
| Windows | 10 또는 11 (64-bit) |
| Node.js | 16 이상 권장 (없어도 바이너리 방식으로 설치 가능) |
| PowerShell | Windows 10 기본 내장 (바이너리 설치 방식에 필요) |
| 인터넷 | 설치·업데이트·배포 시 필요 |

> Node.js가 없어도 설치할 수 있습니다. INSTALL.bat이 자동으로 최적 방법을 선택합니다.

---

## 빠른 시작 — 왕초보 가이드

### 1단계: 이 키트 받기

- 이 페이지 오른쪽 위 **Code → Download ZIP** 을 누르거나
- 터미널에서 `git clone https://github.com/sodam-ai/Railway-CLI-One-Click_Kit.git`

### 2단계: Railway CLI 설치

1. 다운받은 폴더에서 **`INSTALL.bat`** 을 더블클릭하세요.
2. **"관리자 권한 요청"** 창이 뜨면 **예** 를 클릭하세요.
3. 설치 방법은 자동으로 선택됩니다.
   - Node.js가 있으면 → `npm install -g @railway/cli`
   - Node.js가 없으면 → GitHub에서 바이너리 직접 다운로드
4. 화면에 `INSTALLATION COMPLETE!` 가 나오면 완료입니다.

### 3단계: Railway 로그인 및 사용

1. **`RUN.bat`** 을 더블클릭하세요.
2. 메뉴에서 **`1. Login (browser)`** 을 선택하세요.
3. 브라우저에서 Railway 계정으로 로그인하세요.
4. 메뉴로 돌아와 원하는 번호를 선택하세요.

> Railway 계정이 없으면 [https://railway.app/](https://railway.app/) 에서 무료로 만드세요.

---

## INSTALL.bat 설치 방법 상세

INSTALL.bat은 자동으로 환경을 감지해 최적의 방법으로 설치합니다.

```
[방법 1] npm 설치 (Node.js가 있을 때, 우선 시도)
  → npm install -g @railway/cli

[방법 2] 바이너리 직접 다운로드 (npm 실패 또는 Node.js 없을 때)
  → GitHub Releases에서 최신 railway.exe 다운로드
  → %LOCALAPPDATA%\Programs\Railway\ 에 설치
  → 사용자 PATH에 자동 등록
```

기존에 Railway가 설치되어 있으면 자동으로 `railway upgrade`를 실행해 최신 버전으로 업데이트합니다.

---

## RUN.bat 메뉴 전체 안내

```
+-------- 계정 --------+      +-------- 프로젝트 --------+
|  1. 로그인 (브라우저)  |      |  7. 새 프로젝트 초기화    |
|  2. 로그인 (토큰)     |      |  8. 프로젝트 연결         |
|  3. 로그아웃          |      |  9. 프로젝트 연결 해제    |
|  4. 현재 사용자 확인  |      | 10. 프로젝트 목록         |
+---------------------+      | 11. 프로젝트 상태 확인    |
                               | 12. 브라우저에서 열기     |
+-------- 버전 --------+      +-------------------------+
|  5. 버전 확인         |
|  6. Railway CLI 업데이트 |   +-------- 배포 --------+
+---------------------+      | 13. 배포 (railway up)  |
                               | 14. 재배포             |
+---- 로그 + 셸 ------+      | 15. 배포 중단          |
| 18. 실시간 로그 보기  |      | 16. 서비스 선택        |
| 19. 빌드 로그 보기    |      | 17. DB/플러그인 추가   |
| 20. 셸 열기          |      +--------------------+
| 21. 명령어 실행      |
| 22. 서비스에 SSH 접속 |      +-------- 설정 --------+
| 23. DB 플러그인 접속 |      | 24. 환경변수 확인      |
+---------------------+      | 25. 환경(production 등) |
                               | 26. 커스텀 도메인      |
+-------- 도움말 ------+      | 27. 볼륨 관리         |
| 28. 공식 문서 열기    |      +--------------------+
| 29. 도움말 보기      |
| 30. 직접 명령어 입력  |         0. 종료
+---------------------+
```

---

## UNINSTALL.bat 제거 방법

1. **`UNINSTALL.bat`** 을 더블클릭하세요.
2. **"관리자 권한 요청"** 창에서 **예** 를 클릭하세요.
3. 설치 현황을 자동으로 스캔합니다.
4. `DELETE` 를 입력하고 Enter를 누르세요.
5. 6단계 제거가 순서대로 진행됩니다.

**6단계 제거 과정:**

| 단계 | 내용 |
|------|------|
| Phase 1 | Railway 로그아웃 |
| Phase 2 | npm 패키지 제거 (`@railway/cli`) |
| Phase 3 | scoop 패키지 제거 (`railway`) |
| Phase 4 | cargo 설치 제거 + 바이너리 폴더 삭제 |
| Phase 5 | 사용자 PATH·시스템 PATH에서 Railway 경로 제거 |
| Phase 6 | Railway 설정 폴더 삭제 |

**제거 후에도 남는 것:** 내 코드 프로젝트, Node.js, npm, 각 프로젝트 폴더의 `.railway/` 링크 파일

> 프로젝트 폴더의 링크 파일을 찾으려면 해당 폴더에서 `dir /A:D /B .railway` 를 실행하세요.

---

## 오류 대처

| 오류 메시지 | 원인 | 해결 방법 |
|-------------|------|-----------|
| `All install methods failed` | npm·바이너리 모두 실패 | 인터넷 연결 확인, Node.js 설치 후 재시도 |
| `No installer tool available` | npm·PowerShell 모두 없음 | Node.js 설치 → [nodejs.org](https://nodejs.org/) |
| `railway command not found` (설치 후) | PATH 미반영 | 새 명령 프롬프트를 열고 `railway --version` 입력 |
| `tar command not found` | Windows 빌드가 너무 오래됨 | Windows 10 2018년 4월 업데이트(17063) 이상 필요 |
| 로그인 브라우저가 안 열림 | 브라우저 없는 환경 | 메뉴 2번 "Login (no browser)" 선택 후 토큰 붙여넣기 |

> 설치 상세 로그는 `%TEMP%\railway_install.log`, 제거 로그는 `%TEMP%\railway_uninstall.log` 에서 확인하세요.

---

## 보안 주의사항

- `INSTALL.bat` 은 PowerShell 스크립트를 내부에 base64로 인코딩하여 포함합니다. 이 스크립트는 GitHub Releases에서 바이너리를 다운로드하고 PATH를 설정하는 유틸리티 코드로, **인증정보나 개인정보를 포함하지 않습니다.**
- 설치·제거 시 **관리자 권한** 이 요청됩니다 — 시스템 PATH 수정을 위한 정상 동작입니다.
- 설치 로그는 `%TEMP%` 폴더에 저장되며 **민감정보는 기록되지 않습니다.**
- Railway 로그인 토큰은 Railway CLI 자체가 관리하며 이 키트는 저장하지 않습니다.
- 이 저장소에는 API 키, 토큰, 비밀번호 등 민감한 정보가 포함되어 있지 않습니다.

---

## 폴더 구조

```
Railway-CLI-One-Click_Kit/
├── INSTALL.bat      # Railway CLI 설치 (npm 우선 / 바이너리 폴백)
├── RUN.bat          # 30개 메뉴 대화형 실행기
├── UNINSTALL.bat    # 6단계 완전 제거
├── README.md        # 한국어 문서 (이 파일)
├── README_EN.md     # 영어 문서
├── LICENSE          # Apache License 2.0
└── .gitignore
```

---

## 라이선스

Apache License 2.0 — 자세한 내용은 [LICENSE](./LICENSE) 파일을 참고하세요.

© 2026 SoDam AI Studio
