<#
    .SYNOPSIS
    Updates (Removes for now) a project property from a proj file

    .EXAMPLE
    Update-ProjectProperty -ProjectFilePath C:\code\repo\src\Project1\Project1.csproj -PropertyName CodeAnalysisRuleSet -Remove -PendChange -Verbose
#>

function Update-ProjectProperty
{
    [CmdletBinding()]
    Param(
        [string] $ProjectFilePath,
        [string] $PropertyName,
        [Parameter(Mandatory=$true)] #mandatory for now, dont feel like checking update logic
        [switch] $Remove,
        [Parameter(Mandatory=$false)]
        [switch] $PendChange
    )

    Write-Verbose "Removing project property $PropertyName for project '$ProjectFilePath'"

    $projFileContent = [xml](Get-Content -Path $ProjectFilePath)

    if (-Not ($projFileContent | Get-Member -Name Project))
    {
        Write-Warning "Project file '$projectFilePath' does not have a <project> element"
        return
    }

    if (-Not ($projFileContent.Project | Get-Member -Name PropertyGroup))
    {
        Write-Warning "Project file '$projectFilePath' does not have any <propertygroup> elements"
        return
    }

    if (-Not ($projFileContent.Project.PropertyGroup | Where-Object {$_ | Get-Member -Name $PropertyName} ))
    {
        Write-Verbose "Project file '$projectFilePath' does not have any elements matching property name $PropertyName"
        return
    }
    
    $propertyGroupsWithProperty= @($projFileContent.Project.PropertyGroup | Where-Object {$_ | Get-Member -Name $PropertyName})
    foreach ($propertyGroupWithProperty in $propertyGroupsWithProperty)
    {
        Write-Verbose "Locating property to remove in the group"
        $propertyGroupWithProperty.ChildNodes | Where-Object {$_.Name -eq $PropertyName} | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}
    }

    $projFileContent.Save($ProjectFilePath)
}