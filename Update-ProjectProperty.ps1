<#
    .SYNOPSIS
    Updates or removes a project property from a proj file

    .EXAMPLE
    Update-ProjectProperty -ProjectFilePath C:\code\repo\src\Project1\Project1.csproj -PropertyName CodeAnalysisRuleSet -Remove -PendChange -Verbose

    .EXAMPLE 
    Update-ProjectProperty -ProjectFilePath " C:\code\repo\src\Project1\Project1.csproj" -PropertyName CodeAnalysisRuleSet -Value "SecurityRules.ruleset" -PropertyGroupCondition "== 'CodeAnalysis|" -PendChange -Verbose
#>

function Update-ProjectProperty
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $ProjectFilePath,
        [Parameter(Mandatory=$true)]
        [string] $PropertyName,

        [Parameter(Mandatory=$true, ParameterSetName='Remove')] 
        [switch] $Remove,

        [Parameter(Mandatory=$true, ParameterSetName='Update')] 
        [string] $Value,

        [Parameter(Mandatory=$false)]
        [switch] $PendChange,
        
        [Parameter(Mandatory=$false)]
        [string] $PropertyGroupCondition
    )

    if ($PSCmdlet.ParameterSetName -eq "Update")
    {
        Write-Verbose "Updating project property $PropertyName for project '$ProjectFilePath' to be '$Value'"
    }
    else
    {
        Write-Verbose "Removing project property $PropertyName for project '$ProjectFilePath'"
    }

    $projFileContent = [xml](Get-Content -Path $ProjectFilePath)

    if (-Not ($projFileContent | Get-Member -Name Project))
    {
        Write-Warning "Project file '$projectFilePath' does not have a <project> element"
        return
    }

    if (-Not ($projFileContent.Project | Get-Member -Name PropertyGroup))
    {
        Write-Warning "Project file '$projectFilePath' does not have any <propertygroup> elements"
        return
    }
    
    $changesMade = $false
    foreach ($propertyGroup in $projFileContent.Project.PropertyGroup)
    {
        if ([string]::IsNullOrWhiteSpace($PropertyGroupCondition) -eq $false)
        {
            if ($propertyGroup.HasAttribute("Condition") -eq $false)
            {
                Write-Verbose "Property group condition '$PropertyGroupCondition' is specified, but this group has no condition"
                continue
            }

            $condition = $propertyGroup.GetAttribute("Condition")

            if ($condition.IndexOf($PropertyGroupCondition, [StringComparison]::OrdinalIgnoreCase) -lt 0)
            {
                Write-Verbose "Property group condition '$PropertyGroupCondition' is specified, but this group's condition ('$condition') doesnt match"
                continue
            }
        }
            
        if (-Not ($propertyGroup | Get-Member -Name $PropertyName ))
        {
            Write-Verbose "Property group does not have the property '$PropertyName'"
            continue
        }
         
        if ($PSCmdlet.ParameterSetName -eq "Remove")
        {
            $propertyGroup.ChildNodes | Where-Object {$_.Name -eq $PropertyName} | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}
            $changesMade = $true
        }
        else
        {
            $propertyGroup.ChildNodes | Where-Object {$_.Name -eq $PropertyName} | ForEach-Object {$_.InnerText = $Value}
            $changesMade = $true
        }           
    
    }

    
    if ($changesMade -eq $false)
    {
        Write-Verbose "Project file '$projectFilePath' does not have any changes to make."
        return
    }
    else
    {
        Write-Verbose "Saving changes to project file"
        $projFileContent.Save($ProjectFilePath)
    }
    
    
}

