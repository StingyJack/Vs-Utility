
function Get-TestProjects
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath
    )

    Write-Verbose "Using solution $SolutionFilePath"
        
    $allProjects = Get-Projects -SolutionFilePath $SolutionFilePath
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

Get-TestProjects -SolutionFilePath C:\tfs\WarehouseEnhance\Trunk\Master.sln