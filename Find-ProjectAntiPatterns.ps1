

function Find-ProjectAntipatterns
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath
    )

    $antiPatterns = @()

    Add-Type -TypeDefinition (Get-ApType)

    #projects with non-content things set to content (packages.config, *.snk, )  and published mistakenly

}

#can diagnostic
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