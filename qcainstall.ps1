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
            Get-AzureStorageBlobContent -Blob WindowsQCA.ps1 -Container $ContainerName -Destination qcainstall.ps1 -Context $StorageContext
            #wget "https://csg88d63f93fad0x471dx88f.blob.core.windows.net/containermiktest/WindowsQCA.ps1" -UseBasicParsing -outfile qcainstall.ps1
            Invoke-AzureRmVMRunCommand -ResourceGroupName $ResourceGroup.ResourceGroupName -VMName $_.Name -CommandId 'RunPowerShellScript' -ScriptPath qcainstall.ps1 -Parameter @{"ActivationId" = "e84764e1-e219-4b59-8586-e781d3f621dd";"CustomerId" = "8a72be28-4fe4-7b79-838d-b5672cd680ab"} -Confirm:$false
        }
        else {
        #    Write-Output "\nFor Linux Hosts"
        #    Write-Output $_.Name
        #    wget "https://csg88d63f93fad0x471dx88f.blob.core.windows.net/containermiktest/LinuxQCA.sh" -UseBasicParsing -outfile qcainstall.sh
        #    Invoke-AzureRmVMRunCommand -ResourceGroupName $ResourceGroup.ResourceGroupName -VMName $_.Name -CommandId 'RunShellScript' -ScriptPath .\qcainstall.sh -Parameter @{"a"="e84764e1-e219-4b59-8586-e781d3f621dd"; "b"="8a72be28-4fe4-7b79-838d-b5672cd680ab"; "c"="https://csg88d63f93fad0x471dx88f.blob.core.windows.net/containermiktest/qualys-cloud-agent.x86_64_qg2.rpm"; "d"="https://csg88d63f93fad0x471dx88f.blob.core.windows.net/containermiktest/qualys-cloud-agent.x86_64_qg2.deb"} -Confirm:$false    
        }
    } 

} 