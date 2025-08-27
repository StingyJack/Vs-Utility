<#
    .SYNOPSIS
    Removes whitespace at the end of every line of text in a file.

    .DESCRIPTION
    Fixes extra tabs and spaces that IDEs may add to the ends of lines or blank lines
    in PowerShell scripts. These extra characters can cause loading or execution issues.
    The function can automatically handle TFS checkout if needed.

    .PARAMETER Path
    The full path to the file from which to remove trailing whitespace.

    .PARAMETER DontAttemptCheckout
    Switch to prevent automatic TFS checkout attempt. If not specified, the function
    will try to check out the file from TFS before making changes.

    .EXAMPLE
    Remove-TrailingWhitespace -Path "C:\Scripts\MyScript.ps1"
    Removes trailing whitespace from the specified file, checking it out from TFS if needed.

    .EXAMPLE
    Remove-TrailingWhitespace -Path "C:\Scripts\MyScript.ps1" -DontAttemptCheckout
    Removes trailing whitespace without attempting TFS checkout.

    .OUTPUTS
    Writes progress and results to the VS output window using Write-Host.

    .NOTES
    - Uses Write-Host for VS Output Window compatibility
    - Configured for use as an External Tool in Visual Studio
    - Preserves file content while removing only trailing spaces
    - Handles TFS source control integration
#>
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
            Write-Host "Attempting checkout of file"
            Edit-TfVcFile -Path $Path
        }
        Write-Host "Saving file"
        Set-Content -Value $lines -Path $Path
        Write-Host "File saved"
    }
    else
    {
        Write-Host "No trailing whitespace found to remove"
    }    
    
}