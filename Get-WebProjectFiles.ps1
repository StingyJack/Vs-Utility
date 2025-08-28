<#
    .SYNOPSIS
    Gets all web project files from a Visual Studio solution.

    .DESCRIPTION
    This function identifies web projects in a Visual Studio solution by examining their project type GUIDs.
    It supports multiple types of web projects including:
    - ASP.NET MVC (versions 1-5)
    - ASP.NET 5
    - Web Applications
    - Web Sites

    .PARAMETER SolutionFilePath
    The full path to the Visual Studio solution file (.sln).

    .EXAMPLE
    $webProjects = Get-WebProjectFiles -SolutionFilePath "C:\Projects\MySolution\MySolution.sln"
    Returns an array of paths to all web projects in the solution.

    .NOTES
    - Identifies web projects by their Project Type GUIDs
    - Supports multiple versions of ASP.NET MVC and other web project types
    - Project Type GUIDs reference: https://github.com/JamesW75/visual-studio-project-type-guid
    - A project can have multiple type GUIDs; matches if any of them indicate a web project
    - Skips projects that don't exist on disk
#>

function Get-WebProjectFiles
{
    [CmdletBinding()]
    Param(
        [string] $SolutionFilePath
    )

    Write-Verbose "Using solution $SolutionFilePath"
        
    $allProjectFiles = Get-ProjectFiles -SolutionFilePath $SolutionFilePath

    $projectTypes = @()
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET 5";ProjectTypeGuid="{8BB2217D-0F2D-49D1-97BC-3654ED321F3B}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET Core Empty";ProjectTypeGuid="{356CAE8B-CFD3-4221-B0A8-081A261C0C10}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET Core Web API";ProjectTypeGuid="{687AD6DE-2DF8-4B75-A007-DEF66CD68131}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET Core Web App";ProjectTypeGuid="{E27D8B1D-37A3-4EFC-AFAE-77744ED86BCA}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET Core Web App (Model-View-Controller)";ProjectTypeGuid="{065C0379-B32B-4E17-B529-0A722277FE2D}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET Core with Angular";ProjectTypeGuid="{32F807D6-6071-4239-8605-A9B2205AAD60}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET Core with React.js";ProjectTypeGuid="{4C3A4DF3-0AAD-4113-8201-4EEEA5A70EED}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 1";ProjectTypeGuid="{603C0E0B-DB56-11DC-BE95-000D561079B0}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 2";ProjectTypeGuid="{F85E285D-A4E0-4152-9332-AB1D724D3325}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 3";ProjectTypeGuid="{E53F8FEA-EAE0-44A6-8774-FFD645390401}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 4";ProjectTypeGuid="{E3E379DF-F4C6-4180-9B81-6769533ABE47}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 5";ProjectTypeGuid="{349C5851-65DF-11DA-9384-00065B846F21}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Azure WebJob (.NET Framework)";ProjectTypeGuid="{BFBC8063-F137-4FC6-AEB4-F96101BA5C8A}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Blazor Server App";ProjectTypeGuid="{C8A4CD56-20F4-440B-8375-78386A4431B9}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v2 (MVC 2)";ProjectTypeGuid="{F85E285D-A4E0-4152-9332-AB1D724D3325}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v3 (MVC 3)";ProjectTypeGuid="{E53F8FEA-EAE0-44A6-8774-FFD645390401}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v4 (MVC 4)";ProjectTypeGuid="{E3E379DF-F4C6-4180-9B81-6769533ABE47}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v5 (MVC 5)";ProjectTypeGuid="{349C5851-65DF-11DA-9384-00065B846F21}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Silverlight";ProjectTypeGuid="{A1591282-1198-4647-A2B1-27E5FF5F6F3B}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Web Application";ProjectTypeGuid="{349C5851-65DF-11DA-9384-00065B846F21}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Web Site";ProjectTypeGuid="{E24C65DC-7377-472B-9ABA-BC803B73C61A}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Windows Communication Foundation (WCF)";ProjectTypeGuid="{3D9AD99F-2412-4246-B90B-4EAA41C64699}";})

    $projects = @()
    foreach ($projectFullPath in $allProjectFiles)
    {
        if (-Not (Test-Path $projectFullPath))
        {
            Write-Verbose "Project path doesnt have a file: '$projectFullPath'"
            continue
        }

        $projFile = [xml](Get-Content -Path $projectFullPath)

        $projTypeGuidSets = $projfile.Project.PropertyGroup.ProjectTypeGuids
        if ($null -eq $projTypeGuidSets)
        {
            continue
        }

        foreach ($projTypeGuidSet in $projTypeGuidSets)
        {
            if ($null -eq $projTypeGuidSet)
            {
                continue
            }

            $splitGuids = $projTypeGuidSet.Split(";")
            foreach ($splitGuid in $splitGuids)
            {
                $match = @($projectTypes | Where-Object {$_.ProjectTypeGuid -ieq $splitGuid})
                if ($match.Count -gt 0)
                {
                    $projects += $projectFullPath
                    break
                }
            }
        }
    }
    return $projects
}

$PSScriptRoot