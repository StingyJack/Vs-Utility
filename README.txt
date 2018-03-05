Put this folder in your \Documents\WindowsPowerShell\Modules\ folder. 

The path should be like C:\Users\you\Documents\WindowsPowerShell\Modules\Vs-Utility

From any  powershell windows (including the two in Visual studio (package manager console, and powershell interactive console) 
you can run the commands. 

From the file system, several  take a full resolved path to a solution. Within VS you dont have to type that much, just use

$dte.Solution.FullName 

as the parameter. (it auto completes in the Powershell Interactive Console, the Package Manager Console
doesnt autocomplete properly



Known Issues
--------------
There is a bug in Get-PrimaryProjectOutput where if you have a project with a different configuration/platform from 
the solution, it will not get the right output path.  Its correct in MetaHelperLib, I just didn't bring that over here.


To Add
-------
Setup Run Powershell Script and Invoke Script Analyzer external tools
Setup R# toolbar

Anything else I use often.... 