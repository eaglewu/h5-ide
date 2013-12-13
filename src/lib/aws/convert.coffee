define [ 'MC', 'constant', 'underscore', 'jquery' ], ( MC, constant, _, $ ) ->



	mapProperty = ( aws_json, madeira_json ) ->

		for k, v of aws_json

			if typeof(v) is "string" and madeira_json.resource[k[0].toUpperCase() + k.slice(1)] isnt undefined

				madeira_json.resource[k[0].toUpperCase() + k.slice(1)] = v

		madeira_json

	convertEni = ( aws_eni ) ->
		# {
		# 	"uid": "",
		# 	"type": "AWS.VPC.NetworkInterface",
		# 	"name": "eni1", //if number >1 then it's server group name
		# 	"serverGroupUid": "", 	//uid of servergroup(index is 0)
		# 	"serverGroupName": "",  //name of servergroup
		# 	"number": 1,			//if number >1 then it's server group
		# 	"index": 0, 			//index in server group
		# 	"resource":
		# 	{
		# 		"PrivateIpAddressSet": [
		# 		{
		# 			"Association":
		# 			{
		# 				"AssociationID": "",
		# 				"PublicDnsName": "",
		# 				"AllocationID": "",
		# 				"InstanceId": "",
		# 				"IpOwnerId": "",
		# 				"PublicIp": ""
		# 			},
		# 			"PrivateIpAddress": "10.0.0.1",
		# 			"AutoAssign": "true",
		# 			"Primary": "true"
		# 		}],
		# 		"Status": "",
		# 		"GroupSet": [
		# 		//{
		# 		//	"GroupId": "", //eg: @B70030F1-0107-B526-8022-14C0BBD50CC1.resource.GroupId
		# 		//	"GroupName": "" //eg: @B70030F1-0107-B526-8022-14C0BBD50CC1.resource.GroupName
		# 		//}
		# 		],
		# 		"PrivateDnsName": "",
		# 		"SourceDestCheck": "true",
		# 		"RequestId": "",
		# 		"MacAddress": "",
		# 		"OwnerId": "",
		# 		"RequestManaged": "",
		# 		"SecondPriIpCount": "",
		# 		"Attachment":
		# 		{
		# 			"InstanceId": "", //eg: @D673A590-1897-12F8-D1F3-14C116707F9A.resource.InstanceId
		# 			"AttachmentId": "",
		# 			"DeviceIndex": "1",
		# 			"AttachTime": ""
		# 		},
		# 		"AvailabilityZone": "", //eg: ap-northeast-1b
		# 		"SubnetId": "", //eg: @E2236992-27D1-97CA-4B03-14C0C485E033.resource.SubnetId
		# 		"Description": "",
		# 		"VpcId": "", //eg: @3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
		# 		"PrivateIpAddress": "",
		# 		"NetworkInterfaceId": ""
		# 	}
		# }
		eni_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.NetworkInterface",
			"name": if aws_eni.tagSet and aws_eni.tagSet.Name then aws_eni.tagSet.Name else aws_eni.networkInterfaceId,
			"serverGroupUid": "",
			"serverGroupName": "",
			"number": 1,
			"index": 0,
			"resource" : {
				"PrivateIpAddressSet" : [],
				"Status" : '',
				"GroupSet"	:	[],
				"PrivateDnsName": "",
				"SourceDestCheck": "",
				"RequestId": "",
				"MacAddress": "",
				"OwnerId": "",
				"RequestManaged": "",
				"SecondPriIpCount": "",
				"Attachment":{
						"DeviceIndex" : "",
						"InstanceId"	: "",
						"AttachmentId"	: "",
						"AttachTime"	: ""
					},
				"AvailabilityZone": "",
				"SubnetId": "",
				"Description": "",
				"VpcId": "",
				"PrivateIpAddress": "",
				"NetworkInterfaceId": ""

			}
		}

		if aws_eni.attachment and aws_eni.attachment.instanceOwnerId is "amazon-elb"

			return false

		if aws_eni.attachment
			eni_json.resource.Attachment.DeviceIndex = aws_eni.attachment.deviceIndex
			eni_json.resource.Attachment.InstanceId = aws_eni.attachment.instanceId
			eni_json.resource.Attachment.AttachmentId = aws_eni.attachment.attachmentId
			eni_json.resource.Attachment.AttachTime = aws_eni.attachment.attachTime

		for ip in aws_eni.privateIpAddressesSet.item

			eni_json.resource.PrivateIpAddressSet.push {"PrivateIpAddress": ip.privateIpAddress, "AutoAssign" : "false", "Primary" : ip.primary}


		for group in aws_eni.groupSet.item

			eni_json.resource.GroupSet.push {
				"GroupId": group.groupId,
				"GroupName": group.groupName
				}

		eni_json = mapProperty aws_eni, eni_json

		eni_json

	convertInstance = ( aws_instance ) ->

		instance_json = {
			"uid": MC.guid(),
			"type": "AWS.EC2.Instance",
			"name": if aws_instance.tagSet and aws_instance.tagSet.Name then aws_instance.tagSet.Name else aws_instance.instanceId,
			"serverGroupUid": "",
			"serverGroupName": "",
			"number": 1,
			"index": 0,
			"state": "",
			"software":	{},
			"resource":	{
				"RamdiskId": "",
				"InstanceId": "",
				"DisableApiTermination": "",
				"ShutdownBehavior": "",
				"SecurityGroupId": [],
				"SecurityGroup": [],
				"UserData":	{
					"Base64Encoded": "",
					"Data": ""
				},
				"ImageId": "",
				"Placement":{
					"Tenancy": "",
					"AvailabilityZone": "",
					"GroupName": ""
				},
				"PrivateIpAddress": "",
				"BlockDeviceMapping": [],
				"KernelId": "",
				"SubnetId": "",
				"KeyName": "",
				"VpcId": "",
				"InstanceType": "",
				"Monitoring": "",
				"EbsOptimized": "",
				"NetworkInterface":[]
			}
		}

		# for group in aws_eni.groupSet.item

		# 	eni_json.resource.GroupSet.push {
		#  		"GroupId": group.groupId,
		#  		"GroupName": group.groupName
		#  		}

		# todo
		# userdata

		instance_json.resource.Placement.AvailabilityZone = aws_instance.placement.availabilityZone

		instance_json.resource.Placement.Tenancy = aws_instance.placement.tenancy

		instance_json = mapProperty aws_instance, instance_json

		instance_json

	convertSGGroup = ( aws_sg ) ->

		sg_json = {
			"uid": MC.guid(),
			"type": "AWS.EC2.SecurityGroup",
			"name": aws_sg.groupName,
			"resource":	{
				"IpPermissions": [
				],
				"IpPermissionsEgress": [
				],
				"GroupId": "",
				"Default": "",
				"VpcId": "",
				"GroupName": "",
				"OwnerId": "",
				"GroupDescription": ''
			}
		}

		sg_json = mapProperty aws_sg, sg_json

		if aws_sg.ipPermissions

			for sg_rule in aws_sg.ipPermissions.item
				ipranges = ''
				if sg_rule.groups and sg_rule.groups.item[0].groupId
					ipranges = sg_rule.groups.item[0].groupId
				else if sg_rule.ipRanges
					ipranges = sg_rule.ipRanges.item[0].cidrIp

				if ipranges
					sg_json.resource.IpPermissions.push {
						"IpProtocol": sg_rule.ipProtocol,
						"IpRanges": ipranges,
						"FromPort": if sg_rule.fromPort then sg_rule.fromPort else "",
						"ToPort": if sg_rule.toPort then sg_rule.toPort else ""
					}

		if aws_sg.ipPermissionsEgress

			for sg_rule in aws_sg.ipPermissionsEgress.item
				ipranges = ''
				if sg_rule.groups and sg_rule.groups.item[0].groupId
					ipranges = sg_rule.groups.item[0].groupId
				else if sg_rule.ipRanges
					ipranges = sg_rule.ipRanges.item[0].cidrIp

				if ipranges
					sg_json.resource.IpPermissionsEgress.push {
						"IpProtocol": sg_rule.ipProtocol,
						"IpRanges": ipranges,
						"FromPort": if sg_rule.fromPort then sg_rule.fromPort else "",
						"ToPort": if sg_rule.toPort then sg_rule.toPort else ""
					}


		sg_json

	convertELB = ( aws_elb ) ->

		elb_json = {

			"uid": MC.guid(),
			"type": "AWS.ELB",
			"name": aws_elb.LoadBalancerName,
			"resource":	{
				"HealthCheck":{
					"Timeout": "5",
					"Target": "HTTP:80/index.html",
					"HealthyThreshold": "9",
					"UnhealthyThreshold": "4",
					"Interval": "30"
				},
				"Policies":	{
					"AppCookieStickinessPolicies": [],
					"OtherPolicies": [],
					"LBCookieStickinessPolicies": []
				},
				"BackendServerDescriptions": [],
				"SecurityGroups": [],
				"CreatedTime": "",
				"CanonicalHostedZoneNameID": "",
				"ListenerDescriptions": [],
				"DNSName": "",
				"Scheme": "",
				"CanonicalHostedZoneName": "",
				"Instances": [],
				"SourceSecurityGroup":{
					"OwnerAlias": "",
					"GroupName": ""
				},
				"Subnets": [],
				"VpcId": "",
				"LoadBalancerName": "",
				"AvailabilityZones": [],
				"CrossZoneLoadBalancing": "false"
			}
		}

		elb_json.resource.HealthCheck.Timeout = aws_elb.HealthCheck.Timeout
		elb_json.resource.HealthCheck.Interval = aws_elb.HealthCheck.Interval
		elb_json.resource.HealthCheck.UnhealthyThreshold = aws_elb.HealthCheck.UnhealthyThreshold
		elb_json.resource.HealthCheck.Target = aws_elb.HealthCheck.Target
		elb_json.resource.HealthCheck.HealthyThreshold = aws_elb.HealthCheck.HealthyThreshold

		if aws_elb.SecurityGroups
			for sg in aws_elb.SecurityGroups.member
				elb_json.resource.SecurityGroups.push sg

		if aws_elb.Subnets
			for subnet in aws_elb.Subnets.member
				elb_json.resource.Subnets.push subnet

		if aws_elb.VPCId
			elb_json.resource.VpcId = aws_elb.VPCId

		if aws_elb.AvailabilityZones
			for az in aws_elb.AvailabilityZones.member
				elb_json.resource.AvailabilityZones.push az

		if aws_elb.ListenerDescriptions
			for listener in aws_elb.ListenerDescriptions.member
				elb_json.resource.ListenerDescriptions.push {
					"PolicyNames": if listener.PolicyNames then listener.PolicyNames else '',
					"Listener":	{
						"LoadBalancerPort": listener.Listener.LoadBalancerPort,
						"InstanceProtocol": listener.Listener.InstanceProtocol,
						"Protocol": listener.Listener.Protocol,
						"SSLCertificateId": if listener.Listener.SSLCertificateId then listener.Listener.SSLCertificateId else "",
						"InstancePort": listener.Listener.InstancePort
					}
				}

		if aws_elb.Instances
			for ins in aws_elb.Instances.member
				elb_json.resource.Instances.push ins

		elb_json = mapProperty aws_elb, elb_json

		elb_json

	convertACL = ( aws_acl ) ->

		acl_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.NetworkAcl",
			"name": aws_acl.networkAclId,
			"resource": {
				"RouteTableId": "",
				"NetworkAclId": "",
				"VpcId": "",
				"Default": "",
				"EntrySet": [],
				"AssociationSet": []
			}
		}

		for acl in aws_acl.entrySet.item

			acl_json.resource.EntrySet.push {
				"RuleAction": acl.ruleAction,
				"Protocol": acl.protocol,
				"CidrBlock": acl.cidrBlock,
				"Egress": acl.egress,
				"IcmpTypeCode":{
					"Type": if acl.icmpTypeCode then acl.icmpTypeCode.type else "",
					"Code": if acl.icmpTypeCode then acl.icmpTypeCode.code else ""
				},
				"PortRange":{
					"To": if acl.portRange then acl.portRange.to else "",
					"From": if acl.portRange then acl.portRange.from else ""
				},
				"RuleNumber": acl.ruleNumber
			}

		if aws_acl.associationSet

			for acl in aws_acl.associationSet.item

				acl_json.resource.AssociationSet.push {
					"NetworkAclAssociationId": acl.networkAclAssociationId,
					"NetworkAclId": acl.networkAclId,
					"SubnetId": acl.subnetId
				}

		acl_json = mapProperty aws_acl, acl_json

		acl_json


	convertRTB = ( aws_rtb ) ->

		rtb_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.RouteTable",
			"name": aws_rtb.routeTableId,
			"resource":	{
				"VpcId": "",
				"PropagatingVgwSet": [],
				"RouteSet": [],
				"RouteTableId": "",
				"AssociationSet": []
			}
		}
		if aws_rtb.associationSet

			for asso in aws_rtb.associationSet.item

				rtb_json.resource.AssociationSet.push {
					"Main": asso.main,
					"RouteTableId": asso.routeTableId,
					"SubnetId": if asso.subnetId then asso.subnetId else "",
					"RouteTableAssociationId": asso.routeTableAssociationId
				}

		for route in aws_rtb.routeSet.item
			rtb_json.resource.RouteSet.push {
				'State' : route.state,
				'Origin': route.origin,
				'InstanceId': if route.instanceId then route.instanceId else "",
				'InstanceOwnerId': if route.instanceOwnerId then route.instanceOwnerId else "",
				'GatewayId' : if route.gatewayId then route.gatewayId else "",
				'NetworkInterfaceId' : if route.networkInterfaceId then route.networkInterfaceId else "",
				'DestinationCidrBlock' : route.destinationCidrBlock
			}

		if aws_rtb.propagatingVgwSet
			for prop in aws_rtb.propagatingVgwSet.item
				rtb_json.resource.PropagatingVgwSet.push prop.gatewayId

		rtb_json = mapProperty aws_rtb, rtb_json

		rtb_json

	convertSubnet = ( aws_subnet ) ->

		subnet_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.Subnet",
			"name": if aws_subnet.tagSet and aws_subnet.tagSet.Name then aws_subnet.tagSet.Name else aws_subnet.subnetId,
			"resource":	{
				"AvailabilityZone": "",
				"CidrBlock": "",
				"SubnetId": "",
				"VpcId": "",
				"AvailableIpAddressCount": "",
				"State": ""
			}
		}

		subnet_json = mapProperty aws_subnet, subnet_json

		subnet_json

	convertVPC = ( aws_vpc ) ->

		vpc_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.VPC",
			"name": if aws_vpc.tagSet and aws_vpc.tagSet.Name then aws_vpc.tagSet.Name else aws_vpc.vpcId,
			"resource":	{
				"EnableDnsHostnames": "",
				"DhcpOptionsId": "",
				"CidrBlock": "",
				"State": "",
				"InstanceTenancy": "",
				"VpcId": "",
				"IsDefault": "",
				"EnableDnsSupport": ""
			}
		}
		vpc_json = mapProperty aws_vpc, vpc_json

		vpc_json

	convertKP = ( aws_keypair ) ->

		kp_json = {
			"uid": MC.guid(),
			"type": "AWS.EC2.KeyPair",
			"name": aws_keypair.keyName,
			"resource":	{
				"KeyFingerprint": aws_keypair.keyFingerprint,
				"KeyName": aws_keypair.keyName
			}
		}

		kp_json

	convertVolume = ( aws_vol ) ->

		vol_json = {
			"uid": MC.guid(),
			"type": "AWS.EC2.EBS.Volume",
			"name": if aws_vol.attachmentSet then aws_vol.attachmentSet.item[0].device else "",
			"serverGroupUid": "",
			"serverGroupName": "",
			"number": 1,
			"index": 0,
			"resource": {
				"VolumeId": "",
				"CreateTime": "",
				"AvailabilityZone": "",
				"Size": "1",
				"Status": "",
				"SnapshotId": "",
				"Iops": "",
				"AttachmentSet":{
					"VolumeId": "",
					"Status": "",
					"AttachTime": "",
					"InstanceId": "",
					"DeleteOnTermination": "",
					"Device": ""
				},
				"VolumeType": "standard"
			}
		}

		if aws_vol.attachmentSet

			vol_json.resource.AttachmentSet.AttachTime = aws_vol.attachmentSet.item[0].attachTime
			vol_json.resource.AttachmentSet.Status = aws_vol.attachmentSet.item[0].status
			vol_json.resource.AttachmentSet.VolumeId = aws_vol.attachmentSet.item[0].volumeId
			vol_json.resource.AttachmentSet.InstanceId = aws_vol.attachmentSet.item[0].instanceId
			vol_json.resource.AttachmentSet.DeleteOnTermination = aws_vol.attachmentSet.item[0].deleteOnTermination
			vol_json.resource.AttachmentSet.Device = aws_vol.attachmentSet.item[0].device

		vol_json = mapProperty aws_vol, vol_json

		vol_json

	convertASG = ( aws_asg ) ->

		asg_json = {
			'type': 'AWS.AutoScaling.Group',
			'name': aws_asg.AutoScalingGroupName,
			'uid': MC.guid(),
			'resource': {
				'AutoScalingGroupARN': '',
				'AutoScalingGroupName': '',
				'AvailabilityZones': [],
				'CreatedTime': '',
				'DefaultCooldown': "",
				'DesiredCapacity': "",
				'EnabledMetrics': [],
				'HealthCheckGracePeriod': "",
				'HealthCheckType': "",
				'Instances': [],
				'LaunchConfigurationName': '',
				'LoadBalancerNames': [],
				'MaxSize': "2",
				'MinSize': "1",
				'PlacementGroup': '',
				'Status': '',
				'SuspendedProcesses': [],
				'Tags': '',
				'TerminationPolicies': [],
				'VPCZoneIdentifier': '',
				'InstanceId': '',
				'ShouldDecrementDesiredCapacity': ''
			}
		}
		if aws_asg.LoadBalancerNames
			asg_json.resource.LoadBalancerNames = aws_asg.LoadBalancerNames.member

		asg_json.resource.TerminationPolicies = aws_asg.TerminationPolicies.member
		asg_json.resource.AvailabilityZones = aws_asg.AvailabilityZones.member
		asg_json = mapProperty aws_asg, asg_json

		asg_json

	convertLC = ( aws_lc ) ->

		lc_json = {
			'name': aws_lc.LaunchConfigurationName,
			'uid': MC.guid(),
			'type': 'AWS.AutoScaling.LaunchConfiguration',
			'resource': {
				'BlockDeviceMapping': [],
				'CreatedTime': '',
				'EbsOptimized': '',
				'IamInstanceProfile': '',
				'ImageId': '',
				'InstanceMonitoring': '',
				'InstanceType': '',
				'KernelId': '',
				'KeyName': '',
				'LaunchConfigurationARN': '',
				'LaunchConfigurationName': '',
				'RamdiskId': '',
				'SecurityGroups': [],
				'SpotPrice': '',
				'UserData': ''
			}
		}
		lc_json.resource.SecurityGroups = aws_lc.SecurityGroups.member
		if aws_lc.BlockDeviceMappings
			lc_json.resource.BlockDeviceMapping = aws_lc.BlockDeviceMappings.member
		lc_json.resource.InstanceMonitoring = aws_lc.InstanceMonitoring.Enabled
		lc_json = mapProperty aws_lc, lc_json

		lc_json


	convertEIP = ( aws_eip ) ->

		eip_json = {
			"uid": MC.guid(),
			"type": "AWS.EC2.EIP",
			"name": "",
			"resource":	{
				"InstanceId": "",
				"PrivateIpAddress": "",
				"NetworkInterfaceId": "",
				"NetworkInterfaceOwnerId": "",
				"AllowReassociation": "",
				"Domain": "standard",
				"AssociationId": "",
				"PublicIp": "",
				"AllocationId": ""
			}
		}

		eip_json = mapProperty aws_eip, eip_json

		eip_json

	convertCGW = ( aws_cgw ) ->

		cgw_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.CustomerGateway",
			"name": aws_cgw.customerGatewayId,
			"resource":	{
				"Type": "",
				"BgpAsn": "",
				"CustomerGatewayId": "",
				"State": "",
				"IpAddress": ""
			}
		}

		cgw_json = mapProperty aws_cgw, cgw_json

		cgw_json

	convertIGW = ( aws_igw ) ->

		igw_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.InternetGateway",
			"name": "InternetGateway",
			"resource":	{
				"InternetGatewayId": aws_igw.internetGatewayId,
				"AttachmentSet": [{
					"VpcId": aws_igw.attachmentSet.item[0].vpcId,
					"State": aws_igw.attachmentSet.item[0].state
				}]
			}
		}

		#igw_json = mapProperty aws_igw, igw_json

		igw_json


	convertVGW = ( aws_vgw ) ->

		vgw_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.VPNGateway",
			"name": "VirtualPrivateGateway",
			"resource":	{
				"Attachments": [{
					"VpcId": aws_vgw.attachments.item[0].vpcId,
					"State": aws_vgw.attachments.item[0].state
				}],
				"Type": aws_vgw.type,
				#"AvailabilityZone": "",
				"VpnGatewayId": aws_vgw.vpnGatewayId,
				"State": aws_vgw.state
			}
		}

		vgw_json

	convertVPN = ( aws_vpn ) ->

		vpn_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.VPNConnection",
			"name": "VPN",
			"resource":	{
				"CustomerGatewayConfiguration": "",
				"Routes": [],
				"State": "",
				"Type": "ipsec.1",
				"VpnGatewayId": "",
				"Options":{
					"StaticRoutesOnly": "true"
				},
				"CustomerGatewayId": "",
				"VpnConnectionId": ""
			}
		}
		vpn_json.resource.Options.StaticRoutesOnly = aws_vpn.options.staticRoutesOnly
		if aws_vpn.routes
			for route in aws_vpn.routes

				vpn_json.resource.Routes.push {
					"DestinationCidrBlock" : route.destinationCidrBlock
					"Source" : route.source
					"State" : route.state
				}
		vpn_json = mapProperty aws_vpn, vpn_json

		vpn_json


	convertNC = ( aws_nc ) ->

		nc_json = {
			'type': 'AWS.AutoScaling.NotificationConfiguration',
			'name': '',
			'uid': MC.guid(),
			'resource': {
				'AutoScalingGroupName': aws_nc.AutoScalingGroupName,
				'NotificationType': aws_nc.NotificationType,
				'TopicARN': aws_nc.TopicARN
			}
		}
		nc_json

	convertScalingPolicy = ( aws_sp ) ->

		sp_json = {
			'type': 'AWS.AutoScaling.ScalingPolicy',
			'name': aws_sp.PolicyName,
			'uid': MC.guid(),
			'resource': {
				'AdjustmentType': "",
				'Alarms': [],
				'AutoScalingGroupName': '',
				'Cooldown': '',
				'MinAdjustmentStep': '',
				'PolicyARN': '',
				'PolicyName': '',
				'ScalingAdjustment': ''
			}
		}

		if aws_sp.Alarms
			sp_json.resource.Alarms = aws_sp.Alarms.member
		sp_json = mapProperty aws_sp, sp_json

		sp_json

	convertDHCP = ( aws_dhcp ) ->
		dhcp_json = {
			"uid": MC.guid(),
			"type": "AWS.VPC.DhcpOptions",
			"name": "default",
			"resource":	{
				"VpcId": "",
				"DhcpOptionsId": aws_dhcp.dhcpOptionsId,
				"DhcpConfigurationSet": []
			}
		}


		if aws_dhcp.dhcpConfigurationSet

			for dhcp in aws_dhcp.dhcpConfigurationSet.item
				value = []
				for valueset in dhcp.valueSet
					value.push {
						"Value": valueset
					}

				dhcp_json.resource.DhcpConfigurationSet.push {
					"Key": dhcp.key,
					"ValueSet": value
				}

		dhcp_json

	convertAZ = ( aws_az ) ->

		az_json = {
			'uid' : MC.guid(),
			"type": "AWS.EC2.AvailabilityZone",
			"name": aws_az.zoneName,
			"resource": {
				"ZoneName" : aws_az.zoneName
				"RegionName" : aws_az.regionName
			}
		}

		az_json


	convertAZ : convertAZ
	convertDHCP : convertDHCP
	convertScalingPolicy : convertScalingPolicy
	convertNC  : convertNC
	convertVPN : convertVPN
	convertVGW : convertVGW
	convertIGW : convertIGW
	convertCGW : convertCGW
	convertEIP : convertEIP
	convertLC : convertLC
	convertASG : convertASG
	convertVolume : convertVolume
	convertKP : convertKP
	convertVPC	: convertVPC
	convertSubnet : convertSubnet
	convertRTB : convertRTB
	convertACL : convertACL
	convertELB : convertELB
	convertSGGroup : convertSGGroup
	convertEni : convertEni
	convertInstance : convertInstance