@{
    ScriptVersion = "2.0"

    VHDPath = "F:\VMs\Template"
    VHDFile = "Win2019-Core.vhdx"

    VMLocation = "F:\VMs"
    DomainFQDN = "SDN.LAB"

    ManagementSubnet = "10.184.108.0/24"
    ManagementGateway = "10.184.108.1"
    ManagementDNS = @("10.184.108.1")
    ManagementVLANID = 7

    DomainJoinUsername = "SDN\administrator"
    LocalAdminDomainUser = "SDN\administrator"

    DCs                  = 
    @(
        @{
            ComputerName = 'SDN-DC1'; 
            NICs         = @( 
                @{ Name = "MGMT"; IPAddress = '10.184.108.1/24'; Gateway = ''; DNS = @("10.184.108.1") ; VLANID = 7 };
            )   
        }
    )

    HyperVHosts = 
    @(
        @{
            ComputerName = 'SDN-HOST01'; 
            NICs         = @( 
                                @{ Name = "MGMT"; IPAddress = '10.184.108.2/24'; Gateway = '10.184.108.1'; DNS = @("10.184.108.1") ; VLANID = 7 };
                            )   
        },   
        @{
            ComputerName = 'SDN-HOST02'; 
            NICs         = @( 
                                @{ Name = "MGMT"; IPAddress = '10.184.108.3/24'; Gateway = '10.184.108.1'; DNS = @("10.184.108.1") ; VLANID = 7 };
                            )   
        }
    )

    S2DDiskSize     = 128GB
    S2DDiskNumber   = 3
    S2DClusterIP    = "10.184.108.4"
    S2DClusterName  = "HYPV-S2D-01"
    
    ProductKey = 'T99NG-BPP9T-2FX7V-TX9DP-8XFB4'

    # Switch name is only required if more than one virtual switch exists on the Hyper-V hosts.
    # SwitchName=''

    # Amount of Memory and number of Processors to assign to VMs that are created.
    # If not specified a default of 8 procs and 8GB RAM are used.
    VMMemory = 24GB
    VMProcessorCount = 4
    MEM_DC = 2GB                                     # Memory provided for the Domain Controller VM


    SwitchName           = "SDN"

    # If Locale and Timezone are not specified the local time zone of the deployment machine is used.
    # Locale           = ''
    # TimeZone         = ''

    # Passowrds can be optionally included if stored encrypted as text encoded secure strings.  Passwords will only be used
    # if SDN Express is run on the same machine where they were encrypted, otherwise it will prompt for passwords.
    # DomainJoinSecurePassword  = ''
    # LocalAdminSecurePassword   = ''
    # NCSecurePassword   = ''

}