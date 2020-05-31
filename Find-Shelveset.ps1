<#
    .SYNOPSIS
    Finds shelveset based on the paramters given.

    .NOTE
    This is needed until VS Team Explorer can list all my shelvesets. VS TE currently
    requires a name to filter, and I don't remember the names of some shelvesets. This
    gives me a nice list to go through.


#>
function Find-Shelveset
{
    [CmdletBinding()]
    Param(
        [string] $UserName,
        [switch] $IncludeGCI,
        [switch] $IncludeAutoShelve,
        [switch] $IncludeCodeReview

    )
    $existingProgressPreference = $Global:ProgressPreference
    $Global:ProgressPreference = 'SilentlyContinue'
    Write-Verbose "Global progress preference was '$existingProgressPreference' and is now 'SilentlyContinue'"
    try
    {
        
        $projectCollectionUrls = Get-TfsTeamProjectCollectionUrlList
        $allShelveSets = @()
        Write-Verbose "Finding shelvesets for $UserName on $($projectCollectionUrls.Count) project collections"

        foreach ($projectCollectionUrl in $projectCollectionUrls)
        {
            Write-Verbose "Using project collection url $projectCollectionUrl"
            $allDone = $false
            $currentSkipValue = 0

            while ($allDone -eq $false) {

                $url = "$projectCollectionUrl/_apis/tfvc/shelvesets?owner=$UserName&`$skip=$currentSkipValue"
                $resp = Invoke-WebRequest -Uri $url -UseDefaultCredentials
                $shelveSetBlock = $resp.Content | ConvertFrom-Json

                foreach ($shelveSet in $shelveSetBlock.value)
                {
                    $shelveSetName = $shelveset.name

                    if ($shelveSetName.StartsWith("AutoShelve", [System.StringComparison]::OrdinalIgnoreCase))
                    {
                        if ($IncludeAutoShelve.IsPresent -eq $false) { continue }
                    }

                    if ($shelveSetName.StartsWith("Gated", [System.StringComparison]::OrdinalIgnoreCase))
                    {
                        if ($IncludeGCI.IsPresent -eq $false) { continue }
                    }

                    if ($shelveSetName.StartsWith("CodeReview", [System.StringComparison]::OrdinalIgnoreCase))
                    {
                        if ($IncludeCodeReview.IsPresent -eq $false) { continue }
                    }

                    if ($allShelveSets -notcontains $shelveSetName)
                    {
                        $shelveSet | Add-Member -MemberType NoteProperty -Name TeamProjectCollectionUrl -Value $projectCollectionUrl

                        $allShelveSets += $shelveSet
                    }
                }

                $currentSkipValue += 100

                if ($shelveSetBlock.count -lt 100)
                {
                    $allDone = $true
                }
            } #end iterating the current project collection shelfset list
        } #next project collection Url

        $allShelveSets | Sort-Object -Property TeamProjectCollectionUrl,createdDate -Descending | Select-Object -Property TeamProjectCollectionUrl,name,createddate | Format-Table
    }
    finally
    {
        $Global:ProgressPreference = $existingProgressPreference
        Write-Verbose "Global progress preference has been set back to '$existingProgressPreference'"
    }
}