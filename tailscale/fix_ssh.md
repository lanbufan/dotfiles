# SSH Key-Based Authentication Setup via Tailscale
## Complete Documentation for Remote Access Between Two Windows Machines

---

## Overview

This document details the complete setup process for establishing SSH key-based authentication between two Windows machines connected via Tailscale VPN. This setup allows passwordless remote access without relying on Microsoft account passwords.

### Environment
- **Home Machine (SSH Server)**: `cinep` at Tailscale IP `100.122.228.33`
- **Remote Machine (SSH Client)**: `ubco-clw-106155` at Tailscale IP `100.69.56.91`
- **VPN**: Tailscale (tailnet: taild4d016.ts.net)
- **OS**: Windows on both machines
- **SSH Server**: OpenSSH Server (Windows built-in)

---

## Problem History

### Initial Issues Encountered

1. **Connection Timeout**: SSH connections were timing out with no response
2. **Routing Problem**: Traffic was being routed through the regular network gateway (`128.189.122.129`) instead of Tailscale's direct connection
3. **Authentication Failure**: Microsoft account prevented local password changes for SSH
4. **Administrator Group Complication**: User being in Administrators group required special `authorized_keys` file location

### Root Causes

1. **Incorrect routing table**: Windows routing table prioritized the campus network gateway (metric 2) over Tailscale's direct route (metric 5)
2. **Microsoft Account**: The `cinep` account was a Microsoft account, not a local account, preventing local password management
3. **Administrators Group**: Windows OpenSSH treats Administrator users differently, requiring `authorized_keys` in a system-wide location rather than user directory

---

## Solution: SSH Key-Based Authentication

We implemented SSH key-based authentication, which:
- Bypasses the need for Windows password authentication
- Works regardless of Microsoft account status
- Provides more secure authentication
- Enables passwordless login (if no key passphrase is set)

---

## Complete Setup Process

### Part 1: Network Connectivity (Remote Machine)

#### Step 1.1: Verify Tailscale Connection
```powershell
# Check Tailscale status
tailscale status

# Verify both machines are online
# Expected output should show both machines with active status
```

#### Step 1.2: Test Basic Tailscale Connectivity
```powershell
# Test Tailscale-level ping
tailscale ping 100.122.228.33

# Should show successful pongs via DERP relay or direct connection
```

#### Step 1.3: Check Routing Table
```powershell
# View routes for Tailscale IP range
route print | findstr "100.122.228.33"

# Problem identified: Two routes existed
# 1. Via 128.189.122.129 (metric 2) - INCORRECT, campus gateway
# 2. Via On-link/100.69.56.91 (metric 5) - CORRECT, Tailscale direct
```

#### Step 1.4: Fix Routing (if needed)
```powershell
# Remove incorrect route
route delete 100.122.228.33

# Restart Tailscale to recreate proper routes
tailscale down
tailscale up

# Verify route was recreated
route print | findstr "100.122.228.33"
```

**Note**: The routing fix was critical. Even though Tailscale was connected, Windows was routing SSH traffic through the campus gateway instead of Tailscale, causing connection timeouts.

---

### Part 2: SSH Server Setup (Home Machine - cinep)

#### Step 2.1: Verify SSH Server is Running
```powershell
# Check SSH service status
Get-Service sshd

# Should show "Running"
# If not running:
Start-Service sshd

# Set to start automatically
Set-Service -Name sshd -StartupType Automatic
```

#### Step 2.2: Verify SSH is Listening
```powershell
# Check if SSH is listening on port 22
netstat -an | findstr :22

# Expected output:
# TCP    0.0.0.0:22             0.0.0.0:0              LISTENING
# TCP    [::]:22                [::]:0                 LISTENING
```

#### Step 2.3: Configure Windows Firewall
```powershell
# Check existing SSH firewall rules
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*SSH*"} | Select-Object DisplayName, Enabled, Direction, Action, Profile

# Ensure SSH is allowed on all profiles
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Profile Any -Enabled True

# Create specific rule for Tailscale interface
New-NetFirewallRule -DisplayName "SSH via Tailscale" -Direction Inbound -InterfaceAlias "Tailscale" -Protocol TCP -LocalPort 22 -Action Allow -Profile Private

# Restart SSH service to apply changes
Restart-Service sshd
```

