function Decrypt-File
 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter(Mandatory=$true)]
        [string]$KeyFilePath
    )

    if (-not (Test-Path $KeyFilePath)) {
        throw "Decryption key file not found at: $KeyFilePath"
    }

    # Read AES key (take last non-empty line)
    $keyText = Get-Content $KeyFilePath | Where-Object { $_.Trim() -ne "" }
    $aesKeyBase64 = $keyText[-1]

    try {
        $aesKey = [Convert]::FromBase64String($aesKeyBase64)
    }
    catch {
        throw "The key file does not contain a valid Base64 AES key."
    }

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256
    $aes.BlockSize = 128
    $aes.Key = $aesKey

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
        [string]$FolderPath,

        [Parameter(Mandatory=$true)]
        [string]$KeyFilePath 
    )
    
    $FolderPath = Validate-Path -Path $FolderPath -Type Folder

    if (-not (Test-Path $KeyFilePath)) {
        throw "Decryption key file not found at: $KeyFilePath"
    }


    $files = Get-ChildItem -Path $FolderPath -File -Recurse -Filter "*$encExtension"

    foreach ($file in $files) {
        Decrypt-File -FilePath $file.FullName -KeyFilePath $KeyFilePath
    }

    Write-Host "Decryption complete. Key used from: $KeyFilePath"
}