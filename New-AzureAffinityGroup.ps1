<#
.SYNOPSIS 
    Creates a new Azure Affinity Group. 

.DESCRIPTION
    This runbook creates a new Affinity Group representing a location.
    This runbook needs a valid Azure Location name to create the Affinity group. THere are few valid locations
    like East US, East Asia and others and any one from them must be used as parameter.

    It checks if the Azure Affinity group alreasy exists within a azure subscription. If it already  exists, then the
    same message is shown back otherwise a new Affinity group is created.

.PARAMETER AzureSubscriptionName
    Name of the Azure subscription to connect to
    
.PARAMETER AffinityGroupName    
    Name of the Affinity Group that you want to create.  

.PARAMETER Location
    Name of Azure Datacenter location that should represent your new affinity group.
    Use Get-AzureLocation cmdlet to get list of valid location names.
    e.g. East Asia, Easy US
 
.PARAMETER AffinityLabel
    Label of the Affinity Group that you want to create.  

.PARAMETER AffinityDescription
    Description of the Affinity Group that you are creating.  

.PARAMETER AzureCredentials
    A credential containing an Org Id username / password with access to this Azure subscription.

	If invoking this runbook inline from within another runbook, pass a PSCredential for this parameter.

	If starting this runbook using Start-AzureAutomationRunbook, or via the Azure portal UI, pass as a string the
	name of an Azure Automation PSCredential asset instead. Azure Automation will automatically grab the asset with
	that name and pass it into the runbook.

.EXAMPLE
    New-AffinityGroup -AzureSubscriptionName "Visual Studio Ultimate with MSDN" -AffinityGroupName "AffinityName" -Location "East Asia" -AffinityLabel "East Asia group" -AffinityDescription "Affinity group for East Asia location hosting particular workload" -AzureCredentials $cred

.NOTES
    AUTHOR:Ritesh Modi
    LASTEDIT: March 15, 2015 
    Blog: http://automationnext.wordpress.com
    email: callritz@hotmail.com
#>
workflow New-AffinityGroup {
    param
    (
        [parameter(Mandatory=$true)]
        [String]
        $AzureSubscriptionName,
     
        [parameter(Mandatory=$true)]
        [String]
        $AffinityGroupName,
        
        [parameter(Mandatory=$true)]
        [String]
        $Location,

        [parameter(Mandatory=$false)]
        [String]
        $AffinityLabel,

        [parameter(Mandatory=$false)]
        [String]
        $AffinityDescription,
         
        [parameter(Mandatory=$true)]
        [String]
        $AzureCredentials
    )

    # Get the credential to use for Authentication to Azure and Azure Subscription Name 
    $Cred = Get-AutomationPSCredential -Name $AzureCredentials 
     
    # Connect to Azure and Select Azure Subscription 
    $AzureAccount = Add-AzureAccount -Credential $Cred 

    # Connect to Azure and Select Azure Subscription 
    $AzureSubscription = Select-AzureSubscription -SubscriptionName $AzureSubscriptionName 

    # for checking if the affinity group already exists getting affinity group with given name
     $Affinity = Get-AzureAffinityGroup -Name $AffinityGroupName -ErrorAction SilentlyContinue

        # Affinity group with given name does not exists
        if(!$Affinity) {
                try{
                    if(!$AffinityLabel) { # Affinity label value was not provided. Defaulting it to Group Name
                        $AffinityLabel = $AffinityGroupName
                    }
                    if(!$AffinityDescription) {# Affinity Description value was not provided. Defaulting it to Group Name
                        $AffinityDescription = $AffinityGroupName
                    }
                     
                    # Creating new Azure affinity group    
                    $AffinityGroup = New-AzureAffinityGroup -Name $AffinityGroupName `
                                                                    -Label $AffinityLabel `
                                                                    -Description  $AffinityDescription `
                                                                    -Location $Location
                    if($AffinityGroup) {
                       $OutputMessage ="Azure Affinity Group $AffinityGroupName created for location $Location !! `r`n"
                    } else {
                        $OutputMessage ="Error creating Azure Affinity Group $AffinityGroupName for location $Location !!"
                    } 
               }
               catch
               {
                    $OutputMessage ="Error creating Azure Affinity Group $AffinityGroupName for location $Location !!" 
               }                
                                
            }  else  { 
                
                $OutputMessage = "Azure Affinity Group $AffinityGroupName already exists !!" 

            }

        Write-Output "$OutputMessage"
}
