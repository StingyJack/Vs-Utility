<#
    .SYNOPSIS
    Marks a file as a pending change with TFS
#>
function Edit-TfVcFile
{
	[CmdletBinding()]
	Param(
        [string]$Path
    )


    $vsWherePath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

    $installBasePath = (& $vsWherePath -latest -format json -utf8 | COnvertFrom-Json).installationPath

    $tfExePath= "$installBasePath\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"

    $currentStatus = & $tfExePath vc status $Path

    if ($currentStatus -ilike "*There are no pending changes.*")
    {
        & $tfExePath vc checkout $Path
    }
}

