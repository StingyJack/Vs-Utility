<#
    Marks a file as a pending change with TFS
#>
function Edit-TfVcFile
{
	[CmdletBinding()]
	Param(
        [string]$Path
    )

    $tfExePath= "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
    

    & $exe vc checkout $Path
}

