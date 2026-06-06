# Build

Build the frontend first, then build the Go backend so the frontend assets are embedded in `filebrowser.exe`.

Requirements:

- Node.js `>= 24`
- pnpm `>= 10`
- Go

From the repository root:

```powershell
.\build.ps1
```

To build and copy to the default deployment folder:

```powershell
.\build.ps1 -Deploy
```

To deploy to a different executable path:

```powershell
.\build.ps1 -Deploy -DeployPath "G:\util\windows-amd64-filebrowser\filebrowser.exe"
```

From `cmd.exe`, run the PowerShell script through PowerShell:

```cmd
powershell -ExecutionPolicy Bypass -File build.ps1
```

To build and deploy from `cmd.exe`:

```cmd
powershell -ExecutionPolicy Bypass -File build.ps1 -Deploy
```

If using PowerShell 7, replace `powershell` with `pwsh`.

The script runs these steps:

```powershell
cd frontend
pnpm install
pnpm run build

cd ..
go build -o filebrowser.exe .
```

Restart File Browser after replacing the executable.
