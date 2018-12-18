$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$StorageAccountName = Get-AutomationVariable -Name "StorageAccountName"
$ContainerName = Get-AutomationVariable -Name "ContainerName"
$StorageAccountKey = Get-AutomationVariable -Name "StorageAccountKey"
$StorageContext = New-AzureStorageContext $StorageAccountName -StorageAccountKey $StorageAccountKey

#Get all ARM resources from all resource groups
$ResourceGroups = Get-AzureRmResourceGroup 

foreach ($ResourceGroup in $ResourceGroups)
{    
    $VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroup.ResourceGroupName
    $VMs | ForEach-Object {  
        if ($_.StorageProfile.OsDisk.OsType -eq "Windows") {
            Write-Output "\nFor Windows Hosts"
            Write-Output $_.Name
            Get-AzureStorageBlobContent -Blob WindowsQCA.ps1 -Container $ContainerName -Destination qcainstall.ps1 -Context $StorageContext -Confirm:$false
            #wget "https://csg88d63f93fad0x471dx88f.blob.core.windows.net/containermiktest/WindowsQCA.ps1" -UseBasicParsing -outfile qcainstall.ps1 # if script is stored in public container
            Invoke-AzureRmVMRunCommand -ResourceGroupName $ResourceGroup.ResourceGroupName -VMName $_.Name -CommandId 'RunPowerShellScript' -ScriptPath qcainstall.ps1 -Parameter @{"ActivationId" = "e84764e1-e219-4b59-8586-e781d3f621dd";"CustomerId" = "8a72be28-4fe4-7b79-838d-b5672cd680ab"} -Confirm:$false
        }
        else {
            Write-Output "\nFor Linux Hosts"
            Write-Output $_.Name
            Get-AzureStorageBlobContent -Blob LinuxQCA.sh -Container $ContainerName -Destination qcainstall.sh -Context $StorageContext -Confirm:$false
            #wget "https://csg88d63f93fad0x471dx88f.blob.core.windows.net/containermiktest/LinuxQCA.sh" -UseBasicParsing -outfile qcainstall.sh # if script is stored in public container
            Invoke-AzureRmVMRunCommand -ResourceGroupName $ResourceGroup.ResourceGroupName -VMName $_.Name -CommandId 'RunShellScript' -ScriptPath qcainstall.sh -Parameter @{"arg1"="e84764e1-e219-4b59-8586-e781d3f621dd"; "arg2"="8a72be28-4fe4-7b79-838d-b5672cd680ab"; "arg3"="https://testmikstrg.blob.core.windows.net/testmikconpub/qualys-cloud-agent.x86_64_qg2.rpm"; "arg4"="https://testmikstrg.blob.core.windows.net/testmikconpub/qualys-cloud-agent.x86_64_qg2.deb"} -Confirm:$false    
        }
    } 

} 