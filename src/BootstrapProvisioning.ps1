Import-Module .\Provisioning.psm1
Import-Module .\DotNet.psm1

# .Net Framework Version 4.5
if ((Get-DotNetVersion) -lt '4.5') {
	Write-Host 'Installing .Net Version 4.5'
	Install-DotNet -Source 'http://download.microsoft.com/download/1/6/7/167F0D79-9317-48AE-AEDB-17120579F8E2/NDP451-KB2858728-x86-x64-AllOS-ENU.exe'
}

# Windows Management Framework
if ($PSVersionTable.PSVersion.Major -lt '4') {
	Write-Host 'Upgrading Powershell with Windows Management Framework 4.0'
	Request-Download 'http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu' 'Windows6.1-KB2819745-x64-MultiPkg.msu'
}