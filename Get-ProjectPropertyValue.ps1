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


}