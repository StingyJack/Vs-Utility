# Vs Utilities

This has a bunch of functions for working with the vs project system and within visual studio in general.

## Installing

I clone this repo from my `%USERPROFILE%\Documents\PowerShell\Modules\` or `%USERPROFILE%\Documents\WindowsPowerShell\Modules\` folder, so the path would be like `C:\Users\you\Documents\WindowsPowerShell\Modules\Vs-Utility`

From any PowerShell windows available within VS (package manager console and PowerShell interactive console) you can run the commands more conveniently as you can pass the necessary args from the `$dte` global variable. This lets you do things like `$dte.Solution.FullName` to get the full path to a solution for example.From a non VS powershell window, you would need to provide the fully resolved path to the solution.

## Known Issues

There is a bug in Get-PrimaryProjectOutput where if you have a project with a different configuration/platform from
the solution, it will not get the right output path. This should only be a problem if you are using "Mixed Platforms" or the like. If you have "Any CPU" for the solution and projects are configured with "x86" or "x64", then you deserve the headache you get. 

Some SDK style projects support is missing. When these were mostly first written the defaults for the SDK style projects were not yet published. I havent had the time to go back and update any gaps, but PR always welcome. 

## Settings

Also included in here are two vssettings that you can import. One will setup external tools to run powershell commands on the current active file, and the other is just my toolbar customizations (removes browserlink and other buttons I dont use).


