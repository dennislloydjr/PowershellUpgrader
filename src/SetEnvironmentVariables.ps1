# Change this section
$env:ProgramsPath = "D:\p"
$env:DataPath = "D:\d"
$env:CodePath = "D:\c"
$env:ServerPath = "D:\s"
$env:UserDisplayName = "Your name here"
$env:EmailAddress = "email@domain.com"

# Do not modify below this section
# Make environment changes permenant
[Environment]::SetEnvironmentVariable("ProgramsPath", $env:ProgramsPath, "User")
[Environment]::SetEnvironmentVariable("DataPath", $env:DataPath, "User")
[Environment]::SetEnvironmentVariable("CodePath", $env:CodePath, "User")
[Environment]::SetEnvironmentVariable("ServerPath", $env:ServerPath, "User")
[Environment]::SetEnvironmentVariable("UserDisplayName", $env:UserDisplayName, "User")
[Environment]::SetEnvironmentVariable("EmailAddress", $env:EmailAddress, "User")

if ($env:UserDisplayName -eq 'Your name here') {
	throw "Environment variables not configured. Please edit SetEnvironmentVariables.ps1 before running bootstrap.bat"
}