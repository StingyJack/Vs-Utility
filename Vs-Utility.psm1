$ErrorActionPreference = "Stop"

. ("$PSScriptRoot\Remove-SolutionOutputs.ps1")
Export-ModuleMember -Function Remove-SolutionOutputs 

. ("$PSScriptRoot\Remove-AllProjectOutput.ps1")
Export-ModuleMember -Function Remove-AllProjectOutput

. ("$PSScriptRoot\Get-ProjectFiles.ps1")
Export-ModuleMember -Function Get-ProjectFiles

. ("$PSScriptRoot\Get-PrimaryProjectOutput.ps1")
Export-ModuleMember -Function Get-PrimaryProjectOutput

. ("$PSScriptRoot\Get-TestProjects.ps1")
Export-ModuleMember -Function Get-TestProjects

. ("$PSScriptRoot\Get-TestProjectAssemblies.ps1")
Export-ModuleMember -Function Get-TestProjectAssemblies

. ("$PSScriptRoot\Invoke-SolutionTests.ps1")
Export-ModuleMember -Function Invoke-SolutionTests

. ("$PSScriptRoot\Find-References.ps1")
Export-ModuleMember -Function Find-References

. ("$PSScriptRoot\Get-ProjectsWithProperty.ps1")
Export-ModuleMember -Function Get-ProjectsWithProperty

. ("$PSScriptRoot\Update-ProjectProperty.ps1")
Export-ModuleMember -Function Update-ProjectProperty

. ("$PSScriptRoot\Invoke-T4.ps1")
Export-ModuleMember -Function Invoke-T4

. ("$PSScriptRoot\Add-ResharperToggleButton.ps1")
Export-ModuleMember -Function Add-ResharperToggleButton

. ("$PSScriptRoot\Remove-TrailingWhitespace.ps1")
Export-ModuleMember -Function Remove-TrailingWhitespace

. ("$PSScriptRoot\Get-WebProjectFiles.ps1")
Export-ModuleMember -Function Get-WebProjectFiles

. ("$PSScriptRoot\Find-ProjectAntipatterns.ps1")
Export-ModuleMember -Function Find-ProjectAntipatterns

. ("$PSScriptRoot\Remove-ProjectConfiguration.ps1")
Export-ModuleMember -Function Remove-ProjectConfiguration