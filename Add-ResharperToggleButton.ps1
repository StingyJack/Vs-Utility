<#
    .SYNOPSIS
    Adds Resharper toggle button to the VS toolbar.

	.EXAMPLE
	From the package manager console...
	
		Add-ResharperToggleButton -VisualStudioDTE $dte

	.NOTE
    Using the settings files included, you can also do something like this
    $dte.ExecuteCommand("Tools.ImportandExportSettings", @"/import:""C:\yourpath\LightTheme.vssettings""")

#>
$ErrorActionPreference = 'Stop'
function Add-ResharperToggleButton
{
    [CmdletBinding()]
    Param(
        [object] $VisualStudioDTE
    )

    if ($Host.Name -ine "Package Manager Host"){
        throw "This must be run from the Nuget Package Manager Console in order to access the necessary types"
    }

	$typePath = $VisualStudioDTE.GetType().Assembly.Location
	Write-Host "Adding dte types if not already present from `n`t '$typePath'"
    Add-Type -Path "$typePath"
    $cmdBarName = "R#"
    $cmdName = "ReSharper_ToggleSuspended"
    $cmdText = "R# Active"
    $toolbarType = [EnvDTE.vsCommandBarType]::vsCommandBarTypeToolbar
    
	Write-Host "Creating command bar"
    $cmdBar = $VisualStudioDTE.Commands.AddCommandBar($cmdBarName, $toolbarType)

	Write-Host "Creating Command Item"
    $cmdItem = $VisualStudioDTE.Commands.Item($cmdName).AddControl($cmdBar, 1)
	
	Write-Host "Setting item caption"
    $cmdItem.Caption = $cmdText

	Write-Host "Done"
}