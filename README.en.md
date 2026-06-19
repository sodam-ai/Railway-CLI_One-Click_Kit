# Railway CLI One-Click Kit

A beginner-friendly kit that lets you **install, use, and remove the Railway CLI** with a few clicks on Windows. You don't need to memorize any commands — a Korean guide panel tells you **the one number to press next**.

> **What is Railway?** A service that runs your app / server / database on the internet and gives it a URL. (e.g. chatbot, backend, API server, Discord bot)
>
> 📄 A **PDF with identical content** ships next to this file → `README.pdf`
> 🇰🇷 Korean (default): `README.md` / `README.pdf`
> 👶 Gentle step-by-step guide: `사용설명서.md` (Korean), `GUIDE.en.md` / `GUIDE.en.pdf` (English)

---

## 1. Quick start (just remember this)

1. **Double-click `시작하기.bat`** (means "Start Here") in the folder.
2. Press the number it **highlights on a blue background** (arrow keys + Enter, or number keys).
3. Usual order: **[1] Install → [2] Login → [5] Common tasks** for deploy/logs.

That's it. The panel guides the rest. If you get stuck, press **[9] Health check**.

---

## 2. Prerequisites · required programs

| Item | Required? | Notes |
|---|---|---|
| Windows 10 or 11 | ✅ Yes | This kit is Windows-only. |
| Internet connection | ✅ Yes | Needed for install, login, and deploy. |
| Railway account | ✅ Yes (free) | Sign up free at https://railway.com . Login opens your browser. |
| **Node.js** (LTS) | ⛅ Recommended (optional) | Smoothest install. **Without it**, the kit automatically tries another method (downloading the program binary). Get the **LTS** build from https://nodejs.org . |
| Administrator rights | ❌ Not needed | **This kit needs no admin rights. No Windows "User Account Control (UAC)" prompt appears** — the program installs only into your own user folder. |

---

## 3. Download · unblock

1. Put the received **zip file** in any folder.
2. **Before** extracting, right-click the zip → **Properties → check "Unblock" at the bottom → OK**. (This clears the lock Windows places on files downloaded from the internet.)
3. Extract (right-click → Extract All).
4. Double-click **`시작하기.bat`** in the folder.
   - If a blue **"Windows protected your PC"** dialog appears → **More info → Run anyway**.
   - Once `시작하기.bat` runs once, the rest of the files in the folder are **unblocked automatically**.

---

## 4. What's in this folder

| File / folder | What it does |
|---|---|
| **`시작하기.bat`** | Korean guide panel. **Start here.** Detects your PC state and tells you the next step. |
| `INSTALL.bat` | Installs the Railway CLI. (English screen, automatic, **no admin prompt**.) |
| `RUN.bat` | Full **30-function** menu: login, projects, deploy, logs, etc. (English + Korean.) |
| `UNINSTALL.bat` | Clean removal. (Your code files are kept; type `DELETE` to confirm.) |
| `lib\start.ps1` | The Korean menu engine that `시작하기.bat` runs (internal; no need to open). |
| `사용설명서.md` / `.pdf` | Step-by-step **beginner guide** (Korean). |
| `README.md` / `.pdf` | Korean overview. |
| `README.en.md` / `GUIDE.en.md` (+ `.pdf`) | This English overview and guide. |
| `LICENSE` / `NOTICE` | License and copyright notices. |

---

## 5. Home menu at a glance (`시작하기.bat`)

When you run `시작하기.bat`, this menu appears. Above it you see your **PC state** (Node.js / Railway / login) and a one-line **"what to do now"**.

| No. | Menu | Description |
|---|---|---|
| **1** | Install / Update | Installs or updates the Railway CLI. |
| **2** | Login | Connects to your Railway account via browser. |
| **3** | Check login status | Shows who you are logged in as. |
| **4** | View my projects | Lists your Railway projects. |
| **5** | **Common tasks** | Easy menu for deploy/logs/status (see section 6). |
| **6** | Remove | Clean uninstall (your code is kept). |
| **7** | User manual | Opens the beginner guide (`사용설명서.md`). |
| **8** | Railway dashboard | Opens the Railway web console in your browser. |
| **9** | **Health check / troubleshoot** | Self-diagnosis when stuck (see section 7). |
| **0** | Quit | Closes the panel. |

