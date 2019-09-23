Param(
    [string]$VMName,
    [string]$VMSize,
    [int]$DiskNumber,
    [int]$DiskSizeGB
)

Import-Module -Name Az.Compute

$Connected = Get-AzSubscription -ErrorAction Continue -OutVariable null
if ( $Connected ) {
    "Already connected to the subscription"
}
else {
    Connect-AzAccount
}


$ForbiddenChar = @("-", "_", "\", "/", "@", "<", ">", "#")

# Credentials for Local Admin account you created in the sysprepped (generalized) vhd image
$VMLocalAdminUser = "vidou"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "Azertyuiop!01" -AsPlainText -Force 
## Azure Account
$LocationName = "FranceCentral"
$ResourceGroupName = "RG-AZ-FRANCE"
$VnetName = "VNET1-AZ-FRANCE"
$SubnetName = "SUB-ARM-SRV-WIN"
$SecurityGroupName = "$($VMName)_NetSecurityGroup"
$PublicIPAddressName = "$($VMName)_PIP1"
$subscription = "Microsoft Azure Internal Consumption"
$VMSize = "Standard_E8_v3"
$NICName = "$($VMName)_NIC1"
$DNSNameLabel = $VMName
$storageType = 'StandardSSD_LRS'

$NSGName = "NSG-AZ-FRANCE" 

foreach ($c in $ForbiddenChar) { $DNSNameLabel = $DNSNameLabel.ToLower().replace($c, "") }

$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword) 

$VNET = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName
if ( $VNET -eq $null) {
    Write-Host -ForegroundColor Yellow "No VNET found in $ResourceGroupName so going to create one"
    
    $SubnetName = Read-Host "SubnetName(ex:MySubnet)"
    $VnetAddressPrefix = Read-Host "Prefix(ex:10.0.0.0/16)"
    $SubnetAddressPrefix = Read-Host "Prefix(ex:10.0.0.0/24)"
    $SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName `
        -AddressPrefix $SubnetAddressPrefix

    $VNET = New-AzVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName `
        -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet

}

$NSG = Get-AzNetworkSecurityGroup -ResourceName $NSGName -ResourceGroupName $ResourceGroupName 

$PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName `
    -Location $LocationName -AllocationMethod Dynamic -Force

$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName `
    -Location $VNET.Location -SubnetId $VNET.Subnets[0].Id -PublicIpAddressId $PIP.Id `
    -NetworkSecurityGroupId $NSG.Id -Force

    
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName `
                    -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' `
                    -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest    
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMOSDisk -StorageAccountType $storageType -VM $VirtualMachine -CreateOption "FromImage"

Write-Host -ForegroundColor Green "Creating the AZ VM $VMName"

New-AzVm -ResourceGroupName $ResourceGroupName -Location $LocationName `
    -VM $VirtualMachine -Verbose    

Write-Host -ForegroundColor Green "AZ VM $VMName successfully created"

$VirtualMachine = get-AzVm -VMName $VMName

$VirtualMachine | Stop-AzVM -Force

Write-Host -ForegroundColor Green "AZ VM $VMName successfully stopped to add SSD data disk"

$AzDiskConfig = New-AzDiskConfig -Location $LocationName -DiskSizeGB $DiskSizeGB `
    -AccountType $storageType -CreateOption Empty 

for ($i = 0; $i -lt $DiskNumber; $i++) {
    $AzDisk = New-AzDisk -ResourceGroupName $ResourceGroupName -Disk $AzDiskConfig `
        -DiskName "$($VMName)_DataDisk$i"
    $VirtualMachine = Add-AzVMDataDisk -Name "$($VMName)_DataDisk$i" -Caching 'ReadWrite' -Lun $i `
        -ManagedDiskId $AzDisk.Id -CreateOption Attach -VM $VirtualMachine
    Write-Host -ForegroundColor Green "AZ VM $VMName SSD Disk $i successfully added"
        
}

Update-AzVM -ResourceGroupName $ResourceGroupName -VM $VirtualMachine

Write-Host -ForegroundColor Green "AZ VM $VMName  successfully updated"

$VirtualMachine | Start-AzVM

Write-Host -ForegroundColor Green "AZ VM $VMName is running and can be RDP on $($PIP.DnsSettings.Fqdn)"
Write-Host "mstsc /v:$($PIP.DnsSettings.Fqdn)"
