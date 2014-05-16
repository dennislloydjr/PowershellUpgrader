. '.\_Common.ps1'

Add-Type -language CSharp @'
public class FakeRegKey
{
    public string PSPath;
	public string PSParentPath;
	public string PSChildName;
	public string Version;

    public FakeRegKey(string PSPath, string PSParentPath, string PSChildName, string Version) {
        this.PSPath = PSPath;
		this.PSParentPath = PSParentPath;
		this.PSChildName = PSChildName;
		this.Version = Version;
    } 
}
'@


Describe "New-Path" {
	Context "When path exists" {
		New-Item -ItemType directory -Path 'TestDrive:\z' > $null
		Mock New-Item {}
		
		$result = New-Path -path 'TestDrive:\z'
		
		It "should not create path" {
			Assert-MockCalled New-Item -Times 0
		}
		It "should return null" {
			$result | Should Be $null
		}
	}

	Context "When path does not exist" {
		$result = New-Path -path 'TestDrive:\z'
		
		It "should create path" {
			Test-Path 'TestDrive:\z' | Should Be True
		}
		It "should return path" {
			$result | Should Be (Convert-Path 'TestDrive:\z')
		}
	}
}

Describe "Request-Download" {
	Context "When file not found" {
		$sourcePath = (New-Item 'TestDrive:/source.txt' -type file -Force).DirectoryName + '/DoesNotExist.txt'
		$targetPath = (New-Item 'TestDrive:/target.txt' -type file -Force).DirectoryName + '/target.txt'
		$execptionThrown = $False
		
		try {
			Request-Download -Source $sourcePath -Destination $targetPath > $null
		} catch {
			$exceptionThrown = $True
		}

		It "should not create target" {
			Test-Path 'C:/target.txt' | Should Be $False
		}
		
		It "should throw an exception" {
			$exceptionThrown | Should Be $True
		}
	}
	Context "When file exits" {
		$sourcePath = (New-Item 'TestDrive:/source.txt' -type file -Force).DirectoryName + '/source.txt'
		$targetPath = (New-Item 'TestDrive:/target.txt' -type file -Force).DirectoryName + '/target.txt'
		$contents = 'This is my text.'
		
		Add-Content -Path $sourcePath $contents
	
		Request-Download $sourcePath $targetPath
		
		It "should download" {
			Get-Content $targetPath | Should Be $contents
		}
	}
}

Describe 'Get-DotNetVersion' {
	Context 'When Multiple Versions' {
		Mock Get-ChildItem {return @('path1';'path2';'path3')}
		Mock Get-ItemProperty {return New-Object FakeRegKey('path1','path1','1033','99.0.1')} -ParameterFilter {$path -eq 'path1' -and $name -eq 'Version'}
		Mock Get-ItemProperty {return New-Object FakeRegKey('path2','path2','1033','99.9.9')} -ParameterFilter {$path -eq 'path2' -and $name -eq 'Version'}
		Mock Get-ItemProperty {return New-Object FakeRegKey('path3','path3','1033','19.9.9')} -ParameterFilter {$path -eq 'path3' -and $name -eq 'Version'}
		
		$version = Get-DotNetVersion
		
		It 'Returns Highest Version Number' {
			Assert-MockCalled Get-ChildItem -ParamterFilter {$path -eq 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -and $recurse -eq $True}
			$version | Should Be '99.9.9'
		}
	}
}

Describe 'Install-DotNet' {
	Mock New-Path {return $path}
	Mock Request-Download {}
	Mock Start-Process {}
	
	Install-DotNet -source 'source-path'
	
	It 'Downloads and installs .Net from URL' {
		Assert-MockCalled Request-Download -ParameterFilter {$source -eq 'source-path' -and $destination -eq 'DotNet.exe'}
		Assert-MockCalled Start-Process -ParameterFilter {$filePath -eq 'DotNet.exe' -and $argumentList -eq '/q /norestart' -and $wait -eq $True -and $verb -eq 'RunAs'}
	}
}