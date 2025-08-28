
<#
    .SYNOPSIS
    Removes all build outputs for every project in a Visual Studio solution.

    .DESCRIPTION
    This function removes all build outputs (bin, obj folders) for every project in the specified 
    Visual Studio solution. This is useful for performing a clean build or clearing out old build artifacts.

    .PARAMETER SolutionFilePath
    The full path to the Visual Studio solution file (.sln).

    .EXAMPLE
    Remove-SolutionOutputs -SolutionFilePath "C:\Projects\MySolution\MySolution.sln"
    Removes all build outputs for every project in the specified solution.

    .NOTES
    This function calls Remove-AllProjectOutput for each project in the solution.
    Make sure Visual Studio is closed before running this function to ensure all files can be deleted.
#>

function Remove-SolutionOutputs
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath
    )
    Write-Verbose "Getting projects"

    $projects = Get-ProjectFiles $SolutionFilePath
    
    Write-Verbose "found $($projects.Count) projects"
    foreach($project in $projects)
    {
        Write-Verbose "Working on project $project"
        Remove-AllProjectOutput $project
    }
    Write-Host "Removal of solution outputs is complete"
}

