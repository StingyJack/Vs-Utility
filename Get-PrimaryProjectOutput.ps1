<#
    .SYNOPSIS
    Gets the primary output (dll, exe, or dacpac) for a Visual Studio project file.

    .DESCRIPTION
    This function analyzes a Visual Studio project file and determines the path to its primary output file
    based on the project's configuration, platform, output type, and assembly name. It supports different
    output types including libraries (DLL), executables (EXE), and database projects (DACPAC).

    .PARAMETER ProjFilePath
    The full path to the Visual Studio project file (.csproj, .vbproj, etc.).

    .PARAMETER BuildConfiguration
    The build configuration to use (e.g., Debug, Release).

    .PARAMETER BuildPlatform
    The platform target to use (e.g., "Any CPU", x86, x64).

    .EXAMPLE
    Get-PrimaryProjectOutput -ProjFilePath "C:\Projects\MyProject\MyProject.csproj" -BuildConfiguration "Release" -BuildPlatform "Any CPU"
    Returns the full path to the primary output file for the specified project configuration.

    .NOTES
    - Returns null if the output file doesn't exist
    - Automatically handles the conversion of "Any CPU" to "AnyCPU" in the configuration
    - Supports different output types:
      * Library projects (.dll)
      * Executable projects (.exe)
      * Database projects (.dacpac)
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
    if ($null -eq $propertyGroup)
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
    if ($outputType -ieq "Database")
    {
        if ($propertyGroup | Get-Member -Name SqlTargetName -MemberType Property)
        {
            $asmName = $propertyGroup.SqlTargetName
        }
        elseif ($projFileContent.PropertyGroup | Get-Member -Name SqlTargetName -MemberType Property)
        {
            $asmName = $projFileContent.PropertyGroup.SqlTargetName
        }
        $fileExt = "dacpac"
    }
	elseif ($outputType -ne "Library")
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