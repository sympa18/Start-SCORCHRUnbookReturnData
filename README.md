# Start-SCORCHRUnbookReturnData
Start an Orchestrator Runbook using a Hashtable for parameters     
Project Name: Start an Orchestrator Runbook using a Hashtable for parameters    
Runbook Name: Start-ScorchRunbookReturnData    
Original Author: Tiander Turpijn     
Edited by : George Smpyrakis and Anthony Watherston    
Version: 2.0    
Runbook Creation Date: 27/03/2015    
Comments : to call this Runbook you will need to pass through two Parameters the InParam must be a hashtable    
Example     $Parameters = @{"Servername"="SERVER01";"VMROLE"="AzureIsAwesome"}    
$RunbookPath = "\04.0 Provisioning\04.0 ReturnData Example\04.0 ReturnData"    
Start-SCORCHRunbook -InParam $Parameters -RunbookPath $RunbookPath     
Prerequisites : This Runbook uses the OrchetrstorService PowerShell module that resides in the folder C:\inetpub\Service Management Automation\Modules on a Server with SMA installed. 
You can replace those cmdlets with any available PowerShell module for Orchestrator in the community if you like otherwise ensure this module is loaded.
