# Vs Utilities

This has a bunch of functions for working with the vs project system and within visual studio in general.

## Installing

I put this folder in my `\Documents\WindowsPowerShell\Modules\` folder, so the path would be like `C:\Users\you\Documents\WindowsPowerShell\Modules\Vs-Utility`

From any PowerShell windows (including the two in Visual studio;package manager console and PowerShell interactive console) 
you can run the commands. 

From the file system, several take a fully resolved path to a solution. Within VS you don't have to type that much, just use

`$dte.Solution.FullName`

as the parameter. That auto completes nicely in the PowerShell Interactive Console, but the Package Manager Console
autocomplete broke sometime around VS 15.2.

## Known Issues

There is a bug in Get-PrimaryProjectOutput where if you have a project with a different configuration/platform from
the solution, it will not get the right output path. This should only be a problem if you are using "Mixed Platforms" or the like. If you have "Any CPU" for the solution and projects configured with "x86" or "x64", then you deserve the headache you get. 

This doesn't care specifically about SDK style projects, so some things may or may not work.

## Things I may add later

- Setup Run PowerShell Script and Invoke Script Analyzer external tools
- Setup R# toolbar

Anything else I use often.... 