#### Step 2.4: Check SSH Configuration
```powershell
# View SSH server configuration
notepad C:\ProgramData\ssh\sshd_config

# Key settings to verify:
# - AuthorizedKeysFile .ssh/authorized_keys (for regular users)
# - Match Group administrators section exists
# - PasswordAuthentication not explicitly disabled (default is yes)
```

**Important SSH Config Section**:
```
# For Administrator users, this overrides the default AuthorizedKeysFile location
Match Group administrators
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

#### Step 2.5: Identify User Account Type
```powershell
# Check if user is in Administrators group
net user cinep | findstr "Local Group"

# Output showed:
# Local Group Memberships      *Administrators       *Users
# This is CRITICAL - determines where authorized_keys file goes
```

---

### Part 3: SSH Key Generation (Remote Machine)

#### Step 3.1: Generate SSH Key Pair
```powershell
# Generate ED25519 key pair (more secure and faster than RSA)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Prompts:
# 1. "Enter file in which to save the key" - Press ENTER (use default)
# 2. "Enter passphrase" - Press ENTER for no passphrase, or type one for extra security
# 3. "Enter same passphrase again" - Press ENTER again (or retype passphrase)
```

**Output Location**:
- Private key: `C:\Users\<username>\.ssh\id_ed25519` (KEEP SECRET!)
- Public key: `C:\Users\<username>\.ssh\id_ed25519.pub` (safe to share)

#### Step 3.2: View Public Key
```powershell
# Display the public key
type $env:USERPROFILE\.ssh\id_ed25519.pub

# Example output:
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxW... your_email@example.com
```

**COPY THE ENTIRE OUTPUT** - you'll need this for the home machine.

---

### Part 4: Configure Authorized Keys (Home Machine - cinep)

#### Step 4.1: Determine Correct Location

Because the user `cinep` is in the **Administrators** group, the authorized_keys file must be placed in:
```
C:\ProgramData\ssh\administrators_authorized_keys
```

**NOT** in:
```
C:\Users\cinep\.ssh\authorized_keys  ❌ This won't work for Administrator users
```

#### Step 4.2: Create Authorized Keys File
```powershell
# Open Notepad to create the file
notepad C:\ProgramData\ssh\administrators_authorized_keys

# In Notepad:
# 1. Paste the ENTIRE public key from the remote machine (the ssh-ed25519 line)
# 2. Ensure it's on ONE SINGLE LINE with no line breaks
# 3. Save the file
# 4. When saving, choose "All Files (*.*)" as file type to avoid .txt extension
```

**Example content** (all on one line):
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJxW... your_email@example.com
```

#### Step 4.3: Set Correct Permissions

**Critical Step**: Windows OpenSSH is very strict about file permissions.

```powershell
# Remove inheritance and set explicit permissions
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r

# Grant Administrators group full control
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "Administrators:F"

# Grant SYSTEM full control
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "SYSTEM:F"
```

**Why these specific permissions?**
- `/inheritance:r` - Removes inherited permissions (critical for security)
- `Administrators:F` - Grants Administrators group full control
- `SYSTEM:F` - Required for SSH service to read the file

#### Step 4.4: Verify File Permissions
```powershell
# Check permissions are set correctly
icacls C:\ProgramData\ssh\administrators_authorized_keys

# Should show:
# NT AUTHORITY\SYSTEM:(F)
# BUILTIN\Administrators:(F)
```

#### Step 4.5: Restart SSH Service
```powershell
# Restart to apply changes
Restart-Service sshd

# Verify it's running
Get-Service sshd
```

---

### Part 5: Testing the Connection

#### Step 5.1: Initial Connection Test (Remote Machine)
```powershell
# Attempt SSH connection
ssh cinep@100.122.228.33

# First time connecting, you'll see a host key fingerprint warning:
# "The authenticity of host '100.122.228.33' can't be established..."
# Type "yes" to accept and continue
```

#### Step 5.2: Passphrase Prompt (if set)

If you set a passphrase when creating the SSH key, you'll be prompted:
```
Enter passphrase for key 'C:\Users\username\.ssh\id_ed25519':
```

- Enter the passphrase you set during key generation
- If you pressed Enter (no passphrase), just press Enter here too

#### Step 5.3: Successful Connection

Upon successful connection, you should see:
```
Microsoft Windows [Version ...]
(c) Microsoft Corporation. All rights reserved.

cinep@CINEP C:\Users\cinep>
```

---

## Troubleshooting Guide

### Issue: "Connection timed out"

