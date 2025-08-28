<#
    .SYNOPSIS
    Gets the paths to all the test project files in a Visual Studio solution.

    .DESCRIPTION
    This function analyzes a Visual Studio solution and identifies test projects based on naming
    conventions. It currently identifies test projects by:
    - Projects in a folder containing 'UnitTest' (case-insensitive)
    - Projects with names ending in 'Tests' (case-insensitive)
    Future enhancement planned to also check project type GUIDs and other properties.

    .PARAMETER SolutionFilePath
    The full path to the Visual Studio solution file (.sln).

    .EXAMPLE
    $testProjects = Get-TestProjects -SolutionFilePath "C:\Projects\MySolution\MySolution.sln"
    Returns an array of paths to all test projects in the solution.

    .NOTES
    - Currently uses naming conventions to identify test projects:
      * Files in folders containing 'UnitTest'
      * Files with names ending in 'Tests'
    - Skips projects that don't exist on disk
    - Future enhancement planned to check project type GUIDs for more accurate test project detection
#>
function Get-TestProjects
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath
    )

    Write-Verbose "Using solution $SolutionFilePath"
        
    $allProjects = Get-ProjectFiles -SolutionFilePath $SolutionFilePath
    $projects = @()
    foreach ($projectFullPath in $allProjects)
    {
        if (-Not (Test-Path $projectFullPath))
        {
            Write-Verbose "Project path doesnt have a file: '$projectFullPath'"
            continue
        }

        if ($projectFullPath.IndexOf("UnitTest", [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
        {
            Write-Verbose "Project item detected in the UnitTest subfolder"
            $projects += $projectFullPath
            Write-Output $projectFullPath
            Write-Verbose "Project added to the list. There are $($projects.Length) so far"
            continue
        }

        $projFileInfo = New-Object  System.IO.FileInfo -ArgumentList $projectFullPath
        $projectName = $projFileInfo.BaseName
        
        if ($projectName.EndsWith("Tests", [System.StringComparison]::OrdinalIgnoreCase))
        {
            Write-Verbose "Project item detected in by name suffix"
            $projects += $projectFullPath
            Write-Output $projectFullPath
            Write-Verbose "Project added to the list. There are $($projects.Length) so far"
            continue
        }
        
        # add in opening the csproj file and sniffing the project type guids and other properties
        # $projFile = [xml](Get-Content -Path $projectFullPath)
    }    
    #return $projects    
}