﻿#https://docs.microsoft.com/fr-fr/windows-server/storage/storage-spaces/deploy-standalone-storage-spaces
$VDiskResdiliency = "Simple"

$disks = Get-physicaldisk | where canpool -eq $true
$StoragePool = Get-StorageSubsystem | New-StoragePool -Friendlyname MyPool -PhysicalDisks $disks
    
$virtualDisk = new-VirtualDisk –StoragePoolFriendlyName $StoragePool.FriendlyName –FriendlyName VirtualDisk1 –ResiliencySettingName $VDiskResiliency –UseMaximumSize -NumberOfColumns $disks.Count

Get-VirtualDisk –FriendlyName $virtualDisk.FriendlyName | Get-Disk | Initialize-Disk –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume

#Install HYPV
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart