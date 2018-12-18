# deploy_qualys_Azure_Automation
Deploy Qualys Cloud Agent in Azure VM using Azure Automation and Run command

The powershell script "qcainstall.ps1" logs into the Azure Subscription and locates all the Resource Groups in it. Crawling each Resource Groups, it will locate VMs inside them. With the help of Azure Run command "Invoke-AzureRmVMRunCommand" , it will download the script to install Qualys Cloud Agent based on OS of the VM.

Pre-requisites:
1. You have Azure automation account
2. Run as Azure and Connections are set up.

Note: Doesn't work on powershell version below 2 and specifically on V5 core due to unavailability of Invoke-webrequest cmdlet. You can opt for the alternatives.

Steps to Deploy:

1. Create variables named ContainerName, StorageAccountName, StorageAccountKey
![Image1](variables.PNG?raw=true "Title")

2. Copy the executables files ( Qualys Cloud Agent exe, rpm or deb files) and upload it to the Blob storage that is publicly accessible.
![Image2](executables.PNG?raw=true "Title")

3. Repeat the same for scripts LinucQCA.sh and WindowsQCA.ps1 and Store it in Blob storage referred by variables created in step 1 and let it be private.
![Image2](scripts.PNG?raw=true "Title")

4. Import the main script named qcainstall.ps1 on azure automation runbook and save and publish it.
![Image2](runbooks.PNG?raw=true "Title")

5. Start the Runbook.
![Image2](startrunbook.PNG?raw=true "Title")




