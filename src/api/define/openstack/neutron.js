define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'os_neutron_List'                      : { type:'openstack', url:'/os/neutron/v2_0/neutron/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_neutron_V2_Info'                   : { type:'openstack', url:'/os/neutron/v2_0/neutron/',	method:'V2_Info',	params:['username', 'session_id', 'region']   },
		'os_neutron_V2_Extension'              : { type:'openstack', url:'/os/neutron/v2_0/neutron/',	method:'V2_Extension',	params:['username', 'session_id', 'region']   },
		'os_agent_List'                        : { type:'openstack', url:'/os/neutron/v2_0/agent/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_agent_Info'                        : { type:'openstack', url:'/os/neutron/v2_0/agent/',	method:'Info',	params:['username', 'session_id', 'region', 'agent_ids']   },
		'os_agentscheduler_ListNetworksOnDhcpAgent' : { type:'openstack', url:'/os/neutron/v2_0/agentscheduler/',	method:'ListNetworksOnDhcpAgent',	params:['username', 'session_id', 'region', 'agent_id']   },
		'os_agentscheduler_ListDhcpAgentsHostingNetwork' : { type:'openstack', url:'/os/neutron/v2_0/agentscheduler/',	method:'ListDhcpAgentsHostingNetwork',	params:['username', 'session_id', 'region', 'network_id']   },
		'os_agentscheduler_ListRoutersOnL3Agent' : { type:'openstack', url:'/os/neutron/v2_0/agentscheduler/',	method:'ListRoutersOnL3Agent',	params:['username', 'session_id', 'region', 'agent_id']   },
		'os_agentscheduler_ListL3AgentsHostingRouter' : { type:'openstack', url:'/os/neutron/v2_0/agentscheduler/',	method:'ListL3AgentsHostingRouter',	params:['username', 'session_id', 'region', 'router_id']   },
		'os_agentscheduler_ListPoolsOnLbaasAgent' : { type:'openstack', url:'/os/neutron/v2_0/agentscheduler/',	method:'ListPoolsOnLbaasAgent',	params:['username', 'session_id', 'region', 'agent_id']   },
		'os_agentscheduler_GetLbaasAgentHostingPool' : { type:'openstack', url:'/os/neutron/v2_0/agentscheduler/',	method:'GetLbaasAgentHostingPool',	params:['username', 'session_id', 'region', 'pool_id']   },
		'os_firewall_ListFirewall'             : { type:'openstack', url:'/os/neutron/v2_0/firewall/',	method:'ListFirewall',	params:['username', 'session_id', 'region', 'fw_id']   },
		'os_firewall_ListFirewallRule'         : { type:'openstack', url:'/os/neutron/v2_0/firewall/',	method:'ListFirewallRule',	params:['username', 'session_id', 'fw_rule_id']   },
		'os_firewall_ListFirewallPolicy'       : { type:'openstack', url:'/os/neutron/v2_0/firewall/',	method:'ListFirewallPolicy',	params:['username', 'session_id', 'region', 'fw_policy_id']   },
		'os_floatingip_List'                   : { type:'openstack', url:'/os/neutron/v2_0/floatingip/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_floatingip_Info'                   : { type:'openstack', url:'/os/neutron/v2_0/floatingip/',	method:'Info',	params:['username', 'session_id', 'region', 'fip_ids']   },
		'os_healthmonitor_List'                : { type:'openstack', url:'/os/neutron/v2_0/healthmonitor/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_healthmonitor_Info'                : { type:'openstack', url:'/os/neutron/v2_0/healthmonitor/',	method:'Info',	params:['username', 'session_id', 'region', 'health_monitor_ids']   },
		'os_loadbalancer_List'                 : { type:'openstack', url:'/os/neutron/v2_0/loadbalancer/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_loadbalancer_Info'                 : { type:'openstack', url:'/os/neutron/v2_0/loadbalancer/',	method:'Info',	params:['username', 'session_id', 'region', 'load_balancer_ids']   },
		'os_member_List'                       : { type:'openstack', url:'/os/neutron/v2_0/member/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_member_Info'                       : { type:'openstack', url:'/os/neutron/v2_0/member/',	method:'Info',	params:['username', 'session_id', 'region', 'member_ids']   },
		'os_metering_ListMeteringLabel'        : { type:'openstack', url:'/os/neutron/v2_0/metering/',	method:'ListMeteringLabel',	params:['username', 'session_id', 'region', 'metering_label_id']   },
		'os_metering_ListMeteringLabelRule'    : { type:'openstack', url:'/os/neutron/v2_0/metering/',	method:'ListMeteringLabelRule',	params:['username', 'session_id', 'region', 'rule_id']   },
		'os_network_List'                      : { type:'openstack', url:'/os/neutron/v2_0/network/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_network_Info'                      : { type:'openstack', url:'/os/neutron/v2_0/network/',	method:'Info',	params:['username', 'session_id', 'region', 'network_ids']   },
		'os_pool_List'                         : { type:'openstack', url:'/os/neutron/v2_0/pool/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_pool_Info'                         : { type:'openstack', url:'/os/neutron/v2_0/pool/',	method:'Info',	params:['username', 'session_id', 'region', 'pool_ids']   },
		'os_port_List'                         : { type:'openstack', url:'/os/neutron/v2_0/port/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_port_Info'                         : { type:'openstack', url:'/os/neutron/v2_0/port/',	method:'Info',	params:['username', 'session_id', 'region', 'port_ids']   },
		'os_neutron_quota_List'                : { type:'openstack', url:'/os/neutron/v2_0/quota/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_neutron_quota_def'                 : { type:'openstack', url:'/os/neutron/v2_0/quota/',	method:'def',	params:['self', 'username', 'session_id', 'region', 'quota_tenant_id', 'user_ids']   },
		'os_router_List'                       : { type:'openstack', url:'/os/neutron/v2_0/router/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_router_Info'                       : { type:'openstack', url:'/os/neutron/v2_0/router/',	method:'Info',	params:['username', 'session_id', 'region', 'router_ids']   },
		'os_securitygroup_List'                : { type:'openstack', url:'/os/neutron/v2_0/securitygroup/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_securitygroup_Info'                : { type:'openstack', url:'/os/neutron/v2_0/securitygroup/',	method:'Info',	params:['username', 'session_id', 'region', 'sg_ids']   },
		'os_securitygroup_ListSecurityGroupRule' : { type:'openstack', url:'/os/neutron/v2_0/securitygroup/',	method:'ListSecurityGroupRule',	params:['username', 'session_id', 'region', 'sg_rule_id']   },
		'os_subnet_List'                       : { type:'openstack', url:'/os/neutron/v2_0/subnet/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_subnet_Info'                       : { type:'openstack', url:'/os/neutron/v2_0/subnet/',	method:'Info',	params:['username', 'session_id', 'region', 'subnet_ids']   },
		'os_vip_List'                          : { type:'openstack', url:'/os/neutron/v2_0/vip/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_vip_Info'                          : { type:'openstack', url:'/os/neutron/v2_0/vip/',	method:'Info',	params:['username', 'session_id', 'region', 'listener_ids']   },
		'os_vpn_ListVPNService'                : { type:'openstack', url:'/os/neutron/v2_0/vpn/',	method:'ListVPNService',	params:['username', 'session_id', 'region', 'service_id']   },
		'os_vpn_ListIKEPolicy'                 : { type:'openstack', url:'/os/neutron/v2_0/vpn/',	method:'ListIKEPolicy',	params:['username', 'session_id', 'region', 'ikepolicy_id']   },
		'os_vpn_ListIPsecPolicy'               : { type:'openstack', url:'/os/neutron/v2_0/vpn/',	method:'ListIPsecPolicy',	params:['username', 'session_id', 'region', 'ipsecpolicy_id']   },
		'os_vpn_ListIPsecSiteConnection'       : { type:'openstack', url:'/os/neutron/v2_0/vpn/',	method:'ListIPsecSiteConnection',	params:['username', 'session_id', 'region', 'connection_id']   },
	}

	for ( var i in Apis ) {
		/* env:dev */
		if (ApiRequestDefs.Defs[ i ]){
			console.warn('api duplicate: ' + i);
		}
		/* env:dev:end */
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
