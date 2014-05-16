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
	Mock Get-DataPath {return 'TestDrive:\z\data'}
	Mock Install-MsiFromUrl
	
	Install-DotNet -source 'source-path'
	
	It 'Downloads and installs .Net from URL' {
		Assert-MockCalled New-Path -ParamterFilter {$path -eq 'TestDrive:\z\data\provisioning\installs\'}
		Assert-MockCalled Request-Download -ParameterFilter {$source -eq 'source-path' -and $destination -eq 'TestDrive:\z\data\provisioning\installs\DotNet.exe'}
		Assert-MockCalled Start-Process -ParameterFilter {$filePath -eq 'TestDrive:\z\data\provisioning\installs\DotNet.exe' -and $argumentList -eq '/q /norestart' -and $wait -eq $True -and $verb -eq 'RunAs'}
	}
}