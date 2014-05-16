@echo off

:check_permissions
REM Check if Administrative Permissions are available. Otherwise quit.
REM "net session" requires admin permissions, if it errors when we call it, we don't have permission.
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Administrative privileges required to bootstrap the provisioning software. Please start your command shell with Administrative permissions.
	exit /b 1
)

:powershell_settings
powershell Set-ExecutionPolicy unrestricted

:dotnet_and_poweshell_upgrade
powershell -noprofile .\BootstrapProvisioning.ps1
if exist *.msu (
    echo Downloaded Windows Management Framework
	echo.
	echo.
	echo Will now install Windows Management Framework, a reboot will automatically take place. Please shut down any programs before continuing
	pause
	Windows6.1-KB2819745-x64-MultiPkg.msu /quiet
	del Windows6.1-KB2819745-x64-MultiPkg.msu
)
