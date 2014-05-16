function Get-DotNetVersion {
	(Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | Get-ItemProperty -name 'Version' -EA 0 | Sort-Object 'Version' -desc | Select-Object -first 1).Version
}

function Install-DotNet {
	param(
		[Parameter(Mandatory=$True,
				   ValueFromPipeline=$True,
				   ValueFromPipelineByPropertyName=$True)]
		[string]$source
	)

	$downloadPath = Join-Path (Get-DataPath) 'provisioning\installs'
	New-Path ($downloadPath) > $null
	$targetPath = Join-Path $downloadPath 'DotNet.exe'
	Request-Download $source $targetPath
	
	Write-Host "Starting install..."
	Start-Process -FilePath $targetPath -ArgumentList '/q /norestart' -Wait -Verb 'RunAs'
}

Export-ModuleMember 'Get-DotNetVersion'
Export-ModuleMember 'Install-DotNet'