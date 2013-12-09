#*************************************************************************************
#* Filename     : coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:12
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'result_vo', 'constant', 'ebs_service', 'eip_service', 'instance_service'
		 'keypair_service', 'securitygroup_service', 'elb_service', 'iam_service', 'acl_service'
		 'customergateway_service', 'dhcp_service', 'eni_service', 'internetgateway_service', 'routetable_service'
		 'autoscaling_service', 'cloudwatch_service', 'sns_service',
		 'subnet_service', 'vpc_service', 'vpn_service', 'vpngateway_service', 'ec2_service', 'ami_service' ], (MC, result_vo, constant, ebs_service, eip_service, instance_service
		 keypair_service, securitygroup_service, elb_service, iam_service, acl_service
		 customergateway_service, dhcp_service, eni_service, internetgateway_service, routetable_service,
		 autoscaling_service, cloudwatch_service, sns_service,
		 subnet_service, vpc_service, vpn_service, vpngateway_service, ec2_service, ami_service) ->

	URL = '/aws/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "aws." + api_name + " callback is null"
			return false

		try

			MC.api {
				url     : URL
				method  : api_name
				data    : param_ary
				success : ( result, return_code ) ->

					#resolve result
					param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
					aws_result = {}
					aws_result = parser result, return_code, param_ary

					callback aws_result

				error : ( result, return_code ) ->

					aws_result = {}
					aws_result.return_code      = return_code
					aws_result.is_error         = true
					aws_result.error_message    = result.toString()

					param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
					aws_result.param = param_ary

					callback aws_result
			}

		catch error
			console.log "aws." + api_name + " error:" + error.toString()


		true
	# end of send_request


	#///////////////// Parser for quickstart return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveQuickstartResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser quickstart return)
	parserQuickstartReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveQuickstartResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserQuickstartReturn


	#///////////////// Parser for Public return (need resolve) /////////////////
	#private (resolve result to vo )
	resolvePublicResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser Public return)
	parserPublicReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolvePublicResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserPublicReturn


	#///////////////// Parser for info return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveInfoResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser info return)
	parserInfoReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveInfoResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserInfoReturn


	#///////////////// Parser for resource return (need resolve) /////////////////
	resourceMap = ( result ) ->
		responses = {
			"DescribeImagesResponse"               :   ami_service.resolveDescribeImagesResult
			"DescribeAvailabilityZonesResponse"    :   ec2_service.resolveDescribeAvailabilityZonesResult
			"DescribeVolumesResponse"              :   ebs_service.resolveDescribeVolumesResult
			"DescribeSnapshotsResponse"            :   ebs_service.resolveDescribeSnapshotsResult
			"DescribeAddressesResponse"            :   eip_service.resolveDescribeAddressesResult
			"DescribeInstancesResponse"            :   instance_service.resolveDescribeInstancesResult
			"DescribeKeyPairsResponse"             :   keypair_service.resolveDescribeKeyPairsResult
			"DescribeSecurityGroupsResponse"       :   securitygroup_service.resolveDescribeSecurityGroupsResult
			"DescribeLoadBalancersResponse"        :   elb_service.resolveDescribeLoadBalancersResult
			"DescribeNetworkAclsResponse"          :   acl_service.resolveDescribeNetworkAclsResult
			"DescribeCustomerGatewaysResponse"     :   customergateway_service.resolveDescribeCustomerGatewaysResult
			"DescribeDhcpOptionsResponse"          :   dhcp_service.resolveDescribeDhcpOptionsResult
			"DescribeNetworkInterfacesResponse"    :   eni_service.resolveDescribeNetworkInterfacesResult
			"DescribeInternetGatewaysResponse"     :   internetgateway_service.resolveDescribeInternetGatewaysResult
			"DescribeRouteTablesResponse"          :   routetable_service.resolveDescribeRouteTablesResult
			"DescribeSubnetsResponse"              :   subnet_service.resolveDescribeSubnetsResult
			"DescribeVpcsResponse"                 :   vpc_service.resolveDescribeVpcsResult
			"DescribeVpnConnectionsResponse"       :   vpn_service.resolveDescribeVpnConnectionsResult
			"DescribeVpnGatewaysResponse"          :   vpngateway_service.resolveDescribeVpnGatewaysResult
			#
			"DescribeAutoScalingGroupsResponse"            :   autoscaling_service.resolveDescribeAutoScalingGroupsResult
			"DescribeLaunchConfigurationsResponse"         :   autoscaling_service.resolveDescribeLaunchConfigurationsResult
			"DescribeNotificationConfigurationsResponse"   :   autoscaling_service.resolveDescribeNotificationConfigurationsResult
			"DescribePoliciesResponse"                     :   autoscaling_service.resolveDescribePoliciesResult
			"DescribeScheduledActionsResponse"             :   autoscaling_service.resolveDescribeScheduledActionsResult
			"DescribeScalingActivitiesResponse"            :   autoscaling_service.resolveDescribeScalingActivitiesResult
			"DescribeAlarmsResponse"                       :   cloudwatch_service.resolveDescribeAlarmsResult
			"ListSubscriptionsResponse"                    :   sns_service.resolveListSubscriptionsResult
			"ListTopicsResponse"                           :   sns_service.resolveListTopicsResult

		}

		dict = {}

		for node in result

			action_name = ($.parseXML node).documentElement.localName

			dict_name = action_name.replace /Response/i, ""

			dict[dict_name] = [] if dict[dict_name]?

			dict[dict_name] = responses[action_name] [null, node]

		dict


	#private (resolve result to vo )
	resolveResourceResult = ( result ) ->
		#resolve result
		#return vo
		res = {}
		res[region] = resourceMap nodes for region, nodes of result


		res

	#private (parser resource return)
	parserResourceReturn = ( result, return_code, param ) ->

		addition = param[5]
		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = result
			if addition isnt 'statistic'
				resolved_data = resolveResourceResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserResourceReturn


	#///////////////// Parser for price return (need resolve) /////////////////
	#private (resolve result to vo )
	resolvePriceResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser price return)
	parserPriceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolvePriceResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserPriceReturn


	#///////////////// Parser for status return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveStatusResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		$.parseJSON result[2]

	#private (parser status return)
	parserStatusReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveStatusResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserStatusReturn


	vpc_resource_map = {
		#"DescribeImagesResponse"               :   MC.aws.convert.resolveDescribeImagesResult
		"DescribeAvailabilityZones"    :   MC.aws.convert.convertAZ
		"DescribeVolumes"              :   MC.aws.convert.convertVolume
		#"DescribeSnapshots"            :   ebs_service.resolveDescribeSnapshotsResult
		"DescribeAddresses"            :   MC.aws.convert.convertEIP
		"DescribeInstances"            :   MC.aws.convert.convertInstance
		"DescribeKeyPairs"             :   MC.aws.convert.convertKP
		"DescribeSecurityGroups"       :   MC.aws.convert.convertSGGroup
		"DescribeLoadBalancers"        :   MC.aws.convert.convertELB
		"DescribeNetworkAcls"          :   MC.aws.convert.convertACL
		"DescribeCustomerGateways"     :   MC.aws.convert.convertCGW
		"DescribeDhcpOptions"          :   MC.aws.convert.convertDHCP
		"DescribeNetworkInterfaces"    :   MC.aws.convert.convertEni
		"DescribeInternetGateways"     :   MC.aws.convert.convertIGW
		"DescribeRouteTables"          :   MC.aws.convert.convertRTB
		"DescribeSubnets"              :   MC.aws.convert.convertSubnet
		"DescribeVpcs"                 :   MC.aws.convert.convertVPC
		"DescribeVpnConnections"       :   MC.aws.convert.convertVPN
		"DescribeVpnGateways"          :   MC.aws.convert.convertVGW
		#
		"DescribeAutoScalingGroups"            :   MC.aws.convert.convertASG
		"DescribeLaunchConfigurations"         :   MC.aws.convert.convertLC
		"DescribeNotificationConfigurations"   :   MC.aws.convert.convertNC
		"DescribePolicies"                     :   MC.aws.convert.convertScalingPolicy
		#"DescribeScheduledActionsResponse"             :   autoscaling_service.resolveDescribeScheduledActionsResult
		#"DescribeScalingActivitiesResponse"            :   autoscaling_service.resolveDescribeScalingActivitiesResult
		#"DescribeAlarmsResponse"                       :   cloudwatch_service.resolveDescribeAlarmsResult
		#"ListSubscriptionsResponse"                    :   sns_service.resolveListSubscriptionsResult
		#"ListTopicsResponse"                           :   sns_service.resolveListTopicsResult

	}

	#///////////////// Parser for vpc_resource return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveVpcResourceResult = ( result ) ->
		#resolve result
		#return vo

		vpc_resource_layout_map = {
			'AWS.EC2.AvailabilityZone'		: MC.canvas.AZ_JSON,
			'AWS.EC2.Instance' 				: MC.canvas.INSTANCE_JSON,
			'AWS.ELB' 						: MC.canvas.ELB_JSON,
			'AWS.EC2.EBS.Volume' 			: MC.canvas.VOLUME_JSON,
			'AWS.VPC.VPC' 					: MC.canvas.VPC_JSON,
			'AWS.VPC.Subnet'				: MC.canvas.SUBNET_JSON,
			'AWS.VPC.InternetGateway'		: MC.canvas.IGW_JSON,
			'AWS.VPC.RouteTable'			: MC.canvas.ROUTETABLE_JSON,
			'AWS.VPC.VPNGateway'			: MC.canvas.VGW_JSON,
			'AWS.VPC.CustomerGateway'		: MC.canvas.CGW_JSON,
			'AWS.VPC.NetworkInterface'		: MC.canvas.ENI_JSON,
			'AWS.VPC.DhcpOptions'			: MC.canvas.DHCP_JSON,
			'AWS.AutoScaling.Group'			: MC.canvas.ASG_JSON,
			'AWS.AutoScaling.LaunchConfiguration' : MC.canvas.ASL_LC_JSON
		}

		res = {}

		res[region] = resourceMap nodes for region, nodes of result

		app_json = $.extend true, {}, MC.canvas.STACK_JSON

		vpc_id = ""

		for region, nodes of res

			app_json.region = region

			for resource_type, resource_comp of nodes

				if resource_comp

					if resource_type is 'DescribeAvailabilityZones'

						for comp in resource_comp.item

							c = vpc_resource_map[resource_type] comp

							app_json.component[c.uid] = c
							# layout = vpc_resource_layout_map[c.type].layout

							# layout.name = c.name

							# todo: add vpc groud uid
							#layout.groupUId =

							# app_json.layout.component.group[c.uid] = layout

					else
						if resource_type is "DescribeVpcs"

							vpc_id = comp.vpcId

						for comp in resource_comp

							c = vpc_resource_map[resource_type] comp

							app_json.component[c.uid] = c

		ref_res = MC.aws.aws.collectReference app_json.component

		app_json.component = ref_res[0]

		ref_key = ref_res[1]

		vpc_uid = ref_key[vpc_id].split('.')[0].slice(1)

		for uid, c of app_json.component


			if vpc_resource_layout_map[c.type]

				# if c.type not in ['AWS.VPC.NetworkInterface', 'AWS.AutoScaling.Group', 'AWS.AutoScaling.LaunchConfiguration']

				# 	if c.type in ['AWS.VPC.Subnet', 'AWS.VPC.VPC']
				# 		app_json.layout.component.group[c.uid] = vpc_resource_layout_map[c.type].layout
				# 	else
				# 		app_json.layout.component.node[c.uid] = vpc_resource_layout_map[c.type].layout
				layout = vpc_resource_layout_map[c.type].layout

				layout.uid = c.uid

				switch c.type

					when 'AWS.VPC.NetworkInterface'

						layout.groupUId = c.resource.SubnetId.split('.')[0].slice(1)

						if c.resource.Attachment and c.resource.Attachment.DeviceIndex not in ['0', 0]

							app_json.layout.component.node[c.uid] = layout

						else if not c.resource.Attachment

							app_json.layout.component.node[c.uid] = layout

					when "AWS.AutoScaling.Group"

						if c.resource.AvailabilityZones.length != 1

							subnets = []

							if c.resource.VPCZoneIdentifier

								subs = c.resource.VPCZoneIdentifier.split(',')

								for subnet in subs

									subnets.push ref_key[subnet].split('.')[0].slice(1)

							for idx, zone of c.resource.AvailabilityZones

								if idx != 0

									extend_asg_uid = MC.guid()

									extend_asg = vpc_resource_layout_map[c.type].layout

									extend_asg.originalId = c.uid

									if subnets.length != 0

										extend_asg.groupUId = subnets[idx]

									else

										extend_asg.groupUId = zone.split('.')[0].slice(1)

									app_json.layout.component.group[extend_asg_uid] = extend_asg

						app_json.layout.component.group[c.uid] = vpc_resource_layout_map[c.type].layout


					when 'AWS.EC2.Instance'

						if c.resource.SubnetId

							layout.groupUId = c.resource.SubnetId.split('.')[0].slice(1)

						else

							layout.groupUId = c.resource.Placement.AvailabilityZone.split('.')[0].slice(1)

						app_json.layout.component.node[c.uid] = layout

					when 'AWS.AutoScaling.LaunchConfiguration'

						app_json.layout.component.node[c.uid] = vpc_resource_layout_map[c.type].layout

					when "AWS.EC2.AvailabilityZone"

						layout.name = c.name

						layout.groupUId = vpc_uid

						app_json.layout.component.group[c.uid] = layout

					when "AWS.VPC.Subnet"

						layout.groupUId = c.resource.AvailabilityZone.split('.')[0].slice(1)

						app_json.layout.component.group[c.uid] = layout

					when "AWS.VPC.VPC"

						app_json.layout.component.group[c.uid] = layout

					when "AWS.EC2.EBS.Volume"

						app_json.layout.component.node[c.uid] = layout

					else

						layout.groupUId = vpc_uid

						app_json.layout.component.node[c.uid] = layout

		console.log app_json

		#app_json.component = MC.aws.aws.collectReference app_json.component

		[app_json]

		#res

	#private (parser vpc_resource return)
	parserVpcResourceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveVpcResourceResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserVpcResourceReturn


	#///////////////// Parser for stat_resource return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveStatResourceResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser stat_resource return)
	parserStatResourceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserStatResourceReturn


	#############################################################

	#def quickstart(self, username, session_id, region_name):
	quickstart = ( src, username, session_id, region_name, callback ) ->
		send_request "quickstart", src, [ username, session_id, region_name ], parserQuickstartReturn, callback
		true

	#def public(self, username, session_id, region_name):
	Public = ( src, username, session_id, region_name, filters, callback ) ->
		send_request "public", src, [ username, session_id, region_name, filters ], parserPublicReturn, callback
		true

	#def info(self, username, session_id, region_name):
	info = ( src, username, session_id, region_name, callback ) ->
		send_request "info", src, [ username, session_id, region_name ], parserInfoReturn, callback
		true

	#def resource(self, username, session_id, region_name=None, resources=None):
	resource = ( src, username, session_id, region_name=null, resources=null, addition='all', retry_times=1, callback ) ->
		send_request "resource", src, [ username, session_id, region_name, resources, addition, retry_times ], parserResourceReturn, callback
		true

	#def price(self, username, session_id):
	price = ( src, username, session_id, callback ) ->
		send_request "price", src, [ username, session_id ], parserPriceReturn, callback
		true

	#def status(self, username, session_id):
	status = ( src, username, session_id, callback ) ->
		send_request "status", src, [ username, session_id ], parserStatusReturn, callback
		true

	#def vpc_resource(self, username, session_id, region_name, vpc_id):
	vpc_resource = ( src, username, session_id, region_name, vpc_id, callback ) ->
		send_request "vpc_resource", src, [ username, session_id, region_name, vpc_id ], parserVpcResourceReturn, callback
		true

	#def stat_resource(self, username, session_id, region_name=None, resources=None):
	stat_resource = ( src, username, session_id, region_name=null, resources=null, callback ) ->
		send_request "stat_resource", src, [ username, session_id, region_name, resources ], parserStatResourceReturn, callback
		true

	#############################################################
	#public
	quickstart                   : quickstart
	Public                       : Public
	info                         : info
	resource                     : resource
	price                        : price
	status                       : status
	vpc_resource                 : vpc_resource
	stat_resource                : stat_resource