**Symptoms**: SSH hangs and eventually shows "Connection timed out"

**Diagnosis**:
```powershell
# On remote machine, test TCP connectivity
Test-NetConnection -ComputerName 100.122.228.33 -Port 22

# Check which interface is being used
# If it shows InterfaceAlias: Ethernet 2 instead of Tailscale, routing is wrong
```

**Solution**:
```powershell
# Fix routing
route delete 100.122.228.33
tailscale down
tailscale up

# Verify
Test-NetConnection -ComputerName 100.122.228.33 -Port 22
# Should now show InterfaceAlias: Tailscale
```

---

### Issue: "Permission denied (publickey,password,keyboard-interactive)"

**Symptoms**: SSH asks for password, but password doesn't work

**Diagnosis**:
```powershell
# On home machine, check if user is Administrator
net user cinep | findstr "Local Group"

# Check where authorized_keys file is located
dir C:\Users\cinep\.ssh\authorized_keys
dir C:\ProgramData\ssh\administrators_authorized_keys
```

**Solution**:

If user is in Administrators group, ensure key is in correct location:
```powershell
# Create administrators_authorized_keys (not user's .ssh directory)
notepad C:\ProgramData\ssh\administrators_authorized_keys

# Set proper permissions
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "Administrators:F"
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "SYSTEM:F"

# Restart SSH
Restart-Service sshd
```

---

### Issue: "Access denied" when viewing authorized_keys

**Symptoms**: Can't read the authorized_keys file even though you created it

**Solution**:
```powershell
# Take ownership
takeown /f C:\ProgramData\ssh\administrators_authorized_keys

# Reset and set permissions
icacls C:\ProgramData\ssh\administrators_authorized_keys /reset
icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "Administrators:F"
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant "SYSTEM:F"
```

---

### Issue: Still asks for password after key setup

**Diagnosis**:
```powershell
# On home machine, check SSH logs
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 50

# Look for permission errors or "Authentication refused" messages
```

**Common causes**:
1. Wrong file permissions on authorized_keys
2. Public key not on single line (has line breaks)
3. File saved as .txt by mistake
4. Key file in wrong location for Administrator users

---

### Issue: Tailscale ping works but SSH doesn't

**Symptoms**: `tailscale ping` succeeds but `ssh` times out

**This indicates routing issue**, not Tailscale connectivity issue.

**Solution**:
```powershell
# Check routing table
route print | findstr "100.122.228.33"

# Should see only Tailscale route, not campus gateway route
# If you see multiple routes, delete the non-Tailscale one
route delete 100.122.228.33 mask 255.255.255.255 128.189.122.129
```

---

## Security Considerations

### SSH Key Security

1. **Private Key**: Never share or expose `id_ed25519` (private key)
   - Keep it on the remote machine only
   - Set file permissions to restrict access
   - Consider using a passphrase for extra protection

2. **Public Key**: Safe to share `id_ed25519.pub`
   - Can be copied to multiple servers
   - Only grants access when paired with private key

### Passphrase vs No Passphrase

**With Passphrase**:
- ✅ Extra layer of security if private key is stolen
- ✅ Requires knowing the passphrase to use the key
- ❌ Must enter passphrase each time (can be cached with ssh-agent)

**Without Passphrase**:
- ✅ Completely passwordless login
- ✅ Easier for automation/scripts
- ❌ Anyone with access to private key file can authenticate

### Windows Firewall

Keep SSH restricted to specific interfaces:
```powershell
# Allow SSH only on Tailscale interface (most secure)
New-NetFirewallRule -DisplayName "SSH via Tailscale" -Direction Inbound -InterfaceAlias "Tailscale" -Protocol TCP -LocalPort 22 -Action Allow

# Or allow on Private network profile only
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Profile Private
```

### Authorized Keys File Permissions

**Critical**: OpenSSH will refuse to use authorized_keys if permissions are too open.

Required permissions:
- Only Administrators and SYSTEM should have access
- No inheritance from parent directory
- User must not have overly permissive access

---

## Maintenance

### Adding Additional Keys

To allow access from another machine:

1. Generate key pair on new machine (Part 3)
2. On home machine, edit authorized_keys file:
```powershell
notepad C:\ProgramData\ssh\administrators_authorized_keys
```
3. Add new public key on a new line
4. Each line = one authorized key
5. No restart needed (SSH checks file on each connection)

### Removing Access

To revoke access from a machine:

