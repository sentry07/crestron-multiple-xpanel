# crestron-multiple-xpanel
This is the CMD file that allows you to run more than one Smart Graphics XPanel on your machine.

You MUST right click it and run it as Administrator otherwise it won't work. After running the script, you can right click on any Smart Graphics VTZ touchpanel file or C3P xpanel file and you will see three more options for opening the file: Instance 2, Instance 3, and Instance 4.

### Now with an uninstaller! (oooo, aaaah)

## Troubleshooting Errors
If you run into errors that say:

> File Rep.ps1 cannot be loaded because running scripts is disabled on
> this system. For more information, see about_Execution_Policies at
> https:/go.microsoft.com/fwlink/?LinkID=135170.
> + CategoryInfo : SecurityError: (:) [], ParentContainsErrorRecordException
> + FullyQualifiedErrorId : UnauthorizedAccess

The solution is to double click the file in the repo called `FixPowerShellExecutionPolicy.reg`
This file will set a key located at `HKLM:\Software\Policies\Microsoft\Windows\PowerShell` named `ExecutionPolicy` to `RemoteSigned`. This change will allow any scripts created on your machine to run unchecked, and only allow signed scripts that are from other machines. I highly recommend both a) opening Registry Editor and browsing to that location to find out the current value so that you can set it back (it's most likely set to `Restricted`) and b) reading up on PowerShell execution policy at the following link:
[About Execution Policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.1)