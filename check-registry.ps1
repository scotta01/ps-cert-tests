$registryPath = "HKLM:\SOFTWARE\Microsoft\SystemCertificates\AuthRoot\AutoUpdate"

Write-Host "Checking AuthRoot AutoUpdate Registry Values" -ForegroundColor Green
Write-Host "Registry Path: $registryPath" -ForegroundColor Yellow
Write-Host ("-" * 60)

try {
    if (Test-Path $registryPath) {
        Write-Host "Registry key found." -ForegroundColor Green

        $registryKey = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue

        Write-Host "`nEncodedCtl Value:" -ForegroundColor Cyan
        if ($registryKey.PSObject.Properties.Name -contains "EncodedCtl") {
            $encodedCtl = $registryKey.EncodedCtl
            if ($encodedCtl -is [byte[]]) {
                Write-Host "  Type: Binary (REG_BINARY)" -ForegroundColor White
                Write-Host "  Length: $($encodedCtl.Length) bytes" -ForegroundColor White
                Write-Host "  First 16 bytes (hex): $([System.BitConverter]::ToString($encodedCtl[0..([Math]::Min(15, $encodedCtl.Length-1))]) -replace '-', ' ')" -ForegroundColor White
            } else {
                Write-Host "  Value: $encodedCtl" -ForegroundColor White
                Write-Host "  Type: $($encodedCtl.GetType().Name)" -ForegroundColor White
            }
        } else {
            Write-Host "  EncodedCtl value not found" -ForegroundColor Red
        }

        Write-Host "`nLastSyncTime Value:" -ForegroundColor Cyan
        if ($registryKey.PSObject.Properties.Name -contains "LastSyncTime") {
            $lastSyncTime = $registryKey.LastSyncTime
            if ($lastSyncTime -is [byte[]]) {
                Write-Host "  Type: Binary (REG_BINARY)" -ForegroundColor White
                Write-Host "  Length: $($lastSyncTime.Length) bytes" -ForegroundColor White
                Write-Host "  Raw bytes (hex): $([System.BitConverter]::ToString($lastSyncTime) -replace '-', ' ')" -ForegroundColor White

                if ($lastSyncTime.Length -eq 8) {
                    try {
                        $fileTime = [BitConverter]::ToInt64($lastSyncTime, 0)
                        $dateTime = [DateTime]::FromFileTime($fileTime)
                        Write-Host "  Converted to DateTime: $($dateTime.ToString('yyyy-MM-dd HH:mm:ss UTC'))" -ForegroundColor White
                    } catch {
                        Write-Host "  Could not convert to DateTime" -ForegroundColor Yellow
                    }
                }
            } else {
                Write-Host "  Value: $lastSyncTime" -ForegroundColor White
                Write-Host "  Type: $($lastSyncTime.GetType().Name)" -ForegroundColor White
            }
        } else {
            Write-Host "  LastSyncTime value not found" -ForegroundColor Red
        }

    } else {
        Write-Host "Registry key not found: $registryPath" -ForegroundColor Red
        Write-Host "This could indicate:" -ForegroundColor Yellow
        Write-Host "  - Windows certificate auto-update is not configured" -ForegroundColor Yellow
        Write-Host "  - Insufficient permissions to access the registry key" -ForegroundColor Yellow
        Write-Host "  - The system hasn't performed certificate updates yet" -ForegroundColor Yellow
    }

} catch {
    Write-Host "Error accessing registry: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure you're running this script with administrator privileges." -ForegroundColor Yellow
}

Write-Host "`nChecking Policy: DisableRootAutoUpdate" -ForegroundColor Green
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\SystemCertificates\AuthRoot"
Write-Host "Policy Registry Path: $policyPath" -ForegroundColor Yellow

try {
    if (Test-Path $policyPath) {
        Write-Host "Policy key found." -ForegroundColor Green
        $policyKey = Get-ItemProperty -Path $policyPath -ErrorAction SilentlyContinue

        if ($policyKey.PSObject.Properties.Name -contains "DisableRootAutoUpdate") {
            $val = $policyKey.DisableRootAutoUpdate
            Write-Host "DisableRootAutoUpdate: $val (REG_DWORD)" -ForegroundColor Cyan

            if ($val -eq 1) {
                Write-Host "Windows Root Certificate AutoUpdate is DISABLED by policy." -ForegroundColor Red
            } elseif ($val -eq 0) {
                Write-Host "Windows Root Certificate AutoUpdate is ENABLED (explicitly) by policy." -ForegroundColor Green
            } else {
                Write-Host "Unexpected value for DisableRootAutoUpdate: $val" -ForegroundColor Yellow
            }
        } else {
            Write-Host "DisableRootAutoUpdate value not found (policy Not Configured)." -ForegroundColor Yellow
            Write-Host "Windows may use default behavior (AutoUpdate enabled)." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Policy key not found. Policy likely Not Configured." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error accessing policy registry: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" ("-" * 60)
Write-Host "Script completed." -ForegroundColor Green