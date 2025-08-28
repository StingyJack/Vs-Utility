<#
    .SYNOPSIS
    Gets the primary output assembly paths for MSTest based unit test projects in a solution.

    .DESCRIPTION
    This function identifies all MSTest test projects in a Visual Studio solution and returns the paths
    to their compiled test assemblies. It uses Get-TestProjects to identify test projects and 
    Get-PrimaryProjectOutput to locate their output assemblies.

    .PARAMETER SolutionFilePath
    The full path to the Visual Studio solution file (.sln).

    .PARAMETER BuildConfiguration
    The build configuration to use (e.g., Debug, Release).

    .PARAMETER BuildPlatform
    The platform target to use (e.g., "Any CPU", x86, x64).

    .EXAMPLE
    $testAssemblies = Get-TestProjectAssemblies -SolutionFilePath "C:\Projects\MySolution\MySolution.sln" -BuildConfiguration "Release" -BuildPlatform "Any CPU"
    Returns an array of paths to all test assemblies in the solution.

    .NOTES
    - Only includes assemblies that actually exist in the output directory
    - Skips any test projects where the output assembly cannot be found
    - Works with MSTest-based test projects
#>
function Get-TestProjectAssemblies
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath,
        [string] $BuildConfiguration,
        [string] $BuildPlatform
    )

    $testProjects = Get-TestProjects -SolutionFilePath $SolutionFilePath 
    $testAssemblies = @()
    foreach ($testProject in $testProjects)
    {
        $testAsm = Get-PrimaryProjectOutput -ProjFilePath $testProject -BuildConfiguration $BuildConfiguration -BuildPlatform $BuildPlatform
        if ([System.String]::IsNullOrWhiteSpace($testAsm) -eq $false)
        {
            $testAssemblies += $testAsm
        }
    }
    Write-Output $testAssemblies
}