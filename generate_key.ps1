# Generates a random 256-bit AES key and saves it as Base64 text
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

# Create a 256-bit (32-byte) AES key using a cryptographically secure RNG
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$aesKey = New-Object byte[] 32
$rng.GetBytes($aesKey)


# Convert to Base64 for storage
$keyBase64 = [Convert]::ToBase64String($aesKey)

# Write to file
$keyBase64 | Set-Content -Path $OutputPath -Encoding ASCII

Write-Host "AES key saved to $OutputPath"
 
