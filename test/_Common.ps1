$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'

Get-ChildItem -Path $src -Recurse |
				Where-Object {($_.Name -like '*.ps1' -or $_.Name -like '*.psm1') -and -not($_.Name -like 'Install-Provisioning.ps1') -and -not($_.Name -like 'BootstrapProvisioning.ps1') -and -not($_.Directory -like '*\scoop\*') -and -not($_.Name -like 'SetEnvironmentVariables.ps1')} |
				% { 
	$codeFile = Join-Path $_.Directory $_.Name
	
	$code = Get-Content $codeFile | Out-String
	Invoke-Expression $code
}