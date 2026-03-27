param(
    [Parameter(Mandatory = $true)]
    [int]$Quantity,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

# Prepare output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}
$OutputDir = (Resolve-Path $OutputPath).ProviderPath

# ----------------------------
# PARALLEL-ONLY WORKER BLOCK
# ----------------------------

1..$Quantity | ForEach-Object -Parallel {
    $OutputDir = $using:OutputDir

    # ----------------------------
    # Helper resources inside parallel block
    # ----------------------------

    $NameParts1 = @("Annual","Project","Financial","Summary","Employee","Quarterly","Technical","Operations","Internal","Customer")
    $NameParts2 = @("Report","Overview","Notes","Analysis","Review","Update","Plan","Sheet","Document","Brief")
    $NameParts3 = @("2023","2024","v1","v2","Draft","Final","RevA","RevB")

    function New-RealisticName {
        param([string]$Ext)
        "{0}_{1}_{2}.{3}" -f `
            ($NameParts1 | Get-Random), `
            ($NameParts2 | Get-Random), `
            ($NameParts3 | Get-Random), `
            $Ext
    }

    function Get-RandomText {
        param([int]$Length)
        -join ((65..90)+(97..122)+(48..57) | Get-Random -Count $Length | % {[char]$_})
    }

    function New-FileWithRandomContent {
        param(
            [string]$Path,
            [int]$SizeBytes
        )

        $marker = "If you can read this it is not encrypted.`r`n"
        $paddingSize = [Math]::Max(0, $SizeBytes - $marker.Length)
        $content = $marker + (Get-RandomText -Length $paddingSize)
        Set-Content -Path $Path -Value $content -Encoding utf8
    }

    $extensions = @("txt", "docx", "xlsx", "pdf", "pptx")

    foreach ($ext in $extensions) {
        $name = New-RealisticName -Ext $ext
        $filePath = Join-Path -Path $OutputDir -ChildPath $name
        $size = Get-Random -Minimum 1024 -Maximum 65536
        New-FileWithRandomContent -Path $filePath -SizeBytes $size
    }

} -ThrottleLimit 4

Write-Host "Done! Created $Quantity sets of random files in '$OutputDir'."