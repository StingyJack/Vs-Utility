<#
    .SYNOPSIS
    Gets all the project files for a solution
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
