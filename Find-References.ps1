<#
    .SYNOPSIS
    Finds a specific reference in any project in a solution. Uses the Match operator so partial reference names are ok.
#>
function Find-References
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath
        , [string] $ReferenceName
    )

    Write-Verbose "Using solution $SolutionFilePath"
        
    $allProjects = Get-ProjectFiles -SolutionFilePath $SolutionFilePath
    Write-Verbose "There are $($allProjects.Count) projects in this solution"
    [PSObject[]]$matches = @()
    foreach($projectFile in $allProjects)
    {
        Write-Verbose "Checking project file '$projectFile' for references"
        $projFileContent = [xml](Get-Content $projectFile)

        $references = @($projFileContent.Project.ItemGroup.Reference)
        Write-Verbose "Project has $($references.Count) references"

        foreach ($reference in $references)
        {
            if ($reference.Include -match $ReferenceName)
            {
                Write-Verbose "Match found for reference $($reference.Include)"
                $props = @{'ProjectFile'=$projectFile;
                            'ReferenceInclude'=$reference.Include;
                            'ReferencePath'=$reference.HintPath;}

                $obj = (New-Object -TypeName PSObject -Property  $props)
                #$matches += $obj
                Write-Output $obj
            }
        }

    }
    return $matches
}

