# Renewing File Browser HTTPS Certificate (mkcert)

This guide assumes:

```text
Server IP:        192.168.0.2
File Browser Dir: G:\util\windows-amd64-filebrowser
SSL Dir:          G:\util\windows-amd64-filebrowser\ssl
```

---


# 1. Verify Existing Root CA


Check mkcert CA location:

```cmd
mkcert -CAROOT
```

Expected files:

```text
rootCA.pem
rootCA-key.pem
```

Important:

```text
Do NOT create a new root CA.
Do NOT run mkcert -uninstall.
Do NOT delete rootCA.pem or rootCA-key.pem.
```

Using the same CA means:

```text
Clients do NOT need to reinstall rootCA.pem.
```

---

# 2. Stop File Browser Service

Open Administrator CMD:

```cmd
cd /d G:\util\windows-amd64-filebrowser
FileBrowserService.exe stop
```

or:

```cmd
net stop FileBrowser
```

Verify:

```cmd
sc query FileBrowser
```

Expected:

```text
STATE : 1 STOPPED
```

---

# 3. Backup Existing Certificate

```cmd
cd /d G:\util\windows-amd64-filebrowser\ssl
copy filebrowser.crt filebrowser.crt.bak
copy filebrowser.key filebrowser.key.bak
```

---



# 4. Generate New Certificate

Generate a replacement certificate signed by the existing mkcert CA:

```cmd
mkcert ^
    -cert-file G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt ^
    -key-file  G:\util\windows-amd64-filebrowser\ssl\filebrowser.key ^
    192.168.0.2
```

If users access the server using multiple names:

```cmd
mkcert ^
    -cert-file G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt ^
    -key-file  G:\util\windows-amd64-filebrowser\ssl\filebrowser.key ^
    192.168.0.2
```

Include every hostname/IP users may enter in the browser.


---



# 5. Verify New Certificate

Check certificate details:

```cmd
certutil -dump G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt
```

Verify:

```text
Subject Alternative Name
```

contains:

```text
192.168.0.2
```

and any additional names used by clients.

---

# 6. Start File Browser Service

```cmd
cd /d G:\util\windows-amd64-filebrowser
FileBrowserService.exe start
```

or:

```cmd
net start FileBrowser
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

# 7. Test HTTPS

From a client browser:

```text
https://192.168.0.2
```



Verify:

\* No certificate warning
\* Login page loads
\* Files are accessible


---


# 8. Verify Certificate Expiration

Check expiration date:


```cmd
certutil -dump G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt
```

Look for:

```text
NotBefore
NotAfter
```

---


# When Clients Need Reinstallation

Clients DO NOT need a new root certificate if:

```text
rootCA.pem is unchanged
rootCA-key.pem is unchanged
```

Clients MUST reinstall rootCA.pem only if:

```text
A new root CA was created
```

Examples:

```cmd
mkcert -uninstall
mkcert -install
```

OR

```text
rootCA.pem deleted
```

OR

```text
rootCA-key.pem deleted
```

In those cases:

```text
All existing filebrowser.crt certificates become untrusted.
```

and a new rootCA.pem must be distributed to every client.

---



# Quick Renewal Procedure



```cmd
net stop FileBrowser

mkcert ^
    -cert-file G:\util\windows-amd64-filebrowser\ssl\filebrowser.crt ^
    -key-file  G:\util\windows-amd64-filebrowser\ssl\filebrowser.key ^
    192.168.0.2

net start FileBrowser
```

No client action required as long as the same mkcert root CA is used.
