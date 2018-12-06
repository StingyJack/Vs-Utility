<#

    .SYNOPSIS Finds where a packages.config does not match nuspec dependency versions

#>
function Show-NugetDisagreement
{
    [CmdletBinding()]
    Param(
        [string]$ProjectFolder
    )

    Write-Verbose "Searching for packages.config and a nuspec file in $ProjectFolder"

    $pathToPackageConfig = "$ProjectFolder\packages.config"
    $pathToNuspec = Get-ChildItem -Path $ProjectFolder -Filter *.nuspec | Select-Object -First 1 -ExpandProperty FullName

    if ($null -eq $pathToNuspec)
    {
        Write-Verbose "No nuspec found for project folder $ProjectFolder"
        return 
    }

    Write-Verbose "Testing path $pathToPackageConfig"
    if (-Not (Test-Path $pathToPackageConfig)) 
    { 
        Write-Verbose "No packages.config found for project folder $ProjectFolder"
        return 
    }
       

    Write-Verbose "Testing path $pathToNuspec"
    if (-Not (Test-Path $pathToNuspec)) 
    { 
        Write-Verbose "No nuspec found for project folder $ProjectFolder"
        return 
    }

    $packageConfig = [xml](Get-Content $pathToPackageConfig)
    $nuspec = [xml](Get-Content $pathToNuspec)


    foreach ($referencedPackage in $packageConfig.packages.ChildNodes)
    {
        $doesNuspecHaveReferencedPackage = $false

        foreach ($nuspecDependencyPackage in $nuspec.package.metadata.dependencies.ChildNodes)
        {
            if ($nuspecDependencyPackage.id -ieq $referencedPackage.id)
            {
                $doesNuspecHaveReferencedPackage = $true
                Write-Verbose "matching package id found, checking version"

                if ($nuspecDependencyPackage.version -ieq $referencedPackage.version)
                {
                    Write-Verbose "version also matches"
                }
                else
                {
                    Write-Error "Package $($referencedPackage.id) version mismatch. Referenced version $($referencedPackage.version). Nuspec dependency version $($nuspecDependencyPackage.version)"
                }

                break
            }

        }


        if ($doesNuspecHaveReferencedPackage -eq $false)
        {
            Write-Error "Nuspec file '$pathToNuspec' does not have package $($referencedPackage.id) / $($referencedPackage.version) in the dependencies list"
        }

    }



}
