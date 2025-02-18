
@{
   ScriptVersion = '2.0'
   VHDPath = '\\2019-sdnv2\template'
   VHDFile = 'Win2019-Core.vhdx'
   VMLocation = 'C:\ClusterStorage\S2D_CSV1\VMs'
   JoinDomain = 'SDN.LAB'
   ManagementVLANID = '7'
   ManagementSubnet = '10.184.108.0/24'
   ManagementGateway = '10.184.108.1'
   ManagementDNS = @('10.184.108.1' )

   DomainJoinUsername = 'SDN\administrator'
   LocalAdminDomainUser = 'SDN\administrator'
   RestName = 'NCFabric.SDN.LAB'

   HyperVHosts = @('SDN-HOST01', 'SDN-HOST02' )

   NCs = @(
      @{
         ComputerName = 'SDN-NC01'
         HostName = 'SDN-HOST01'
         ManagementIP = '10.184.108.14'
         MACAddress = '00:1D:D8:B7:1C:00'
      },
      @{
         ComputerName = 'SDN-NC02'
         HostName = 'SDN-HOST02'
         ManagementIP = '10.184.108.15'
         MACAddress = '00-1D-D8-B7-1C-01'
      },
      @{
         ComputerName = 'SDN-NC03'
         HostName = 'SDN-HOST01'
         ManagementIP = '10.184.108.16'
         MACAddress = '00-1D-D8-B7-1C-02'
      }
   )
   Muxes = @(
      @{
         ComputerName = 'SDN-MUX01'
         HostName = 'SDN-HOST02'
         ManagementIP = '10.184.108.17'
         MACAddress = '00-1D-D8-B7-1C-03'
         PAIPAddress = '10.10.56.6'
         PAMACAddress = '00-1D-D8-B7-1C-04'
      },
      @{
         ComputerName = 'SDN-MUX02'
         HostName = 'SDN-HOST01'
         ManagementIP = '10.184.108.18'
         MACAddress = '00-1D-D8-B7-1C-05'
         PAIPAddress = '10.10.56.7'
         PAMACAddress = '00-1D-D8-B7-1C-06'         
      }
   )
   Gateways = @(
      @{
         ComputerName = 'SDN-GW01'
         HostName = 'SDN-HOST02'
         ManagementIP = '10.184.108.19'
         MACAddress = '00-1D-D8-B7-1C-07'
         FrontEndIp = '10.10.56.8'
         FrontEndMac = '00-1D-D8-B7-1C-08'
         BackEndMac = '00-1D-D8-B7-1C-09'         
      },
      @{
         ComputerName = 'SDN-GW02'
         HostName = 'SDN-HOST01'
         ManagementIP = '10.184.108.20'
         MACAddress = '00-1D-D8-B7-1C-0A'
         FrontEndIp = '10.10.56.9'
         FrontEndMac = '00-1D-D8-B7-1C-0B'
         BackEndMac = '00-1D-D8-B7-1C-0C'
      }
   )
 
   NCUsername = 'SDN\administrator'
 
   PAVLANID = '11'
   PASubnet = '10.10.56.0/23'
   PAGateway = '10.10.56.1'
   PAPoolStart = '10.10.56.8'
   PAPoolEnd = '10.10.56.254'

   SDNMacPoolStart = '00-1D-D8-B7-1C-0D'
   SDNMacPoolEnd = '00:1D:D8:B7:1F:FF'
   SDNASN = '64628'
   Routers = @(
      @{
         RouterASN = '64623'
         RouterIPAddress = '10.10.56.1'
      }
   )
   
   PrivateVIPSubnet = '20.20.20.0/27'
   PublicVIPSubnet = '41.40.40.0/27'
   PoolName = 'DefaultAll'
   GRESubnet = '192.168.0.0/24'
   Capacity = '10000'

   ProductKey       = 'T99NG-BPP9T-2FX7V-TX9DP-8XFB4'
    
   # Amount of Memory and number of Processors to assign to VMs that are created.
   # If not specified a default of 8 procs and 8GB RAM are used.
   VMMemory = 4GB
   VMProcessorCount = 2
    
   SwitchName= 'SDNSwitch'



}


