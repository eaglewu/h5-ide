define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	getAZofASGNode = ( uid ) ->

		#uid is asg layout uid ( maybe original asg, or expand asg )

		comp_data   = MC.canvas_data.component
		layout_data = MC.canvas_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE
		tgt_az      = ''

		parent_id   = layout_data.component.group[uid].groupUId
		asg_parent  = layout_data.component.group[ parent_id ]


		if asg_parent

			switch asg_parent.type

				when res_type.AWS_EC2_AvailabilityZone then tgt_az = asg_parent.name

				when res_type.AWS_VPC_Subnet           then tgt_az = comp_data[ parent_id ].resource.AvailabilityZone

		#return
		tgt_az

	updateASGCount = ( app_id ) ->
		if MC.canvas.getState() == 'stack'
			return null

		appData   = MC.data.resource_list[MC.canvas_data.region]
		component = MC.canvas_data.component
		layout    = MC.canvas_data.layout

		for uid, comp of component
			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

				asg_comp = component[ layout.component.node[uid].groupUId ]
				asg_data = appData[ asg_comp.resource.AutoScalingGroupARN ]

				if asg_data
					MC.canvas.update uid, 'text', 'instance-number', asg_data.Instances.member.length
		null


	getASGInAZ = ( orig_uid, az ) ->
		#uid is original asg uid

		result      = ''

		comp_data   = MC.canvas_data.component
		layout_data = MC.canvas_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE
		tgt_az      = ''

		asg_layout  = layout_data.component.group[orig_uid]


		if asg_layout

			#if orig_uid is expand asg ,then use originalId
			if asg_layout.originalId

				orig_uid = asg_layout.originalId
				asg_layout  = layout_data.component.group[orig_uid]


			parent_id   = asg_layout.groupUId

			asg_parent  = layout_data.component.group[ parent_id ]


			for uid, group of layout_data.component.group

				if group.type is res_type.AWS_AutoScaling_Group

					tgt_layout = layout_data.component.group[group.groupUId]

					if tgt_layout

						switch tgt_layout.type

							when res_type.AWS_EC2_AvailabilityZone then tgt_az = tgt_layout.name

							when res_type.AWS_VPC_Subnet           then tgt_az = comp_data[group.groupUId].resource.AvailabilityZone


						if ( group.originalId is orig_uid  or  uid is orig_uid )  and  az == getAZofASGNode uid

							result = uid

		result

	updateAttachedELBAZ = (targetAsgUID, azAry) ->

		asgComp = MC.canvas_data.component[targetAsgUID]
		attachedELBAry = asgComp.resource.LoadBalancerNames
		_.each attachedELBAry, (elbUIDRef) ->
			elbUID = elbUIDRef.split('.')[0].slice(1)
			elbComp = MC.canvas_data.component[elbUID]

			# update AZ field
			elbAZAry = elbComp.resource.AvailabilityZones
			elbAZAryLength = elbAZAry.length

			MC.canvas_data.component[elbUID].resource.AvailabilityZones = _.union(elbAZAry, azAry)

			null

	#public
	getAZofASGNode      : getAZofASGNode
	getASGInAZ          : getASGInAZ
	updateASGCount      : updateASGCount
	updateAttachedELBAZ : updateAttachedELBAZ
