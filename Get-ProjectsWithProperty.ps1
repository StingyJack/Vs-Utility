<#
    .SYNOPSIS
    This returns a set of objects composed of (ProjectName, ProjectPath, PropertyName, PropertyValue)
#>
function Get-ProjectsWithProperty
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    Param(
        [string] $SolutionFilePath,
        [string] $PropertyName
    )
    
    [PSObject[]]$returnValue = @()

    $projectFilePaths = Get-ProjectFiles -SolutionFilePath $SolutionFilePath
    foreach ($projectFilePath in $projectFilePaths)
    {
        $projFileContent = [xml] (Get-Content -Path $projectFilePath)
        if (-Not ($projFileContent | Get-Member -Name Project))
        {
            Write-Warning "Project file '$projectFilePath' does not have a <project> element"
            continue
        }

        if (-Not ($projFileContent.Project | Get-Member -Name PropertyGroup))
        {
            Write-Warning "Project file '$projectFilePath' does not have any <propertygroup> elements"
            continue
        }

        if (-Not ($projFileContent.Project.PropertyGroup | Where-Object {$_ | Get-Member -Name $PropertyName} ))
        {
            Write-Verbose "Project file '$projectFilePath' does not have any elements matching property name $PropertyName"
            continue
        }

        $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectFilePath)
        $matches = @($projFileContent.Project.PropertyGroup | Where-Object {$_ | Get-Member -Name $PropertyName} |  Select-Object -Property $PropertyName -Unique)
        Write-Verbose "Project file has $($matches.Count) matching properties"
        foreach ($match in $matches)
        {
            $props = @{'ProjectName'=$projectName;
                        'ProjectFilePath'=$projectFilePath;
                        'PropertyName'=$PropertyName;
                        'PropertyValue'=$match.$PropertyName}

            $obj = New-Object -TypeName PSObject -Property $props
            $returnValue += $obj
        }

    }
    return $returnValue
}
