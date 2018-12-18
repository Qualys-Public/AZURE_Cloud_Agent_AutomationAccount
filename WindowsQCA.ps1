param (
    [string]$ActivationId, 
    [string]$CustomerId,    
    [string]$Downloadlocation = "c:\temp"
)

	if (Get-Service \"QualysAgent\" -ErrorAction SilentlyContinue)
		{
		Write-Host \"Qualys Cloud Agent is already installed, Exiting\"
		exit 0
		}
	if (!(Test-Path $Downloadlocation))
		{
		New-Item -ItemType Directory $Downloadlocation -ErrorAction SilentlyContinue | out-null
		}
	Set-Location -Path $Downloadlocation
	$uri = "https://s3.amazonaws.com/qualys-agent-deploy/QualysCloudAgent.exe"
	Write-Host -ForegroundColor White "==>Downloading from $uri"   

	try
		{
			$downloadlink = Invoke-WebRequest -Uri $uri -OutFile QualysCloudAgent.exe
			$Downloadfile = Join-Path $Downloadlocation "QualysCloudAgent.exe"
		}
	catch
		{
		Write-Host $_.Exception|format-list -force
		Write-Warning "Error While Downloading the file"
		Break
		}
	try
		{
		& $Downloadfile CustomerId=$CustomerId ActivationId=$ActivationId
		}
	Catch
		{
		Write-Host \"Installation failed, exception raised during installation\"
		Write-Host $_.Exception|format-list -force
		exit 6
		}
