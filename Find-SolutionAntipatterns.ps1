<#

    .SYNOPSIS Finds antipatterns across projects in a solution

#>
function Find-SolutionAntipatterns
{
    [CmdletBinding()]
    Param(
        [string] $PathToSlnFile
    )
    
    $projectFiles = Get-ProjectFiles -SolutionFilePath $PathToSlnFile

    foreach($projectFile in $projectFiles)
    {
        Find-ProjectAntiPatterns -ProjFilePath $projectFile
        
    }

    Write-Output "command completed"
}