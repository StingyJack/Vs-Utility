<#

    .SYNOPSIS
    Gets all the web project files from a solution

    .NOTE
    List of guids courtesy of https://www.codeproject.com/Reference/720512/List-of-Visual-Studio-Project-Type-GUIDs
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
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 1";ProjectTypeGuid="{603C0E0B-DB56-11DC-BE95-000D561079B0}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 2";ProjectTypeGuid="{F85E285D-A4E0-4152-9332-AB1D724D3325}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 3";ProjectTypeGuid="{E53F8FEA-EAE0-44A6-8774-FFD645390401}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 4";ProjectTypeGuid="{E3E379DF-F4C6-4180-9B81-6769533ABE47}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="ASP.NET MVC 5";ProjectTypeGuid="{349C5851-65DF-11DA-9384-00065B846F21}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v2 (MVC 2)";ProjectTypeGuid="{F85E285D-A4E0-4152-9332-AB1D724D3325}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v3 (MVC 3)";ProjectTypeGuid="{E53F8FEA-EAE0-44A6-8774-FFD645390401}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v4 (MVC 4)";ProjectTypeGuid="{E3E379DF-F4C6-4180-9B81-6769533ABE47}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Model-View-Controller v5 (MVC 5)";ProjectTypeGuid="{349C5851-65DF-11DA-9384-00065B846F21}";})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Web Application";ProjectTypeGuid="{349C5851-65DF-11DA-9384-00065B846F21};"})
    $projectTypes += (New-Object -Type PsObject -Property @{ProjectType="Web Site";ProjectTypeGuid="{E24C65DC-7377-472B-9ABA-BC803B73C61A};"})

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