<#
    .SYNOPSIS
    Gets the primary output (a dll or exe) for a proj file.
#>
function Get-PrimaryProjectOutput
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath,
        [string] $BuildConfiguration,
        [string] $BuildPlatform
    )

    Write-Verbose "Getting project output for project file $ProjFilePath"

    $projFileFolder = Split-Path $projFilePath -Parent
    $projFileContent = [xml] (Get-Content $projFilePath)
    $projectBuildPlatform = $BuildPlatform.Replace(" ", "")  #"Any CPU" to "AnyCPU"

   $conditon = "'`$(Configuration)|`$(Platform)' == '$BuildConfiguration|$projectBuildPlatform'".Trim()
    $propertyGroup = $projFileContent.Project.PropertyGroup | Where-Object {$null -ne $_.Condition -and $_.Condition.Trim() -ieq $conditon}
    if ($propertyGroup -eq $null)
    {
        Write-Warning "No build property group found that matches '$conditon'"
        return $null
    }

    $relativeOutputFolderPath = $propertyGroup.OutputPath
    $absoluteOutputFolderPath = Join-Path -Path $projFileFolder  -ChildPath $relativeOutputFolderPath

    $asmName = $projFileContent.Project.PropertyGroup.AssemblyName | Where-Object {[System.String]::IsNullOrWhiteSpace($_) -eq $false} | Select-Object -First 1
    Write-Verbose "AssemblyName = '$($asmName)'"

	$outputType = $projFileContent.Project.PropertyGroup.OutputType| Where-Object {[System.String]::IsNullOrWhiteSpace($_) -eq $false} | Select-Object -First 1
	Write-Verbose "OutputType = ''$($outputType)'"

	$fileExt = "dll"
	if ($outputType -ne "Library")
	{
		$fileExt = "exe" #https://docs.microsoft.com/en-us/dotnet/api/vslangproj.prjoutputtype?view=visualstudiosdk-2017
	}

    $outputName = "$asmName.$fileExt"
    Write-Verbose "OutputName = '$outputName'"
    $absoluteOutputFilePath = Join-Path -Path $absoluteOutputFolderPath -ChildPath $outputName

    if (-Not (Test-Path $absoluteOutputFilePath))
    {
        Write-Warning "Could not locate project build output '$absoluteOutputFilePath'"
        return $null
    }
    Write-Verbose "Found output at path '$absoluteOutputFilePath'"

    return $absoluteOutputFilePath
}