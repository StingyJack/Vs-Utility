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

    $installBasePath = (& $vsWherePath -latest -format json -utf8 | ConvertFrom-Json).installationPath

    return $installBasePath

}