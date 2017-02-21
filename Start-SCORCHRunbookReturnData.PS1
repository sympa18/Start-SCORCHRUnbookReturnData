workflow Start-SCORCHRUnbookReturnData
{
<#---------------------------------------------------------------------------------------------------------------------------
    Project Name: Start an Orchestrator Runbook using a Hashtable for parameters
    Runbook Name: Start-ScorchRunbookReturnData
    Original Author: Tiander Turpijn 
    Edited by : George Smpyrakis and Anthony Watherston
    Version: 2.0
    Runbook Creation Date: 27/03/2015
    Comments : to call this Runbook you will need to pass through two Parameters the InParam must be a hashtable
    Example 
    $Parameters = @{"Servername"="SERVER01";"VMROLE"="AzureIsAwesome"}
    $RunbookPath = "\04.0 Provisioning\04.0 ReturnData Example\04.0 ReturnData"
    Start-SCORCHRunbook -InParam $Parameters -RunbookPath $RunbookPath 
    Prerequisites : This Runbook uses the OrchetrstorService PowerShell module that resides in the 
    folder C:\inetpub\Service Management Automation\Modules on a Server with SMA installed. You can replace those cmdlets 
    with any available PowerShell module for Orchestrator in the community if you like otherwise ensure this module is loaded

-----------------------------------------------------------------------------------------------------------------------------#>

<#---------------------------------------------------------------------------------------------------------------------------
Declare Parameters below
-----------------------------------------------------------------------------------------------------------------------------#>
    param( 
        [Parameter(Mandatory = $true)] 
        [System.Collections.Hashtable]$InParam,
        [Parameter(Mandatory = $true)] 
        [string]$RunbookPath
    ) 

<#---------------------------------------------------------------------------------------------------------------------------
Grab Variables and credentials from Azure Automation 
-----------------------------------------------------------------------------------------------------------------------------#>       
         
         
    $SCOserverName = Get-AutomationVariable -Name "SERVERNAME" #Add your SCORCH server variable here#
    $PSCredName = "AACREDENTIALNAME" #Add your PS Credentials for SCORCH Here#
    $PSUserCred = Get-AutomationPSCredential -Name $PSCredName   
<#---------------------------------------------------------------------------------------------------------------------------
    # Get the url for the Orchestrator service  
---------------------------------------------------------------------------------------------------------------------------#>

    $url = Get-OrchestratorServiceUrl -Server $SCOserverName     

<#---------------------------------------------------------------------------------------------------------------------------
    # Get the Runbook Details Note this variable becomes a Hashtable
---------------------------------------------------------------------------------------------------------------------------#>    
    $runbook = Get-OrchestratorRunbook -serviceurl $url -runbookpath $RunbookPath -credentials $PSUserCred 

<#---------------------------------------------------------------------------------------------------------------------------
    # Run through a number of ForEach and If Statements to match the Runbook Parameter Guids with the appropriate Values 
    from the specified Parameters and output them to $ReturnData
---------------------------------------------------------------------------------------------------------------------------#>      
    $Returndata = Inlinescript{
    $VerbosePreference = [System.Management.Automation.ActionPreference]$Using:VerbosePreference
    $GUIDParams = @{}
    $InParam = $using:InParam
    $runbook = $using:runbook
   
<#---------------------------------------------------------------------------------------------------------------------------
        #Correlate the Initialize Data parameters with our values  
---------------------------------------------------------------------------------------------------------------------------#> 
    foreach ($SCOParam in $runbook.Parameters)
    	{
    	if ($InParam.ContainsKey($SCOParam.Name))
    	    {
    	        #write-host "-I- Supplied hash contains key. Value is $($InParam.Get_item($($SCOParam.Name)))"
    	        ## Add to new hash ##
    	        $GUIDParams.Add($SCOParam.Id,$($InParam.Get_item($($SCOParam.Name))))
    	    }
    	else
    	    {
    	        #write-host "-E- Supplied hash is missing a parameter"
    	        #exit 8
    	    }
    	}
    Return $GUIDParams
    }
<#---------------------------------------------------------------------------------------------------------------------------
   #Start the runbook with our params 
---------------------------------------------------------------------------------------------------------------------------#> 
   $job = Start-OrchestratorRunbook -runbook $runbook -parameters $ReturnData -credentials $PSUserCred 
            
<#---------------------------------------------------------------------------------------------------------------------------
# Show the Runbook job information  
---------------------------------------------------------------------------------------------------------------------------#> 

    # If a job has been created then wait for it to complete and get any output 
    if ($job -ne $null) 
    { 
        # Wait for the Job to complete 
        while( ($job.Status -eq "Running") -or ($job.Status -eq "Pending") ) 
        { 
            Start-Sleep -m 500 
            $job = Get-OrchestratorJob -jobid $job.Id -serviceurl $job.Url_Service -credentials $PSUserCred 
        } 
        # The job is complete, so get any output 
        $instance = Get-OrchestratorRunbookInstance -Job $job -Credentials $PSUserCred
    }
         if ($instance -ne $null) 
        { 
            $instparams = Get-OrchestratorRunbookInstanceParameter -RunbookInstance $instance -Credentials $PSUserCred 
            if ($instparams -ne $null) 
            { 
                $ReturnData = InLinescript{ 
                    $ReturnDataHashTable = @{} 
                    foreach ($instparam in $Using:instparams) { 
                      if ($instparam.Direction -eq "Out") 
                      { 
                        $ReturnDataHashTable.Add($instparam.name,$instparam.Value) 
                      } 
               } 

              Return $ReturnDataHashTable 
                } 
            } 
         } 
      
    else 
    { 
        Write-Output "No job created" 
    }


#Output the ReturnData variable          
$ReturnData

}