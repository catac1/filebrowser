# File Browser HTTPS Installation Guide (Windows)

## Server Environment

File Browser installation directory:

```text
G:\util\windows-amd64-filebrowser
```

Shared folder:

```text
G:\Shared
```

HTTPS certificate directory:

```text
G:\util\windows-amd64-filebrowser\ssl
```

---

# 1. Generate Local CA

Install mkcert and run:

```cmd
mkcert -install
```

Find the CA location:

```cmd
mkcert -CAROOT
```

Files created:

```text
rootCA.pem
rootCA-key.pem
```

Keep:

```text
rootCA-key.pem
```

private and never distribute it.

---

# 2. Generate File Browser Certificate

Generate certificate for the server IP:

```cmd
mkcert ^
  -cert-file filebrowser.crt ^
  -key-file filebrowser.key ^
  192.168.0.2
```

Copy files:

```text
filebrowser.crt
filebrowser.key
```

to:

```text
G:\util\windows-amd64-filebrowser\ssl
```

---

# 3. Configure File Browser HTTPS

Configure TLS certificate:

```cmd
filebrowser.exe config set ^
  --cert G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt
```

Configure TLS key:

```cmd
filebrowser.exe config set ^
  --key G:\util\windows-amd64-filebrowser\ssl\filebrowser.key
```

Configure HTTPS port:

```cmd
filebrowser.exe config set --port 443
```

Configure root folder:

```cmd
filebrowser.exe config set --root G:\Shared
```

Verify configuration:

```cmd
filebrowser.exe config cat
```

Expected values:

```text
Port:      443
Root:      G:/Shared
TLS Cert:  G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt
TLS Key:   G:\util\windows-amd64-filebrowser\ssl\filebrowser.key
```

---

# 4. Test HTTPS Manually

Run:

```cmd
cd /d G:\util\windows-amd64-filebrowser

filebrowser.exe
```

Open:

```text
https://192.168.0.2
```

Verify login page appears.

Stop File Browser:

```cmd
Ctrl+C
```

---

# 5. Install Root CA on Client PCs

Copy:

```text
rootCA.pem
```

to the client.

Create:

```cmd
install_rootca.cmd
```

Contents:

```cmd
@echo off

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process cmd -Verb RunAs -ArgumentList '/c ""%~f0""'"
    exit /b
)

certutil -addstore Root "%~dp0rootCA.pem"

pause
```

Run:

```text
install_rootca.cmd
```

Accept UAC prompt.

Restart browser.

---

# 6. Install File Browser as Windows Service

Download WinSW.

Rename:

```text
WinSW-x64.exe
```

to:

```text
FileBrowserService.exe
```

Copy into:

```text
G:\util\windows-amd64-filebrowser
```

---

# 7. Create Service Configuration

Create:

```text
G:\util\windows-amd64-filebrowser\FileBrowserService.xml
```

```xml
<service>
  <id>FileBrowser</id>

  <name>File Browser</name>

  <description>File Browser HTTPS Service</description>

  <executable>%BASE%\filebrowser.exe</executable>

  <workingdirectory>%BASE%</workingdirectory>

  <startmode>Automatic</startmode>

  <log mode="roll" />

  <onfailure action="restart" delay="10 sec" />
  <onfailure action="restart" delay="30 sec" />
</service>
```

---

# 8. Install Service

Open Administrator CMD:

```cmd
cd /d G:\util\windows-amd64-filebrowser
```

Install:

```cmd
FileBrowserService.exe install
```

Start:

```cmd
FileBrowserService.exe start
```

Verify:

```cmd
sc query FileBrowser
```

Expected:

```text
STATE : 4 RUNNING
```

---

# 9. Verify Service Startup

Reboot the server.

After reboot:

```cmd
sc query FileBrowser
```

Expected:

```text
STATE : 4 RUNNING
```

Open from a client:

```text
https://192.168.0.2
```

Verify:

* HTTPS certificate trusted
* Login page displayed
* Shared files accessible

---

# Troubleshooting

Check service logs:

```text
FileBrowserService.out.log
FileBrowserService.err.log
```

Check File Browser log:

```text
G:\util\windows-amd64-filebrowser\filebrowser.log
```

Check ports:

```cmd
netstat -ano | findstr :80
netstat -ano | findstr :443
```

Verify certificate:

```cmd
certutil -dump G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt
```

Verify root CA installation:

```cmd
certutil -store Root
```
