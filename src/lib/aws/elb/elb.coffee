define [ 'constant', 'MC' ], ( constant, MC ) ->

	#private
	init = (uid) ->

		elbComp = MC.canvas_data.component[uid]

		# init
		newELBName = MC.aws.elb.getNewName()
		MC.canvas_data.component[uid].resource.LoadBalancerName = newELBName
		MC.canvas_data.component[uid].name = newELBName
		MC.canvas.update uid, 'text', 'elb_name', newELBName

		allComp = MC.canvas_data.component
		vpcUIDRef = elbComp.resource.VpcId

		defaultVPC = false
		if MC.aws.aws.checkDefaultVPC()
			defaultVPC = true

		if !vpcUIDRef and !defaultVPC
			MC.canvas_data.component[uid].resource.Scheme = ''

		# have igw ?
		# igwCompAry = _.filter allComp, (obj) ->
		# 	obj.type is 'AWS.VPC.InternetGateway'
		# if igwCompAry.length isnt 0
		# 	MC.canvas_data.component[uid].resource.Scheme = 'internet-facing'
		# else
		# 	MC.canvas_data.component[uid].resource.Scheme = 'internal'

		# create elb default sg

		if MC.aws.vpc.getVPCUID() or defaultVPC
			sgComp = $.extend(true, {}, MC.canvas.SG_JSON.data)
			sgComp.uid = MC.guid()
			sgComp.name = newELBName + '-sg'
			sgComp.resource.GroupDescription = 'Automatically created SG for load-balancer'
			sgComp.resource.GroupName = sgComp.name

			if vpcUIDRef then sgComp.resource.VpcId = vpcUIDRef

			MC.canvas_data.component[sgComp.uid] = sgComp

			sgRef = '@' + sgComp.uid + '.resource.GroupId'
			MC.canvas_data.component[uid].resource.SecurityGroups = [sgRef]

			# add rule to default sg
			MC.aws.elb.updateRuleToElbSG uid

			#add sg to MC.canvas_property.sg_list
			MC.aws.sg.addSGToProperty sgComp

		null

	getNewName = () ->
		maxNum = 0
		namePrefix = 'load-balancer-'
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is 'AWS.ELB'
				elbName = compObj.name
				if elbName.slice(0, namePrefix.length) is namePrefix
					currentNum = Number(elbName.slice(namePrefix.length))
					if currentNum > maxNum
						maxNum = currentNum
			null
		maxNum++
		return namePrefix + maxNum

	addInstanceAndAZToELB = (elbUID, instanceUID) ->
		elbComp = MC.canvas_data.component[elbUID]
		instanceComp = MC.canvas_data.component[instanceUID]

		currentInstanceAZ = instanceComp.resource.Placement.AvailabilityZone

		instanceUID = instanceComp.uid
		instanceRef = '@' + instanceUID + '.resource.InstanceId'

		elbInstanceAry = elbComp.resource.Instances
		elbInstanceAryLength = elbInstanceAry.length

		elbAZAry = elbComp.resource.AvailabilityZones
		elbAZAryLength = elbAZAry.length

		addInstanceToElb = true
		_.each elbInstanceAry, (elem, index) ->
			if elem.InstanceId is instanceRef
				addInstanceToElb = false
				null

		if addInstanceToElb
			MC.canvas_data.component[elbUID].resource.Instances.push({
				InstanceId: instanceRef
			})

		addAZToElb = true
		_.each elbAZAry, (elem, index) ->
			if elem is currentInstanceAZ
				addAZToElb = false
				null

		if addAZToElb
			MC.canvas_data.component[elbUID].resource.AvailabilityZones.push(currentInstanceAZ)

		# If current AZ has no subnet connects to the elb. connect the subnet to elb
		subnet_uid = "@" + subnet_uid + ".resource.SubnetId"

		for subnet, i in elbComp.resource.Subnets
			linkedSubnetID = MC.extractID( subnet )
			linkedSubnet   = MC.canvas_data.component[ linkedSubnetID ]

			if linkedSubnet.resource.AvailabilityZone == currentInstanceAZ
				alreadyLinkedSubnet = true
				break

		if !alreadyLinkedSubnet && instanceComp.resource.SubnetId
			elbComp.resource.Subnets.push instanceComp.resource.SubnetId
			return MC.extractID( instanceComp.resource.SubnetId )

		null

	removeInstanceFromELB = (elbUID, instanceUID) ->
		elbComp = MC.canvas_data.component[elbUID]
		instanceComp = MC.canvas_data.component[instanceUID]

		instanceUID = instanceComp.uid
		instanceRef = '@' + instanceUID + '.resource.InstanceId'

		elbInstanceAry = elbComp.resource.Instances
		elbInstanceAryLength = elbInstanceAry.length

		instanceAry = MC.canvas_data.component[elbUID].resource.Instances

		newInstanceAry = _.filter instanceAry, (value) ->
			if value.InstanceId is instanceRef
				false
			else
				true

		MC.canvas_data.component[elbUID].resource.Instances = newInstanceAry

		null

	setAllELBSchemeAsInternal = () ->
		_.each MC.canvas_data.component, (value, key) ->
			if value.type is 'AWS.ELB'
				MC.canvas_data.component[key].resource.Scheme = 'internal'
				MC.canvas.update key, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS
			null
		null

	addSubnetToELB = ( elb_uid, subnet_uid ) ->
		elb = MC.canvas_data.component[ elb_uid ]

		az_subnet_map = {}

		newSubnetAZ   = MC.canvas_data.component[ subnet_uid ].resource.AvailabilityZone

		subnet_uid = "@" + subnet_uid + ".resource.SubnetId"

		for subnet, i in elb.resource.Subnets
			linkedSubnetID = MC.extractID( subnet )
			linkedSubnet   = MC.canvas_data.component[ linkedSubnetID ]

			if linkedSubnet.resource.AvailabilityZone == newSubnetAZ
				replacedSubnet = linkedSubnetID
				elb.resource.Subnets[i] = subnet_uid

		if not replacedSubnet
			elb.resource.Subnets.push subnet_uid
			elb.resource.AvailabilityZones.push newSubnetAZ

		replacedSubnet

	removeSubnetFromELB = ( elb_uid, subnet_uid ) ->
		elb = MC.canvas_data.component[ elb_uid ]

		for subnet, i in elb.resource.Subnets
			if subnet.indexOf( subnet_uid ) != -1
				elb.resource.Subnets.splice i, 1
				break

		# Update resource.AvailabilityZones
		az_map = {}
		az_arr = []
		for subnet, i in elb.resource.Subnets
			az = MC.canvas_data.component[ MC.extractID( subnet ) ].resource.AvailabilityZone
			if az_map[ az ]
				continue

			az_map[ az ] = true
			az_arr.push az

		elb.resource.AvailabilityZones = az_arr
		null

	# Returns subnets that should be linked
	addLCToELB = ( elb_uid, lc_uid ) ->

		components = MC.canvas_data.component

		# Find ASG component
		for uid, comp of components
			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
				if comp.resource.LaunchConfigurationName.indexOf( lc_uid ) isnt -1
					asg = comp
					break

		if not asg
			return []

		# Insert ELB Uid into ASG component
		if asg.resource.LoadBalancerNames.join(" ").indexOf( elb_uid ) is -1
			asg.resource.LoadBalancerNames.push "@#{elb_uid}.resource.LoadBalancerName"


		elb_res = components[ elb_uid ].resource
		azs     = {}

		# --- Update Elb component
		#

		if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC or MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.DEFAULT_VPC
			# For Classic / Default VPC
			for az in elb_res.AvailabilityZones
				azs[ az ] = true

			for az in asg.resource.AvailabilityZones
				if not azs[ az ]
					elb_res.AvailabilityZones.push az

			return []
		else
			# For VPC

			# Find out ASG's az
			if asg.resource.VPCZoneIdentifier.length
				subnets = asg.resource.VPCZoneIdentifier.split ","
				subnets = _.map subnets, MC.extractID
			else
				subnets = []

			for sb in subnets
				if sb && components[ sb ]
					azs[ components[ sb ].resource.AvailabilityZone ] = sb

			# Ignore az that is connected to the elb
			for az in elb_res.AvailabilityZones
				delete azs[ az ]

			# Add subnets to the elb component
			subnets = []
			linkedSubnets = elb_res.Subnets.join " "
			for az, sb of azs
				elb_res.AvailabilityZones.push az
				if linkedSubnets.indexOf( sb ) is -1
					subnets.push sb
					elb_res.Subnets.push "@#{sb}.resource.SubnetId"


		# Returns subnets that should linked to the elb
		subnets

	removeASGFromELB = ( elb_uid, asg_uid ) ->
		asg = MC.canvas_data.component[ asg_uid ]
		names = asg.resource.LoadBalancerNames.join(" ").replace("@#{elb_uid}.resource.LoadBalancerName", "")
		asg.resource.LoadBalancerNames = if names.length is 0 then [] else names.split(" ")

		null


	updateRuleToElbSG = (elbUID) ->

		if !MC.aws.vpc.getVPCUID() then return

		elbComp = MC.canvas_data.component[elbUID]

		elbListenerAry = elbComp.resource.ListenerDescriptions

		listenerAry = []
		_.each elbListenerAry, (listenerObj) ->
			# protocol = listenerObj.Listener.Protocol.toLowerCase()
			port = listenerObj.Listener.LoadBalancerPort
			listenerAry.push {
				protocol: 'tcp',
				port: port
			}
			null
		listenerAry = _.uniq listenerAry

		elbDefaultSG = MC.aws.elb.getElbDefaultSG elbUID
		elbDefaultSGUID = elbDefaultSG.uid
		elbDefaultSGInboundRuleAry = elbDefaultSG.resource.IpPermissions

		# add rule to sg
		_.each listenerAry, (listenerObj) ->
			addListenerToRule = true
			removeListenerToRule = true
			_.each elbDefaultSGInboundRuleAry, (ruleObj) ->
				protocol = 'tcp' #ruleObj.IpProtocol
				port = ruleObj.FromPort
				if listenerObj.protocol is protocol and listenerObj.port is port
					addListenerToRule = false
					return
				null

			if addListenerToRule
				elbDefaultSGInboundRuleAry.push {
					FromPort: listenerObj.port,
					ToPort: listenerObj.port,
					IpProtocol: listenerObj.protocol,
					IpRanges: '0.0.0.0/0',
					Groups: [{
						GroupId: '',
						GroupName: '',
						UserId: ''
					}]
				}

			null

		# remove rule from sg
		elbDefaultSGInboundRuleAry = _.filter elbDefaultSGInboundRuleAry, (ruleObj) ->
			protocol = ruleObj.IpProtocol
			port = ruleObj.FromPort
			isInListener = false
			_.each listenerAry, (listenerObj) ->
				if listenerObj.protocol is protocol and listenerObj.port is port
					isInListener = true
				null
			return isInListener


		MC.canvas_data.component[elbDefaultSGUID].resource.IpPermissions = elbDefaultSGInboundRuleAry

	getElbDefaultSG = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		if !elbComp then return null
		elbName = elbComp.resource.LoadBalancerName
		elbSGName = elbName + '-sg'

		elbSGUID = ''
		allComp = MC.canvas_data.component
		_.each allComp, (compObj) ->
			if compObj.name is elbSGName
				elbSGUID = compObj.uid
				return

		return MC.canvas_data.component[elbSGUID]

	getAllElbSGUID = () ->

		elbSGUIDAry = []
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is 'AWS.ELB'
				elbSGObj = MC.aws.elb.getElbDefaultSG compObj.uid
				if elbSGObj then elbSGUIDAry.push elbSGObj.uid
			null

		return elbSGUIDAry

	removeELBDefaultSG = (elbUID) ->

		elbSGObj = MC.aws.elb.getElbDefaultSG(elbUID)
		if elbSGObj then delete MC.canvas_data.component[elbSGObj.uid]

	isELBDefaultSG = (sgUID) ->

		result = false
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is 'AWS.ELB'
				elbSGObj = MC.aws.elb.getElbDefaultSG compObj.uid
				if elbSGObj and elbSGObj.uid is sgUID
					result = true
			null

		return result

	removeAllELBForInstance = (instanceUID) ->

		originInstanceUIDRef = '@' + instanceUID + '.resource.InstanceId'
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is 'AWS.ELB'
				instanceAry = compObj.resource.Instances
				newInstanceAry = _.filter instanceAry, (instanceObj) ->
					instanceRef = instanceObj.InstanceId
					if instanceRef is originInstanceUIDRef
						return false
					else
						return true
				MC.canvas_data.component[compObj.uid].resource.Instances = newInstanceAry
			null

		null

	haveAssociateInAZ = (elbUID, azName) ->

		elbComp = MC.canvas_data.component[elbUID]
		elbInstances = elbComp.resource.Instances
		elbAZs = elbComp.resource.AvailabilityZones

		haveAssociate = false
		_.each elbInstances, (instanceObj) ->
			instanceUID = instanceObj.InstanceId.slice(1).split('.')[0]
			instanceComp = MC.canvas_data.component[instanceUID]
			instanceAZ = instanceComp.resource.Placement.AvailabilityZone
			if instanceAZ is azName
				haveAssociate = true

		return haveAssociate

	getAZAryForDefaultVPC = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		elbInstances = elbComp.resource.Instances
		azNameAry = []

		_.each elbInstances, (instanceRefObj) ->
			instanceRef = instanceRefObj.InstanceId
			instanceUID = instanceRef.slice(1).split('.')[0]
			instanceAZName = MC.canvas_data.component[instanceUID].resource.Placement.AvailabilityZone
			if !(instanceAZName in azNameAry)
				azNameAry.push(instanceAZName)
			null

		return azNameAry

	#public
	init                      : init
	addInstanceAndAZToELB     : addInstanceAndAZToELB
	removeInstanceFromELB     : removeInstanceFromELB
	setAllELBSchemeAsInternal : setAllELBSchemeAsInternal
	addSubnetToELB            : addSubnetToELB
	removeSubnetFromELB       : removeSubnetFromELB
	addLCToELB                : addLCToELB
	removeASGFromELB           :removeASGFromELB
	getNewName                : getNewName
	getElbDefaultSG           : getElbDefaultSG
	updateRuleToElbSG         : updateRuleToElbSG
	getAllElbSGUID            : getAllElbSGUID
	removeELBDefaultSG        : removeELBDefaultSG
	isELBDefaultSG            : isELBDefaultSG
	removeAllELBForInstance   : removeAllELBForInstance
	haveAssociateInAZ         : haveAssociateInAZ
	getAZAryForDefaultVPC     : getAZAryForDefaultVPC