---

## 6. [5] Common tasks (the easy menu)

Pressing **[5]** opens a small Korean menu of the most-used actions (arrow-key selection) instead of the scary 30-item English menu.

| No. | Menu | What it does | Safety gate |
|---|---|---|---|
| 1 | Init project | Creates a new Railway project for this folder (`railway init`) | — |
| 2 | Link project | Links this folder to an existing project (`railway link`) | — |
| 3 | **Deploy** | Publishes this folder **to the internet** (`railway up`) | **YES confirmation** |
| 4 | Redeploy | Re-publishes the latest (`railway redeploy`) | **YES confirmation** |
| 5 | View live logs | Live server logs (`railway logs`) | Stop: Ctrl+C |
| 6 | Project status | Current link/deploy status (`railway status`) | — |
| 7 | View variables | List of settings (`railway variables`) | — |
| 8 | Open all 30 functions | Opens the advanced menu (`RUN.bat`) in a new window | — |
| 0 | Back | Returns home | — |

> **Deploy (3) is hard to undo** (it publishes to the internet), so it asks for uppercase **`YES`** right before running. Pressing Enter cancels.

---

## 7. [9] Health check / troubleshoot (when stuck!)

Pressing **[9]** runs an **automatic check** on one screen and tells you, in Korean, **what to press** for each item.

- Whether Node.js is present
- Whether the Railway CLI is present / its version / install location
- Whether you are logged in
- **Internet connection** (checks railway.com within ~4 seconds)

Then it offers **quick fixes**:

| No. | Action | When to use |
|---|---|---|
| 1 | Reinstall / update | When install failed or broke |
| 2 | **Refresh PATH** | **When you just installed but it still shows "missing"** (makes it recognized without reopening) |
| 3 | Re-check | After a fix, re-run the check |
| 0 | Back | Home |

---

## 8. All 30 functions (`RUN.bat`)

The full menu for advanced users. Open it via home **[5] → [8] Open all 30 functions**, or double-click `RUN.bat`. Each line shows **number · Korean · English**.

**ACCOUNT** — 1 Login (browser) · 2 Login (no browser) · 3 Logout · 4 Show current user
**VERSION** — 5 Show version · 6 Update
**PROJECT** — 7 Init new project · 8 Link to project · 9 Unlink · 10 List projects · 11 Project status · 12 Open in browser
**DEPLOY** — 13 **Deploy (up)** *YES* · 14 **Redeploy** *YES* · 15 **Take down** *YES* · 16 Select service · 17 Add database/plugin
**LOGS + SHELL** — 18 Live logs · 19 Build logs · 20 Open shell · 21 Run command · 22 SSH · 23 Connect to plugin
**CONFIG** — 24 Variables · 25 Environment · 26 Custom domain · 27 Volumes
**HELP** — 28 Open docs · 29 Help · 30 Run custom command
- 0 Quit (q / exit / 종료 also work)

> Stray spaces in the number (e.g. ` 13 `) are handled automatically. Pressing an invalid number just returns to the menu — nothing breaks.

---

## 9. Standard workflow (start to finish)

```
[Download + Unblock]
        ↓
  Double-click 시작하기.bat
        ↓
  [1] Install / Update        ← once
        ↓
  [2] Login (browser)         ← once
        ↓
  [5] Common tasks
        ├─ [1] Init project   or   [2] Link project
        ├─ [3] Deploy (YES)         ← publish to internet
        ├─ [5] Live logs            ← verify it works
        └─ [6] Project status
        ↓
  (stuck?) [9] Health check / troubleshoot
        ↓
  (done?) [6] Remove  ← optional
```

---

## 10. By task (install · run · use · remove)

### Install
1. `시작하기.bat` → **[1] Install / Update**.
2. A black English window runs automatically. **Don't close it; wait** (usually 1–10 min).
3. Success when you see `INSTALLATION COMPLETE` or similar.
4. No Node.js? The kit tries another method automatically. If it still fails, install LTS from https://nodejs.org and run [1] again.

### Run
- Always start with **`시작하기.bat`** (Korean panel).
- If the Korean panel won't open, double-click `INSTALL.bat → RUN.bat → UNINSTALL.bat` directly (English) — same result.

