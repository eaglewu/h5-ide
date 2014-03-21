define [ 'MC' ], ( MC) ->

	#get valid deviceName for Volume
	getDeviceName = (uid,volume_id) ->

		comp_data 	= Design.instance().serialize().component[uid]
		region 		= Design.instance().region()
		image_id 	= (if comp_data then comp_data.resource.ImageId else "")
		ami_info 	= (if (MC.data.config[region].ami and MC.data.config[region].ami[image_id]) then MC.data.config[region].ami[image_id] else MC.data.dict_ami[image_id])
		device_list	= []
		device_name = null #result

		#check deviceName
		if ami_info and ami_info.osType != 'windows'
			#linux
			device_list = 'f g h i j k l m n o p q r s t u v w x y z'.split(' ')

		else
			#windows
			device_list = 'f g h i j k l m n o p'.split(' ')


		$.each ami_info.blockDeviceMapping, (key, value) ->

			if key.slice(0, 4) is "/dev/"
				k = key.slice(-1)
				index = device_list.indexOf(k)
				device_list.splice index, 1  if index >= 0



		if comp_data.type == 'AWS.EC2.Instance'

			#for Instance
			$.each comp_data.resource.BlockDeviceMapping, (key, value) ->
				volume_uid = value.slice(1)
				k = MC.canvas_data.component[volume_uid].name.slice(-1)
				index = device_list.indexOf(k)
				device_list.splice index, 1  if index >= 0

		else if comp_data.type == 'AWS.AutoScaling.LaunchConfiguration'

			#for LaunchConfiguration
			$.each comp_data.resource.BlockDeviceMapping, (key, value) ->
			  index = device_list.indexOf(value.DeviceName.substr(-1, 1))
			  device_list.splice index, 1  if index >= 0


		if device_list.length is 0
			#no valid deviceName
			device_name = null

		else

			if ami_info.osType isnt "windows"
			  device_name = "/dev/sd" + device_list[0]
			else
			  device_name = "xvd" + device_list[0]

		device_name

	getDeviceName : getDeviceName

