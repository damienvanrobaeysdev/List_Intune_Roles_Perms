If (!(Get-Module -listavailable | where {$_.name -like "*Microsoft.Graph.Intune*"})) 
	{ 
		Install-Module Microsoft.Graph.Intune -ErrorAction SilentlyContinue 
	} 
Else 
	{ 
		Import-Module Microsoft.Graph.Intune -ErrorAction SilentlyContinue 			
	} 

$Ask_Creds = Connect-MSGraph
$User_To_Check = $Ask_Creds.UPN

write-host ""	
write-host "Checking permissions for $User_To_Check" -ForegroundColor Cyan	
write-host ""
	
If (!(Get-Module -listavailable | where {$_.name -like "*Microsoft.Graph.Intune*"})) 
	{ 
		Install-Module Microsoft.Graph.Intune -ErrorAction SilentlyContinue 
	} 
Else 
	{ 
		Import-Module Microsoft.Graph.Intune -ErrorAction SilentlyContinue 			
	} 
	
Try
	{
		$Ask_Creds = Connect-MSGraph
		write-host "Conexion OK to your tenant"
	}
Catch
	{
		write-host "Conexion KO to your tenant"	
	}
	
$User_To_Check = $Ask_Creds.UPN

$Get_All_Permissions = Get-DeviceManagement_ResourceOperations	
$Get_Roles = Get-DeviceManagement_RoleDefinitions 
	
$Permissions_report = @()
ForEach($Role in $Get_Roles)
	{	
		$found = $false

		$Role_displayName = $Role.displayName
		$Role_FriendlyName = $Role.resourceName
		$Roles_Action = $Role.actionName
		
		$My_Permissions = $Role.RolePermissions.resourceActions.allowedResourceActions
		ForEach($Permission in $Get_All_Permissions)
			{	
				$Permission_ID = $Permission.id
				$Permission_FriendlyName = $Permission.resourceName
				$Permission_Action = $Permission.actionName	
				$Permissions_Obj = New-Object PSObject
				$Permissions_Obj | Add-Member NoteProperty -Name "Role Name" -Value $Role_displayName				
				$Permissions_Obj | Add-Member NoteProperty -Name "Permission friendly Name" -Value $Permission_FriendlyName -force
				$Permissions_Obj | Add-Member NoteProperty -Name "Action" -Value $Permission_Action -force
				
				ForEach($My_Permission in $My_Permissions)
					{
						If($Permission_ID -eq $My_Permission)
							{ 	
								$found = $true
								break
							}
					}
					
				If($found) 
					{
						$Script:found = $false
						$Permissions_Obj | Add-Member NoteProperty -Name "Permissions status" -Value 'Enable' -force						
					}
				Else
					{
						$Permissions_Obj | Add-Member NoteProperty -Name "Permissions status" -Value 'Not enable' -force											
					}
				$Permissions_report += $Permissions_Obj
			}  
	}	
$Permissions_report