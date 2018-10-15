<#
    .SYNOPSIS
    Updates all projects in a solution to the same target framework version.

    .DESCRIPTION
    This will make copies of the project files to a temp folder, create new proj files from those with the alterations to another
    temp folder, and then copy those into the original location. Even with this protection, this script sets its
    ErrorActionPreference to STOP to avoid mangling a proj file.

    .PARAMETER $SolutionFilePath
    The full path to the solution

    .PARAMETER $TargetFrameworkVersion
    The target framework version ("v4.7.2" , "v4.6.1" , etc)

#>
function Update-SolutionTargetFramework
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath,
        [string] $TargetFrameworkVersion
    )
    $script:ErrorActionPreference = 'Stop'


    $sourceProjFiles = Get-ProjectFiles -SolutionFilePath $SolutionFilePath
    $replacementTargets = @{}

    $tempPath = [IO.Path]::GetTempPath()
    $projFilesTemp = "$tempPath\projfileswitch"
    if (-Not (Test-Path $projFilesTemp)) { New-Item $projFilesTemp -ItemType Directory | Out-Null }

    $projFilesBeforePath = Join-Path -Path $projFilesTemp -ChildPath "Before"
    if (-Not (Test-Path $projFilesBeforePath)) { New-Item $projFilesBeforePath -ItemType Directory | Out-Null }

    $projFilesAfterPath = Join-Path -Path $projFilesTemp -ChildPath "After"
    if (-Not (Test-Path $projFilesAfterPath)) { New-Item $projFilesAfterPath -ItemType Directory | Out-Null }

    Get-ChildItem -Path $projFilesTemp -Recurse -File | Remove-Item -Force -Recurse -Confirm:$false
    Write-Output "Copying proj files to staging area '$projFilesBeforePath'"

    #copying them to a "before" path makes it easier to diff the changes between them.
    #modifying the file in place is also an option, but I had pending changes for some of these.

    foreach ($sourceProjFile in $sourceProjFiles)
    {
        Copy-Item -Path $sourceProjFile -Destination $projFilesBeforePath
        $fileName = Split-Path -Path $sourceProjFile -Leaf

        $replacementTargets.Add($fileName, $sourceProjFile)
    }

    $beforeProjFiles = @(Get-ChildItem -Path $projFilesBeforePath -Filter *.csproj | Select-Object -ExpandProperty FullName)

    Write-Output "Updating files from staging path to '$projFilesAfterPath'"
    foreach ($beforeProjFile in $beforeProjFiles)
    {
        Copy-Item -Path $beforeProjFile -Destination $projFilesAfterPath
        $fileName = Split-Path -Path $beforeProjFile -Leaf
        $afterProjFile = Join-Path $projFilesAfterPath -ChildPath $fileName
        Set-ItemProperty -Path $afterProjFile -Name IsReadOnly -Value $false

        Update-ProjectProperty -ProjectFilePath $afterProjFile -PropertyName "TargetFrameworkVersion" -Value $TargetFrameworkVersion
    }

    $afterProjFiles = @(Get-ChildItem -Path $projFilesAfterPath -Filter *.csproj | Select-Object -ExpandProperty FullName)

    Write-Output "Updating original source files"

#copying them back as a separate step
foreach ($afterProjFile in $afterProjFiles)
{
    $fileName = Split-Path -Path $afterProjFile -Leaf
    $sourceFilePath = $replacementTargets[$fileName]
    Write-Output "Checking out source file at $sourceFilePath"
    Edit-TfVcFile -Path $sourceFilePath
    Write-Output "Overwriting source file at $sourceFilePath with `n`t $afterProjFile"
    Copy-Item -Path $afterProjFile -Destination $sourceFilePath -Force -Confirm:$false

}

}