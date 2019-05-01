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

    $tfExePath= Get-TfExePath 

    $currentStatus = & $tfExePath vc status $Path

    if ($currentStatus -ilike "*There are no pending changes.*")
    {
        & $tfExePath vc checkout $Path
    }
}

