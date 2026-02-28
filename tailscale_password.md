# Tailscale SSH Setup — Termux (Phone) → Home Rig

## Problem

From work computer → home rig:
- SSH works without asking for Linux password
- Likely using SSH key authentication (or Tailscale SSH)

From phone (Termux) → home rig:
- Prompt asks for regular Linux account password
- This means no SSH key is configured on the phone

---

# Goal

Make phone SSH behave like work computer:

- Use SSH key authentication
- No Linux password prompt
- Clean login via Tailscale IP

---

# Step 1 — Generate SSH Key on Phone (Termux)

Open Termux and run:

```bash
ssh-keygen -t ed25519