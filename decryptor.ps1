$encExtension = ".pwndl33t"
$aesKeyBase64="S36moXdlX1G3KDAeBRJjSeOuCU9If7IaCKxGMhUIvhw="

function Validate-Path 
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$false)]
        [ValidateSet("File","Folder","Any")]
        [string]$Type = "Any"
    )

    if (-not $Path) {
        throw "Path cannot be empty."
    }

    # Resolve to full path if possible
    try {
        $resolved = Resolve-Path -Path $Path -ErrorAction Stop
        $resolved = $resolved.ProviderPath
    }
    catch {
        throw "Path does not exist: $Path"
    }

    switch ($Type) {

        "File" {
            if (-not (Test-Path $resolved -PathType Leaf)) {
                throw "Expected a file but found something else: $resolved"
            }
        }

        "Folder" {
            if (-not (Test-Path $resolved -PathType Container)) {
                throw "Expected a folder but found something else: $resolved"
            }
        }

        "Any" {
            # nothing else to check
        }
    }

    return $resolved
}

function Decrypt-File
 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    # Read AES key
    $aesKeyBase64 = $aesKeyBase64.Trim() -replace "^[\uFEFF\u200B]+",""
    $KeyBytes = [Convert]::FromBase64String($aesKeyBase64)

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256
    $aes.BlockSize = 128
    $aes.Key = $KeyBytes 

    # Read encrypted file
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)

    # Extract IV
    $iv = $fileBytes[0..15]
    $aes.IV = $iv

    $decryptor = $aes.CreateDecryptor()


    $encryptedBytes = $fileBytes[16..($fileBytes.Length - 1)]
    $decryptedBytes = $decryptor.TransformFinalBlock(
        $encryptedBytes, 0, $encryptedBytes.Length
    )

    # Remove extension dynamically
    $escapedExt = [Regex]::Escape($encExtension)
    $originalPath = $FilePath -replace "$escapedExt$",""

    [System.IO.File]::WriteAllBytes($originalPath, $decryptedBytes)

    $aes.Dispose()
}

function Decrypt 
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$FolderPath
    )
    
    $FolderPath = Validate-Path -Path $FolderPath -Type Folder


    $files = Get-ChildItem -Path $FolderPath -File -Recurse -Filter "*$encExtension"

    foreach ($file in $files) {
        Decrypt-File -FilePath $file.FullName -KeyFilePath $key
    }

    Write-Host "Decryption complete."
}