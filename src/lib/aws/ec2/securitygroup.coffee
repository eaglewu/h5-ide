define [ 'i18n!nls/lang.js', 'MC', 'constant' ], ( lang, MC, constant ) ->

	#private
	getAllRefComp = (sgUID) ->

		refNum = 0
		sgAry = []
		refCompAry = []
		_.each MC.canvas_data.component, (comp) ->
			compType = comp.type
			if compType is 'AWS.ELB' or compType is 'AWS.AutoScaling.LaunchConfiguration'
				sgAry = comp.resource.SecurityGroups
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.EC2.Instance'
				sgAry = comp.resource.SecurityGroupId
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.VPC.NetworkInterface'
				_sgAry = []
				_.each comp.resource.GroupSet, (sgObj) ->
					_sgAry.push sgObj.GroupId
					null

				sgAry = _sgAry
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID

				if sgUID in sgAry
					refCompAry.push comp
			null

		return refCompAry

	# delete and assign default sg when sglist is empty
	deleteRefInAllComp = (sgUID) ->

		refNum = 0
		sgAry = []
		refCompAry = []
		defaultSGComp = MC.aws.sg.getDefaultSG()
		defaultSGUID = defaultSGComp.uid

		# remove all ref in all comp
		_.each MC.canvas_data.component, (comp) ->
			compType = comp.type
			compUID = comp.uid

			if compType is 'AWS.ELB' or compType is 'AWS.AutoScaling.LaunchConfiguration'
				sgAry = comp.resource.SecurityGroups
				sgAry = _.filter sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					if sgUID is refSGUID
						return false
					else
						return true
				if sgAry.length is 0
					sgAry.push('@' + defaultSGUID + '.resource.GroupId')
				MC.canvas_data.component[compUID].resource.SecurityGroups = sgAry

				#update sg color label
				MC.aws.sg.updateSGColorLabel compUID

			if compType is 'AWS.EC2.Instance'

				# delete eni sg
				eniComp = MC.aws.eni.getInstanceDefaultENI(compUID)
				if eniComp
					eniSgAry = eniComp.resource.GroupSet
					eniSgAry = _.filter eniSgAry, (sgObj) ->
						refSGUID = sgObj.GroupId.slice(1).split('.')[0]
						if sgUID is refSGUID
							return false
						else
							return true
					if eniSgAry.length is 0
						eniSgAry.push({
							'GroupId': '@' + defaultSGUID + '.resource.GroupId',
							'GroupName': '@' + defaultSGUID + '.resource.GroupName'
						})
					MC.canvas_data.component[eniComp.uid].resource.GroupSet = eniSgAry

				# delete classic instance sg
				if !eniComp
					sgAry = comp.resource.SecurityGroupId
					sgAry = _.filter sgAry, (value) ->
						refSGUID = value.slice(1).split('.')[0]
						if sgUID is refSGUID
							return false
						else
							return true
					if sgAry.length is 0
						sgAry.push('@' + defaultSGUID + '.resource.GroupId')

					sgNameAry = comp.resource.SecurityGroup
					sgNameAry = _.filter sgNameAry, (value) ->
						refSGUID = value.slice(1).split('.')[0]
						if sgUID is refSGUID
							return false
						else
							return true
					if sgNameAry.length is 0
						sgNameAry.push('@' + defaultSGUID + '.resource.GroupName')

					MC.canvas_data.component[compUID].resource.SecurityGroupId = sgAry
					MC.canvas_data.component[compUID].resource.SecurityGroup = sgNameAry

				#update sg color label
				MC.aws.sg.updateSGColorLabel compUID

			if compType is 'AWS.VPC.NetworkInterface'
				sgAry = comp.resource.GroupSet
				sgAry = _.filter sgAry, (sgObj) ->
					refSGUID = sgObj.GroupId.slice(1).split('.')[0]
					if sgUID is refSGUID
						return false
					else
						return true
				if sgAry.length is 0
					sgAry.push({
						'GroupId': '@' + defaultSGUID + '.resource.GroupId',
						'GroupName': '@' + defaultSGUID + '.resource.GroupName'
					})
				MC.canvas_data.component[compUID].resource.GroupSet = sgAry

				#update sg color label
				MC.aws.sg.updateSGColorLabel compUID

			# remove all ref rule in all sg
			if compType is 'AWS.EC2.SecurityGroup'

				sgRuleRef = '@' + sgUID + '.resource.GroupId'

				sgInboundRuleAry = comp.resource.IpPermissions
				sgOutboundRuleAry = comp.resource.IpPermissionsEgress

				if sgInboundRuleAry
					newSgInboundRuleAry = _.filter sgInboundRuleAry, (ruleObj) ->
						if ruleObj.IpRanges is sgRuleRef
							return false
						return true
					MC.canvas_data.component[compUID].resource.IpPermissions = newSgInboundRuleAry

				if sgOutboundRuleAry
					newSgOutboundRuleAry = _.filter sgOutboundRuleAry, (ruleObj) ->
						if ruleObj.IpRanges is sgRuleRef
							return false
						return true
					MC.canvas_data.component[compUID].resource.IpPermissionsEgress = newSgOutboundRuleAry

			null

		

		return refCompAry

	getAllRule = (sgRes, isAppEdit) ->

		currentState = MC.canvas.getState()

		outboundRule = []
		if sgRes.ipPermissionsEgress
			outboundRule = sgRes.ipPermissionsEgress.item

		inboundRule = []
		if sgRes.ipPermissions
			inboundRule = sgRes.ipPermissions.item

		inboundRule = _.map inboundRule, (ruleObj) ->
			ruleObj.direction = 'inbound'
			return ruleObj

		outboundRule = _.map outboundRule, (ruleObj) ->
			ruleObj.direction = 'outbound'
			return ruleObj

		allRuleAry = inboundRule.concat outboundRule

		allDispRuleAry = []

		_.each allRuleAry, (originRuleObj) ->

			ruleObj = _.clone originRuleObj

			ipRanges = ''
			sgColor = ''
			if ruleObj.ipRanges
				ipRanges = ruleObj.ipRanges['item'][0]['cidrIp']
			else
				sgId = ruleObj.groups.item[0].groupId
				
				if isAppEdit or currentState is 'app'
					ipRanges = MC.aws.sg.getSGNameInStackForApp(sgId)
				else
					ipRanges = sgId

				sgUID = MC.aws.sg.getSGUIDInStackForApp(sgId)
				sgColor = MC.aws.sg.getSGColor(sgUID)

			if ruleObj.ipProtocol in [-1, '-1']
				ruleObj.ipProtocol = 'all'
				ruleObj.fromPort = 0
				ruleObj.toPort = 65535
			else if ruleObj.ipProtocol not in ['tcp', 'udp', 'icmp', 'all', -1, '-1']
				ruleObj.ipProtocol = "custom(#{ruleObj.ipProtocol})"

			partType = ''
			if ruleObj.ipProtocol is 'icmp'
				partType = '/'
			else
				partType = '-'

			dispPort = ruleObj.fromPort + partType + ruleObj.toPort
			if Number(ruleObj.fromPort) is Number(ruleObj.toPort) and ruleObj.ipProtocol isnt 'icmp'
				dispPort = ruleObj.toPort

			if !ruleObj.fromPort or !ruleObj.toPort
				dispPort = '-'

			dispSGObj =
				fromPort : ruleObj.fromPort
				toPort : ruleObj.toPort
				ipProtocol : ruleObj.ipProtocol
				ipRanges : ipRanges
				direction : ruleObj.direction
				partType : partType
				dispPort : dispPort
				sgColor: sgColor

			allDispRuleAry.push dispSGObj

			null

		return allDispRuleAry

	getSgRuleDetail = (line_id_or_target) ->

		both_side = []

		options = null

		if $.type(line_id_or_target) is "string"

			options = MC.canvas.lineTarget line_id_or_target

		else

			options = line_id_or_target

		$.each options, ( i, connection_obj ) ->

			switch MC.canvas_data.component[connection_obj.uid].type

				when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

					if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

						side_sg = {}

						side_sg.name = MC.canvas_data.component[connection_obj.uid].name

						side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name, color:MC.aws.sg.getSGColor(sg.split('.')[0][1...])} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroupId)

						both_side.push side_sg

					else

						$.each MC.canvas_data.component, ( comp_uid, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (comp.resource.Attachment.InstanceId.split ".")[0][1...] == connection_obj.uid and comp.resource.Attachment.DeviceIndex == '0'

								side_sg = {}

								side_sg.name = MC.canvas_data.component[connection_obj.uid].name

								side_sg.sg = ({name:MC.canvas_data.component[sg.GroupId.split('.')[0][1...]].name, uid:sg.GroupId.split('.')[0][1...], color:MC.aws.sg.getSGColor(sg.GroupId.split('.')[0][1...])} for sg in comp.resource.GroupSet)

								both_side.push side_sg

								return false

				when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

					side_sg = {}

					side_sg.name = MC.canvas_data.component[connection_obj.uid].name

					side_sg.sg = ({uid:sg.GroupId.split('.')[0][1...],name:MC.canvas_data.component[sg.GroupId.split('.')[0][1...]].name, color:MC.aws.sg.getSGColor(sg.GroupId.split('.')[0][1...])} for sg in MC.canvas_data.component[connection_obj.uid].resource.GroupSet)

					both_side.push side_sg

				when constant.AWS_RESOURCE_TYPE.AWS_ELB, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

					side_sg = {}

					side_sg.name = MC.canvas_data.component[connection_obj.uid].name

					side_sg.sg = ({uid:sg.split('.')[0][1...],name:MC.canvas_data.component[sg.split('.')[0][1...]].name, color:MC.aws.sg.getSGColor(sg.split('.')[0][1...])} for sg in MC.canvas_data.component[connection_obj.uid].resource.SecurityGroups)

					both_side.push side_sg

		return both_side

	createNewSG = () ->

		uid = MC.guid()

		component_data = $.extend(true, {}, MC.canvas.SG_JSON.data)

		component_data.uid = uid

		sg_name = MC.aws.aws.getNewName(constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup)

		component_data.name = sg_name

		component_data.resource.GroupName = sg_name
		vpcUID = MC.aws.vpc.getVPCUID()
		if vpcUID
			component_data.resource.VpcId = '@' + vpcUID + '.resource.VpcId'
		component_data.resource.GroupDescription = lang.ide.PROP_TEXT_CUSTOM_SG_DESC

		component_data.resource.IpPermissions = []

		component_data.resource.IpPermissionsEgress.push {
			"IpProtocol": "-1",
			"IpRanges": "0.0.0.0/0",
			"FromPort": "0",
			"ToPort": "65535",
			"Groups": []
			}

		data = MC.canvas.data.get('component')

		data[uid] = component_data

		MC.canvas.data.set('component', data)

		#add new sg to MC.canvas_property.sg_list
		addSGToProperty component_data

		return uid


	addSGToProperty = (sg) ->
		#add sg to MC.canvas_property.sg_list

		found = false
		prop  = MC.canvas_property

		if !prop

			console.log '[addSGToProperty] no canvas_property found'

		else

			#check exist
			$.each prop.sg_list, (i, item) ->

				if sg.id == item.uid
					found = true
					return false
				null

			if !found

				prop.sg_list.push {
					color  : getNextSGColor()
					member : 0
					name   : sg.name
					uid    : sg.uid
				}


		null


	# initSGColor = () ->
	# #init color property in MC.canvas_property.sg_list

	# 	if MC.canvas_property and MC.canvas_property.sg_list
	# 		$.each MC.canvas_property.sg_list, (key, value) ->

	# 			if key < MC.canvas.SG_COLORS.length
	# 				#use color table
	# 				MC.canvas_property.sg_list[key].color = MC.canvas.SG_COLORS[key]
	# 			else #random color
	# 				rand = Math.floor(Math.random() * 0xFFFFFF).toString(16)
	# 				while rand.length < 6
	# 				  rand = "0" + rand
	# 				MC.canvas_property.sg_list[key].color = rand
	# 	else

	# 		console.error '[initSGColor]Init SG color failed'


	getSGColor = (uid) ->
	#get color from MC.canvas_property.sg_list by sg uid
		color = null

		if MC.canvas_property and MC.canvas_property.sg_list
			#use color table
			$.each MC.canvas_property.sg_list, ( i, value ) ->

				if value.color and value.uid == uid
					color = value.color
					false

		if !color
			#random color
			color = Math.floor(Math.random() * 0xFFFFFF).toString(16)
			while color.length < 6
				color = '0' + color

		'#' + color

	getNextSGColor = () ->
	#for createNewSG()
	#get next availability color from MC.canvas.SG_COLORS
		next_color = null

		if MC.canvas_property and MC.canvas_property.sg_list
			#use color table

			$.each MC.canvas.SG_COLORS, ( i, color ) ->

				found = false

				$.each MC.canvas_property.sg_list, ( j, sg ) ->

					if sg.color == color

						found = true

						false

				if !found

					next_color = color

					false

		if !next_color
			#random next_color
			next_color = Math.floor(Math.random() * 0xFFFFFF).toString(16)
			while next_color.length < 6
				next_color = '0' + next_color

		#no '#'
		next_color


	updateSGColorLabel = ( uid ) ->

		if uid
			MC.canvas.updateSG uid
		else
			# console.error '[updateSGColorLabel] not found uid: ' + uid

		null

	getDefaultSG = () ->

		deafaultSGComp = null
		_.each MC.canvas_data.component, (sgComp) ->

			if sgComp.name is 'DefaultSG'
				deafaultSGComp = sgComp
			null
		return deafaultSGComp

	convertMemberNameToReal = (memberAry) ->

		newMemberAry = []
		newMemberAry = _.map memberAry, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface' and compObj.name is 'eni0'
				instanceRef = compObj.resource.Attachment.InstanceId
				instanceUID = instanceRef.split('.')[0].slice(1)
				instanceComp = MC.canvas_data.component[instanceUID]
				return instanceComp
			else
				return compObj

		return newMemberAry

	getSGNameInStackForApp = (sgId) ->

		sgName = ''
		_.each MC.canvas_data.component, (comp) ->

			if comp.type is 'AWS.EC2.SecurityGroup'
				currentSgId = comp.resource.GroupId
				if currentSgId is sgId
					sgName = comp.name
			null

		return sgName

	getSGUIDInStackForApp = (sgId) ->

		sgUID = ''
		_.each MC.canvas_data.component, (comp, uid) ->

			if comp.type is 'AWS.EC2.SecurityGroup'
				currentSgId = comp.resource.GroupId
				if currentSgId is sgId
					sgUID = uid
			null

		return sgUID

	#public
	getAllRefComp      : getAllRefComp
	getAllRule         : getAllRule
	getSgRuleDetail    : getSgRuleDetail
	createNewSG        : createNewSG
	addSGToProperty    : addSGToProperty
	getSGColor         : getSGColor
	updateSGColorLabel : updateSGColorLabel
	deleteRefInAllComp : deleteRefInAllComp
	getDefaultSG       : getDefaultSG
	convertMemberNameToReal : convertMemberNameToReal
	getSGNameInStackForApp : getSGNameInStackForApp
	getSGUIDInStackForApp : getSGUIDInStackForApp