### Use (up to deploy)
1. **[2] Login** (once).
2. In your app (code) folder: **[5] → [1] Init project** (or [2] Link).
3. **[5] → [3] Deploy** → type uppercase `YES` → published to the internet.
4. **[5] → [5] Live logs** to verify it's running.

### Remove
1. `시작하기.bat` → **[6] Remove**.
2. Review what gets deleted, then type uppercase `DELETE`.
3. Only the program is removed. **Your code files, Node.js, and your apps on Railway's servers are kept.**

---

## 11. Command reference (menu ↔ actual Railway command)

What the kit runs under the hood. You don't need to memorize these.

| Task | Railway command | Menu |
|---|---|---|
| Login (browser) | `railway login` | Home[2], RUN 1 |
| Login (no browser) | `railway login --browserless` | RUN 2 |
| Logout | `railway logout` | RUN 3 |
| Who am I | `railway whoami` | Home[3], RUN 4 |
| Version | `railway --version` | RUN 5 |
| Update | `railway upgrade` (fallback `npm i -g @railway/cli`) | Home[1], RUN 6 |
| Init project | `railway init` | [5]→1, RUN 7 |
| Link project | `railway link` | [5]→2, RUN 8 |
| Unlink | `railway unlink` | RUN 9 |
| List projects | `railway list` | Home[4], RUN 10 |
| Project status | `railway status` | [5]→6, RUN 11 |
| Open in browser | `railway open` | RUN 12 |
| **Deploy (up)** | `railway up` | [5]→3, RUN 13 |
| Redeploy | `railway redeploy` | [5]→4, RUN 14 |
| Take down | `railway down` | RUN 15 |
| Select service | `railway service` | RUN 16 |
| Add DB/plugin | `railway add` | RUN 17 |
| Live logs | `railway logs` | [5]→5, RUN 18 |
| Build logs | `railway logs --build` | RUN 19 |
| Open shell | `railway shell` | RUN 20 |
| Run command | `railway run <cmd>` | RUN 21 |
| SSH | `railway ssh` | RUN 22 |
| Connect plugin | `railway connect` | RUN 23 |
| Variables | `railway variables` | [5]→7, RUN 24 |
| Environment | `railway environment` | RUN 25 |
| Custom domain | `railway domain` | RUN 26 |
| Volumes | `railway volume` | RUN 27 |
| Docs | `railway docs` | RUN 28 |
| Help | `railway help` | RUN 29 |
| Custom | `railway <your args>` | RUN 30 |

> Install uses `npm install -g @railway/cli` by default; if Node.js is missing, it auto-downloads the **binary from GitHub Releases**.

---

## 12. Troubleshooting · error handling

First press **Home [9] Health check** — it usually finds the cause and the fix.

| Screen / symptom | Cause | Do this |
|---|---|---|
| "Windows protected your PC / blocked" | Downloaded file is locked | Right-click → Properties → **Unblock** → OK. Or **More info → Run anyway**. |
| `RAILWAY CLI IS NOT INSTALLED` | Not installed yet | Home **[1] Install / Update**. |
| Installed but `railway ... not found` | Current window doesn't know the new program yet | **[9] → [2] Refresh PATH**, or close all windows and rerun `시작하기.bat`. |
| `Node.js` warning | No Node.js | Leave it; the kit tries another way. Else install **LTS** from https://nodejs.org and rerun [1]. |
| `The install did not finish` etc. | Internet / antivirus / corporate network block | Check **[9] → Internet**. Turn off antivirus for 10 min and retry. Try a personal network if on a corporate one. |
| Deploy fails | No project linked / wrong folder | Run **[5]→[1] Init** or **[2] Link** in your app folder first. |
| Wrong number in menu | — | It just returns to the menu. No harm. |
| Korean panel won't open | PowerShell blocked etc. | Double-click `INSTALL.bat → RUN.bat → UNINSTALL.bat` (English). |

---

## 13. File · document · config · log locations

