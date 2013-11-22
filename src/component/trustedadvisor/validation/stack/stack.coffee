define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'stack_service', 'ami_service', '../result_vo' ], ( constant, $, MC, lang, stackService, amiService ) ->

	_getCompName = (compUID) ->

		compName = ''
		compObj = MC.canvas_data.component[compUID]
		if compObj and compObj.name
			compName = compObj.name
		return compName

	verify = (callback) ->

		try
			if !callback
				callback = () ->

			validData = $.extend true, {}, MC.canvas_data
			if MC.aws.aws.checkDefaultVPC()
				validData.component = MC.aws.vpc.generateComponentForDefaultVPC()

			stackService.verify {sender: this},
				$.cookie( 'usercode' ),
				$.cookie( 'session_id' ),
				validData, (result) ->

					checkResult = true
					returnInfo = null
					errInfoStr = ''

					if !result.is_error
						validResultObj = result.resolved_data
						if typeof(validResultObj) is 'object'
							if validResultObj.result
								callback(null)
							else
								checkResult = false

								try
									returnInfo = validResultObj.cause
									returnInfoObj = JSON.parse(returnInfo)

									# get api call info
									errCompUID = returnInfoObj.uid
									errMessage = returnInfoObj.message
									errCompName = _getCompName(errCompUID)

									errInfoStr = sprintf lang.ide.TA_MSG_ERROR_STACK_FORMAT_VALID_FAILED, errCompName, errMessage

								catch err
									errInfoStr = "Stack format validation error"
						else
							callback(null)
					else
						callback(null)

					if checkResult
						callback(null)
					else
						validResultObj = {
							level: constant.TA.ERROR,
							info: errInfoStr
						}
						callback(validResultObj)
						console.log(validResultObj)

			# immediately return
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_CHECKING_FORMAT_VALID
			return {
				level: constant.TA.ERROR,
				info: tipInfo
			}
		catch err
			callback(null)

	isHaveNotExistAMIAsync = (callback) ->

		try
			if !callback
				callback = () ->

			currentState = MC.canvas.getState()

			# get current all using ami
			amiAry = []
			instanceAMIMap = {}
			_.each MC.canvas_data.component, (compObj) ->
				if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance or
					compObj.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
						imageId = compObj.resource.ImageId
						if imageId
							if not instanceAMIMap[imageId]
								instanceAMIMap[imageId] = []
								amiAry.push imageId
							instanceAMIMap[imageId].push(compObj.uid)
				null

			# get ami info from aws
			if amiAry.length

				currentRegion = MC.canvas_data.region
				amiService.DescribeImages {sender: this},
					$.cookie( 'usercode' ),
					$.cookie( 'session_id' ),
					currentRegion, amiAry, null, null, null, (result) ->
						
						tipInfoAry = []

						if result.is_error and result.aws_error_code is 'InvalidAMIID.NotFound'
							# get current stack all aws ami
							awsAMIIdAryStr = result.error_message
							awsAMIIdAryStr = awsAMIIdAryStr.replace("The image ids '[", "").replace("]' do not exist", "")
							.replace("The image id '[", "").replace("]' does not exist", "")

							awsAMIIdAry = awsAMIIdAryStr.split(',')
							awsAMIIdAry = _.map awsAMIIdAry, (awsAMIId) ->
								return $.trim(awsAMIId)

							if not awsAMIIdAry.length
								callback(null)
								return null

							_.each amiAry, (amiId) ->
								if amiId in awsAMIIdAry
									# not exist in stack
									instanceUIDAry = instanceAMIMap[amiId]
									_.each instanceUIDAry, (instanceUID) ->
										instanceObj = MC.canvas_data.component[instanceUID]
										instanceType = instanceObj.type
										instanceName = instanceObj.name

										infoObjType = 'Instance'
										infoTagType = 'instance'
										if instanceType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
											infoObjType = 'Launch Configuration'
											infoTagType = 'lc'
										tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceName, amiId
										tipInfoAry.push({
											level: constant.TA.ERROR,
											info: tipInfo,
											uid: instanceUID
										})
										null
								null

							# return error valid result
							if tipInfoAry.length
								callback(tipInfoAry)
								console.log(tipInfoAry)
							else
								callback(null)

						else
							callback(null)

				return null

			else
				callback(null)
		catch err
			callback(null)

	isHaveNotExistAMI = () ->

		# get current all using ami
		amiAry = []
		instanceAMIMap = {}
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance or
				compObj.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
					imageId = compObj.resource.ImageId
					if imageId
						if not instanceAMIMap[imageId]
							instanceAMIMap[imageId] = []
							amiAry.push imageId
						instanceAMIMap[imageId].push(compObj.uid)
			null

		awsAMIIdAry = []
		_.each MC.data.dict_ami, (amiObj) ->
			amiId = amiObj.imageId
			awsAMIIdAry.push(amiId)
			null

		tipInfoAry = []

		_.each amiAry, (amiId) ->
			if amiId not in awsAMIIdAry
				# not exist in stack
				instanceUIDAry = instanceAMIMap[amiId]
				_.each instanceUIDAry, (instanceUID) ->
					instanceObj = MC.canvas_data.component[instanceUID]
					instanceType = instanceObj.type
					instanceName = instanceObj.name

					infoObjType = 'Instance'
					infoTagType = 'instance'
					if instanceType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
						infoObjType = 'Launch Configuration'
						infoTagType = 'lc'
					tipInfo = sprintf lang.ide.TA_MSG_ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceName, amiId
					tipInfoAry.push({
						level: constant.TA.ERROR,
						info: tipInfo,
						uid: instanceUID
					})
					null
			null

		return tipInfoAry

	isHaveNotExistAMIAsync : isHaveNotExistAMIAsync
	isHaveNotExistAMI : isHaveNotExistAMI
	verify : verify
