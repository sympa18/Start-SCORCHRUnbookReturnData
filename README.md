Start-SCORCHRunbookReturnData

Description
This Script will help you start an Orchestrator Runbook using a Hashtable for parameters     

To call this Runbook you will need to pass through two Parameters the InParam must be a hashtable    

Example     

$Parameters = @{"Servername"="SERVER01";"VMROLE"="AzureIsAwesome"}    

$RunbookPath = "\04.0 Provisioning\04.0 ReturnData Example\04.0 ReturnData"    


Start-SCORCHRunbook -InParam $Parameters -RunbookPath $RunbookPath     

Prerequisites 
OrchestratorService.zip module 

This Runbook uses the OrchetrstorService PowerShell module that resides in the folder C:\inetpub\Service Management Automation\Modules on a Server with SMA installed. 

You can replace those cmdlets with any available PowerShell module for Orchestrator in the community if you like otherwise ensure this module is loaded.

The OrchestratorService.zip module has now been added to the Repository

Azure Automation Variable with the Orchestrator Servername
Azure Automation Credential with appropriate Orchestrator rights