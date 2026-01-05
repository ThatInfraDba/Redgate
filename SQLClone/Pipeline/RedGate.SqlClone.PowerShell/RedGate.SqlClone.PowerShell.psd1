@{
    GUID = '{3bf82e85-f8d7-4945-a012-531aefdddc45}'
    Author = 'Redgate Software'
    CompanyName = 'Redgate Software'
    Copyright = 'Copyright © Red Gate Software Ltd 2016-2022'
    ModuleVersion = '5.6.10.7984'
    PowerShellVersion = '3.0'
    
    NestedModules = @("RedGate.SqlClone.PowerShell.dll")
    CmdletsToExport = @('Connect-SqlClone', 'Get-SqlClone', 'Get-SqlCloneImage', 'Get-SqlCloneImageLocation', 'Get-SqlCloneMachine', 'Get-SqlCloneSqlServerInstance', 'Get-SqlCloneTeam', 'Get-SqlCloneTemplate', 'New-SqlClone', 'New-SqlCloneImage', 'New-SqlCloneMask', 'New-SqlCloneSqlScript', 'New-SqlCloneTemplate', 'Remove-SqlClone', 'Remove-SqlCloneImage', 'Remove-SqlCloneMachine', 'Remove-SqlCloneTemplate', 'Rename-SqlClone', 'Rename-SqlCloneImage', 'Rename-SqlCloneMachine', 'Reset-SqlClone', 'Start-SqlCloneAgent', 'Wait-SqlCloneOperation')
}
