<#
    .SYNOPSIS
    Removes all project outputs regardless of build configuration, including the obj folder

#>

function Remove-AllProjectOutput
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath
    )

    Write-Verbose "Removing project output for file $ProjFilePath"

    $projFileFolder = Split-Path $projFilePath -Parent
    $projFileContent = [xml] (Get-Content $projFilePath)
    
    #filter out empty or the "." paths that pyproj have by default
    $relativeOutputPaths = @($projFileContent.Project.PropertyGroup.OutputPath | Where-Object {[system.string]::IsNullOrWhiteSpace($_) -eq $false -and ([string]::Equals($_, ".") -eq $false) } | Get-Unique)
    Write-Verbose "Project has $($relativeOutputPaths.Count) output paths"
    if ($relativeOutputPaths.Count -gt 0)
    {
        foreach ($relativeOutputPath in $relativeOutputPaths)
        {
            $absoluteOutputPath = Join-Path -Path $projFileFolder  -ChildPath $relativeOutputPath
            if (Test-Path $absoluteOutputPath)
            {
                Write-Host "Clearing $absoluteOutputPath"
                Get-ChildItem $absoluteOutputPath -Include * -Recurse | ForEach-Object { if(Test-Path $_) {Remove-Item $_ -Force -Confirm:$false -Recurse -ErrorAction Continue } }  
                $itemsRemain = @(Get-ChildItem -Path $absoluteOutputPath).Count
                Write-Verbose "$($itemsRemain) items remaining"
            }
        }
    }
    elseif ($null -ne $projFileContent.Project.Sdk)
    {
        Write-Verbose "SDK Style project without named output paths detected, inferring default output paths"
        $absoluteOutputPath = Join-Path -Path $projFileFolder  -ChildPath "bin"
        Write-Host "Clearing $absoluteOutputPath"
        Get-ChildItem $absoluteOutputPath -Include * -Recurse | ForEach-Object { if(Test-Path $_) {Remove-Item $_ -Force -Confirm:$false -Recurse -ErrorAction Continue } }  
        $itemsRemain = @(Get-ChildItem -Path $absoluteOutputPath).Count
        Write-Verbose "$($itemsRemain) items remaining"
    }

    $objFolder = Join-Path -Path $projFileFolder -ChildPath "obj\"
    if (Test-Path $objFolder)
    {
        Write-Host "Clearing $objFolder"
        Remove-Item -Path $objFolder -Recurse -Force -Confirm:$false
    }
}