<#
    .SYNOPSIS
    Disables assembly signing (strong naming) for a project if the attribute is present.

    .DESCRIPTION
    Modifies a project file to disable strong name signing by setting the SignAssembly
    property to false in all non-conditional PropertyGroup elements. This is useful when
    you need to temporarily disable strong naming for development or testing purposes.

    .PARAMETER ProjFilePath
    The full path to the project file (.csproj, .vbproj, etc.) where assembly signing
    should be disabled.

    .EXAMPLE
    Disable-SignAssembly -ProjFilePath "C:\Projects\MyApp\MyApp.csproj"
    Disables strong name signing for the specified project.

    .EXAMPLE
    Disable-SignAssembly -ProjFilePath "C:\Projects\MyApp\MyApp.csproj" -Verbose
    Disables strong name signing with detailed progress information.

    .OUTPUTS
    Writes a message indicating whether the project file was updated or not.

    .NOTES
    - Only modifies non-conditional PropertyGroup elements
    - Will not modify files that already have SignAssembly set to false
    - Changes are saved directly to the project file
#>
function Disable-SignAssembly
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath
    )

    Write-Verbose "Looking for 'SignAssembly' property in '$ProjFilePath'"
    $projContent = [xml](Get-Content -Path $ProjFilePath)

    $nonConditionalPropertyGroups = $projContent.Project.PropertyGroup | Where-Object {-Not $_.Condition}
    if ($null -eq $nonConditionalPropertyGroups -or $nonConditionalPropertyGroups.Count -eq 0)
    {
        Write-Verbose "Only conditional property groups are present."
        return
    }

    $signAssemblyPropertyGroups = @($nonConditionalPropertyGroups | Where-Object {Get-Member -InputObject $_ -Name "SignAssembly"})

    if ($null -eq $signAssemblyPropertyGroups -or $signAssemblyPropertyGroups.Count -eq 0)
    {
        Write-Verbose "No SignAssembly property detected"
        return
    }
    $updatedPropertyCount = 0

    foreach ($signAssemblyPropertyGroup in $signAssemblyPropertyGroups)
    {

        if ($signAssemblyPropertyGroup.SignAssembly -eq $false)
        {
            Write-Verbose "SignAssembly is already false"
            continue
        }

        Write-Verbose "Updating SignAssembly to be false "
        $signAssemblyPropertyGroup.SignAssembly = [bool]::FalseString
        $updatedPropertyCount++
    }

    if ($updatedPropertyCount -gt 0)
    {
        $projContent.Save($ProjFilePath)
        Write-Output "'$ProjFilePath' updated to disable assembly signing"
    }
    else
    {
        Write-Output "'$ProjFilePath' was not updated"
    }
}

