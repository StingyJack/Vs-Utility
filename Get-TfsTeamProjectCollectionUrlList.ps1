<#
    .SYNOPSIS
    Gets a string array of the current tfs project collection urls for the current user

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