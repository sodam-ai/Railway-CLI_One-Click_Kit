# Railway CLI One-Click Kit

> A batch file kit for Windows — install, run, and remove Railway CLI with a single double-click.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078d4.svg)](https://www.microsoft.com/windows)
[![Node](https://img.shields.io/badge/Node.js-16%2B-green.svg)](https://nodejs.org/)

**[한국어 README →](./README.md)**

---

## Overview

Railway is a platform for deploying apps to the cloud with ease.  
This kit lets complete beginners install, use, and remove Railway CLI with zero command-line knowledge — just double-click a `.bat` file and follow the on-screen prompts.

---

## Files Included

| File | Purpose |
|------|---------|
| `INSTALL.bat` | Install Railway CLI — auto-selects npm or direct binary download |
| `RUN.bat` | Interactive 30-option launcher — login, deploy, logs, env vars, and more |
| `UNINSTALL.bat` | Complete 6-phase removal — handles npm, scoop, cargo, binary, PATH, and config |

---

## Requirements

| Item | Details |
|------|---------|
| Windows | 10 or 11 (64-bit) |
| Node.js | 16 or higher recommended (optional — binary method works without it) |
| PowerShell | Built into Windows 10/11 (needed for binary install method) |
| Internet | Required for install, update, and deploy |

> Node.js is **not required**. `INSTALL.bat` automatically picks the best installation method for your system.

---

## Quick Start — Beginner's Guide

### Step 1: Get this kit

- Click **Code → Download ZIP** at the top of this page, or
- Run `git clone https://github.com/sodam-ai/Railway-CLI-One-Click_Kit.git` in a terminal.

### Step 2: Install Railway CLI

1. Open the downloaded folder and **double-click `INSTALL.bat`**.
2. Click **Yes** when Windows asks for administrator permission.
3. The installer automatically picks the best method:
   - If Node.js is available → installs via `npm install -g @railway/cli`
   - If Node.js is missing → downloads the binary directly from GitHub Releases
4. When you see `INSTALLATION COMPLETE!`, you're ready.

### Step 3: Log in and use Railway

1. **Double-click `RUN.bat`**.
2. Choose **`1. Login (browser)`** from the menu.
3. Sign in with your Railway account in the browser.
4. Return to the menu and pick any option.

> No Railway account yet? Sign up for free at [https://railway.app/](https://railway.app/)

---

## INSTALL.bat — How Installation Works

`INSTALL.bat` detects your environment and picks the optimal method automatically.

```
[Method 1] npm install (preferred when Node.js is available)
  → npm install -g @railway/cli

[Method 2] Binary download (fallback when npm fails or Node.js is missing)
  → Downloads the latest railway.exe from GitHub Releases
  → Installs to %LOCALAPPDATA%\Programs\Railway\
  → Automatically adds the folder to your user PATH
```

If Railway is already installed, `INSTALL.bat` runs `railway upgrade` automatically to update to the latest version.

---

## RUN.bat — Full Menu Reference

```
+-------- ACCOUNT --------+    +-------- PROJECT --------+
|  1. Login (browser)     |    |  7. Init new project    |
|  2. Login (no browser)  |    |  8. Link to project     |
|  3. Logout              |    |  9. Unlink project      |
|  4. Show current user   |    | 10. List projects       |
+-------------------------+    | 11. Project status      |
                                | 12. Open in browser     |
+-------- VERSION --------+    +-------------------------+
|  5. Show version        |
|  6. Update Railway CLI  |    +-------- DEPLOY ---------+
+-------------------------+    | 13. Deploy (up)         |
                                | 14. Redeploy            |
+------ LOGS + SHELL -----+    | 15. Take down           |
| 18. View logs (live)    |    | 16. Select service      |
| 19. View build logs     |    | 17. Add database/plugin |
| 20. Open shell          |    +-------------------------+
| 21. Run command         |
| 22. SSH into service    |    +-------- CONFIG ---------+
| 23. Connect to plugin   |    | 24. Variables           |
+-------------------------+    | 25. Environment         |
                                | 26. Custom domain       |
+--------- HELP ----------+    | 27. Volumes             |
| 28. Open docs in browser|    +-------------------------+
| 29. Show help           |
| 30. Run custom command  |       0. Quit
+-------------------------+
```

---

## UNINSTALL.bat — Removal Steps

1. **Double-click `UNINSTALL.bat`**.
2. Click **Yes** when prompted for administrator permission.
3. The tool scans all Railway installations automatically.
4. Type `DELETE` and press Enter to confirm.
5. The 6-phase removal runs in sequence.

**6-phase removal process:**

| Phase | What it does |
|-------|-------------|
| Phase 1 | Log out from Railway |
| Phase 2 | Remove npm package (`@railway/cli`) |
| Phase 3 | Remove scoop package (`railway`) |
| Phase 4 | Remove cargo install + delete binary folder |
| Phase 5 | Remove Railway paths from user PATH and system PATH |
| Phase 6 | Delete Railway configuration folders |

**What is NOT removed:** Your code projects, Node.js, npm, and `.railway/` link files inside project folders.

> To find project link files, run `dir /A:D /B .railway` inside any project folder.

---

## Troubleshooting

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `All install methods failed` | Both npm and binary download failed | Check internet connection; install Node.js and retry |
| `No installer tool available` | No npm and no PowerShell | Install Node.js → [nodejs.org](https://nodejs.org/) |
| `railway command not found` (after install) | PATH not refreshed | Open a new Command Prompt and run `railway --version` |
| `tar command not found` | Windows build too old | Upgrade to Windows 10 April 2018 Update (build 17063) or later |
| Login browser does not open | Headless / no-browser environment | Choose menu option 2 "Login (no browser)" and paste your token |

> Detailed install logs: `%TEMP%\railway_install.log`  
> Detailed uninstall logs: `%TEMP%\railway_uninstall.log`

---

## Security Notes

- `INSTALL.bat` contains PowerShell utility scripts encoded in base64 and decoded at runtime via `certutil`. These scripts download the Railway binary from GitHub Releases and configure the system PATH — **they contain no credentials or personal data**.
- **Administrator permission** is required for install and uninstall — this is normal, as modifying the system PATH requires elevated rights.
- Install logs are written to `%TEMP%` and **do not contain sensitive information**.
- Railway login tokens are managed by Railway CLI itself. This kit does not store or transmit them.
- This repository contains no API keys, tokens, passwords, or other sensitive information.

---

## Folder Structure

```
Railway-CLI-One-Click_Kit/
├── INSTALL.bat      # Installer (npm first / binary fallback)
├── RUN.bat          # Interactive 30-option launcher
├── UNINSTALL.bat    # Complete 6-phase uninstaller
├── README.md        # Korean documentation
├── README_EN.md     # English documentation (this file)
├── LICENSE          # Apache License 2.0
└── .gitignore
```

---

## License

Apache License 2.0 — see the [LICENSE](./LICENSE) file for details.

© 2026 SoDam AI Studio
