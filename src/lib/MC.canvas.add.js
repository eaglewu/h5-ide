MC.canvas.add = function (flag, option, coordinate)
{
	var data = MC.canvas.data.get('component'),
		layout = MC.canvas.data.get('layout.component'),
		group = document.createElementNS("http://www.w3.org/2000/svg", 'g'),
		create_mode = true,
		type = '',
		class_type = '',
		component_data = {},
		component_layout = {},
		width = 100,
		height = 100,
		pad = 10,
		top = 0,
		size,
		platform;

	if (!option && !coordinate)
	{
		//existed resource ( init data from MC.tab[tab_id].data )
		create_mode = false;

		option = {};
		coordinate = {};

		group.id = flag; //flag is uid
		type = !data[ group.id ] ? layout.group[ group.id ].type : data[ group.id ].type;
	}
	else
	{
		//new resource ( init data from option and layout )
		create_mode = true;

		group.id = MC.guid();
		type = flag; //flag is resource type

		//get parent group
		if (option.groupUId && option.groupUId !== 'Canvas')
		{
			var group_layout = MC.canvas_data.layout.component.group[ option.groupUId ],
				group_comp = MC.canvas_data.component[ option.groupUId ];

			option.group = {};

			switch (group_layout.type)
			{
				case 'AWS.EC2.AvailabilityZone':
					option.group.availableZoneName = group_layout.name;
					option.group.vpcUId = $(".AWS-VPC-VPC")[0] ? $(".AWS-VPC-VPC")[0].id : '' ;
					break;

				case 'AWS.VPC.Subnet':
					option.group.subnetUId = option.groupUId;
					option.group.availableZoneName = group_comp.resource.AvailabilityZone;
					option.group.vpcUId = $(".AWS-VPC-VPC")[0].id;
					break;

				case 'AWS.VPC.VPC':
					option.group.vpcUId = $(".AWS-VPC-VPC")[0].id;
					break;

				case 'AWS.AutoScaling.Group':
					// var group_parent = MC.canvas.data.get('layout.component.group')[ option.groupUId ],
					// 	az = '';

					// switch (group_parent.type)
					// {
					// 	case 'AWS.EC2.AvailabilityZone':
					// 		break;

					// 	case 'AWS.VPC.Subnet':
					// 		//get parent of subnet
					// 		group_parent = MC.canvas.data.get('layout.component.group')[ group_parent.groupUId ];
					// 		break;

					// 	default:
					// 		group_parent = null;
					// 		break;
					// }

					// if (group_parent)
					// {
					// 	az = group_parent.name;
					// }

					// option.group.availableZoneName = az;
					// option.group.vpcUId = $(".AWS-VPC-VPC")[0] ? $(".AWS-VPC-VPC")[0].id : '' ;

					//change AWS.EC2.Instance to AWS.AutoScaling.LaunchConfiguration
					type = 'AWS.AutoScaling.LaunchConfiguration';
					break;
			}
		}
	}

	class_type = type.replace(/\./ig, '-'); // type is resource type

	switch (type) {

		//***** az begin *****//
		case 'AWS.EC2.AvailabilityZone':

			if (create_mode)
			{//write
				component_layout = $.extend(true, {}, MC.canvas.AZ_JSON.layout);
				component_layout.name = option.name;

				$.each($(".resource-item"), function ( idx, item){

					var data = $(item).data();

					if(data.type === 'AWS.EC2.AvailabilityZone' && data.option.name === option.name){
						$(item)
							.data('enable', false)
							.attr('data-enable', false)
							.addClass('resource-disabled')
							.removeClass("tooltip");
						return false;
					}
				});

				size = MC.canvas.GROUP_DEFAULT_SIZE[ type ];
				option.width = size[0];
				option.height = size[1];

				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_layout = layout.group[group.id];
				option.name = component_layout.name;

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.width = component_layout.size[0];
				option.height = component_layout.size[1];
			}

			width = option.width * MC.canvas.GRID_WIDTH,
			height = option.height * MC.canvas.GRID_HEIGHT,

			$(group).append(

				////1. area
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'group group-az',
					'rx': 5,
					'ry': 5
				}),

				////2.scale area
				Canvon.group().append(
					Canvon.rectangle(
						0, top, pad, pad
					).attr({'class': 'group-resizer resizer-topleft', 'data-direction': 'topleft'}),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-top', 'data-direction': 'top'}),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr({'class': 'group-resizer resizer-topright', 'data-direction': 'topright'}),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-left', 'data-direction': 'left'}),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-right', 'data-direction': 'right'}),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomleft', 'data-direction': 'bottomleft'}),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-bottom', 'data-direction': 'bottom'}),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomright', 'data-direction': 'bottomright'})
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.az label
				Canvon.text(MC.canvas.GROUP_LABEL_COORDINATE[ type ][0], MC.canvas.GROUP_LABEL_COORDINATE[ type ][1], option.name).attr({
					'class': 'group-label name',
					'id': group.id + '_name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group',
				'data-class': type
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			component_layout.size = [option.width, option.height];
			layout.group[group.id] = component_layout;
			MC.canvas.data.set('layout.component.group', layout.group);

			$('#az_layer').append(group);

			if (create_mode)
			{
				platform = MC.canvas.data.get('platform');

				if (platform === 'custom-vpc' || platform === 'ec2-vpc')
				{
					MC.canvas.add('AWS.VPC.Subnet', {
						'name': 'subnet',
						'groupUId': group.id
					}, {
						'x': coordinate.x + MC.canvas.GROUP_PADDING,
						'y': coordinate.y + MC.canvas.GROUP_PADDING
					});
				}
			}

			break;
		//***** az end *****//

		//***** vpc begin *****//
		case 'AWS.VPC.VPC':

			if (create_mode)
			{
				component_data = $.extend(true, {}, MC.canvas.VPC_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.VPC_JSON.layout);

				size = MC.canvas.GROUP_DEFAULT_SIZE[ type ];
				option.width = size[0];
				option.height = size[1];
			}
			else
			{
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.group[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.width = component_layout.size[0];
				option.height = component_layout.size[1];
			}

			width = option.width * MC.canvas.GRID_WIDTH,
			height = option.height * MC.canvas.GRID_HEIGHT,

			$(group).append(
				////1. area
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'group group-vpc',
					'rx': 5,
					'ry': 5
				}),

				////2.scale area
				Canvon.group().append(
					Canvon.rectangle(
						0, top, pad, pad
					).attr({'class': 'group-resizer resizer-topleft', 'data-direction': 'topleft'}),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-top', 'data-direction': 'top'}),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr({'class': 'group-resizer resizer-topright', 'data-direction': 'topright'}),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-left', 'data-direction': 'left'}),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-right', 'data-direction': 'right'}),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomleft', 'data-direction': 'bottomleft'}),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-bottom', 'data-direction': 'bottom'}),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomright', 'data-direction': 'bottomright'})
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.vpc label
				Canvon.text(MC.canvas.GROUP_LABEL_COORDINATE[ type ][0], MC.canvas.GROUP_LABEL_COORDINATE[ type ][1], option.name).attr({
					'class': 'group-label name',
					'id': group.id + '_name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group',
				'data-class': type
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			component_layout.size = [option.width, option.height];
			layout.group[group.id] = component_layout;
			MC.canvas.data.set('layout.component.group', layout.group);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#vpc_layer').append(group);

			break;
		//***** vpc end *****//

		//***** subnet begin *****//
		case 'AWS.VPC.Subnet':

			if (create_mode)
			{
				component_data = $.extend(true, {}, MC.canvas.SUBNET_JSON.data);
				component_data.name = option.name;
				component_data.resource.VpcId = "@" + option.group.vpcUId + '.resource.VpcId';
				component_data.resource.AvailabilityZone = option.group.availableZoneName;

				component_layout = $.extend(true, {}, MC.canvas.SUBNET_JSON.layout);
				component_layout.groupUId = option.groupUId;

				size = MC.canvas.GROUP_DEFAULT_SIZE[ type ];
				option.width = size[0];
				option.height = size[1];
			}
			else
			{
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.group[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.width = component_layout.size[0];
				option.height = component_layout.size[1];
			}

			width = option.width * MC.canvas.GRID_WIDTH,
			height = option.height * MC.canvas.GRID_HEIGHT,

			$(group).append(

				////1. area
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'group group-subnet',
					'rx': 5,
					'ry': 5
				}),

				////2.scale area
				Canvon.group().append(
					Canvon.rectangle(
						0, top, pad, pad
					).attr({'class': 'group-resizer resizer-topleft', 'data-direction': 'topleft'}),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-top', 'data-direction': 'top'}),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr({'class': 'group-resizer resizer-topright', 'data-direction': 'topright'}),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-left', 'data-direction': 'left'}),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-right', 'data-direction': 'right'}),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomleft', 'data-direction': 'bottomleft'}),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-bottom', 'data-direction': 'bottom'}),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomright', 'data-direction': 'bottomright'})
				).attr({
					'class': 'resizer-wrap'
				}),

				//3 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-subnet-assoc-in',
					'transform': 'translate(-12, ' + ((height / 2) - 13) + ')', //port position: right:0 top:-90 left:-180 bottom:-270
					'data-name': 'subnet-assoc-in', //for identify port
					'data-position': 'left', //port position: for calc point of junction
					'data-type': 'association', //color of line
					'data-direction': 'in', //direction
					'data-angle': MC.canvas.PORT_LEFT_ANGLE //port angle: right:0 top:90 left:180 bottom:270
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-subnet-assoc-out',
					'transform': 'translate(' + (width + 4) + ', ' + ((height / 2) - 13) + ')',
					'data-name': 'subnet-assoc-out',
					'data-position': 'right',
					'data-type': 'association',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5.subnet label
				Canvon.text(MC.canvas.GROUP_LABEL_COORDINATE[ type ][0], MC.canvas.GROUP_LABEL_COORDINATE[ type ][1], option.name).attr({
					'class': 'group-label name',
					'id': group.id + '_name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group',
				'data-class': type
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			component_layout.size = [option.width, option.height];
			layout.group[group.id] = component_layout;
			MC.canvas.data.set('layout.component.group', layout.group);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#subnet_layer').append(group);

			break;
		//***** subnet end *****//

		//***** asg begin *****//
		case 'AWS.AutoScaling.Group':

			if (create_mode)
			{

				//init layout data
				component_layout = $.extend(true, {}, MC.canvas.ASG_JSON.layout);
				component_layout.groupUId = option.groupUId;

				size = MC.canvas.GROUP_DEFAULT_SIZE[ type ];
				option.width = size[0];
				option.height = size[1];

				//init component data
				if (option['originalId'])
				{//expand ASG
					component_layout.originalId = option['originalId'];
				}
				else
				{//create new ASG
					component_data = $.extend(true, {}, MC.canvas.ASG_JSON.data);
					//name
					component_data.name = option.name;
					//az
					component_data.resource.AvailabilityZones = [option.group.availableZoneName];

					component_data.resource.MaxSize = 2;

					component_data.resource.MinSize = 1;

					component_data.resource.AutoScalingGroupName = option.name;

					if(option['launchConfig']){
						//use existed launchConfig
						component_data.resource.LaunchConfigurationName = '@' + option['launchConfig'] + '.resource.LaunchConfigurationName';
					}

					//vpc
					if(MC.canvas_data.platform !== MC.canvas.PLATFORM_TYPE.EC2_CLASSIC){
						component_data.resource.VPCZoneIdentifier = '@' + option.group.subnetUId + '.resource.SubnetId';

					}
				}



			}
			else
			{
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.group[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.width = component_layout.size[0];
				option.height = component_layout.size[1];
			}

			width = option.width * MC.canvas.GRID_WIDTH,
			height = option.height * MC.canvas.GRID_HEIGHT;

			$(group).append(

				////1.scale area
				Canvon.group().append(
					Canvon.rectangle(
						0, top, pad, pad
					).attr({'class': 'group-resizer'}),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr({'class': 'group-resizer'}),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr({'class': 'group-resizer'}),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer'}),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer'}),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr({'class': 'group-resizer'}),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr({'class': 'group-resizer'}),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr({'class': 'group-resizer'})
				),

				////2. area
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'group group-asg',
					'rx': 5,
					'ry': 5
				}),

				////3.dragger
				Canvon.path('M ' + (width - 1) + ' 1 l' + ' 0 20 l -20 -20 z', {}).attr({
					'class': 'asg-resource-dragger',
					'id': group.id + '_asg_resource_dragger',
					'display': option['launchConfig'] ? 'inline' : 'none'
				}),

				////5.asg label
				Canvon.text(MC.canvas.GROUP_LABEL_COORDINATE[ type ][0], MC.canvas.GROUP_LABEL_COORDINATE[ type ][1], option.name).attr({
					'class': 'group-label name',
					'id': group.id + '_name'
				}),

				//prompt
				Canvon.group().append(
					Canvon.text(30, 45, 'Drop AMI from'),
					Canvon.text(25, 65, 'resource panel to'),
					Canvon.text(35, 85, 'create launch'),
					Canvon.text(35, 105, 'configuration')
				).attr({
					'class': 'prompt_text',
					'id': group.id + '_prompt_text',
					'display': option['originalId'] || option['launchConfig'] ? 'none' : 'inline'
				})


			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group',
				'data-class': type
			});

			if (option['originalId'])
			{
				var orig_asg_comp = data[ option['originalId'] ],
					offset = 20,
					lc_comp_id,
					lc_comp_layout,
					os_type,
					lc_name;

				if ( orig_asg_comp && orig_asg_comp.resource.LaunchConfigurationName !== "" )
				{
					lc_comp_id = orig_asg_comp.resource.LaunchConfigurationName.split(".")[0].substr(1);
					lc_comp_layout = layout.node[ lc_comp_id ];
					os_type = lc_comp_layout.osType + '.' + lc_comp_layout.architecture + '.' + lc_comp_layout.rootDeviceType;
					lc_name = data[ lc_comp_id ].name;

					$(group).append(
						////bg
						Canvon.image('../assets/images/ide/icon/instance-canvas.png', 15 + offset, 11 + offset, 70, 70),
						////os_type
						Canvon.image('../assets/images/ide/ami/' + os_type + '.png', 30 + offset, 15 + offset, 39, 27),
						////lc name
						Canvon.text(50 + offset, 90 + offset, lc_name).attr({
							'class': 'node-label name'
						})
					);
				}
			}

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			component_layout.size = [option.width, option.height];
			layout.group[group.id] = component_layout;
			MC.canvas.data.set('layout.component.group', layout.group);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#asg_layer').append(group);

			if(option['launchConfig']){

				MC.canvas.add('AWS.EC2.Instance', {
					'name': 'launchConfig',
					'groupUId': group.id,
					'launchConfig' : option['launchConfig']
				}, {
					'x': coordinate.x + 2,
					'y': coordinate.y + 2
				});
			}

			break;
		//***** asg end *****//

		//***** instance begin *****//
		case 'AWS.EC2.Instance':

			var os_type = 'ami-unknown',
				volume_number = 0,
				icon_volume_status = 'not-attached',
				eni = null,
				eip_icon = MC.canvas.IMAGE.EIP_OFF,
				data_eip_state = 'off'; //on | off

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.INSTANCE_JSON.data);
				component_data.name = option.name;

				component_data.resource.ImageId = option.imageId;
				component_data.resource.InstanceType = 'm1.small';
				component_data.resource.Placement.AvailabilityZone = option.group.availableZoneName;

				// if not kp
				if (MC.canvas_property.kp_list.length === 0)
				{
					//default kp
				}

				component_data.resource.KeyName = "@"+MC.canvas_property.kp_list[0].DefaultKP + ".resource.KeyName";
				component_data.resource.SecurityGroupId.push("@"+MC.canvas_property.sg_list[0].uid + ".resource.GroupId");
				component_data.resource.SecurityGroup.push("@"+MC.canvas_property.sg_list[0].uid + ".resource.GroupName");
				MC.canvas_property.sg_list[0].member.push(group.id);

				// if subnet
				if(MC.canvas_data.platform !== MC.canvas.PLATFORM_TYPE.EC2_CLASSIC){

					//default eni
					eni = $.extend(true, {}, MC.canvas.ENI_JSON.data);
					uid = MC.guid();
					eni.uid = uid;
					eni.name = "eni0";
					eni.resource.Attachment.DeviceIndex = "0";
					eni.resource.Attachment.InstanceId = "@"+group.id+".resource.InstanceId";
					eni.resource.AvailabilityZone = component_data.resource.Placement.AvailabilityZone;
					var sg_group = {};
					sg_group.GroupId = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId';
					sg_group.GroupName = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupName';
					eni.resource.GroupSet.push(sg_group);

					if (MC.canvas_data.platform !== MC.canvas.PLATFORM_TYPE.DEFAULT_VPC){
						component_data.resource.SubnetId = '@' + option.group.subnetUId + '.resource.SubnetId';
						component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.VpcId';
						eni.resource.SubnetId = component_data.resource.SubnetId;
						eni.resource.VpcId = component_data.resource.VpcId;
					}

				}

				component_layout = $.extend(true, {}, MC.canvas.INSTANCE_JSON.layout);
				component_layout.groupUId = option.groupUId;
				component_layout.osType =  option.osType;
				component_layout.architecture =  option.architecture;
				component_layout.rootDeviceType =  option.rootDeviceType;
				component_layout.virtualizationType = option.virtualizationType;

			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				if (MC.canvas_data.platform !== MC.canvas.PLATFORM_TYPE.EC2_CLASSIC){
					$.each(MC.canvas_data.component, function ( key, val ){

						if (val.type === 'AWS.VPC.NetworkInterface' && val.resource.Attachment.InstanceId.split(".")[0].slice(1) === component_data.uid && val.resource.Attachment.DeviceIndex === '0'){

							$.each(MC.canvas_data.component, function ( k, v ){
								if(v.type === 'AWS.EC2.EIP' && v.resource.NetworkInterfaceId === '@' + val.uid + '.resource.NetworkInterfaceId'){
									eip_icon = MC.canvas.IMAGE.EIP_ON;
									data_eip_state = 'on'
								}
							});
						}
					});
				}


				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.osType = component_layout.osType ;
				option.architecture = component_layout.architecture ;
				option.rootDeviceType = component_layout.rootDeviceType ;
				option.virtualizationType = component_layout.virtualizationType;
			}

			//os type
			os_type = option.osType + '.' + option.architecture + '.' + option.rootDeviceType;

			//check volume number,set icon
			volume_number = component_data.resource.BlockDeviceMapping.length;
			if (volume_number > 0)
			{
				icon_volume_status = 'attached-normal';
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width , height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/instance-canvas.png', 15, 11, 70, 70),

				//2 path: left port(blue)
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-instance-sg port-instance-sg-left',
					'transform': 'translate(8, 26)' + MC.canvas.PORT_RIGHT_ROTATE, //port position: right:0 top:-90 left:-180 bottom:-270
					'data-name': 'instance-sg', //for identify port
					'data-position': 'left', //port position: for calc point of junction
					'data-type': 'sg', //color of line
					'data-direction': 'in', //direction
					'data-angle': MC.canvas.PORT_LEFT_ANGLE //port angle: right:0 top:90 left:180 bottom:270
				}),

				//3 path: left port(green)
				// Canvon.path(MC.canvas.PATH_D_PORT).attr({
				// 	'class': 'port port-green port-instance-elb-attach',
				// 	'transform': 'translate(8, 52)' + MC.canvas.PORT_RIGHT_ROTATE,
				// 	'data-name': 'instance-elb-attach',
				// 	'data-position': 'left',
				// 	'data-type': 'attachment',
				// 	'data-direction': 'in',
				// 	'data-angle': MC.canvas.PORT_LEFT_ANGLE
				// }),

				//4 path: right port(blue)
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-instance-sg port-instance-sg-right',
					'transform': 'translate(84, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'instance-sg',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//5 path: right port(green)
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-instance-attach',
					'id': group.id + '_instance_attach',
					'transform': 'translate(84, 52)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'instance-attach',
					'data-position': 'right',
					'data-type': 'attachment',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//6 path: top port(blue)
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-instance-rtb',
					'id': group.id + '_instance_rtb',
					'transform': 'translate(50, -6)' + MC.canvas.PORT_UP_ROTATE,
					'data-name': 'instance-rtb',
					'data-position': 'top',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_UP_ANGLE
				}),

				////7. os_type
				Canvon.image('../assets/images/ide/ami/' + os_type + '.png', 30, 15, 39, 27),

				////8.1 volume-attached
				Canvon.image('../assets/images/ide/icon/instance-volume-' + icon_volume_status + '.png' , 21, 48, 29, 24).attr({
					'id': group.id + '_volume_status'
				}),

				//8.2 volume number
				Canvon.text(35, 60, volume_number).attr({
					'class': 'node-label volume-number',
					'id': group.id + '_volume_number'
				}),

				//8.3 hot area for volume
				Canvon.rectangle(21, 48, 29, 24).attr({
					'class': 'instance-volume',
					'data-target-id': group.id,
					'fill': 'none'
				}),

				////7. eip
				Canvon.image(eip_icon, 58, 49, 14, 17).attr({
					'class': 'eip-status',
					'data-eip-state': data_eip_state,

					'id': group.id + '_eip_status'
				}),

				////10. hostname
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name',
					'id': group.id + '_hostname'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			if (eni)
			{
				data[eni.uid] = eni;
				MC.canvas.data.set('component', data);
			}
			$('#node_layer').append(group);

			//hide port by platform
			switch (MC.canvas.data.get('platform'))
			{
				case 'ec2-classic':
				case 'default-vpc':
					MC.canvas.display(group.id,'instance_rtb',false);//hide port instance_rtb
					MC.canvas.display(group.id,'instance_attach',false);//hide port instance_attach
					break;
				case 'custom-vpc':
				case 'ec2-vpc':
					break;
			}

			break;
		//***** instance end *****//


		//***** volume begin *****//
		case 'AWS.EC2.EBS.Volume':

			if (create_mode)
			{//write

				//set deviceName
				ami_info = MC.data.config[MC.canvas_data.component[option.instance_id].resource.Placement.AvailabilityZone.slice(0,-1)].ami[MC.canvas_data.component[option.instance_id].resource.ImageId];
				device_name = null;
				if (ami_info.virtualizationType !== 'hvm')
				{
					device_name = ['f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
				}
				else
				{
					device_name = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p'];
				}

				$.each(ami_info.blockDeviceMapping, function (key, value){
					if(key.slice(0,4) === '/dev/'){
						k = key.slice(-1);
						index = device_name.indexOf(k);
						if (index >= 0)
						{
							device_name.splice(index, 1);
						}
					}
				});
				$.each(MC.canvas_data.component[option.instance_id].resource.BlockDeviceMapping, function (key, value){
					volume_uid = value.slice(1);
					k = MC.canvas_data.component[volume_uid].name.slice(-1);
					index = device_name.indexOf(k);
					if (index >= 0)
					{
						device_name.splice(index, 1);
					}
				});
				if (device_name.length === 0)
				{
					//no valid deviceName
					notification('warning', 'No valid device name to assign,cancel!', false);
					return null;
				}

				if (ami_info.virtualizationType !== 'hvm') {
					option.name = '/dev/sd' + device_name[0];
				} else {
					option.name = 'xvd' + device_name[0];
				}


				component_data = $.extend(true, {}, MC.canvas.VOLUME_JSON.data);
				component_data.name = option.name;
				component_data.resource.Size = option.volumeSize;
				component_data.resource.AttachmentSet.InstanceId = '@' + option.instance_id + '.resource.InstanceId';
				component_data.resource.AttachmentSet.VolumeId = '@' + group.id + '.resource.VolumeId';
				component_data.resource.AvailabilityZone = MC.canvas_data.component[option.instance_id].resource.Placement.AvailabilityZone;
				component_data.resource.SnapshotId = option.snapshotId;

				component_data.resource.AttachmentSet.Device =  option.name;

				if (option.snapshotId)
				{
					component_data.resource.SnapshotId = option.snapshotId;
				}
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;
				option.volumeSize = component_data.resource.AttachmentSet.Size;
			}

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			return group;

			break;
		//***** volume end *****//

		//***** elb begin *****//
		case 'AWS.ELB':

			var icon_scheme = '';
			//init scheme by platform
			switch (MC.canvas.data.get('platform'))
			{
				case 'ec2-classic':
				case 'default-vpc':
					icon_scheme = 'internet';
					break;
				case 'custom-vpc':
				case 'ec2-vpc':
					icon_scheme = 'internal';
					break;
			}

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.ELB_JSON.data);
				option.name = 'load-balancer-0';
				component_data.name = option.name;
				component_data.resource.LoadBalancerName = option.name;

				if(MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.EC2_VPC || MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.CUSTOM_VPC){

					component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.VpcId';
					component_data.resource.SecurityGroups.push('@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId');

				}else if (MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.DEFAULT_VPC){
					component_data.resource.SecurityGroups.push('@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId');
				}else {
					component_data.resource.Scheme = 'internet-facing';
				}

				component_layout = $.extend(true, {}, MC.canvas.ELB_JSON.layout);
				component_layout.groupUId = option.groupUId;

				component_data.resource.Scheme = icon_scheme;

			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				icon_scheme = component_data.resource.Scheme;
			}

			icon_scheme = component_data.resource.Scheme === 'internal' ? 'internal' : 'internet';

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/elb-' + icon_scheme + '-canvas.png', 15, 24, 70, 53).attr({
					'id' : group.id + '_elb_scheme'
				}),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'id' : group.id + '_elb_sg_in',
					'class': 'port port-blue port-elb-sg-in',
					'transform': 'translate(8, 39)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-sg-in',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port -> instance sg
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'id' : group.id + '_elb_sg_out',
					'class': 'port port-blue port-elb-sg-out',
					'transform': 'translate(84, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-sg-out',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				// //4 path: right port -> instance attach
				// Canvon.path(MC.canvas.PATH_D_PORT).attr({
				// 	'class': 'port port-green port-elb-attach',
				// 	'transform': 'translate(84, 42)' + MC.canvas.PORT_RIGHT_ROTATE,
				// 	'data-name': 'elb-attach',
				// 	'data-position': 'right',
				// 	'data-type': 'attachment',
				// 	'data-direction': 'out',
				// 	'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				// }),

				//5 path: right port -> subnet
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'id' : group.id + '_elb_assoc',
					'class': 'port port-gray port-elb-assoc',
					'transform': 'translate(84, 57)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-assoc',
					'data-position': 'right',
					'data-type': 'association',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),


				////6. elb_name
				Canvon.text(50, 86, option.name).attr({
					'class': 'node-label name',
					'id' : group.id + '_elb_name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			//hide port by platform
			switch (MC.canvas.data.get('platform'))
			{
				case 'ec2-classic':
				case 'default-vpc':
					MC.canvas.display(group.id,'elb_sg_in',false);//hide port elb_sg_in
					MC.canvas.display(group.id,'elb_assoc',false);//hide port elb_assoc
					$('#' + group.id + '_elb_sg_out').attr('transform','translate(84, 39)');//move port to middle
					break;
				case 'custom-vpc':
				case 'ec2-vpc':
					break;
			}


			break;
		//***** elb end *****//

		//***** routetable begin *****//
		case 'AWS.VPC.RouteTable':
			var main_icon = '';

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.ROUTETABLE_JSON.data);
				component_data.name = option.name;
				if(MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.EC2_VPC || MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.CUSTOM_VPC){
					component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.VpcId';
				}
				if(option.main){
					main_icon = "main-";
				}

				component_layout = $.extend(true, {}, MC.canvas.ROUTETABLE_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;
				if(component_data.resource.AssociationSet.length > 0 && component_data.resource.AssociationSet[0].Main === 'true'){
					main_icon = "main-";
				}
				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/rt-'+main_icon+'canvas.png', 10, 13, 60, 57).attr({
					'id': group.id + '_rt_status'
				}),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-left',
					'transform': 'translate(11, 25)' + MC.canvas.PORT_LEFT_ROTATE,
					'data-name': 'rtb-tgt-left',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-right',
					'transform': 'translate(69, 25)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'rtb-tgt-right',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: top port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src port-rtb-src-top',
					'transform': 'translate(41, -4)' + MC.canvas.PORT_UP_ROTATE,
					'data-name': 'rtb-src',
					'data-position': 'top',
					'data-type': 'association',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_UP_ANGLE
				}),

				//5 path: bottom port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src port-rtb-src-bottom',
					'transform': 'translate(42, 66)' + MC.canvas.PORT_DOWN_ROTATE,
					'data-name': 'rtb-src',
					'data-position': 'bottom',
					'data-type': 'association',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_DOWN_ANGLE
				}),

				////6. routetable name
				Canvon.text(41, 28, option.name).attr({
					'class': 'node-label name',
					'id': group.id + '_rt_name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** routetable end *****//

		//***** igw begin *****//
		case 'AWS.VPC.InternetGateway':

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.IGW_JSON.data);
				option.name = 'Internet-gateway';
				component_data.name = option.name;
				component_data.resource.AttachmentSet[0].VpcId = '@' + option.group.vpcUId + '.resource.VpcId';
				component_layout = $.extend(true, {}, MC.canvas.IGW_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;


			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/igw-canvas.png', 10, 15, 60, 46),

				//2 path: left port
				// Canvon.path(MC.canvas.PATH_D_PORT).attr({
				// 	'class': 'port port-blue port-igw-unknown',
				// 	'transform': 'translate(12, 25)' + MC.canvas.PORT_LEFT_ROTATE,
				// 	'data-name': 'igw-unknown',
				// 	'data-position': 'left',
				// 	'data-type': 'sg',
				// 	'data-direction': 'out',
				// 	'data-angle': MC.canvas.PORT_LEFT_ANGLE
				// }),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-igw-tgt',
					'transform': 'translate(76, 25)' + MC.canvas.PORT_LEFT_ROTATE,
					'data-name': 'igw-tgt',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. igw name
				Canvon.text(40, 70, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** igw end *****//

		//***** vgw begin *****//
		case 'AWS.VPC.VPNGateway':

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.VGW_JSON.data);
				option.name = 'VPN-gateway';
				component_data.name = option.name;
				component_data.resource.Attachments[0].VpcId = '@' + option.group.vpcUId + '.resource.VpcId';
				component_layout = $.extend(true, {}, MC.canvas.VGW_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/vgw-canvas.png', 10, 15, 60, 46),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-vgw-tgt',
					'transform': 'translate(4, 25)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'vgw-tgt',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-vgw-vpn',
					'transform': 'translate(69, 25)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'vgw-vpn',
					'data-position': 'right',
					'data-type': 'vpn',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. vgw name
				Canvon.text(40, 70, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** vgw end *****//

		//***** cgw begin *****//
		case 'AWS.VPC.CustomerGateway':

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.CGW_JSON.data);
				option.name = 'customer-gateway-1';
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.CGW_JSON.layout);
				component_layout.networkName = option.networkName;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.networkName = component_layout.networkName;
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/cgw-canvas.png', 13, 10, 153, 76),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-cgw-vpn',
					'transform': 'translate(7, 35)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'cgw-vpn',
					'data-position': 'left',
					'data-type': 'vpn',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				////3. cgw name
				Canvon.text(100, 95, option.name).attr({
					'class': 'node-label name',
					'id': group.id + '_name'
				})

				// ////4. network name
				// Canvon.text(100, 95, option.networkName).attr({
				// 	'class': 'node-label network-name'
				// })

			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** cgw end *****//


		//***** eni begin *****//
		case 'AWS.VPC.NetworkInterface':
			var data_eip_state = 'off',
				attached = 'unattached',
				eip_icon = MC.canvas.IMAGE.EIP_OFF;

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.ENI_JSON.data);
				component_data.name = option.name;
				component_data.resource.SubnetId = '@' + option.group.subnetUId + '.resource.SubnetId';
				component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.VpcId';

				var sg_group = {};
				sg_group.GroupId = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId';
				sg_group.GroupName = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupName';
				component_data.resource.GroupSet.push(sg_group);

				component_layout = $.extend(true, {}, MC.canvas.ENI_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				if (component_data.resource.Attachment.InstanceId)
				{
					attached = 'attached'
				}

				$.each(MC.canvas_data.component, function ( k, v ){
					if(v.type === 'AWS.EC2.EIP' && v.resource.NetworkInterfaceId === '@' + component_data.uid + '.resource.NetworkInterfaceId'){
						eip_icon = MC.canvas.IMAGE.EIP_ON;
						data_eip_state = 'on'
					}
				});

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),

				Canvon.image('../assets/images/ide/icon/eni-canvas-'+attached+'.png', 16, 28, 68, 53).attr({
					'id': group.id + '_eni_status'
				}),

				Canvon.image(eip_icon, 46, 50, 14, 17).attr({
					'id': group.id + '_eip_status',
					'class': 'eip-status',
					'data-eip-state': data_eip_state,
				}),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-eni-sg port-eni-sg-left',
					'id': group.id + '_eni_sg_left',
					//'display': 'none', //hide
					'transform': 'translate(7, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-sg',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-eni-attach',
					'transform': 'translate(7, 52)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-attach',
					'data-position': 'left',
					'data-type': 'attachment',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-eni-sg port-eni-sg-right',
					'id': group.id + '_eni_sg_right',
					//'display': 'none', //hide
					'transform': 'translate(85, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-sg',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//5 path: top port(blue)
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-eni-rtb',
					'id': group.id + '_eni_rtb',
					'transform': 'translate(48, 10)' + MC.canvas.PORT_UP_ROTATE,
					'data-name': 'eni-rtb',
					'data-position': 'top',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_UP_ANGLE
				}),


				////6. eni_name
				Canvon.text(43, 85, option.name, {
					'text-anchor': 'start' // start, middle(default), end, inherit
				}).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			//hide port by platform
			switch (MC.canvas.data.get('platform'))
			{
				case 'ec2-classic':
				case 'default-vpc':
					MC.canvas.display(group.id,'_eni_rtb',false);//hide port eni_rtb
					break;
				case 'custom-vpc':
				case 'ec2-vpc':
					break;
			}


			break;
			//***** eni end *****//

		//***** asl_lc begin *****//
		case 'AWS.AutoScaling.LaunchConfiguration':

			var os_type = 'ami-unknown',
				volume_number = 0,
				icon_volume_status = 'not-attached';

			if (create_mode)
			{//write

				if(!option['launchConfig']){
					option.name = 'launchConfig';
					component_data = $.extend(true, {}, MC.canvas.ASL_LC_JSON.data);
					component_data.name = option.name;
					component_data.resource.LaunchConfigurationName = option.name;

					//show dragger
					MC.canvas.display(option.groupUId, 'asg_resource_dragger', true);

					// create new icon on resource panel
					$("#resource-asg-list").append($($("#resource-asg-list").children()[1]).clone());

					$($("#resource-asg-list").children()[$("#resource-asg-list").children().length-1]).children()
							.data('option', {"name": "asg", "launchConfig": group.id })
							.attr('data-option','{"name": "asg", "launchConfig":"'+group.id+'"}');

					$($($("#resource-asg-list").children()[$("#resource-asg-list").children().length-1]).children().children()[0]).text(option.name);

					MC.canvas_data.component[option.groupUId].resource.LaunchConfigurationName = '@' + group.id + '.resource.LaunchConfigurationName';
					//imageId
					component_data.resource.ImageId = option.imageId;

					//instanceType
					component_data.resource.InstanceType = 'm1.small';

					component_data.resource.KeyName = "@"+MC.canvas_property.kp_list[0].DefaultKP + ".resource.KeyName";
					component_data.resource.SecurityGroups.push("@"+MC.canvas_property.sg_list[0].uid + ".resource.GroupId");
					MC.canvas_property.sg_list[0].member.push(group.id);

					component_layout = $.extend(true, {}, MC.canvas.ASL_LC_JSON.layout);
					component_layout.groupUId = option.groupUId;
					component_layout.osType =  option.osType;
					component_layout.architecture =  option.architecture;
					component_layout.rootDeviceType =  option.rootDeviceType;
					component_layout.virtualizationType = option.virtualizationType;

					coordinate.x = MC.canvas.data.get('layout.component.group')[option.groupUId].coordinate[0] + 2;
					coordinate.y = MC.canvas.data.get('layout.component.group')[option.groupUId].coordinate[1] + 2;

				}
				else{

					component_data = $.extend(true, {}, MC.canvas_data.component[option['launchConfig']]);
					component_layout = $.extend(true, {}, MC.canvas_data.layout.component.node[option['launchConfig']]);
					component_layout.groupUId = option.groupUId;
					option.osType = component_layout.osType ;
					option.architecture = component_layout.architecture ;
					option.rootDeviceType = component_layout.rootDeviceType ;
					option.virtualizationType = component_layout.virtualizationType;
					//coordinate.x = component_layout.coordinate[0];
					//coordinate.y = component_layout.coordinate[1];
				}


				MC.canvas.display(option.groupUId, 'prompt_text', false);
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				if(!option['launchConfig']){
					$("#resource-asg-list").append($($("#resource-asg-list").children()[1]).clone());

					$($("#resource-asg-list").children()[$("#resource-asg-list").children().length-1]).children()
							.data('option', {"name": "asg", "launchConfig": group.id })
							.attr('data-option','{"name": "asg", "launchConfig":"'+group.id+'"}');

					$($($("#resource-asg-list").children()[$("#resource-asg-list").children().length-1]).children().children()[0]).text(option.name);
				}
				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.osType = component_layout.osType ;
				option.architecture = component_layout.architecture ;
				option.rootDeviceType = component_layout.rootDeviceType ;
				option.virtualizationType = component_layout.virtualizationType;
			}

			//os type
			os_type = option.osType + '.' + option.architecture + '.' + option.rootDeviceType;

			//check volume number,set icon
			volume_number = component_data.resource.BlockDeviceMapping.length;
			if (volume_number > 0)
			{
				icon_volume_status = 'attached-normal';
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width , height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/instance-canvas.png', 15, 11, 70, 70),

				//2 path: left port(blue)
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-instance-sg port-instance-sg-left',
					'transform': 'translate(8, 26)' + MC.canvas.PORT_RIGHT_ROTATE, //port position: right:0 top:-90 left:-180 bottom:-270
					'data-name': 'instance-sg', //for identify port
					'data-position': 'left', //port position: for calc point of junction
					'data-type': 'sg', //color of line
					'data-direction': 'in', //direction
					'data-angle': MC.canvas.PORT_LEFT_ANGLE //port angle: right:0 top:90 left:180 bottom:270
				}),

				//4 path: right port(blue)
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-instance-sg port-instance-sg-right',
					'transform': 'translate(84, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'instance-sg',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////7. os_type
				Canvon.image('../assets/images/ide/ami/' + os_type + '.png', 30, 15, 39, 27),

				////8.1 volume-attached
				Canvon.image('../assets/images/ide/icon/instance-volume-' + icon_volume_status + '.png' , 35, 48, 29, 24).attr({
					'id': group.id + '_volume_status'
				}),

				//8.2 volume number
				// Canvon.text(35, 60, volume_number).attr({
				// 	'class': 'node-label volume-number',
				// 	'id': group.id + '_volume_number'
				// }),

				//8.3 hot area for volume
				Canvon.rectangle(35, 48, 29, 24).attr({
					'class': 'instance-volume',
					'data-target-id': group.id,
					'fill': 'none'
				}),

				////10. lc name
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name',
					'id': group.id + '_lc_name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			if(!option['launchConfig']){
				component_data.uid = group.id;
				data[group.id] = component_data;
				MC.canvas.data.set('component', data);
			}
			$('#node_layer').append(group);

			break;
			//***** asl_lc end *****//
	}

	//set the node position
	MC.canvas.position(group, coordinate.x, coordinate.y);

	if (create_mode)
	{
		$("#svg_canvas").trigger("CANVAS_COMPONENT_CREATE", group.id);
	}

	return group;
};
