function Get-WebProjects
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
        #open project file
        #check project type guid
        #add to $projects

    }
}