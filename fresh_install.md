# 🧠 Fresh Windows Install — Setup Roadmap

## ✅ Phase 1: Essential System Setup

1. **Windows Updates**
   - Fully update via *Settings → Windows Update*
   - Reboot when prompted

2. **System Tweaks**
   - Enable **Virtualization** in BIOS (already done)
   - Optional: Turn off "Fast Startup" under Power Options (can cause dual-boot/WSL issues)

3. **User Account Setup**
   - Create a local admin account (`cinep`) ✔️
   - Rename PC (optional)

---

## Ὢ0 Phase 2: Core Developer Tools

1. **Package Managers**
   - [ ] Install [**Winget**](https://github.com/microsoft/winget-cli) (usually preinstalled on Win 11)
   - [ ] Optional: [**Chocolatey**](https://chocolatey.org/install) for CLI installs

2. **Browsers**
   - [ ] Firefox / Brave / Chrome (your pick)

3. **Terminal Tools**
   - [ ] [**Windows Terminal**](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701)
   - [ ] [**Oh My Posh**](https://ohmyposh.dev/) (for pretty prompts)

4. **WSL & Ubuntu**
   - [ ] Enable WSL:
     ```powershell
     wsl --install
     ```
   - [ ] Install Ubuntu 22.04 (preferred for dev work)
   - [ ] Update Ubuntu:
     ```bash
     sudo apt update && sudo apt upgrade
     ```

5. **Git & GitHub**
   - [ ] Install [**Git for Windows**](https://git-scm.com/)
   - [ ] Setup SSH keys and Git config:
     ```bash
     git config --global user.name "Francois Lachapelle"
     git config --global user.email "your_email@example.com"
     ```

---

## 🐍 Phase 3: Python & Data Dev Stack

1. **Python (Windows-native and WSL)**
   - [ ] Install Python via Winget or [python.org](https://www.python.org/)
   - [ ] Install in Ubuntu:
     ```bash
     sudo apt install python3-pip python3-venv
     ```

2. **Conda (optional)**
   - [ ] Install [**Miniconda**](https://docs.conda.io/en/latest/miniconda.html)

3. **Jupyter & Dev Tools**
   - [ ] Install VS Code
   - [ ] `pip install jupyterlab pandas numpy matplotlib seaborn`
   - [ ] Install VS Code extensions: Python, Jupyter, Docker, GitLens, etc.

---

## 🐳 Phase 4: Docker & GPU

1. **Docker**
   - [ ] Install [**Docker Desktop**](https://www.docker.com/products/docker-desktop/)
   - [ ] Enable WSL2 integration
   - [ ] Verify:
     ```bash
     docker info
     ```

2. **NVIDIA Drivers for CUDA**
   - [ ] Install latest [**Studio Driver**](https://www.nvidia.com/Download/index.aspx)
   - [ ] Optional: Install [**CUDA Toolkit 12.8**](https://developer.nvidia.com/cuda-downloads)
   - [ ] Install [**cuDNN**](https://developer.nvidia.com/cudnn)
     - Copy to `CUDA/include`, `CUDA/bin`, `CUDA/lib/x64`

3. **Test GPU Access in Python**
   - [ ] Create venv, install `tensorflow` or `torch`
   - [ ] Run:
     ```python
     from tensorflow.python.client import device_lib
     print(device_lib.list_local_devices())
     ```

---

## ⚙️ Phase 5: Workflow & Utilities

1. **Coding Tools**
   - [ ] Vim / Neovim (import `.vimrc`)
   - [ ] Tmux (optional)
   - [ ] RainbowCSV
   - [ ] jq, htop, tree in WSL

2. **File & Text Tools**
   - [ ] Notepad++ / Sublime / VS Code
   - [ ] 7zip

3. **Cloud & Sync**
   - [ ] Google Drive / Dropbox / OneDrive
   - [ ] GitHub CLI / Login

---

## 🎮 Phase 6: Projects & Custom Scripts

1. **Clone Key Repos**
   - [ ] `Pool is Art`, `SubTrace`, `BilliardsBluePrint`, etc.

2. **Set up `.env`, credentials, secrets**
   - [ ] `.bashrc`, `.gitconfig`, SSH keys

3. **Install Custom CLI Tools**
   - [ ] ffmpeg, imagemagick, etc.
   - [ ] AutoGPT (if needed)

---

Let me know when you're ready for `.bashrc`/`.vimrc`/Conda env or CUDA checks.

