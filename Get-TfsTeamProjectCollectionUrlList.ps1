<#
    .SYNOPSIS
    Gets a string array of the current TFS project collection URLs for the current user.

    .DESCRIPTION
    Searches through Visual Studio's TeamExplorer.config files in the user's AppData
    directory to find all Team Foundation Server (TFS) project collection URLs that
    the current user has accessed. Returns unique URLs to avoid duplicates.

    .OUTPUTS
    System.String[]
    An array of unique TFS project collection URLs.

    .EXAMPLE
    $urls = Get-TfsTeamProjectCollectionUrlList
    Returns all TFS project collection URLs the current user has accessed.

    .EXAMPLE
    Get-TfsTeamProjectCollectionUrlList | ForEach-Object { Write-Host "Collection URL: $_" }
    Lists all TFS collection URLs with a custom format.

    .NOTES
    - Searches in %APPDATA%\Microsoft\VisualStudio
    - Only returns URLs marked as 'current' in the config
    - Filters out duplicate URLs
    - Works with multiple Visual Studio versions
#>
function Get-TfsTeamProjectCollectionUrlList
{
    $searchBaseFolder = "$env:APPDATA\Microsoft\VisualStudio"

    $teConfigs = @(Get-ChildItem -Path $searchBaseFolder -Filter TeamExplorer.config -Recurse -File)

    $projectCollectionUrls = @()

    foreach ($teConfig in $teConfigs)
    {
        $teConfigContent = [xml](Get-Content -Path $teConfig.FullName )

        $urls = @($teConfigContent.server_list.server | Where-Object {$_.current -ieq "yes"} | Select-Object -ExpandProperty collection | Select-Object -ExpandProperty url -Unique)

        foreach ($url in $urls)
        {
            if ($projectCollectionUrls -icontains $url) { continue }
            $projectCollectionUrls += $url
        }
    }
    Write-output $projectCollectionUrls
}