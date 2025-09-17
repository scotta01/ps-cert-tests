# ps-cert-tests

A small collection of PowerShell scripts and tests that help you inspect Windows Root Certificate AutoUpdate behavior and validate TLS connectivity against one or more URLs.

## What's inside

- **check-certs.ps1**: Verifies whether specific root CA certificates (by thumbprint) are present on the local machine, performs live web requests to given URLs, and then re-checks the presence of those root CAs. Optionally offers to delete listed roots to facilitate repeated testing.
- **check-registry.ps1**: Reads the Windows registry to display information related to the AuthRoot AutoUpdate feature and the DisableRootAutoUpdate policy setting.
- **Tests/CertScripts.Tests.ps1**: A minimal Pester test suite that ensures both scripts execute without errors in typical environments.

## Requirements

- Windows with PowerShell (Windows PowerShell 5.1 or PowerShell 7+)
- Network access to the target URLs if you plan to run check-certs.ps1
- Administrator rights are recommended (and required for deletion of certificates from the LocalMachine store). Running without elevation still works for read-only checks
- Pester (for running tests). The current tests use syntax compatible with Pester 3.4 and newer

## Quick start
1. Clone or download this repository
2. Open an elevated PowerShell session (recommended for full functionality)
3. Run the scripts from the repository root as shown below

## check-certs.ps1

**Purpose**: Check presence of specific root CA(s), make a web request, then check again.

### Parameters

- **-CertThumbprints**: One or more SHA-1 thumbprints (as strings) of the root CA certificates to check in the LocalMachine\Root store
- **-Urls**: One or more HTTPS URLs to request

### Examples

```powershell
# Example thumbprint provided for Google-related testing (subject to change over time)
$thumb = 'b1bc968bd4f49d622aa89a81f2150152a41d829c'

# Single URL
.\check-certs.ps1 -CertThumbprints @($thumb) -Urls @('https://www.google.com')

# Multiple URLs and multiple thumbprints
.\check-certs.ps1 -CertThumbprints @('thumb1','thumb2') -Urls @('https://example.com','https://contoso.com')
```

### Notes

- The script uses the LocalMachine Root store (Cert:\LocalMachine\Root). You typically need admin rights to remove certificates from this store
- Windows often does not store or add the root from a server response; instead, it builds the chain to a trusted root already present in the local store. AutoUpdate may add roots as needed based on policy and chain building
- Root/thumbprint expectations vary by environment and time due to cross-signing and CA rotations

## check-registry.ps1

**Purpose**: Display registry values for AuthRoot AutoUpdate and the DisableRootAutoUpdate group policy setting.

### What it checks

- `HKLM:\SOFTWARE\Microsoft\SystemCertificates\AuthRoot\AutoUpdate`
  - EncodedCtl (REG_BINARY)
  - LastSyncTime (REG_BINARY) with a best-effort conversion to DateTime
- `HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\AuthRoot`
  - DisableRootAutoUpdate (REG_DWORD)

### How to run

```powershell
.\check-registry.ps1
```

Output is color-coded and resilient to missing keys or permission issues.

## Running tests

- Ensure Pester is installed:
  ```powershell
  Install-Module Pester -Scope CurrentUser
  ```

- From the repository root, run:
  ```powershell
  Invoke-Pester -Path .\Tests
  ```

### The test suite

- Executes check-certs.ps1 against https://www.google.com with the example thumbprint and asserts that the script does not throw
- Executes check-registry.ps1 and asserts that the script does not throw

## Troubleshooting

- **Execution policy**: If scripts are blocked, you may need to adjust your execution policy temporarily in an elevated session:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
  ```

- **Proxy/Firewall**: If Invoke-WebRequest fails, verify your proxy settings or firewall connectivity. You can try adding -UseBasicParsing on older Windows PowerShell versions if needed

- **Admin rights**: Deleting certificates from the LocalMachine store requires elevation. Read-only checks can be done without admin rights, but some registry keys may still need elevation to access

## Security and safety notes

- Do not pin SHA-1 thumbprints for security decisions. SHA-1 is used here only for identification and store lookups (as used by the Windows Cert: provider). If you need pinning, prefer SHA-256 of the leaf/intermediate and fully understand operational risks
- Removing certificates from the LocalMachine Root store can affect trust decisions system-wide. Only remove test certificates on disposable or lab machines

## License

This project is licensed under the MIT License. See LICENSE for details.
