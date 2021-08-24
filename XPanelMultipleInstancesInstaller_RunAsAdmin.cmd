@echo off
cls
echo.
echo [------------------------------------------------------------------------]
echo [           Utility: Enable Multiple Crestron XPanel Instances           ]
echo [                        Written By: Eric Walters                        ]
echo [------------------------------------------------------------------------]
echo.

rem Change directory into the folder where the cmd file is located
cd %~dp0

rem Check first that we have admin rights before continuing
call:check_Permissions

rem Check to see if PowerShell ExecutionPolicy will allow us to run scripts
call:Check_PowerShell

rem Check to see if Crestron XPanel is even installed
call:check_Installation

rem Create the XPanels directory. This directory name must be C:\Crestron XPanels unless you also edit the registry file
if not exist "C:\Crestron XPanels" (
	echo Creating C:\Crestron XPanels.
	echo.
	md "C:\Crestron XPanels"
)

rem Copy the existing Crestron XPanel folder into the new XPanels folder 3 times for the 3 new instances
if exist "C:\Program Files (x86)\Crestron\XPanel\" (
	echo Copying XPanel files to new folder.
	echo.
	xcopy "C:\Program Files (x86)\Crestron\XPanel\CrestronXPanel" "C:\Crestron XPanels\CrestronXPanel-1" /E /I /Y >nul
	xcopy "C:\Program Files (x86)\Crestron\XPanel\CrestronXPanel" "C:\Crestron XPanels\CrestronXPanel-2" /E /I /Y >nul
	xcopy "C:\Program Files (x86)\Crestron\XPanel\CrestronXPanel" "C:\Crestron XPanels\CrestronXPanel-3" /E /I /Y >nul
)
if exist "C:\Program Files\Crestron\XPanel\" (
	echo Copying XPanel files to new folder.
	echo.
	xcopy "C:\Program Files\Crestron\XPanel\CrestronXPanel" "C:\Crestron XPanels\CrestronXPanel-1" /E /I /Y >nul
	xcopy "C:\Program Files\Crestron\XPanel\CrestronXPanel" "C:\Crestron XPanels\CrestronXPanel-2" /E /I /Y >nul
	xcopy "C:\Program Files\Crestron\XPanel\CrestronXPanel" "C:\Crestron XPanels\CrestronXPanel-3" /E /I /Y >nul
)

echo Updating application.xml files.
rem The search and replace function expects to take an existing file and output a new file with the new text so I'm renaming the file first
ren "C:\Crestron XPanels\CrestronXPanel-1\META-INF\AIR\application.xml" application.tmp
ren "C:\Crestron XPanels\CrestronXPanel-2\META-INF\AIR\application.xml" application.tmp
ren "C:\Crestron XPanels\CrestronXPanel-3\META-INF\AIR\application.xml" application.tmp

rem Changing the <id> key in the xml file is what allows us to run multiple instances of the Adobe AIR app
call:DoReplace "<id>CrestronXPanel</id>" "<id>CrestronXPanel-1</id>" "C:\Crestron XPanels\CrestronXPanel-1\META-INF\AIR\application.tmp" "C:\Crestron XPanels\CrestronXPanel-1\META-INF\AIR\application.xml"
call:DoReplace "<id>CrestronXPanel</id>" "<id>CrestronXPanel-2</id>" "C:\Crestron XPanels\CrestronXPanel-2\META-INF\AIR\application.tmp" "C:\Crestron XPanels\CrestronXPanel-2\META-INF\AIR\application.xml"
call:DoReplace "<id>CrestronXPanel</id>" "<id>CrestronXPanel-3</id>" "C:\Crestron XPanels\CrestronXPanel-3\META-INF\AIR\application.tmp" "C:\Crestron XPanels\CrestronXPanel-3\META-INF\AIR\application.xml"

rem Clean up the temp files from before
del "C:\Crestron XPanels\CrestronXPanel-1\META-INF\AIR\application.tmp"
del "C:\Crestron XPanels\CrestronXPanel-2\META-INF\AIR\application.tmp"
del "C:\Crestron XPanels\CrestronXPanel-3\META-INF\AIR\application.tmp"

rem Import the registry file that adds the new instances to the context menu
call:DropRegFile
reg import Add_to_context.reg
del Add_to_context.reg

