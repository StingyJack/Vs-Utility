<#
    .SYNOPSIS
    Adds Resharper toggle button to the VS toolbar.

    Currently is a string result so you can paste it into the package manager console. The powershell 
    interactive window does not have a $DTE for some reason. 
    
    Using the settings files included, you can also do something like this
    $dte.ExecuteCommand("Tools.ImportandExportSettings", @"/import:""C:\yourpath\LightTheme.vssettings""")

#>
function Add-ResharperToggleButton
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