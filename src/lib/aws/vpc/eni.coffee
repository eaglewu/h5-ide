define [ 'MC', 'jquery' ], ( MC, $ ) ->

	#private
	getAvailableIPInCIDR = (ipCidr, filter, maxNeedIPCount) ->

		_addZeroToLeftStr = (str, n) ->
			count = n - str.length + 1
			strAry = _.map [1...count], () ->
				return '0'
			str = strAry.join('') + str

		cutAry = ipCidr.split('/')
		ipAddr = cutAry[0]
		suffix = Number cutAry[1]
		prefix = 32 - suffix

		ipAddrAry = ipAddr.split '.'
		ipAddrBinAry = _.map ipAddrAry, (value) ->
			return _addZeroToLeftStr(parseInt(value).toString(2), 8)

		ipAddrBinStr = ipAddrBinAry.join ''
		ipAddrBinPrefixStr = ipAddrBinStr.slice(0, suffix)

		ipAddrBinStrSuffixMin = ipAddrBinStr.slice(suffix).replace(/1/g, '0')
		ipAddrBinStrSuffixMax = ipAddrBinStrSuffixMin.replace(/0/g, '1')

		# console.log(ipAddrBinStrSuffixMin, ipAddrBinStrSuffixMax)

		ipAddrNumSuffixMin = parseInt ipAddrBinStrSuffixMin, 2
		ipAddrNumSuffixMax = parseInt ipAddrBinStrSuffixMax, 2

		allIPAry = []
		availableIPCount = 0
		readyAssignAry = [ipAddrNumSuffixMin...ipAddrNumSuffixMax + 1]
		readyAssignAryLength = readyAssignAry.length
		$.each readyAssignAry, (idx, value) ->
			newIPBinStr = ipAddrBinPrefixStr + _addZeroToLeftStr(value.toString(2), prefix)
			isAvailableIP = true
			if idx in [0, 1, 2, 3]
				isAvailableIP = false
			if idx is readyAssignAryLength - 1
				isAvailableIP = false
			newIPAry = _.map [0, 8, 16, 24], (value) ->
				newIPNum = (parseInt newIPBinStr.slice(value, value + 8), 2)
				# if value is 24 and (newIPNum in [0, 1, 2, 3, 255])
				# 	isAvailableIP = false
				return newIPNum

			newIPStr = newIPAry.join('.')
			if newIPStr in filter
				isAvailableIP = false
			newIPObj = {
				ip: newIPStr
				available: isAvailableIP
			}

			allIPAry.push(newIPObj)
			if isAvailableIP then availableIPCount++
			if availableIPCount > maxNeedIPCount then return false

			null

		console.log('availableIPCount: ' + availableIPCount)

		return allIPAry

	getAllOtherIPInCIDR = (subnetUIDRefOrAZ, rejectEniUID) ->

		defaultVPCId = MC.aws.aws.checkDefaultVPC()

		allCompAry = MC.canvas_data.component

		allOtherIPAry = []

		_.each allCompAry, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface'
				if compObj.uid is rejectEniUID
					return
				currentSubnetUIDRef = compObj.resource.SubnetId
				currentAZName = compObj.resource.AvailabilityZone
				if (!defaultVPCId and currentSubnetUIDRef is subnetUIDRefOrAZ) or
					(defaultVPCId and currentAZName is subnetUIDRefOrAZ)
						privateIpAddressSet = compObj.resource.PrivateIpAddressSet
						_.each privateIpAddressSet, (value) ->
							allOtherIPAry.push value.PrivateIpAddress
							null
			null

		return allOtherIPAry

	getAllNoAutoAssignIPInCIDR = (subnetUIDRefOrAZ) ->

		defaultVPCId = MC.aws.aws.checkDefaultVPC()

		allCompAry = MC.canvas_data.component

		allOtherIPAry = []

		_.each allCompAry, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface'
				currentSubnetUIDRef = compObj.resource.SubnetId
				currentAZName = compObj.resource.AvailabilityZone
				if (!defaultVPCId and currentSubnetUIDRef is subnetUIDRefOrAZ) or
					(defaultVPCId and currentAZName is subnetUIDRefOrAZ)
						privateIpAddressSet = compObj.resource.PrivateIpAddressSet
						_.each privateIpAddressSet, (value) ->
							if value.AutoAssign in ['false', false]
								allOtherIPAry.push value.PrivateIpAddress
							null
			null

		return allOtherIPAry

	saveIPList = (eniUID, ipList) ->

		eniComp = MC.canvas_data.component[eniUID]

		instanceUIDRef = eniComp.resource.Attachment.InstanceId

		privateIpAddressSet = []

		primary = true

		_.each ipList, (ipObj) ->
			ip = ipObj.ip
			eip = ipObj.eip
			auto = ipObj.auto

			instanceId = ''
			if eip then instanceId = instanceUIDRef

			privateIpAddressObj = {
				Association: {
					IpOwnerId: ''
					AssociationID: ''
					InstanceId: instanceId
					PublicDnsName: ''
					AllocationID: ''
					PublicIp: ''
				},
				PrivateIpAddress: ip
				AutoAssign: auto
				Primary: primary
			}

			primary = false

			privateIpAddressSet.push privateIpAddressObj

			null

		MC.canvas_data.component[eniUID].resource.PrivateIpAddressSet = privateIpAddressSet

	generateIPList = (eniUID, inputIPAry) ->

		currentEniComp = MC.canvas_data.component[eniUID]

		rejectEniUID = eniUID
		subnetUIDRef = ''
		allOtherIPAry = []
		defaultVPCId = MC.aws.aws.checkDefaultVPC()
		azName = ''
		if defaultVPCId
			azName = currentEniComp.resource.AvailabilityZone
			allOtherIPAry = MC.aws.eni.getAllOtherIPInCIDR azName, rejectEniUID
		else
			subnetUIDRef = currentEniComp.resource.SubnetId
			allOtherIPAry = MC.aws.eni.getAllOtherIPInCIDR subnetUIDRef, rejectEniUID

		# get self-set ip
		needAutoAssignIPCount = 0
		selfSetIPAry = []
		_.each inputIPAry, (ipObj) ->
			ipAddr = ipObj.ip
			if ipAddr.slice(ipAddr.length - 1) isnt 'x'
				selfSetIPAry.push ipObj.ip
			else
				needAutoAssignIPCount++

		ipFilterAry = allOtherIPAry.concat selfSetIPAry

		# get current subnet cidr
		subnetCidr = ''

		if defaultVPCId
			subnetObj = MC.aws.vpc.getAZSubnetForDefaultVPC(azName)
			subnetCidr = subnetObj.cidrBlock
		else
			subnetId = subnetUIDRef.slice(1).split('.')[0]
			subnetComp = MC.canvas_data.component[subnetId]
			subnetCidr = subnetComp.resource.CidrBlock

		# get current available ip
		needIPCount = 0
		if defaultVPCId
			needIPCount = MC.aws.eni.getSubnetNeedIPCount(azName)
		else
			needIPCount = MC.aws.eni.getSubnetNeedIPCount(subnetId)
		currentAvailableIPAry = MC.aws.eni.getAvailableIPInCIDR(subnetCidr, ipFilterAry, needIPCount)

		# start auto assign ip
		assignedIPAry = []
		_.each currentAvailableIPAry, (newIPObj) ->
			if needAutoAssignIPCount is 0
				return false
			if newIPObj.available
				needAutoAssignIPCount--
				assignedIPAry.push newIPObj.ip

		# generate result ip list
		realIPAry = []
		assignNum = 0
		_.each inputIPAry, (ipObj) ->

			ipAddr = ipObj.ip
			haveEIP = ipObj.eip

			if ipAddr.slice(ipAddr.length - 1) is 'x'
				assignIP = assignedIPAry[assignNum++]
				realIPAry.push({
					ip: assignIP
					eip: haveEIP
					auto: true
				})
			else
				realIPAry.push({
					ip: ipAddr
					eip: haveEIP
					auto: false
				})

			null

		return realIPAry

	getInstanceDefaultENI = (instanceUID) ->

		eniComp = null
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface' and
			compObj.resource.Attachment.DeviceIndex is '0' and
			compObj.resource.Attachment.InstanceId is ('@' + instanceUID + '.resource.InstanceId')
				eniComp = compObj
				return
			null

		return eniComp

	getENIDivIPAry = (subnetCIDR, ipAddr) ->

		suffix = Number(subnetCIDR.split('/')[1])

		ipAddrAry = ipAddr.split('.')

		resultPrefix = ''
		resultSuffix = ''

		if suffix > 23
			resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.' + ipAddrAry[2] + '.'
			resultSuffix = ipAddrAry[3]
		else
			resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.'
			resultSuffix = ipAddrAry[2] + '.' + ipAddrAry[3]

		return [resultPrefix, resultSuffix]

	getSubnetComp = (eniUID) ->

		eniComp = MC.canvas_data.component[eniUID]
		subnetUIDRef = eniComp.resource.SubnetId
		subnetUID = subnetUIDRef.slice(1).split('.')[0]
		return MC.canvas_data.component[subnetUID]

	getSubnetNeedIPCount = (subnetUidOrAZ) ->

		defaultVPC = false
		if MC.aws.aws.checkDefaultVPC()
			defaultVPC = true

		needIPCount = 0
		subnetRef = ''
		azName = ''
		if defaultVPC
			azName = subnetUidOrAZ
		else
			subnetRef = '@' + subnetUidOrAZ + '.resource.SubnetId'

		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface'
				if (!defaultVPC and compObj.resource.SubnetId is subnetRef) or (defaultVPC and compObj.resource.AvailabilityZone is azName)
					needIPCount += compObj.resource.PrivateIpAddressSet.length
			null
		return needIPCount

	#display eni number for server group
	displayENINumber = ( uid, visible ) ->

		MC.canvas.display( uid , 'eni-number-group', visible )

	getENIMaxIPNum = (eniOrInstanceUID) ->

		eniComp = MC.canvas_data.component[eniOrInstanceUID]

		if !eniComp then return 0
		instanceUID = ''
		if eniComp.type is 'AWS.VPC.NetworkInterface'
			instanceUIDRef = eniComp.resource.Attachment.InstanceId
			if !instanceUIDRef then return 0
			instanceUID = instanceUIDRef.split('.')[0].slice(1)
		else
			instanceUID = eniOrInstanceUID
		instanceComp = MC.canvas_data.component[instanceUID]
		instanceType = instanceComp.resource.InstanceType
		instanceTypeAry = instanceType.split('.')
		if !(instanceTypeAry[0] and instanceTypeAry[1]) then return 0

		typeENINumMap =	MC.data.config[MC.canvas_data.region].instance_type
		if !typeENINumMap then return 0

		eniMaxIPNum = typeENINumMap[instanceTypeAry[0]][instanceTypeAry[1]].ip_per_eni
		if !eniMaxIPNum then return 0

		return eniMaxIPNum

	reduceIPNumByInstanceType = (eniOrInstanceUID) ->

		currentENIMaxIPNum = MC.aws.eni.getENIMaxIPNum(eniOrInstanceUID)

		eniComp = MC.canvas_data.component[eniOrInstanceUID]
		if !eniComp then return

		eniUID = ''
		if eniComp.type is 'AWS.VPC.NetworkInterface'
			eniUID = eniComp.uid
			ipsAry = eniComp.resource.PrivateIpAddressSet
		else
			defaultENIComp = MC.aws.eni.getInstanceDefaultENI(eniOrInstanceUID)
			eniUID = defaultENIComp.uid
			ipsAry = defaultENIComp.resource.PrivateIpAddressSet

		i = 0
		newIpsAry = _.filter ipsAry, (ipObj) ->
			i++
			if i > currentENIMaxIPNum and currentENIMaxIPNum isnt 0
				return false
			else
				return true

		MC.canvas_data.component[eniUID].resource.PrivateIpAddressSet = newIpsAry

	reduceAllENIIPList = (instanceUID) ->

		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface'
				instanceUIDRef = compObj.resource.Attachment.InstanceId
				if !instanceUIDRef then return
				eniInstanceUID = instanceUIDRef.split('.')[0].slice(1)
				if eniInstanceUID is instanceUID
					MC.aws.eni.reduceIPNumByInstanceType(compObj.uid)
			null

	markAutoAssginFalse = () ->

		_.each MC.canvas_data.component, (compObj) ->

			if compObj.type is 'AWS.VPC.NetworkInterface'

				_.each compObj.resource.PrivateIpAddressSet, (compIp) ->

					compIp.AutoAssign = false
			null

	haveIPConflictWithOtherENI = (ipAddr, eniUID) ->

		conflict = false
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface'
				ipAry = compObj.resource.PrivateIpAddressSet
				_.each ipAry, (ipObj, innerIdx) ->
					if compObj.uid isnt eniUID
						if ipObj.AutoAssign in [false, 'false']
							currentIPAddr = ipObj.PrivateIpAddress
							if currentIPAddr is ipAddr
								conflict = true
						null
			null
		return conflict

	updateAllInstanceENIIPToAutoAssign = (instanceUID) ->

		instanceUIDRef = '@' + instanceUID + '.resource.InstanceId'
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface'
				if compObj.resource.Attachment.InstanceId is instanceUIDRef
					eniIPAry = compObj.resource.PrivateIpAddressSet
					newENIIPAry = _.map eniIPAry, (ipObj) ->
						ipObj.AutoAssign = true
						return ipObj
					MC.canvas_data.component[compObj.uid].resource.PrivateIpAddressSet = newENIIPAry
			null

	#public
	markAutoAssginFalse	:	markAutoAssginFalse
	getAvailableIPInCIDR : getAvailableIPInCIDR
	getAllOtherIPInCIDR : getAllOtherIPInCIDR
	saveIPList : saveIPList
	generateIPList : generateIPList
	getInstanceDefaultENI : getInstanceDefaultENI
	getENIDivIPAry : getENIDivIPAry
	getSubnetComp : getSubnetComp
	getSubnetNeedIPCount : getSubnetNeedIPCount
	displayENINumber : displayENINumber
	getENIMaxIPNum : getENIMaxIPNum
	reduceIPNumByInstanceType : reduceIPNumByInstanceType
	reduceAllENIIPList : reduceAllENIIPList
	getAllNoAutoAssignIPInCIDR : getAllNoAutoAssignIPInCIDR
	haveIPConflictWithOtherENI : haveIPConflictWithOtherENI
	updateAllInstanceENIIPToAutoAssign : updateAllInstanceENIIPToAutoAssign
