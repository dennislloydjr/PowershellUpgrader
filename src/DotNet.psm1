function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException)) {
		"$i" * 80
		$Exception |Format-List * -Force
   }
   throw $Exception
}

function New-Path {
	param(
		[Parameter(Mandatory=$True,
				   ValueFromPipeline=$True,
				   ValueFromPipelineByPropertyName=$True)]
		[string]$path
	)
	if (!(Test-Path -Path $path)) {
		New-Item -ItemType directory -Path $path
	}
}

function Request-Download {
	param(
		[Parameter(Mandatory=$True,
				   ValueFromPipeline=$True,
				   ValueFromPipelineByPropertyName=$True)]
		[string]$source,
		[Parameter(Mandatory=$True)]
		[string]$destination
	)
	Write-Host "Downloading $source to $destination"
	
	try {
		$webclient = New-Object System.Net.WebClient
		$proxy = New-Object System.Net.WebProxy
		$proxy.Address = $webclient.proxy.GetProxy($source).AbsoluteUri
		$proxy.useDefaultCredentials = $true
		$webclient.proxy = $proxy
		$webclient.DownloadFile($source, $destination)
	} catch [System.Exception] {
		Resolve-Error $_.Exception
	}
}

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

	$targetPath = 'DotNet.exe'
	Request-Download $source $targetPath
	
	Write-Host "Starting install..."
	Start-Process -FilePath $targetPath -ArgumentList '/q /norestart' -Wait -Verb 'RunAs'
}

Export-ModuleMember 'Get-DotNetVersion'
Export-ModuleMember 'Install-DotNet'