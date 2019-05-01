<#
    .SYNOPSIS
    Gets the path to the tf.exe program

#>
function Get-TfExePath
{
    [CmdletBinding()]
    Param(
    )


    $vsWherePath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

    $installBasePath = (& $vsWherePath -latest -format json -utf8 | ConvertFrom-Json).installationPath

    $tfExePath= "$installBasePath\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
    
    return $tfExePath

}