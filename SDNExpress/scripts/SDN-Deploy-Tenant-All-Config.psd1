@{
    ScriptVersion                     = "2.0"

    VHDPath                           = "F:\VMs\Template"
    VHDFile                           = "Win2019-Core.vhdx"
    VMLocation                        = "C:\ClusterStorage\S2D_CSV1\VMs"
    
    ProductKey                        = 'T99NG-BPP9T-2FX7V-TX9DP-8XFB4'

    VMMemory                          = 2GB
    VMProcessorCount                  = 2
    SwitchName                        = "SDNSwitch"

    HYPV                              = @("SDN-HOST01.SDN.LAB","SDN-HOST02.SDN.LAB")

    DomainJoinUserName                = "SDN\adminisrator"
    LocalAdminDomainUser              = "SDN\adminisrator"

    Tenants                           = 
    @(
        @{
            Name                              = "Contoso";
            TenantVirtualNetworkName          = "VNET-Tenant-Contoso"
            TenantVirtualNetworkAddressPrefix = @("172.16.1.0/16") 

            TenantVirtualSubnetId             = "VSUBNET-Tenant-Contoso-WebTier"
            TenantVirtualSubnetAddressPrefix  = @( "172.16.1.0/24" )
            DomainFQDN                        = "contoso.local"
        
        },
        @{
            Name                              = "Fabrikam";
            TenantVirtualNetworkName          = "VNET-Tenant-Fabrikam"
            TenantVirtualNetworkAddressPrefix = @("172.16.1.0/16") 

            TenantVirtualSubnetId             = "VSUBNET-Tenant-Fabrikam-WebTier"
            TenantVirtualSubnetAddressPrefix  = @( "172.16.1.0/24" )
            DomainFQDN                        = "fabrikam.local"

        }
    )

    TenantVMs = 
    @(
        @{
            HypvHostname = "SDN-HOST01.SDN.LAB"
            Tenant       = "Contoso"
            ComputerName = 'Contoso-TestVM01'
            NICs         = @( 
                                @{ 
                                    Name = "Contoso-NetAdapter"; IPAddress = '172.16.1.10/24'; Gateway = '172.16.1.1'; 
                                    DNS = @("172.16.1.53") ; MACAddress = '00-00-00-00-00-00'; VLANID = 0 
                                };
                            )   
        },
        @{
            HypvHostname = "SDN-HOST02.SDN.LAB"
            Tenant       = "Contoso"
            ComputerName = 'Contoso-TestVM02'
            NICs         = @( 
                                @{ 
                                    Name = "Contoso-NetAdapter"; IPAddress = '172.16.1.11/24'; Gateway = '172.16.1.1'; 
                                    DNS = @("172.16.1.53") ; MACAddress = '00-00-00-00-00-00'; VLANID = 0 
                                };
                            )   
        },
        @{
            HypvHostname = "SDN-HOST01.SDN.LAB"
            Tenant       = "Fabrikam"
            ComputerName = 'Fabrikam-TestVM01'
            NICs         = @( 
                                @{ 
                                    Name = "Fabrikam-NetAdapter"; IPAddress = '172.16.1.10/24'; Gateway = '172.16.1.1'; 
                                    DNS = @("172.16.1.53") ; MACAddress = '00-00-00-00-00-00'; VLANID = 0 
                                };
                            )
        },
        @{
            HypvHostname = "SDN-HOST02.SDN.LAB"
            Tenant       = "Fabrikam"            
            ComputerName = 'Fabrikam-TestVM02'
            NICs         = @( 
                                @{ 
                                    Name = "Fabrikam-NetAdapter"; IPAddress = '172.16.1.11/24'; Gateway = '172.16.1.1'; 
                                    DNS = @("172.16.1.53") ; MACAddress = '00-00-00-00-00-00'; VLANID = 0 
                                };
                            )   
        }
    )

    TenantGWs =
    @(
        @{
            Tenant                      = "Contoso"
            Type                        = 'L3'
            VirtualGwName               = 'Contoso_vGW'
            LogicalNetworkName          = "Contoso_L3_Network"
            LogicalSunetName            = "Contoso_L3_Subnet"
            VLANID                      = 1001;
            LogicalSunetAddressPrefix   = "10.127.134.0/25"
            LogicalSunetDefaultGateways = "10.127.134.1"
            LocalIpAddrGW               = "10.127.134.55"
            PeerIpAddrGW                = @( "10.127.134.65" )
            RouteDstPrefix              = @( "0.0.0.0/0" )
            #BGP Router properties  
            BGPEnabled                  = $True;
            BgpLocalExtAsNumber         = "0.64512"   
            BgpLocalBRouterId           = "10.127.134.55"   
            BgpLocalRouterIP            = @("10.127.134.55")
            BgpPeerIpAddress            = "10.127.134.65"   
            BgpPeerAsNumber             = 64521   
            BgpPeerExtAsNumber          = "0.64521"   
        },
        @{
            Tenant              = "Fabrikam";
            Type                = 'GRE';
            VirtualGwName       = 'Fabrikam_vGW';
            RouteDstPrefix      = @( "0.0.0.0/0" )
            #BGP Router properties  
            PSK                 = "1234"
            GrePeer             = "1.1.1.1"
            BGPEnabled          = $true;
            BgpLocalExtAsNumber = "0.64512"   
            BgpLocalBRouterId   = "Fabrikam_vGW"   
            BgpLocalRouterIP    = @("2.2.2.2")
            BgpPeerIpAddress    = "172.16.254.50"   
            BgpPeerAsNumber     = 64521   
            BgpPeerExtAsNumber  = "0.64521"   
        }
    )


    RestURI = "https://NCFABRIC.SDN.LAB"

}