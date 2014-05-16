function Get-ProgramsPath {
	return $env:ProgramsPath
}

function Get-DataPath {
	return $env:DataPath
}

function Get-CodePath {
	return $env:CodePath
}

function Get-UserDisplayName {
	return $env:UserDisplayName
}

function Get-EmailAddress {
	return $env:EmailAddress
}

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

function Install-MsiFromUrl {
	param(
		[Parameter(Mandatory=$True,
				   ValueFromPipeline=$True,
				   ValueFromPipelineByPropertyName=$True)]
		[string]$url,
		[Parameter(Mandatory=$True)]
		[string]$name,
		[Parameter(Mandatory=$False)]
		[string]$targetDirArgument
	)
	$downloadPath = (Join-Path (Get-DataPath) 'provisioning/installs')
	$downloadTarget = (Join-Path $downloadPath "$name.msi")
	
	New-Path $downloadPath > $null
	
	Request-Download -Source $url -Destination $downloadTarget
	
	$argumentList = "/i $downloadTarget "
	if (!([string]::IsNullOrEmpty($targetDirArgument))) {
		$targetDir = (Join-Path (Get-ProgramsPath) $name)
		$argumentList += "$targetDirArgument=$targetDir"
	}
	$argumentList += " REINSTALL=ALL /quiet /passive /qn /norestart /l* log.txt"
	
	Write-Host "Installing $name from $downloadTarget to $targetDir"
	Start-Process -FilePath 'msiexec' -ArgumentList $argumentList -Verb 'RunAs' -Wait
}

Export-ModuleMember 'Resolve-Error'
Export-ModuleMember 'Initialize-ProvisioningPath'
Export-ModuleMember 'New-Path'
Export-ModuleMember 'Request-Download'
Export-ModuleMember 'Install-MsiFromUrl'