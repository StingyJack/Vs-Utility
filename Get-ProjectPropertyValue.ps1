<#
    .SYNOPSIS
    Gets a project property value (or values) that match a property name from a proj file

    .EXAMPLE
    Get-ProjectPropertyValue -ProjectFilePath C:\code\repo\src\Project1\Project1.csproj -PropertyName AutoGenerateBindingRedirects -Verbose
    
    if the project does not have this property, $null will be returned
    if the project does have this property in only one <PropertyGroup> its value will be returned as string
    if the project does have this property more than one <PropertyGroup> the values will be returned as string[]

    
#>

function Get-ProjectPropertyValue
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $ProjectFilePath,
        [Parameter(Mandatory=$true)]
        [string] $PropertyName
    )

 $projFileContent = [xml] (Get-Content -Path $projectFilePath)
 if (-Not ($projFileContent | Get-Member -Name Project))
 {
     Write-Warning "Project file '$projectFilePath' does not have a <project> element"
     return $null
 }

 if (-Not ($projFileContent.Project | Get-Member -Name PropertyGroup))
 {
     Write-Warning "Project file '$projectFilePath' does not have any <propertygroup> elements"
     return $null
 }
 
 if (-Not ($projFileContent.Project.PropertyGroup | Where-Object {$_ | Get-Member -Name $PropertyName} ))
 {
     Write-Verbose "Project file '$projectFilePath' does not have any elements matching property name $PropertyName"
     return $null
 }

 $matchingProperties = $projFileContent.Project.PropertyGroup | Where-Object {$_ | Get-Member -Name $PropertyName} 
 return $matchingProperties.$PropertyName


}
