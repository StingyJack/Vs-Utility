. .\Get-ProjectItems.ps1

function Find-ProjectAntiPatterns
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath
    )

    $antiPatterns = @()

    Add-Type -TypeDefinition (Get-HelperTypes)

    #projects with non-content things set to content (packages.config, *.snk, )  and published mistakenly

}


function Find-NonContentContentIncludes
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath
    )

    Add-Type -TypeDefinition (Get-HelperTypes)
    $badPatterns = [VsUtility.Consts]::GetNonContentFilePatterns()
    $items = @(Get-ProjectItems -ProjFilePath $ProjFilePath -ItemType Content)
    $returnValue = @()
    foreach ($item in $items)
    {
        $fileName = [IO.Path]::GetFileName($item.FullName)
        foreach ($badPattern in $badPatterns)
        {
            if ($fileName -ilike $badPattern)
            {
                $locProps = @{'FilePath'= $item.FullName;'Code'="NCC";'Message'="Content file matches non-content pattern '$badPattern'"}
                $returnValue += (New-Object -TypeName PSObject -Property $locProps)
                continue
            }
        }
    }

    return $returnValue
}

#can diagnostic
function Get-HelperTypes
{
    return @"

    namespace VsUtility 
    {
        using System;
        using System.Collections.Generic;

        public class Location
        {
            public string FilePath {get;set;}
            public int LineNumber {get;set;}
            public string Code {get;set;}
            public string Message {get;set;}
        }

        public static class Consts
        {
            public static List<string> GetNonContentFilePatterns()
            {
                var files = new List<string>();
                files.Add("*.snk");
                files.Add("packages.config");
                return files;
            }
        }

    }

"@

}
$ErrorActionPreference = 'Stop'
Find-NonContentContentIncludes -ProjFilePath "E:\Projects\StingyBot\src\StingyBot.SalesForce\StingyBot.SalesForce.csproj"