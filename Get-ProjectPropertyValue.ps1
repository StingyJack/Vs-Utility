<#
    .SYNOPSIS
    Gets a project property value (or values) that match a property name from a project file.

    .DESCRIPTION
    Retrieves the value of a specified property from a Visual Studio project file. The function
    searches all PropertyGroup elements for the specified property name and returns its value(s).
    Can return multiple values if the property exists in multiple PropertyGroup elements.

    .PARAMETER ProjectFilePath
    The full path to the project file (.csproj, .vbproj, etc.) to search for the property.

    .PARAMETER PropertyName
    The name of the property to find in the project file's PropertyGroup elements.

    .EXAMPLE
    Get-ProjectPropertyValue -ProjectFilePath "C:\Projects\MyApp\MyApp.csproj" -PropertyName "TargetFramework"
    Returns the target framework specified in the project.

    .EXAMPLE
    Get-ProjectPropertyValue -ProjectFilePath "C:\Projects\MyApp\MyApp.csproj" -PropertyName "AutoGenerateBindingRedirects" -Verbose
    Returns the binding redirects setting with detailed progress information.

    .OUTPUTS
    - Returns $null if the property is not found
    - Returns a string if the property is found in one PropertyGroup
    - Returns string[] if the property is found in multiple PropertyGroups

    .NOTES
    - Validates project file XML structure
    - Case-sensitive property name matching
    - Returns all instances of the property if found in multiple PropertyGroups
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
