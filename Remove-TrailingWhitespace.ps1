function Remove-TrailingWhitespace
{
    [CmdletBinding()]
    Param(
        [string] $Path, 
        [switch] $DontAttemptCheckout
    )

    Write-Host "Removing trailing whitespace from file '$Path'"
    $countOfTrims = 0
    $lines = @()
    $content = Get-Content $Path
    foreach ($line in $content)
    {
        $trimLine = $line.TrimEnd()
        if ($trimLine.Length -lt $line.Length)
        {
            $countOfTrims++
        }
        $lines += $trimLine
    }
    if ($countOfTrims -gt 0)
    {
        Write-Host "Trailing whitespace removed from $countOfTrims lines"
        if ($DontAttemptCheckout.IsPresent -eq $false)
        {
 #           $tfExePath= "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
 #           & $exe vc checkout $Path
        }
        Set-Content -Value $lines -Path $Path
    }
    else
    {
        Write-Host "No trailing whitespace found to remove"
    }    
    
}