| What | Path |
|---|---|
| This kit folder | Wherever you extracted it |
| Railway CLI (default) | `%APPDATA%\npm\railway.cmd` (npm install) |
| Railway CLI (fallback) | `%LOCALAPPDATA%\Programs\Railway\railway.exe` (no Node) |
| Login info (config) | `%USERPROFILE%\.railway\config.json` |
| Install log | `%TEMP%\railway_install.log` |
| Uninstall log | `%TEMP%\railway_uninstall.log` |
| Korean guide | `사용설명서.md` / `사용설명서.pdf` |
| Korean overview | `README.md` / `README.pdf` |
| English overview/guide | `README.en.md`·`README.en.pdf` / `GUIDE.en.md`·`GUIDE.en.pdf` |
| License / notice | `LICENSE` / `NOTICE` |

> `%APPDATA%`, `%TEMP%` etc. are aliases for folders in your user account. Paste them into the File Explorer address bar to jump there.

---

## 13-1. Environment variables · build · test

- **Environment variables:** This kit (`*.bat` / `lib\start.ps1`) **needs no environment variables of its own.** Just extract and run.
  - Environment variables for your Railway *service* (your app's settings) are managed via full menu **24 Variables** or **[5] → [7] View variables** (`railway variables`).
  - Login info (token) is stored at `%USERPROFILE%\.railway\config.json`. **It is secret — be careful when sharing or screenshotting.**
- **Build:** **There is no build step.** This kit is a set of scripts that need no compilation — extract and use.
- **Test (follow along):**
  1. Double-click `시작하기.bat` → the menu appears in Korean = OK.
  2. **[9] Health check** → Node.js / Railway / login / internet are shown = OK.
  3. (Optional) **[1] Install → [2] Login → [5] → [6] Project status** completing = full flow OK.

---

## 14. Safety notes (please read)

- **No administrator (UAC) prompt appears.** The program installs only into your user folder, so admin rights aren't required.
- Hard-to-undo actions require **confirmation**:
  - **Deploy / Redeploy** (publish to internet): type uppercase `YES`.
  - **Take down** (stop a running service): type uppercase `YES`.
  - **Remove**: type uppercase `DELETE`.
- **Cost notice:** Railway uses usage-based pricing / free credits. Heavy usage may incur charges — check your https://railway.com dashboard. **This kit itself has no cost.**
- Login info (`config.json`) and variables may contain **secret values**. Be careful not to expose them in screenshots or shares.

---

## 15. License · copyright · commercial use

> This section is general information, not legal advice. Verify the originals at each official source before commercial distribution.

### This kit
- **License: Apache License 2.0** — © 2026 SoDam AI Studio. Full text in `LICENSE`.
- **Commercial use allowed**: Apache-2.0 permits commercial use, modification, and redistribution, provided you **keep the copyright notice and the `NOTICE` file** and state changes (includes a patent license clause).

### Third-party tools installed
- **Railway CLI (`@railway/cli`)**: **MIT License** — © 2023 Railway Corp.
  - Verified: the `LICENSE` in the official repo https://github.com/railwayapp/cli is MIT (SPDX: `MIT`).
  - Note: the npm package metadata has previously shown `ISC`, but the **authoritative source (the repository LICENSE) is MIT**.
  - MIT also permits commercial use; the condition is **keeping the copyright notice**.
- **Node.js**: a trademark of the OpenJS Foundation. https://nodejs.org

### Trademark · non-affiliation
- This kit is an **independent helper, not affiliated with, endorsed by, or sponsored by** Railway.
- **"Railway"** is a trademark of Railway Corp., used here for identification only.

### Service terms (important)
- The kit/CLI licenses (Apache-2.0 / MIT) are **software licenses only**.
- **Commercial use of the Railway service itself** is governed by **Railway Corp.'s Terms of Service and pricing** (not by this kit). See https://railway.com .

### Warranty disclaimer · liability
- The kit and CLI are provided **"AS IS" with no warranty of any kind** (both Apache-2.0 and MIT disclaim warranty).
- **You are responsible** for any data loss, charges, or service impact during install, deploy, or removal.

---

## 16. Need more help?

- Read the step-by-step **`사용설명서.md`** (Korean) or **`GUIDE.en.md`** (English) first.
- When stuck: **`시작하기.bat` → [9] Health check**.
- Official Railway docs: menu **[8] Dashboard** or `RUN.bat` 28 (`railway docs`).
