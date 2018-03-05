function Checkout-File
{
	[CmdletBinding()]
	Param(
        [string]$Path
    )

    $tfExePath= "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"

   

   & $exe vc checkout $Path
}

Checkout-File -Path C:\tfs\Utility\Acsis.PowerShell\Acsis.PowerShell\AcsisDb\confirm-SqlAssembliesLoaded.ps1