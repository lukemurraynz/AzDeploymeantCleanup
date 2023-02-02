# Deployment Cleaner Script

A script and Azure DevOps pipeline for cleaning up old [Azure resource group deployments](https://learn.microsoft.com/azure/azure-resource-manager/troubleshooting/deployment-quota-exceeded?tabs=azure-cli&WT.mc_id=AZ-MVP-5004796).

## Parameters
- `ManagementGroupName` (Mandatory) : The name of the management group for which to clean up deployments.
- `NumberOfDeploymentsToKeep` (Mandatory) : The number of deployments to keep in each resource group. The script will delete all other deployments.

## Script Execution
The script performs the following actions:
1. Sets the security protocol to `TLS12`
2. Gets the specified management group
3. Gets all active subscriptions within the management group
4. For each subscription, the script:
   1. Selects the subscription
   2. Gets all resource groups within the subscription
   3. For each resource group, the script:
      1. Gets all deployments within the resource group
      2. Sorts the deployments by timestamp in descending order
      3. Deletes all deployments except for the specified number to keep.

## Error handling
The script includes error handling for the following cases:
- Error getting the management group
- Error getting subscriptions within the management group
- Error selecting a subscription
- Error getting resource groups within a subscription
- Error getting deployments within a resource group
- Error deleting a deployment.

## Output
The script writes output to the console, including:
- The management group and subscription details
- The resource group and deployment details
- Error messages, if any.
