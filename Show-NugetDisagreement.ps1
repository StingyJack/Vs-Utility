﻿<#

    .SYNOPSIS Finds where a packages.config does not match nuspec dependency versions

#>
function Show-NugetDisagreement
{
    [CmdletBinding()]
    Param(
        [string]$ProjectFolder
    )

    Write-Verbose "Searching for packages.config and a nuspec file in $ProjectFolder"
    $projectFolderName = Split-Path -Path $ProjectFolder -Leaf

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
        Write-Verbose "evaluating referenced package $($referencedPackage.id) / $($referencedPackage.version)"

        if ($referencedPackage.developmentDependency -eq $true) {continue}

        foreach ($nuspecDependencyPackage in $nuspec.package.metadata.dependencies.ChildNodes)
        {
            Write-Verbose "comparing nuspec dependency $($nuspecDependencyPackage.id) / $($nuspecDependencyPackage.version)"

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
                    Write-Host "Project folder $projectFolderName - $($referencedPackage.id) version mismatch. Referenced version $($referencedPackage.version). Nuspec dependency version $($nuspecDependencyPackage.version)" -ForegroundColor Red
                }

                break
            }

        }


        if ($doesNuspecHaveReferencedPackage -eq $false)
        {
            Write-Host "Project folder $projectFolderName - nuspec file '$pathToNuspec' does not have package $($referencedPackage.id) / $($referencedPackage.version) in the dependencies list" -ForegroundColor Red
        }

    }



}
