<#
    .SYNOPSIS
    Runs all the test projects in the solution for the config/platform
#>
function Invoke-SolutionTests
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath,
        [string] $BuildConfiguration,
        [string] $BuildPlatform
    )

    $testProjects = Get-TestProjects -SolutionFilePath $SolutionFilePath 
    $testAssemblies = Get-TestProjectAssemblies -SolutionFilePath $SolutionFilePath -BuildConfiguration $BuildConfiguration -BuildPlatform $BuildPlatform
    
    if ($testAssemblies.Length -eq 0)
    {
        Write-Warning "There were no test assemblies found to execute"
        return
    }

    $testAssembliesArg = "`"" + [System.String]::Join("`" `"", $testAssemblies) + "`""
    $solutionDir = Split-Path -Path $SolutionFilePath -Parent
    $runsettingsFile = (Get-ChildItem -Path $solutionDir *.runsettings | Select-Object -First 1)

    $defaultArgs = "/EnableCodeCoverage /logger:trx "
    if ($runsettingsFile)
    {
        $defaultArgs += " /Settings:`"$runsettingsFile`" "
    }

    Write-Verbose "testAssembliesArg = '$testAssembliesArg'"
    Write-Verbose "Default args = '$defaultArgs'"
    $vstestConsolePath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"
    $args = $testAssembliesArg + " " + $defaultArgs
    $cmd = "`& `"$vstestConsolePath`" $args"
    Write-Verbose "cmd = $cmd"
    Invoke-Expression $cmd 

}


