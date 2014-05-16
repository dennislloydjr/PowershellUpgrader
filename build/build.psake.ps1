$psake.use_exit_on_error = $true

properties {
    $currentDir = resolve-path .
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $baseDir = Join-Path $psake.build_script_dir '..'
}

Task default -depends Build
Task Build -depends Clean, Test, Package

Task Clean {
	if ((Test-Path -Path "$baseDir\build\output")) {
		Get-ChildItem -Path "$baseDir\build\output" -Recurse | Remove-Item -force -recurse
	}
	New-Item -ItemType directory -Path "$baseDir\build\output\test-results" > $null
	New-Item -ItemType directory -Path "$baseDir\build\output\package" > $null
}

Task Test {
	Import-Module "$baseDir\packages\Pester-2.0.3\Pester.psm1"
	CD "$baseDir\test"
	Invoke-Pester -OutputXml "$baseDir\build\output\test-results\Tests.xml"
	CD $currentDir
}

Task Package {
	CD $baseDir
	[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
	$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
	[System.IO.Compression.ZipFile]::CreateFromDirectory("$baseDir\src", "$baseDir\build\output\package\Provisioning.zip", $compressionLevel, $false)
}