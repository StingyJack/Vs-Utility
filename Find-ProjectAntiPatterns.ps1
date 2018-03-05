function Find-ProjectAntipatterns
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath
    )

    $antiPatterns = @()

    Add-Type -TypeDefinition (Get-ApType)


}


function Get-ApType
{
    return @"

    namespace VsUtility 
    {
        using System;

        public class AntiPattern
        {
            public string FilePath {get;set;}
            public int LineNumber {get;set;}
        }

    }

"@

}