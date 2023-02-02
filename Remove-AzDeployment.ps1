
    param(
        [Parameter(Mandatory=$true)]
        [string]$ManagementGroupName,

        [Parameter(Mandatory=$true)]
        [int]$NumberOfDeploymentsToKeep
    )

    $TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol

    # Get Management Group
    try {
        $mg = Get-AzManagementGroup -GroupName $ManagementGroupName
        Write-Host "$mg"
    } catch {
        Write-Error "Error getting management group: $($_.Exception.Message)"
        exit 1
    }

    # Get all subscriptions in the Management Group
    try {
        $mgname = $mg.Name 
        $subs = Get-AzManagementGroupSubscription -GroupName $mgname | Where-Object -FilterScript {$_.State -EQ 'Active'}
        Write-Host  "$mgname"
    } catch {
        Write-Error "Error getting subscriptions in management group: $($_.Exception.Message)"
        Write-Host "Error"
     }

    # Iterate through subscriptions
    foreach($sub in $subs){
        # Select the subscription
        try {
           $subscriptionId = $subs.Id -split "/" | Select-Object -Last 1
            Select-AzSubscription -SubscriptionId  $subscriptionId
        } catch {
            Write-Error "Error selecting subscription: $($_.Exception.Message)"
            continue
        }

        # Get all resource groups
        try {
            $rgs = Get-AzResourceGroup
            Write-Host $rgs
        } catch {
            Write-Error "Error getting resource groups: $($_.Exception.Message)"
            continue
        }

        # Iterate through resource groups
        foreach($rg in $rgs){
            # Get all deployments in resource group
               $rgname = $rg.ResourceGroupName
                Write-Host " $rgname"
            try {
                $deployments = Get-AzResourceGroupDeployment -ResourceGroupName  $rgname
                 Write-Host  "$deployments.DeploymentName"
            } catch {
                Write-Error "Error getting deployments for resource group '$($rgname)': $($_.Exception.Message)"
                continue
            }

            # Sort the deployments by timestamp in descending order
            $deployments = $deployments | Sort-Object -Property Timestamp -Descending

            # Keep the specified number of deployments and delete the rest
            Write-Host "$NumberOfDeploymentsToKeep"
            for($i = $NumberOfDeploymentsToKeep; $i -lt $deployments.Count; $i++){
                # Delete deployment
                try {
                    Remove-AzResourceGroupDeployment -ResourceGroupName $rgname -Name $deployments[$i].DeploymentName
                } catch {
                    Write-Error "Error deleting deployment '$($deployments[$i].DeploymentName)' in resource group '$($rgname)': $($_.Exception.Message)"
                }
            }
        }
    }
