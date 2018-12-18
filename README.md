# deploy_qualys_Azure_Automation
Deploy Qualys Cloud Agent in Azure VM using Azure Automation and Run command

Pre-requisites:
1. You have Azure automation account
2. Run as Azure and Connections are set up.

The powershell script logs into the Azure Subscription and locates all the Resource Groups in it. Crawling each Resource Groups, it will locate VMs inside them. With the help of Azure Run command "Invoke-AzureRmVMRunCommand" , it will download the script to install Qualys Cloud Agent based on OS of the VM.


