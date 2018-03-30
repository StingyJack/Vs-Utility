

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


function Get-ProjectItems
{
    [CmdletBinding()]
    Param(
        [string] $ProjFilePath,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Compile','Content','None','Analyzer','Reference','EmbeddedResource')]
        [string] $ItemType
    )

    if (-Not (Test-Path $ProjFilePath)) {throw "Project file does not exist at '$ProjFilePath'"}

    Write-Verbose "Checking project file '$ProjFilePath' for '$ItemType'"
    $projFileContent = [xml](Get-Content $ProjFilePath)

    $projItems = @()
    foreach($projItemGroup in $projFileContent.Project.ItemGroup)
    {
        foreach ($projItem in $projItemGroup)
        {
            if ($projItem.Name -ieq $ItemType)
            {
                

            }
        }
    }
    
    Write-Verbose "Project has $($projItems.Count) items"

    return $projItems
}

Get-ProjectItems -ProjFilePath "E:\Projects\Scripty\src\Scripty.MsBuild\Scripty.MsBuild.csproj" -ItemType  "Compile"
#can diagnostic
function Get-HelperTypes
{
    return @"

    namespace VsUtility 
    {
        using System;

        public class Location
        {
            public string FilePath {get;set;}
            public int LineNumber {get;set;}
            public string Code {get;set;}
            public string Message {get;set;}
        }

        public static class Consts
        {
            public static List<string> GetNonContentFileNames()
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