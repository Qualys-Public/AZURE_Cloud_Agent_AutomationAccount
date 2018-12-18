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
            #wget "REPLACE_ME" -UseBasicParsing -outfile qcainstall.ps1 # if script is stored in public container
            Invoke-AzureRmVMRunCommand -ResourceGroupName $ResourceGroup.ResourceGroupName -VMName $_.Name -CommandId 'RunPowerShellScript' -ScriptPath qcainstall.ps1 -Parameter @{"ActivationId" = "REPLACE_ME";"CustomerId" = "REPLACE_ME"} -Confirm:$false
        }
        else {
            Write-Output "\nFor Linux Hosts"
            Write-Output $_.Name
            Get-AzureStorageBlobContent -Blob LinuxQCA.sh -Container $ContainerName -Destination qcainstall.sh -Context $StorageContext -Confirm:$false
            #wget "REPLACE_ME" -UseBasicParsing -outfile qcainstall.sh # if script is stored in public container
            Invoke-AzureRmVMRunCommand -ResourceGroupName $ResourceGroup.ResourceGroupName -VMName $_.Name -CommandId 'RunShellScript' -ScriptPath qcainstall.sh -Parameter @{"ActivationId"="REPLACE_ME"; "CustomerId"="REPLACE_ME"; "url_rpm"="REPLACE_ME"; "url_deb"="REPLACE_ME"} -Confirm:$false    
        }
    } 

} 