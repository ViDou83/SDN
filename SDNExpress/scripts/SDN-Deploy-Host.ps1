# --------------------------------------------------------------
#  Copyright © Microsoft Corporation.  All Rights Reserved.
#  Microsoft Corporation (or based on where you live, one of its affiliates) licenses this sample code for your internal testing purposes only.
#  Microsoft provides the following sample code AS IS without warranty of any kind. The sample code arenot supported under any Microsoft standard support program or services.
#  Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
#  The entire risk arising out of the use or performance of the sample code remains with you.
#  In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the code be liable for any damages whatsoever
#  (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss)
#  arising out of the use of or inability to use the sample code, even if Microsoft has been advised of the possibility of such damages.
# ---------------------------------------------------------------
<#
.SYNOPSIS 
    Deploys and configures the Microsoft SDN infrastructure, 
    including creation of the network controller, Software Load Balancer MUX 
    and gateway VMs.  Then the VMs and Hyper-V hosts are configured to be 
    used by the Network Controller.  When this script completes the SDN 
    infrastructure is ready to be fully used for workload deployments.
.EXAMPLE
    .\SDNExpress.ps1 -ConfigurationDataFile .\MyConfig.psd1
    Reads in the configuration from a PSD1 file that contains a hash table 
    of settings data.
.EXAMPLE
    .\SDNExpress -ConfigurationData $MyConfigurationData
    Uses the hash table that is passed in as the configuration data.  This 
    parameter set is useful when programatically generating the 
    configuration data.
.EXAMPLE
    .\SDNExpress 
    Displays a user interface for interactively defining the configuraiton 
    data.  At the end you have the option to save as a configuration file
    before deploying.
.NOTES
    Prerequisites:
    * All Hyper-V hosts must have Hyper-V enabled and the Virtual Switch 
    already created.
    * All Hyper-V hosts must be joined to Active Directory.
    * The physical network must be preconfigured for the necessary subnets and 
    VLANs as defined in the configuration data.
    * The VHD specified in the configuration data must be reachable from the 
    computer where this script is run. 
#>

[CmdletBinding(DefaultParameterSetName = "NoParameters")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "ConfigurationFile")]
    [String] $ConfigurationDataFile = $null,
    [Parameter(Mandatory = $true, ParameterSetName = "ConfigurationData")]
    [object] $ConfigurationData = $null,
    [Switch] $SkipValidation,
    [Switch] $SkipDeployment,
    [PSCredential] $DomainJoinCredential = $null,
    [PSCredential] $NCCredential = $null,
    [PSCredential] $LocalAdminCredential = $null
)    

import-module .\SDNExpressModule.psm1 -force
import-module .\SDN-Deploy-Module.psm1 -force

# Script version, should be matched with the config files
$ScriptVersion = "2.0"

#Validating passed in config files
if ($psCmdlet.ParameterSetName -eq "ConfigurationFile") {
    Write-Host "Using configuration file passed in by parameter."    
    $configdata = [hashtable] (iex (gc $ConfigurationDataFile | out-string))
}
elseif ($psCmdlet.ParameterSetName -eq "ConfigurationData") {
    Write-Host "Using configuration data object passed in by parameter."    
    $configdata = $configurationData 
}

if ($Configdata.ScriptVersion -ne $scriptversion) {
    Write-Host "Configuration file version $($ConfigData.ScriptVersion) is not compatible with this version of SDN express.  Please update your config file to match the version $scriptversion example."
    return
}

#Get credentials for provisionning

$DomainJoinPassword = GetPassword $ConfigData.DomainJoinSecurePassword $DomainJoinCredential "Enter credentials for joining VMs to the AD domain." $configdata.DomainJoinUserName
$LocalAdminPassword = GetPassword $ConfigData.LocalAdminSecurePassword $LocalAdminCredential "Enter the password for the local administrator of newly created VMs.  Username is ignored." "Administrator"

