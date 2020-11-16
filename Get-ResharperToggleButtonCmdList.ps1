<#
    .SYNOPSIS
    Gets the commands as text for adding Resharper toggle button to the VS toolbar.

    Currently is a string result so you can paste it into the package manager console or the Powershell 
	Interactive Window (part of the powershell pro tools extension)
    
    Using the settings files included, you can also do something like this
    $dte.ExecuteCommand("Tools.ImportandExportSettings", @"/import:""C:\yourpath\LightTheme.vssettings""")

#>
function Get-ResharperToggleButtonCmdList
{
    [CmdletBinding()]
    Param(
        [object] $VisualStudioDTE
    )

    #Add-Type $VisualStudioDTE.GetType().Assembly.Location
$str = @"
    `$cmdBarName = "R#"
    `$cmdName = "ReSharper_ToggleSuspended"
    `$cmdText = "R# Active"
    `$toolbarType = [EnvDTE.vsCommandBarType]::vsCommandBarTypeToolbar
    
    `$cmdBar = `$dte.Commands.AddCommandBar(`$cmdBarName, `$toolbarType)

    `$cmdItem = `$dte.Commands.Item(`$cmdName).AddControl(`$cmdBar, 1)
    `$cmdItem.Caption = `$cmdText

"@
return $str
}