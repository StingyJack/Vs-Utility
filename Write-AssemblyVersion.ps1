<#
    .SYNOPSIS
    Writes the assembly attribute values to any file in the search path matching the pattern "*AssemblyInfo.*"


#>
function Write-AssemblyVersion
{
    [CmdletBinding()]
    Param(
        [string] $SearchPath,
        [string] $AssemblyVersion,
        [string] $AssemblyFileVersion,
        [string] $AssemblyInfoVersion
    )


    $pathToSearch = $SearchPath
    if ((Get-Item $SearchPath) -is [System.IO.DirectoryInfo] -eq $false)
    {
        $pathToSearch = Split-Path $SearchPath -Parent
    }

    $matchingItems = @(Get-ChildItem -Path $pathToSearch -Recurse -File | Where-Object {$_.Name -ilike "*AssemblyInfo.*" -and $_.FullName -inotlike "*\obj\*"})

    foreach($matchingItem in $matchingItems)
    {
        $linesToSave = [string[]]@()
        $existingLines = [string[]]@(Get-Content $matchingItem.FullName)

        foreach ($line in $existingLines)
        {
            $trimmedLine = $line.Trim()

            if ($trimmedLine -inotlike "*Assembly*Version(*")
            {
                $linesToSave += $trimmedLine
            }
        }

        $linesToSave += "[assembly: AssemblyVersion(`"$AssemblyVersion`")]"
        $linesToSave += "[assembly: AssemblyFileVersion(`"$AssemblyFileVersion`")]"
        $linesToSave += "[assembly: AssemblyInformationalVersion(`"$AssemblyInfoVersion`")]"

        Edit-TfVcFile -Path $matchingItem.FullName

        if ((Get-ItemProperty -Path $matchingItem.FullName -Name IsReadOnly) -eq $true)
        {
            Set-ItemProperty -Path $matchingItem.FullName -Name IsReadOnly -Value $false
        }

        Set-Content -Path $matchingItem.FullName -Value $linesToSave -Encoding Unicode
    }

}