$DomainJoinUserNameDomain = $ConfigData.DomainJoinUserName.Split("\")[0]
$DomainJoinUserNameName = $ConfigData.DomainJoinUserName.Split("\")[1]
$LocalAdminDomainUserDomain = $ConfigData.LocalAdminDomainUser.Split("\")[0]
$LocalAdminDomainUserName = $ConfigData.LocalAdminDomainUser.Split("\")[1]


if ( $null -eq $ConfigData.VMProcessorCount) { $ConfigData.VMProcessorCount = 2 }
if ( $null -eq $ConfigData.VMMemory) { $ConfigData.VMMemory = 4GB }

$params = @{
    'VMLocation'          = $ConfigData.VMLocation;
    'VMName'              = '';
    'VHDSrcPath'          = $ConfigData.VHDPath;
    'VHDName'             = $ConfigData.VHDFile;
    'VMMemory'            = $ConfigData.VMMemory;
    'VMProcessorCount'    = $ConfigData.VMProcessorCount;
    'SwitchName'          = $ConfigData.SwitchName;
    'NICs'                = @();
    'CredentialDomain'    = $DomainJoinUserNameDomain;
    'CredentialUserName'  = $DomainJoinUserNameName;
    'CredentialPassword'  = $DomainJoinPassword;
    'JoinDomain'          = $ConfigData.DomainFQDN;
    'LocalAdminPassword'  = $LocalAdminPassword;
    'DomainAdminDomain'   = $LocalAdminDomainUserDomain;
    'DomainAdminUserName' = $LocalAdminDomainUserName;
    'IpGwAddr'            = $ConfigData.ManagementGateway;
    'DnsIpAddr'           = $ConfigDanoteta.ManagementDNS;
    'DomainFQDN'          = $ConfigData.DomainFQDN;
    'ProductKey'          = $ConfigData.ProductKey;
}

#Checking VMSwitch
$vmswitch = get-vmswitch
if ( $null -eq $vmswitch ) {
    throw "No virtual switch found on this host.  Please create the virtual switch before adding this host."
}    

if ( $vmswitch.name | Where-Object { -Name $params.SwitchName } ) { 
    Write-Host -ForegroundColor Green "VMSwitch $($params.SwitchName) found"
}
else {
    throw "No virtual switch $($params.SwitchName) found on this host.  Please create the virtual switch before adding this host."    
}


#Creating DC
foreach ( $dc in $configdata.DCs) {
    $params.VMName = $dc.ComputerName
    $params.Nics = $dc.NICs
    $params.VMMemory = 2GB
    $params.VMProcessorCount = 2
    $params.VHDName = "Win2019-GUI.vhdx"

    Write-Host -ForegroundColor Green "Step 1 - Creating DC VM $($dc.ComputerName)" 
    New-SdnVM @params 

    $password = $LocalAdminPassword | ConvertTo-SecureString -asPlainText -Force
    $LocalAdminCredential = New-Object System.Management.Automation.PSCredential(".\administrator", $password)

    $params = @{
        DomainName                    = $ConfigData.DomainFQDN
        DomainMode                    = 'WinThreshold'
        DatabasePath                  = "C:\Domain"
        DomainNetBiosName             = $($ConfigData.DomainFQDN).split(".")[0]
        SafeModeAdministratorPassword = $password
    }

    while ((Invoke-Command -VMName $dc.ComputerName -Credential $LocalAdminCredential { "Test" } `
                -ea SilentlyContinue) -ne "Test") { Start-Sleep -Seconds 1 }

    Install-ADDSForest  @params -InstallDns -Confirm -Force -NoRebootOnCompletion | Out-Null
}

#Creating HYPV Hosts
foreach ( $node in $configdata.HyperVHosts) {
    $params.VMName = $node.ComputerName
    $params.Nics = $node.NICs

    Write-Host -ForegroundColor Green "Step 1 - Creating Host VM $($node.ComputerName)" 
    New-SdnVM @params

    #required for nested virtualization 
    Get-VM -Name $node.ComputerName | Set-VMProcessor -ExposeVirtualizationExtensions $true | out-null
    #Required to allow multiple MAC per vNIC
    Get-VM -Name $node.ComputerName | Get-VMNetworkAdapter | Set-VMNetworkAdapter -MacAddressSpoofing On

    $password = $LocalAdminPassword | ConvertTo-SecureString -asPlainText -Force
    $LocalAdminCredential = New-Object System.Management.Automation.PSCredential(".\administrator", $password)

    Write-Host -ForegroundColor Green "Step 2 - Adding  VM DataDisk for S2D on $($node.ComputerName)" 
    Add-VMDataDisk $node.ComputerName $ConfigData.S2DDiskSize $ConfigData.S2DDiskNumber
 
    Write-Host -ForegroundColor Green  "Step 3 - Starting VM $($node.ComputerName)"
    Start-VM $node.ComputerName 

    Start-Sleep 120

    while ( $( Invoke-Command -VMName $node.ComputerName -Credential $LocalAdminCredential { (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain }) -ne $true ) {
        Start-Sleep 10
        Write-Host -ForegroundColor yellow "Waiting while the $($node.computername) has not joined  the domain $JoinDomain "
    }

    Write-Host -ForegroundColor Green  "Step 4 - Adding required features on VM $($node.ComputerName)"
    $FeatureList = "Hyper-V", "Failover-Clustering", "Data-Center-Bridging", "RSAT-Clustering-PowerShell", "Hyper-V-PowerShell", "FS-FileServer"
    Add-WindowsFeature $node.ComputerName $LocalAdminCredential $FeatureList 

    Start-Sleep 120    

    Invoke-Command -VMName $node.ComputerName -Credential $LocalAdminCredential {
        Write-Host -ForegroundColor Green "Step 5 - Adding SDN VMSwitch on $($env:COMPUTERNAME)"
        New-VMSwitch -NetAdapterName $(Get-Netadapter).Name  -SwitchName SDNSwitch -AllowManagementOS $true
        Get-VMNetworkAdapter -ManagementOS -Name SDNSwitch | Rename-VMNetworkAdapter -NewName MGMT
        Get-VMNetworkAdapter -ManagementOS -Name MGMT | Set-VMNetworkAdapterVlan -Access -VlanId $args[0]
    } -ArgumentList $Node.NICs[0].VLANID
    Get-VMNetworkAdapter -VMName $node.ComputerName | Set-VMNetworkAdapterVlan -Trunk -AllowedVlanIdList 7-11 -NativeVlanId 0
}

$password = $DomainJoinPassword | ConvertTo-SecureString -asPlainText -Force
$DomainJoinCredential = New-Object System.Management.Automation.PSCredential($ConfigData.DomainJoinUserName, $password)

Start-Sleep 5

Write-Host -ForegroundColor Green "Step 6 - Creating new S2D Failover cluster for Hyperconverged SDN"
New-SDNS2DCluster $ConfigData.HyperVHosts.ComputerName $DomainJoinCredential $ConfigData.S2DClusterIP $ConfigData.S2DClusterName 

Write-Host -ForegroundColor Green "SDN HyperConverged Cluster is ready. It's time to deploy the SDN Stack using SNDExpress script"