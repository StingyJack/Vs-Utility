<#

#>
function Invoke-T4
{
    [CmdletBinding()]
    Param(
        [string]$RootSearchPath
    )

    Write-Verbose "Requested t4 regeneration for path '$RootSearchPath'"

    $searchPath = $RootSearchPath
    if (Test-Path $RootSearchPath -PathType Leaf)
    {
        Write-Verbose "Path was a file, getting directory of file"
        $searchPath = Split-Path -Path $RootSearchPath -Parent
        Write-Verbose "Resolved folder '$searchPath'"
    }
    
    $t4exePath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\TextTransform.exe"
    $tfExePath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
    
    $ttFiles = @(Get-ChildItem -Path $searchPath -Recurse -File -Include *.tt)
    Write-Verbose "Found $($ttFiles.Count) tt files"
    foreach($ttFile in $ttFiles)
    {
        Write-Verbose "Calling t4 generation on '$($ttFile.FullName)'"
        #<#@ output extension=".txt" #>
        $outputExtension = ".cs"
        $ttContent = (Get-Content $ttFile.FullName)
        foreach ($line in $ttContent)
        {
            $index = $line.IndexOf("output extension")
            if ($index -lt 0) { continue }
            $indexOfStartRead = $index + "output extension=`"".Length
            $indexOfEndRead = $line.IndexOf("`"", $indexOfStartRead)
            $outputExtension = $line.Substring($indexOfStartRead, $indexOfEndRead - $indexOfStartRead)
            break
        }
        
        $outFile = $ttFile.FullName.Replace(".tt", $outputExtension)
        Write-Verbose "Using output file '$outFile'"

        if (Get-ItemProperty $outFile -Name IsReadOnly)
        {
            & $tfExePath vc checkout $outFile
            #Set-ItemProperty $outFile -name IsReadOnly -value $false
        }

        & $t4exePath $($ttFile.FullName) -out $outFile
        Write-Verbose "Generation complete"
    }

    Write-Output "Operation complete"
}
