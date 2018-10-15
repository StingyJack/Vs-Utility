#Requires -Version 5.1


#getters

. ("$PSScriptRoot\Find-References.ps1")
Export-ModuleMember -Function Find-References

. ("$PSScriptRoot\Find-ProjectAntipatterns.ps1")
Export-ModuleMember -Function Find-ProjectAntipatterns

. ("$PSScriptRoot\Get-ProjectFiles.ps1")
Export-ModuleMember -Function Get-ProjectFiles

. ("$PSScriptRoot\Get-ProjectItems.ps1")
Export-ModuleMember -Function Get-ProjectItems

. ("$PSScriptRoot\Get-ProjectsWithProperty.ps1")
Export-ModuleMember -Function Get-ProjectsWithProperty

. ("$PSScriptRoot\Get-PrimaryProjectOutput.ps1")
Export-ModuleMember -Function Get-PrimaryProjectOutput

. ("$PSScriptRoot\Get-TestProjects.ps1")
Export-ModuleMember -Function Get-TestProjects

. ("$PSScriptRoot\Get-TestProjectAssemblies.ps1")
Export-ModuleMember -Function Get-TestProjectAssemblies

. ("$PSScriptRoot\Get-WebProjectFiles.ps1")
Export-ModuleMember -Function Get-WebProjectFiles




#modifiers

. ("$PSScriptRoot\Disable-SignAssembly.ps1")
Export-ModuleMember -Function Disable-SignAssembly

. ("$PSScriptRoot\Remove-SolutionOutputs.ps1")
Export-ModuleMember -Function Remove-SolutionOutputs 

. ("$PSScriptRoot\Remove-AllProjectOutput.ps1")
Export-ModuleMember -Function Remove-AllProjectOutput

. ("$PSScriptRoot\Update-ProjectProperty.ps1")
Export-ModuleMember -Function Update-ProjectProperty

. ("$PSScriptRoot\Update-SolutionTargetFramework.ps1")
Export-ModuleMember -Function Update-SolutionTargetFramework



#tooling

. ("$PSScriptRoot\Add-ResharperToggleButton.ps1")
Export-ModuleMember -Function Add-ResharperToggleButton

. ("$PSScriptRoot\Edit-TfVcFile.ps1")
Export-ModuleMember -Function Edit-TfVcFile

. ("$PSScriptRoot\Invoke-SolutionTests.ps1")
Export-ModuleMember -Function Invoke-SolutionTests

. ("$PSScriptRoot\Invoke-T4.ps1")
Export-ModuleMember -Function Invoke-T4

. ("$PSScriptRoot\Remove-ProjectConfiguration.ps1")
Export-ModuleMember -Function Remove-ProjectConfiguration

. ("$PSScriptRoot\Remove-TrailingWhitespace.ps1")
Export-ModuleMember -Function Remove-TrailingWhitespace



