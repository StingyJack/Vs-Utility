<#
    .SYNOPSIS
    Removes a specific configuration from a project.

    .DESCRIPTION
    This function removes a specific build configuration and platform target combination from a Visual Studio
    project file. It can optionally backup the removed configuration elements to a specified file or folder.

    .PARAMETER ProjectFilePath
    The full path to the Visual Studio project file (.csproj, .vbproj, etc.).

    .PARAMETER BuildConfiguration
    The build configuration to remove (e.g., Debug, Release).

    .PARAMETER PlatformTarget
    The platform target to remove (e.g., x86, x64, AnyCPU).

    .PARAMETER RemovedElementPath
    If specified, the configuration elements that are removed are written to this path. 
    It can be a file or folder. If folder, a file will be created with the removed config elements. 
    If it is a file, the file will be appended.

    .EXAMPLE
    Remove-ProjectConfiguration -ProjectFilePath "C:\Projects\MyProject\MyProject.csproj" -BuildConfiguration "Debug" -PlatformTarget "x86"
    Removes the Debug|x86 configuration from the specified project.

    .NOTES
    - It is recommended to NOT run this while Visual Studio has the project open.
    - This function is intended to be part of a future "Normalize-ProjectConfiguration" that would update 
      a solution and all projects to use the same set of build configs.
#>
function Remove-ProjectConfiguration
{
    [CmdletBinding()]
    Param(
        [string] $ProjectFilePath,
        [string] $BuildConfiguration,
        [string] $PlatformTarget,
        [Parameter(Mandatory=$false)]
        [string] $RemovedElementPath
    )

    Write-Verbose "Removing project configuration $BuildConfiguration/$PlatformTarget from '$ProjectFilePath'"
    $configBackupPath = ""

    if ([string]::IsNullOrWhiteSpace($RemovedElementPath) -eq $false)
    {
        $info = [System.IO.DirectoryInfo]::new($RemovedElementPath)

        if ($info.Exists -and (Get-Item -Path $info).PSIsContainer)
        {
            $configBackupPath = Join-Path -Path $RemovedElementPath -ChildPath ("RemovedProjectConfigs$((Get-Date).ToFileTime()).txt")
            Write-Verbose "Removed element backup path is a folder, using '$configBackupPath' to write the backup."
        }
        elseif ([io.path]::GetDirectoryName($RemovedElementPath) -ine $RemovedElementPath)
        {
            $configBackupPath = $RemovedElementPath
            Write-Verbose "Removed element backup path is an existing file, using '$configBackupPath' to write the backup."
        }
        else
        {
            throw "Removed element backup path appears to be a folder, but the folder does not exist. Please create it before using it as a parameter"
        }
    }


    Write-Verbose "Getting project file contents"
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

    
    $propertyGroupCondition = "'`$(Configuration)|`$(Platform)' == '$BuildConfiguration|$($PlatformTarget.Replace(" ",[string]::Empty))'"
    $propertyGroupElementToRemove = $null
    foreach ($propertyGroup in $projFileContent.Project.PropertyGroup)
    {        
        if ($propertyGroup.HasAttribute("Condition") -eq $false)
        {
            Write-Verbose "Property group has no condition"
            continue
        }

        $condition = $propertyGroup.GetAttribute("Condition")

        if ($condition -ine $propertyGroupCondition)
        {
            Write-Verbose "Property group condition does not match, skipping"
            continue
        }
        $propertyGroupElementToRemove = $propertyGroup
        break
    }

    if ($null -eq $propertyGroupElementToRemove)
    {
        Write-Output "No property group element was found to remove from '$ProjFilePath' for '$propertyGroupCondition'"
        return
    }
   
    if ([string]::IsNullOrWhiteSpace($configBackupPath) -eq $false)
    {
        Add-Content -Path $configBackupPath -Value $propertyGroupElementToRemove.OuterXml
        Write-Output "Backup of removed element saved to '$configBackupPath'"
    }

    Write-Verbose "Removing node from parent"
    $propertyGroupElementToRemove.ParentNode.RemoveChild($propertyGroupElementToRemove)

    if ((Get-ItemProperty $ProjectFilePath -Name IsReadOnly).IsReadOnly -eq $true)
    {
        Write-Verbose "Removing readonly flag on file"
        Set-ItemProperty $ProjectFilePath -Name IsReadOnly -Value $false
    }

    Write-Verbose "Saving file"
    $projFileContent.Save($ProjectFilePath)
    Write-Output "Removed project configuration $BuildConfiguration/$PlatformTarget from '$ProjectFilePath'"
}
