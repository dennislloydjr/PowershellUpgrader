. '.\_Common.ps1'

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

Describe "Installing MSI From URL" {
	Context "When download succeeds" {
		Mock New-Path {}
		Mock Get-DataPath {return 'TestDrive:/z/data'}
		Mock Get-ProgramsPath {return 'TestDrive:/z/programs'}
		Mock Request-Download {}
		Mock Start-Process {}
		
		Install-MsiFromUrl -Url 'url' -Name 'mymsi'
		
		It "should create installs path" {
			Assert-MockCalled New-Path -ParameterFilter {$path -eq 'TestDrive:\z\data\provisioning\installs'}
		}
		It "should download file" {
			Assert-MockCalled Request-Download -ParamterFilter {$source -eq 'sourcepath' -and $destination -eq 'TestDrive:\z\data\provisioning\installs\mymsi.msi'}
		}
		It "and execute msiexec" {
			Assert-MockCalled Start-Process -ParameterFilter {$filepath -eq 'msiexec'}
		}
		It "specifying the package" {
			Assert-MockCalled Start-Process -ParameterFilter {$argumentList -like '*/i TestDrive:\z\data\provisioning\installs\mymsi.msi*'}
		}
		It "with verb 'RunAs'" {
			Assert-MockCalled Start-Process -ParameterFilter {$verb -eq 'RunAs'}
		}
		It "and run silently" {
			Assert-MockCalled Start-Process -ParameterFilter {$argumentList -like '*/quiet /passive /qn /norestart*'}
		}
		It "and should wait" {
			Assert-MockCalled Start-Process -ParameterFilter {$wait -eq $True}
		}
	}
	
	Context "When target directory argument name is TARGETDIR" {
		Mock Get-DataPath {return 'TestDrive:/z/data'}
		Mock Get-ProgramsPath {return 'TestDrive:/z/programs'}
		Mock Request-Download {}
		Mock Start-Process {}
		
		Install-MsiFromUrl -Url 'url' -Name 'mymsi' -TargetDirArgument 'TARGETDIR'

		It "should include TARGETDIR argument" {
			Assert-MockCalled Start-Process -ParameterFilter {$argumentList -like '*TARGETDIR=TestDrive:\z\programs\mymsi*'}
		}
	}
}