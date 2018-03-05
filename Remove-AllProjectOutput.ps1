function Remove-AllProjectOutput
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath
    )

    Write-Verbose "Removing project output for file $ProjFilePath"

    $projFileFolder = Split-Path $projFilePath -Parent
    $projFileContent = [xml] (Get-Content $projFilePath)
    $relativeOutputPaths = @($projFileContent.Project.PropertyGroup.OutputPath | Where-Object {[system.string]::IsNullOrWhiteSpace($_) -eq $false } | Get-Unique)
    Write-Verbose "Project has $($relativeOutputPaths.Count) output paths"
    if ($relativeOutputPaths.Count -gt 0)
    {
        foreach ($relativeOutputPath in $relativeOutputPaths)
        {
            $absoluteOutputPath = Join-Path -Path $projFileFolder  -ChildPath $relativeOutputPath
            if (Test-Path $absoluteOutputPath)
            {
                Write-Host "Clearing $absoluteOutputPath"
                Get-ChildItem $absoluteOutputPath -Include * -Recurse | ForEach-Object { if(Test-Path $_) {Remove-Item $_ -Force -Confirm:$false -Recurse } }  
                $itemsRemain = @(Get-ChildItem -Path $absoluteOutputPath).Count
                Write-Verbose "$($itemsRemain) items remaining"
            }
        }
    }

    $objFolder = Join-Path -Path $projFileFolder -ChildPath "obj\"
    if (Test-Path $objFolder)
    {
        Write-Host "Clearing $objFolder"
        Remove-Item -Path $objFolder -Recurse -Force -Confirm:$false
    }
}