rem Jump to end
goto:end_script

rem [------------------------------------------------------------------------]
rem [                          Utility Subroutines                           ]
rem [------------------------------------------------------------------------]

rem This checks to make sure we have admin rights, otherwise none of this will work.
:check_Permissions
echo Administrative permissions required. Detecting permissions...

net session >nul 2>&1
if %errorLevel% == 0 (
	echo Passed.
	echo.
	exit /b
) else (
	echo Failed. This batch file MUST be run as an administrator. Please use the Run As Administrator option after right clicking on this file.
	echo.
	goto:end_script
)

rem Check for XPanel folder:check_Installation
:check_Installation
if not exist "C:\Program Files (x86)\Crestron\XPanel\" (
	if not exist "C:\Program Files\Crestron\XPanel\" (
		echo Can't find Crestron XPanel folder. Are you sure it's installed?
		echo.
		goto:end_script
	)
)
exit /b

rem This checks for PowerShell execution policy
:Check_PowerShell
echo Checking PowerShell execution policy...
echo New-Item -Path . -Name "execPolPass.txt" -ItemType "file" -Value "" >checkExecPol.ps1
Powershell.exe -executionpolicy ByPass -File checkExecPol.ps1 > nul
del checkExecPol.ps1 /q
if not exist execPolPass.txt (
	echo Failed: PowerShell execution policy is restricted and this script will not run.
	echo Please read the README.MD for troubleshooting this error.
	echo.
	goto:end_script
)
del execPolPass.txt /q
exit /b

rem This is what allows me to distribute this without packaging Crestron files. Without this little gem, you would be editing the xml files by hand.
:DoReplace
echo ^(Get-Content %3^) ^| ForEach-Object { $_ -replace %1, %2 } ^| Set-Content %4>Rep.ps1
Powershell.exe -executionpolicy ByPass -File Rep.ps1
if exist Rep.ps1 del Rep.ps1
exit /b

rem This creates the registry file that gets imported
:DropRegFile
if exist Add_to_context.reg ( del Add_to_context.reg )

(
echo Windows Registry Editor Version 5.00
echo.
echo [HKEY_CLASSES_ROOT\vtz\shell\Instance 2]
echo.
echo [HKEY_CLASSES_ROOT\vtz\shell\Instance 2\command]
echo @="\"C:\\Crestron XPanels\\CrestronXPanel-1\\CrestronXPanel.exe\" \"%%1\""
echo.
echo [HKEY_CLASSES_ROOT\vtz\shell\Instance 3]
echo.
echo [HKEY_CLASSES_ROOT\vtz\shell\Instance 3\command]
echo @="\"C:\\Crestron XPanels\\CrestronXPanel-2\\CrestronXPanel.exe\" \"%%1\""
echo.
echo [HKEY_CLASSES_ROOT\vtz\shell\Instance 4]
echo.
echo [HKEY_CLASSES_ROOT\vtz\shell\Instance 4\command]
echo @="\"C:\\Crestron XPanels\\CrestronXPanel-3\\CrestronXPanel.exe\" \"%%1\""
echo.
echo [HKEY_CLASSES_ROOT\c3p\shell\Instance 2]
echo.
echo [HKEY_CLASSES_ROOT\c3p\shell\Instance 2\command]
echo @="\"C:\\Crestron XPanels\\CrestronXPanel-1\\CrestronXPanel.exe\" \"%%1\""
echo.
echo [HKEY_CLASSES_ROOT\c3p\shell\Instance 3]
echo.
echo [HKEY_CLASSES_ROOT\c3p\shell\Instance 3\command]
echo @="\"C:\\Crestron XPanels\\CrestronXPanel-2\\CrestronXPanel.exe\" \"%%1\""
echo.
echo [HKEY_CLASSES_ROOT\c3p\shell\Instance 4]
echo.
echo [HKEY_CLASSES_ROOT\c3p\shell\Instance 4\command]
echo @="\"C:\\Crestron XPanels\\CrestronXPanel-3\\CrestronXPanel.exe\" \"%%1\""
)>"Add_to_context.reg"
exit /b

rem [------------------------------------------------------------------------]
rem [                       End of Script: Done Here                         ]
rem [------------------------------------------------------------------------]
:end_script
rem Done here.
echo.
echo Press any key.
pause > nul
exit
