# Beginner Guide — Railway CLI One-Click Kit

Written so that even first-time users of computers, the internet, or AI tools can follow along, describing **exactly what you see on screen**. Hard terms are explained in parentheses.

> **Railway** = a service that runs your app / server / database **on the internet** and gives it a URL. (e.g. chatbot, backend, API)
>
> 📄 PDF with identical content: `GUIDE.en.pdf` · 🇰🇷 Korean: `사용설명서.md` / `사용설명서.pdf`
> 📘 Full reference: `README.en.md` / `README.en.pdf`

---

## 0. Before you start (just one thing)

**Double-click `시작하기.bat`** (means "Start Here") in the folder.
In blue text it shows your **PC state** and a one-line **"what to do now."** Just follow that.

> - A black (or blue) window is normal.
> - Choose with **Up/Down arrows + Enter**, or press **number keys**.
> - **No administrator (UAC) prompt appears.** This kit needs no admin rights. (If some other admin prompt appears, it's unrelated to this kit.)

---

## 0-1. If a file won't open or you see a "protected" warning (unblock downloads)

Windows sometimes **locks** files downloaded from the internet for safety. Just unblock them.

- **Way 1 (easiest):** **Before** extracting, right-click the zip → **Properties → check "Unblock" at the bottom → OK**, then extract.
- **Way 2:** Right-click `시작하기.bat` → **Properties → check "Unblock" → OK**, then double-click.
- If a blue **"Windows protected your PC"** dialog appears → **More info → Run anyway**.

> Once `시작하기.bat` runs once, the rest of the files are **unblocked automatically** (usually you only deal with this the first time).

---

## 1. Install (once)

1. `시작하기.bat` → choose **[1] Install / Update**.
2. A **black window** runs in English automatically. **Don't close it; wait** (usually 1–10 min).
   - ✅ **No admin prompt appears.** Just wait.
3. Success when you see `INSTALLATION COMPLETE` (or a similar message).
4. Return to the panel and press **any key** — it re-checks your state.

**If it says "Node.js is missing"?**
→ The kit still **tries another method (downloading the program binary) automatically**. If that also fails, get it yourself:
1. Open https://nodejs.org in a browser
2. Download the big green **LTS** button (version 20+ recommended) and install
3. Close the window, **rerun `시작하기.bat`**, then **[1] Install / Update**

> If it says "railway not found" right after install → press **[9] Health check → [2] Refresh PATH**, or close all windows and reopen `시작하기.bat`.

---

## 2. Login (connect your Railway account, once)

1. `시작하기.bat` → choose **[2] Login**.
2. A browser opens automatically → **log in / Authorize with your Railway account**.
   - No account? Sign up free at https://railway.com first.
3. When you see "success", close the browser and return to the panel.

> - Login is one-time; it remembers you afterward.
> - Verify: **[3] Check login status**.
> - See your projects: **[4] View my projects**.

---

## 3. Common tasks menu (deploy · logs · status)

From home, press **[5] Common tasks** to open an **easy Korean menu** instead of the hard 30-item English one.

| No. | What it does |
|---|---|
| 1 | **Init project** — create a new project for this folder |
| 2 | **Link project** — link to an existing project |
| 3 | **Deploy** — publish this folder to the internet *(YES confirm)* |
| 4 | Redeploy — re-publish the latest *(YES confirm)* |
| 5 | View live logs — server logs (stop: Ctrl+C) |
| 6 | Project status — current status |
| 7 | View variables — list of settings |
| 8 | Open all 30 functions — advanced menu (new window) |
| 0 | Back (home) |

---

## 4. Prepare → Deploy (order matters!)

Order: **Login → Init/Link project → Deploy**

1. Best to start inside the folder that holds your app (code) files.
2. `시작하기.bat` → **[5] Common tasks** → **[1] Init project** (or **[2] Link** if it already exists).
   - If English questions appear, choose with **arrow keys (↑↓) and Enter**.
3. **[5] → [3] Deploy**.
4. When it says **"type uppercase YES to publish"** → type **`YES`** and Enter. (Plain Enter cancels.)
5. Verify with **[5] → [5] View live logs**.

> Deploy = running your app **on Railway's servers**. It becomes public, so do it **inside your app folder, after linking/initializing a project**.

---

## 5. When stuck — Health check (self-diagnosis)

`시작하기.bat` → **[9] Health check / troubleshoot**.

On one screen it auto-checks **Node.js · Railway · install location · login · internet** and tells you **what's wrong and what to press**.

Quick-fix buttons:
- **[1]** Reinstall / update
- **[2]** Refresh PATH — instant fix *when you just installed but it shows "missing"*
- **[3]** Re-check
- **[0]** Back

---

## 6. Remove (uninstall)

1. `시작하기.bat` → **[6] Remove**.
2. Review what will be deleted, then type uppercase **`DELETE`** to proceed.
3. It removes cleanly.

**Don't worry — removal keeps:**
- Your **app (code) files**
- **Node.js**
- Your **apps already on Railway's servers**

> Only the program is removed. The hidden link info (`.railway`) in your project folder is intentionally kept to prevent mistakes.

---

## 7. When an error appears (don't panic)

| Screen | Do this |
|---|---|
| "Windows protected your PC / blocked" | Right-click → Properties → **Unblock** → OK. Or **More info → Run anyway** |
| `RAILWAY CLI IS NOT INSTALLED` | First `시작하기.bat` → **[1] Install / Update** |
| Installed but `railway ... not found` | **[9] → [2] Refresh PATH**, or close and reopen in a new window |
| Node.js warning | Leave it; it tries another way. Else install **LTS** from https://nodejs.org and rerun [1] |
| `install did not finish`-like message | **[9] → Internet** check. Turn off antivirus for 10 min and retry |
| Deploy fails | Run **[5]→[1] Init** or **[2] Link** in your app folder first |
| Wrong number in a menu | It just returns to the menu. No harm |
| Korean panel won't open | Double-click `INSTALL.bat → RUN.bat → UNINSTALL.bat` (English) |

---

## 8. FAQ

**Q. Must I memorize commands?**
A. No. Just press arrows or numbers. (Advanced users can type commands directly via the full menu (RUN.bat) **30. Run custom command**.)

**Q. Do I need administrator rights?**
A. No. **No admin prompt appears.** The program installs only into your user folder.

**Q. Does it cost money?**
A. Railway uses usage-based pricing / free credits. Heavy usage may incur charges — check your https://railway.com dashboard. (This kit itself has no cost.)

**Q. What if I press the wrong thing?**
A. Dangerous actions (deploy, take down, remove) all require typing **`YES` or `DELETE`** first. You can also just close the window.

**Q. Where are my files / logs / config?**
A. Login info `%USERPROFILE%\.railway\config.json`, install log `%TEMP%\railway_install.log`. (See `README.en.md` section 13 for full locations.)

---

For the full reference, command table, and license, see **`README.en.md`**.
