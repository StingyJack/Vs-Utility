<# 
    .SYNOPSIS
    Gets any visual studio installation base path. Use this to locate vs tools like msbuild or tf.exe
#>
function Get-VsInstallBasePath
{
    [CmdletBinding()]
    Param(

    )
    $vsWherePath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vsWherePath))
    {
        throw "Could not find vswhere.exe at $vsWherePath"
    }
    $installBasePath = (& $vsWherePath -latest -format json -utf8 | ConvertFrom-Json).installationPath

    if ($null -eq $installBasePath)
    {
        throw "Could not get Visual Studio installation path from vswhere."
    }

    if (-not (Test-Path $installBasePath))
    {
        throw "Visual Studio installation path does not exist."
    }

    return $installBasePath
}