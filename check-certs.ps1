param (
    [string[]]$CertThumbprints,
    [string[]]$Urls
)

cls

function Write-Section {
    param ([string]$Title)
    Write-Host "========================================="
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "========================================="
}

# Display installed Root CAs
Write-Section "Installed Root CAs"
foreach ($thumbprint in $CertThumbprints) {
    if (Test-Path "Cert:\LocalMachine\Root\$thumbprint") {
        Write-Host "Certificate with thumbprint $thumbprint is installed" -ForegroundColor Green
    } else {
        Write-Host "Certificate with thumbprint $thumbprint is NOT installed" -ForegroundColor Yellow
    }
}

Write-Section "Web Requests to Test Auto Certificate Add"
foreach ($url in $Urls) {
    Write-Host "Testing URL: $url" -ForegroundColor Cyan
    try {
        Invoke-WebRequest $url -ErrorAction Stop | Out-Null
        Write-Host "Request to $url succeeded" -ForegroundColor Green
    } catch {
        Write-Host "Request to $url failed: $_" -ForegroundColor Red
    }
}

Write-Section "Root CAs After Web Requests"
foreach ($thumbprint in $CertThumbprints) {
    if (Test-Path "Cert:\LocalMachine\Root\$thumbprint") {
        Write-Host "Certificate with thumbprint $thumbprint is installed" -ForegroundColor Green
    } else {
        Write-Host "Certificate with thumbprint $thumbprint is NOT installed" -ForegroundColor Yellow
    }
}

if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]) -eq "Administrator") {
    Write-Section "Certificate Deletion"
    $delete = Read-Host -Prompt "Do you wish to remove the CA certs for further testing? [y/N]"

    if ($delete -eq "y") {
        foreach ($thumbprint in $CertThumbprints) {
            try {
                Remove-Item "Cert:\LocalMachine\Root\$thumbprint" -ErrorAction Stop
                Write-Host "Certificate with thumbprint $thumbprint removed successfully" -ForegroundColor Green
            } catch {
                Write-Host "Failed to remove certificate" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "No certificates were removed" -ForegroundColor Yellow
    }
}