<#
    .SYNOPSIS
    Gets all the project file paths for a Visual Studio solution.

    .DESCRIPTION
    This function parses a Visual Studio solution file (.sln) and returns the full paths to all project 
    files (.csproj, .vbproj, etc.) referenced in the solution. It validates that each project file exists
    and only includes files that end with 'proj'.

    .PARAMETER SolutionFilePath
    The full path to the Visual Studio solution file (.sln) to analyze.

    .EXAMPLE
    $projects = Get-ProjectFiles -SolutionFilePath "C:\Projects\MySolution\MySolution.sln"
    Returns an array of full paths to all project files in the solution.

    .NOTES
    - The function only returns paths to existing project files
    - Project references that don't end in 'proj' are ignored
    - Returns an empty array if no valid project files are found
#>

function Get-ProjectFiles
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath
    )

    Write-Verbose "Using solution $SolutionFilePath"

    $slnFileContent = Get-Content $SolutionFilePath 
    $slnFileFolder = Split-Path $SolutionFilePath -Parent
    $projects = @()
    $lineNumber = 0
    foreach ($line in $slnFileContent)
    {
        $lineNumber++

        if ($line.StartsWith("Project", [System.StringComparison]::OrdinalIgnoreCase) -eq $false)
        {
            continue
        }
        
        Write-Verbose "Project file detected on line $lineNumber"
        $lineSplits = $line.Split(",") 
        $projectRelativePath = $lineSplits[1].Replace("`"", "").Trim()
        Write-Verbose "Project relative path $projectRelativePath"

        if ($projectRelativePath.EndsWith("proj", [System.StringComparison]::OrdinalIgnoreCase) -eq $false)
        {
            Write-Verbose "Project item is not actually a proj file"
            continue
        }

        $projectFullPath = Join-Path -Path $slnFileFolder -ChildPath $projectRelativePath

        if (Test-Path $projectFullPath)
        {
            $projects += $projectFullPath
            Write-Verbose "Project added to the list. There are $($projects.Length) so far"
        }
        else
        {
            Write-Verbose "Project path doesnt have a file: '$projectFullPath'"
        }
    }
    
    return $projects    
}
