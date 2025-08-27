<#
    .SYNOPSIS
    Gets Visual Studio project <Item> elements from a project file.

    .DESCRIPTION
    Retrieves specific item types (Compile, Content, None, etc.) from a Visual Studio
    project file. For each item found, returns detailed information including the full path,
    relative path, link status, subtype, and output copy settings.

    .PARAMETER ProjFilePath
    The full path to the project file (.csproj, .vbproj, etc.) to analyze.

    .PARAMETER ItemType
    The type of items to retrieve. Must be one of:
    - Compile: Source code files
    - Content: Content files that are included in the project
    - None: Miscellaneous files
    - Analyzer: Code analysis tools
    - Reference: Project references
    - EmbeddedResource: Resources embedded in the assembly

    .EXAMPLE
    Get-ProjectItems -ProjFilePath "C:\Projects\MyApp\MyApp.csproj" -ItemType Content
    Returns all content files in the project.

    .EXAMPLE
    Get-ProjectItems -ProjFilePath "C:\Projects\MyApp\MyApp.csproj" -ItemType Compile -Verbose
    Returns all source code files with detailed progress information.

    .OUTPUTS
    Array of PSObjects with properties:
    - FullName: Absolute path to the item
    - Path: Project-relative path
    - IsLinked: Whether the item is linked from outside the project
    - Subtype: Item subtype (if any)
    - CopyToOutputDirectory: Output directory copy setting

    .NOTES
    - Validates file existence for each item
    - Warns about missing files
    - Handles linked items
    - Returns empty array if no matching items found
#>
function Get-ProjectItems {
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Compile', 'Content', 'None', 'Analyzer', 'Reference', 'EmbeddedResource')]
        [string] $ItemType
    )

    if (-Not (Test-Path $ProjFilePath)) { throw "Project file does not exist at '$ProjFilePath'" }

    Write-Verbose "Checking project file '$ProjFilePath' for '$ItemType'"
    $projFileContent = [xml](Get-Content $ProjFilePath)
    $projFolder = Split-Path -Path $ProjFilePath -Parent

    $projItems = @()
    foreach ($projItemGroup in $projFileContent.Project.ItemGroup) {
        if ($projItemGroup.GetType() -eq [System.String]) {
            Write-Verbose "Empty project item group"
            continue
        }

        $items = $projItemGroup.GetElementsByTagName($ItemType)

        foreach ($item in $items) {
            if ($item | Get-Member -Name "Include") {
                $absPath = Join-Path -Path $projFolder -ChildPath $item.Include 

                if (-not (Test-Path -Path $absPath)) {
                    Write-Warning "ProjectFile '$ProjFilePath' reports that file '$absPath' is part of the project but it cannot be found on disk "
                    continue
                }
                $isLinked = (-Not ([string]::IsNullOrWhiteSpace($item.Link)))
                $subtype = if ($null -ne $item.SubType) { $item.SubType } else { "None" }
                $copyToOutputDirectory = if ($null -ne $item.CopyToOutputDirectory) { $item.CopyToOutputDirectory } else { "Do not copy" }
                $itemProps = @{'FullName' = $absPath; 'Path' = $item.Include; 'IsLinked' = $isLinked; 'Subtype' = $subtype; 'CopyToOutputDirectory' = $copyToOutputDirectory }
                $projItems += (New-Object -TypeName PSObject -Property $itemProps)
            }
        }
    }
    
    Write-Verbose "Project has $($projItems.Count) items"

    return $projItems
}


