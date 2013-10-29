define [ 'constant', 'MC','i18n!nls/lang.js'], ( constant, MC, lang ) ->

	isEBSOptimizedForAttachedProvisionedVolume = (instanceUID) ->

		instanceComp = MC.canvas_data.component[instanceUID]
		instanceType = instanceComp.type
		isInstanceComp = instanceType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
		# check if the instance/lsg have provisioned volume
		haveProvisionedVolume = false
		instanceUIDRef = lsgName = amiId = null
		if instanceComp
			instanceUIDRef = '@' + instanceUID + '.resource.InstanceId'
		else
			lsgName = instanceComp.resource.LaunchConfigurationName
			amiId = instanceComp.resource.ImageId
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
				if compObj.resource.VolumeType isnt 'standard'
					# if instanceComp is instance
					if isInstanceComp and (compObj.resource.AttachmentSet.InstanceId is instanceUIDRef)
						haveProvisionedVolume = true
					# if instanceComp is LSG
					else if (!isInstanceComp and compObj.resource.ImageId is amiId and compObj.resource.LaunchConfigurationName is lsgName)
						haveProvisionedVolume = true
			null

		# check if the instance/lsg is EbsOptimized
		if !(haveProvisionedVolume and (instanceComp.resource.EbsOptimized in ['false', false, '']))
			return null
		else
			instanceName = instanceComp.name
			tipInfo = sprintf lang.ide.TA_MSG_NOTICE_INSTANCE_NOT_EBS_OPTIMIZED_FOR_ATTACHED_PROVISIONED_VOLUME, instanceName
			# return
			level: constant.TA.NOTICE
			info: tipInfo

	_getSGCompRuleLength = (sgUID) ->
		sgComp = MC.canvas_data.component[sgUID]
		sgInboundRuleAry = sgComp.resource.IpPermissions
		sgOutboundRuleAry = sgComp.resource.IpPermissionsEgress

		# count sg rule total number
		sgTotalRuleNum = 0
		if sgInboundRuleAry
			sgTotalRuleNum += sgInboundRuleAry.length
		if sgOutboundRuleAry
			sgTotalRuleNum += sgOutboundRuleAry.length
		return sgTotalRuleNum

	isAssociatedSGRuleExceedFitNum = (instanceUID) ->

		instanceComp = MC.canvas_data.component[instanceUID]
		instanceType = instanceComp.type
		isInstanceComp = instanceType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
		# check platform type
		platformType = MC.canvas_data.platform
		if platformType isnt MC.canvas.PLATFORM_TYPE.EC2_CLASSIC
			# have vpc, count eni's sg rule number
			sgUIDAry = []
			if isInstanceComp
				# get associated eni sg for instance
				_.each MC.canvas_data.component, (compObj) ->
					if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
						associatedInstanceRef = compObj.resource.Attachment.InstanceId
						associatedInstanceUID = associatedInstanceRef.split('.')[0].slice(1)
						if associatedInstanceUID is instanceUID
							eniSGAry = compObj.resource.GroupSet
							_.each eniSGAry, (sgObj) ->
								eniSGUIDRef = sgObj.GroupId
								eniSGUID = eniSGUIDRef.split('.')[0].slice(1)
								if !(eniSGUID in sgUIDAry)
									sgUIDAry.push(eniSGUID)
								null
					null
			else
				# get all LSG's sg
				lsgSGAry = instanceComp.resource.SecurityGroups
				_.each lsgSGAry, (sgRef) ->
					sgUID = sgRef.split('.')[0].slice(1)
					if !(sgUID in sgUIDAry)
						sgUIDAry.push(sgUID)
					null

			# loop sg array to count rule number
			totalSGRuleNum = 0
			_.each sgUIDAry, (sgUID) ->
				totalSGRuleNum += _getSGCompRuleLength(sgUID)
				null

			if totalSGRuleNum > 50
				instanceName = instanceComp.name
				tipInfo = sprintf lang.ide.TA_INFO_WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM, instanceName, 50
				return {
					level: constant.TA.WARNING,
					info: tipInfo
				}

		else
			# no vpc
			sgUIDAry = []
			if isInstanceComp
				instanceSGAry = instanceComp.resource.SecurityGroup
			else
				instanceSGAry = instanceComp.resource.SecurityGroups
			_.each instanceSGAry, (sgRef) ->
				sgUID = sgRef.split('.')[0].slice(1)
				if !(sgUID in sgUIDAry)
					sgUIDAry.push(sgUID)
				null

			# loop sg array to count rule number
			totalSGRuleNum = 0
			_.each sgUIDAry, (sgUID) ->
				totalSGRuleNum += _getSGCompRuleLength(sgUID)
				null

			if totalSGRuleNum > 100
				instanceName = instanceComp.name
				tipInfo = sprintf lang.ide.TA_INFO_WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM, instanceName, 100
				return {
					level: constant.TA.WARNING,
					info: tipInfo
				}

		return null

	isEBSOptimizedForAttachedProvisionedVolume : isEBSOptimizedForAttachedProvisionedVolume
	isAssociatedSGRuleExceedFitNum : isAssociatedSGRuleExceedFitNum
