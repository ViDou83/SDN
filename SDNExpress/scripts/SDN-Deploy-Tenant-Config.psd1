@{
    ScriptVersion                     = "2.0"

    VHDPath                           = "C:\Template"
    VHDFile                           = "Win2019-Core.vhdx"
    VMLocation                        = "C:\ClusterStorage\S2D_CSV1\VMs"
    
    ProductKey                        = 'T99NG-BPP9T-2FX7V-TX9DP-8XFB4'

    VMMemory                          = 2GB
    VMProcessorCount                  = 2
    SwitchName                        = "SDNSwitch"

    TenantVMs = 
    @(
        @{
            ComputerName = 'Contoso-TestVM02'; 
            NICs         = @( 
                @{ Name = "Contoso-NetAdapter"; IPAddress = '172.16.1.11/24'; Gateway = '172.16.1.1'; DNS = @("172.16.1.53") ; VLANID = 0 };
            )   
        }
    )

    TenantGWs =
    @(
        @{
            Type                        = 'L3';
            VirtualGwName               = 'Contoso_vGW';
            LogicalNetworkName          = "Contoso_L3_Network";
            LogicalSunetName            = "Contoso_L3_Subnet";
            VLANID                      = 1001;
            LogicalSunetAddressPrefix   = "10.127.134.0/25";
            LogicalSunetDefaultGateways = "10.127.134.1";
            LocalIpAddrGW               = "10.127.134.55";
            PeerIpAddrGW                = @( "10.127.134.65" );
            RouteDstPrefix              = @( "1.1.1.1/32" );
            #BGP Router properties  
            BGPEnabled                  = $True;
            BgpLocalExtAsNumber         = "0.64512"   
            BgpLocalBRouterId           = "10.127.134.55"   
            BgpLocalRouterIP            = @("10.127.134.55")
            BgpPeerIpAddress            = "10.127.134.65"   
            BgpPeerAsNumber             = 64521   
            BgpPeerExtAsNumber          = "0.64521"   
        }
    )

    DomainFQDN = "contoso.local"

    RestURI                           = "https://NCFABRIC.SDN.LAB"

    TenantVirtualNetworkName            = "VNET-Tenant-Contoso"
    TenantVirtualNetworkAddressPrefix = @("172.16.1.0/16") 

    TenantVirtualSubnetId             = "VSUBNET-Tenant-Contoso-WebTier"
    TenantVirtualSubnetAddressPrefix  = @( "172.16.1.0/24" )

}