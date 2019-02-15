# AZURE_Cloud_Agent_AutomationAccount
Deploy Qualys Cloud Agent in Azure Virtual Machine (VM) using Azure Automation and Run command

# License
_**THIS SCRIPT IS PROVIDED TO YOU "AS IS."  TO THE EXTENT PERMITTED BY LAW, QUALYS HEREBY DISCLAIMS ALL WARRANTIES AND LIABILITY FOR THE PROVISION OR USE OF THIS SCRIPT.  IN NO EVENT SHALL THESE SCRIPTS BE DEEMED TO BE CLOUD SERVICES AS PROVIDED BY QUALYS**_

The powershell script "qcainstall.ps1" logs into the Azure subscription and locates all the Resource Groups in it. Crawling each Resource Groups, it will locate VMs inside them. With the help of Azure Run command "Invoke-AzureRmVMRunCommand" , it will download the script to install Qualys Cloud Agent based on Operating System (OS) of the VM.

Pre-requisites:
* You have Azure automation account
* Run as Azure and Connections are set up.

Note: This script does not work on powershell version below 2 and specifically on V5 core due to unavailability of Invoke-webrequest cmdlet. You can opt for the alternatives.

Steps to Deploy:

1. Create variables named ContainerName, StorageAccountName, StorageAccountKey
![Image1](variables.PNG?raw=true "Title")

2. Copy the executables files (Qualys Cloud Agent exe, rpm or deb files) and upload it to the Blob storage that is publicly accessible.
![Image2](executables.PNG?raw=true "Title")

3. Repeat the steps 1 and 2 for scripts LinucQCA.sh and WindowsQCA.ps1 and store it in Blob storage referred by variables created in step 1 and let it be private.
![Image2](scripts.PNG?raw=true "Title")

4. Import the main script named qcainstall.ps1 on azure automation runbook and edit the variables and Save and publish it.
# ActivationId, CustomerId, url_rpm, url_deb
![Image2](runbooks.PNG?raw=true "Title")

5. Start the Runbook.
![Image2](startrunbook.PNG?raw=true "Title")




