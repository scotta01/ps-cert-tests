$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $here

Describe "ps-cert-tests scripts" -Tag 'integration' {

    Context "check-certs.ps1" {
        It "runs without error against google.com with provided thumbprint" {
            $scriptPath = Join-Path $repoRoot 'check-certs.ps1'
            $thumb = 'b1bc968bd4f49d622aa89a81f2150152a41d829c'
            { & $scriptPath -CertThumbprints @($thumb) -Urls @('https://www.google.com') } | Should Not Throw
        }
    }

    Context "check-registry.ps1" {
        It "executes without throwing, regardless of registry state" {
            $scriptPath = Join-Path $repoRoot 'check-registry.ps1'
            { & $scriptPath } | Should Not Throw
        }
    }
}
