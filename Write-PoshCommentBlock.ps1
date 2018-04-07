<#

    .SYNOPSIS
    Not finished. Should create a comment based help block for a single function script, but the AST seems 
    to parse similarly looking scripts differently.


#>
function Write-PoshCommentBlock
{
    [CmdletBinding()]
    Param(
        [string] $Path
    )

    if (-Not(Test-Path $Path))
    {
        throw "file at path '$Path' does not exist"
    }

    $AST = [System.Management.Automation.Language.Parser]::ParseFile($Path,[ref]$null,[ref]$Null)
    $commentBlock = "<#`n"
    $commentBlock += "`t.SYNOPSIS`n"
    $commentBlock += "`t$($ast.EndBlock.Statements[0].Name)`n"
    $commentBlock += "`n"
    $commentBlock += "`t.DESCRIPTION`n"
    $commentBlock += "`t$($ast.EndBlock.Statements[0].Name)`n"
    $commentBlock += "`n"
    $astParams  = @($ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ParameterAst] }, $true))
    foreach($astParam in $astParams)
    {
        $commentBlock += "`t.PARAMETER $($astParam.Name.Extent)`n`t$($astParam.Name.VariablePath)`n`n"
    }
    
    $commentBlock += "#>"

    $commentBlock

    $mixed = $commentBlock + (Get-Content -Path $Path)
#    Set-Content -Path $Path -Value $mixed
    $mixed
}
