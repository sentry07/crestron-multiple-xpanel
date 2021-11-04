@echo off
cls
echo.
echo [------------------------------------------------------------------------]
echo [         Uninstaller: Enable Multiple Crestron XPanel Instances         ]
echo [                        Written By: Eric Walters                        ]
echo [------------------------------------------------------------------------]
echo.

rem Change directory into the folder where the cmd file is located
cd %~dp0

rem Check first that we have admin rights before continuing
call:check_Permissions

rem Delete the folder created by the installer and all it's contents
if exist "C:\Crestron XPanels" (
	echo Deleting C:\Crestron XPanels.
	echo.
	del "C:\Crestron XPanels" /s /q >nul
	rd "C:\Crestron XPanels" /s /q >nul
)

rem Import the registry file that adds the new instances to the context menu
call:DropRegFile
reg import DelContext.reg
del DelContext.reg

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

rem This creates the registry file that gets imported
:DropRegFile
if exist DelContext.reg ( del DelContext.reg )

(
echo Windows Registry Editor Version 5.00
echo.
echo [-HKEY_CLASSES_ROOT\vtz\shell\Instance 2]
echo [-HKEY_CLASSES_ROOT\vtz\shell\Instance 3]
echo [-HKEY_CLASSES_ROOT\vtz\shell\Instance 4]
echo [-HKEY_CLASSES_ROOT\vtz\shell\Instance 5]
echo [-HKEY_CLASSES_ROOT\c3p\shell\Instance 2]
echo [-HKEY_CLASSES_ROOT\c3p\shell\Instance 3]
echo [-HKEY_CLASSES_ROOT\c3p\shell\Instance 4]
echo [-HKEY_CLASSES_ROOT\c3p\shell\Instance 5]
)>"DelContext.reg"
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