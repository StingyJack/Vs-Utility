<#
    .SYNOPSIS
    Gets the primary output assembly paths for MSTest based unit test projects in a solution
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