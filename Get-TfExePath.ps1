<#
    .SYNOPSIS
    Gets the path to the tf.exe program

#>
function Get-TfExePath
{
    [CmdletBinding()]
    Param(
    )
    
    $installBasePath = Get-VsInstallBasePath

    $tfExePath= "$installBasePath\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
    
    return $tfExePath

}