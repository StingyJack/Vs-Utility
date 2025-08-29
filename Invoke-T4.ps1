<#
    .SYNOPSIS
    Runs all the Text Templating Toolkit Transformations in a search path. 
#>
function Invoke-T4
{
    [CmdletBinding()]
    Param(
        [string]$RootSearchPath,
        [switch] $IncludePackagesFolder
    )

    Write-Verbose "Requested t4 regeneration for path '$RootSearchPath'"

    $searchPath = $RootSearchPath
    if (Test-Path $RootSearchPath -PathType Leaf)
    {
        Write-Verbose "Path was a file, getting directory of file"
        $searchPath = Split-Path -Path $RootSearchPath -Parent
        Write-Verbose "Resolved folder '$searchPath'"
    }
    
    $t4exePath = Join-Path -Path (Get-VsInstallBasePath) -ChildPath "\Common7\IDE\TextTransform.exe"
   # $tfExePath = Get-TfExePath
    
    if ($IncludePackagesFolder.IsPresent)
    {
        $ttFiles = @(Get-ChildItem -Path $searchPath -Recurse -File -Include *.tt)
    }
    else
    {
        $ttFiles = @(Get-ChildItem -Path $searchPath -Recurse -File -Include *.tt | Where-Object {$_.FullName -notmatch "packages"})
    }
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
            #& $tfExePath vc checkout $outFile
            #Set-ItemProperty $outFile -name IsReadOnly -value $false
        }

        & $t4exePath $($ttFile.FullName) -out $outFile
        Write-Verbose "Generation complete"
    }

    Write-Output "Operation complete"
}

