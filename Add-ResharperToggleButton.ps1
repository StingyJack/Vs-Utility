<#
    .SYNOPSIS
    Adds Resharper toggle button to the VS toolbar.

    .DESCRIPTION
    Creates a toggle button in the Visual Studio toolbar that allows quick enabling/disabling of ReSharper functionality.
    This function must be run from the Package Manager Console to access the necessary Visual Studio DTE types.

    .PARAMETER VisualStudioDTE
    The Visual Studio DTE (Development Tools Environment) object from the Package Manager Console ($dte).

    .EXAMPLE
    From the package manager console:
    Add-ResharperToggleButton -VisualStudioDTE $dte

    .EXAMPLE
    Using with custom settings:
    $dte.ExecuteCommand("Tools.ImportandExportSettings", @"/import:""C:\yourpath\LightTheme.vssettings""")
    Add-ResharperToggleButton -VisualStudioDTE $dte

    .NOTES
    - Must be run from Package Manager Console
    - Requires ReSharper to be installed
    - If button creation fails, you can delete it manually through toolbar customization
#>
$ErrorActionPreference = 'Stop'
function Add-ResharperToggleButton {
    [CmdletBinding()]
    Param(
        [object] $VisualStudioDTE
    )

    if ($Host.Name -ine "Package Manager Host") {
        throw "This must be run from the Nuget Package Manager Console in order to access the necessary types"
    }

    Write-Host "If this fails for any reason, delete the toolbar button by right clicking the toolbar, choosing Customize, selecting it and clickcing delete."
    $typePath = $VisualStudioDTE.GetType().Assembly.Location
    Write-Host "Adding dte types if not already present from `n`t '$typePath'"
    Add-Type -Path "$typePath"
    $cmdBarName = "R#"
    $cmdName = "ReSharper_ToggleSuspended"
    $cmdText = "R# Active"
    $toolbarType = [EnvDTE.vsCommandBarType]::vsCommandBarTypeToolbar
   

    $cmdBar = $VisualStudioDTE.Commands | Where-Object { $_.Name -ieq $cmdBarName } | Select-Object -First 1
    if ($null -eq $cmdBar) {
		try {
			Write-Host "Creating command bar"
			$cmdBar = $VisualStudioDTE.Commands.AddCommandBar($cmdBarName, $toolbarType)
		}
		catch {
			if ($_.Message -ilike "*Value does not fall within the expected range*")
			{
				throw "Resharper does not appear to be installed"
			}	
		}
    }
    
    try	{
		Write-Host "Creating Command Item"
		$cmdItem = $VisualStudioDTE.Commands.Item($cmdName).AddControl($cmdBar, 1)
	}
	catch {
		if ($_.Message -ilike "*Value does not fall within the expected range*")
		{
			throw "Resharper does not appear to be installed"
		}
	}

    Write-Host "Setting item caption"
    $cmdItem.Caption = $cmdText

    Write-Host "Done"
}