1. Edit authorized_keys file:
```powershell
notepad C:\ProgramData\ssh\administrators_authorized_keys
```
2. Delete the line containing that machine's public key
3. Save the file
4. Access is immediately revoked

### Checking Active SSH Sessions

```powershell
# View active SSH connections
netstat -an | findstr :22 | findstr ESTABLISHED

# View SSH service logs
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 20
```

---

## Advanced Configuration

### Setting Up SSH Config File (Remote Machine)

Create a config file for easier connections:

```powershell
# Create/edit SSH config
notepad $env:USERPROFILE\.ssh\config
```

Add content:
```
Host home
    HostName 100.122.228.33
    User cinep
    IdentityFile ~/.ssh/id_ed25519

Host cinep
    HostName cinep.taild4d016.ts.net
    User cinep
    IdentityFile ~/.ssh/id_ed25519
```

Now you can connect with just:
```powershell
ssh home
# or
ssh cinep
```

### Using SSH Agent (Windows)

To cache passphrase so you don't enter it repeatedly:

```powershell
# Start ssh-agent service
Start-Service ssh-agent
Set-Service -Name ssh-agent -StartupType Automatic

# Add your key to agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519

# Enter passphrase once - it's now cached
```

### Port Forwarding Through SSH

Forward a remote port to your local machine:

```powershell
# Forward remote port 8080 to local 8080
ssh -L 8080:localhost:8080 cinep@100.122.228.33

# Now access localhost:8080 locally to reach home machine's port 8080
```

---

## Key Files Reference

### Remote Machine (ubco-clw-106155)
```
C:\Users\<username>\.ssh\
├── id_ed25519           # Private key (KEEP SECRET)
├── id_ed25519.pub       # Public key
├── known_hosts          # Stores server fingerprints
└── config               # Optional: SSH client config
```

### Home Machine (cinep)
```
C:\ProgramData\ssh\
├── sshd_config                        # SSH server configuration
├── administrators_authorized_keys     # Public keys for admin users
├── ssh_host_*_key                     # Server host keys
└── logs\
    └── sshd.log                       # SSH server logs

C:\Users\cinep\.ssh\
├── known_hosts          # Servers this machine has connected to
└── known_hosts.old      # Backup of known_hosts
```

---

## Quick Reference Commands

### Connection
```powershell
# Basic connection
ssh cinep@100.122.228.33

# With verbose output (for troubleshooting)
ssh -vvv cinep@100.122.228.33

# Using hostname instead of IP
ssh cinep@cinep.taild4d016.ts.net
```

### Testing
```powershell
# Test Tailscale connectivity
tailscale ping 100.122.228.33

# Test TCP connectivity
Test-NetConnection -ComputerName 100.122.228.33 -Port 22

# Check SSH service
Get-Service sshd

# Check routing
route print | findstr "100.122.228.33"
```

### Maintenance
```powershell
# Restart SSH service (home machine)
Restart-Service sshd

# View SSH logs (home machine)
Get-Content C:\ProgramData\ssh\logs\sshd.log -Tail 50

# Check authorized keys (home machine)
type C:\ProgramData\ssh\administrators_authorized_keys

# Regenerate SSH keys (remote machine)
ssh-keygen -t ed25519 -C "your_email@example.com"
```

---

## Conclusion

This setup provides secure, passwordless SSH access between Windows machines over Tailscale. The key points:

1. **Tailscale** handles the networking and encryption
2. **SSH keys** provide authentication without passwords
3. **Administrator users** require special authorized_keys location
4. **Proper permissions** are critical for OpenSSH security

The configuration is now persistent and will survive:
- Windows updates
- Reboots
- Network changes

As long as Tailscale is running on both machines, SSH access will work seamlessly.

---

## Document Information

- **Created**: November 28, 2025
- **Last Updated**: November 28, 2025
- **Machines**: cinep (100.122.228.33) ↔ ubco-clw-106155 (100.69.56.91)
- **Tailnet**: taild4d016.ts.net
- **SSH Version**: OpenSSH for Windows

---

## Additional Resources

- [OpenSSH for Windows Documentation](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview)
- [Tailscale SSH Documentation](https://tailscale.com/kb/1193/tailscale-ssh/)
- [SSH Key Management Best Practices](https://www.ssh.com/academy/ssh/key-management)
- [Windows Firewall Configuration](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/windows-firewall-with-advanced-security)
