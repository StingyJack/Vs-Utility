<#
    .SYNOPSIS
    This will remove and re-add the binding redirects for each project in a solution. This can only
    be executed from within the package manager console. Save all files before executing.

#>


function Update-BindingRedirect
{
    [CmdletBinding()]
    Param(

    )

    $currentHost = Get-Host
    Write-Verbose "Current host is '$($currentHost.Name)'"

    if ($currentHost.Name -ine "Package Manager Host")
    {
        throw "This can only be invoked from the package manager console in VS"
    }

    if ($null -eq $dte)
    {
        throw "Unable to get a reference to the VS DTE"
    }

    if ($null -eq $dte.Solution -or (-Not (Test-Path $dte.Solution.FullName)))
    {
        throw "There must be a valid solution loaded"
    }

    Write-Verbose "Current solution path '$($dte.Solution.FullName)'"

    $projectFiles = Get-ProjectFiles -SolutionFilePath $dte.Solution.FullName

    foreach($projectFile in $projectFiles)
    {
        $projectFolder = Split-Path -Path $projectFile -Parent

        $configFilePath = "$projectFolder\app.config"
        if (-Not(Test-Path $configFilePath))
        {
            $configFilePath = "$projectFolder\Web.config"
            if (-Not(Test-Path $configFilePath))
            {
                Write-Verbose "Project file '$projectFile' does not have a config file. Skipping"
                continue
            }
        }

        Write-Verbose "Project file '$projectFile' has a config file at $configFilePath"

        $configFileContent = [xml](Get-Content -Path $configFilePath)

        Write-Verbose "Config file content loaded"

        if (-Not ($configFileContent | Get-Member -Name "configuration"))
        {
            Write-Verbose "Config file '$configFilePath' does not have a configuration element. Skipping"
            continue
        }

        if (-Not ($configFileContent.configuration | Get-Member -Name "runtime"))
        {
            Write-Verbose "Config file '$configFilePath' does not have a configuration.runtime element. Skipping"
            continue
        }

        if (-Not ($configFileContent.configuration.runtime | Get-Member -Name "assemblyBinding"))
        {
            Write-Verbose "Config file '$configFilePath' does not have a configuration.runtime.assemblyBinding element. Skipping"
            continue
        }

        Write-Verbose "Removing assemblyBinding node from configuration.runtime element"

        $asmBindingNode = $configFileContent.configuration.runtime.assemblyBinding
        $configFileContent.configuration.runtime.RemoveChild($asmBindingNode)

        Write-Verbose "Saving changes to file"
        $configFileContent.Save($configFilePath)

        Write-Verbose "Invoking adding of assembly binding redirect"
        $projectName = [IO.Path]::GetFileNameWithoutExtension($projectFile)
        Add-BindingRedirect -ProjectName $projectName
    }
}