#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'event', 'i18n!nls/lang.js' ], ( PropertyModel, constant, ide_event, lang ) ->

	InstanceModel = PropertyModel.extend {

		init : ( uid ) ->

			component = Design.instance().component( uid )

			attr = component.toJSON()
			attr.uid = uid
			attr.classic_stack  = not Design.instance().typeIsVpc()
			attr.can_set_ebs    = component.isEbsOptimizedEnabled()
			attr.instance_type  = component.getInstanceTypeList()
			attr.tenancy        = component.isDefaultTenancy()
			attr.displayCount   = attr.count - 1
			attr.defaultVpc     = Design.instance().typeIsDefaultVpc()

			eni = component.getEmbedEni()
			attr.number_disable = eni and eni.connections('RTB_Route').length > 0

			# If Vpc is dedicated, instance should be dedicated.
			vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).allObjects()[0]
			attr.force_tenacy = vpc and not vpc.isDefaultTenancy()

			@set attr

			@getAmi()
			@getKeyPair()
			@getEni()
			null

		getKeyPair : ()->
			selectedKP = Design.instance().component(@get("uid")).connectionTargets("KeypairUsage")[0]

			@set "keypair", selectedKP.getKPList()
			null

		addKP : ( kp_name ) ->

			KpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )

			for kp in KpModel.allObjects()
				if kp.get("name") is kp_name
					return false

			kp = new KpModel( { name : kp_name } )
			kp.id

		deleteKP : ( kp_uid ) ->
			Design.instance().component( kp_uid ).remove()
			null

		setKP : ( kp_uid ) ->
			design  = Design.instance()
			instance = design.component( @get("uid") )
			design.component( kp_uid ).assignTo( instance )
			null

		setCount : ( val ) ->
			Design.instance().component( @get("uid") ).setCount( val )

		setEbsOptimized : ( value )->
			Design.instance().component( @get("uid") ).set( "ebsOptimized", value )

		setTenancy : ( value ) ->
			Design.instance().component( @get("uid") ).setTenancy( value )

		setMonitoring : ( value ) ->
			Design.instance().component( @get("uid") ).set( "monitoring", value )

		setUserData : ( value ) ->
			Design.instance().component( @get("uid") ).set( "userData", value )

		setEniDescription: ( value ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().set("description", value)

		setSourceCheck : ( value ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().set("sourceDestCheck", value)

		setPublicIp : ( value ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().set("assoPublicIp", value)

		getAmi : () ->
			ami_id = @get("imageId")
			ami    = Design.instance().component( @get("uid") ).getAmi()

			if not ami
				data = {
					name        : ami_id + " is not available."
					icon        : "ami-not-available.png"
					unavailable : true
				}
			else
				data = {
					name : ami.name
					icon : ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
				}

			@set 'instance_ami', data
			null

		canSetInstanceType : ( value ) ->
			instance   = Design.instance().component( @get("uid") )
			eni_number = instance.connectionTargets("EniAttachment").length + 1
			config     = instance.getInstanceTypeConfig()

			max_eni_num = if config then config.eni else 2

			if eni_number <= 2 or eni_number <= max_eni_num
				return true

			return sprintf lang.ide.PROP_WARN_EXCEED_ENI_LIMIT, value, max_eni_num

		setInstanceType  : ( value ) ->
			instance = Design.instance().component( @get("uid") )
			instance.setInstanceType( value )

			# Update IP List
			@getEni()
			instance.isEbsOptimizedEnabled()

		getEni : () ->
			instance = Design.instance().component(@get("uid"))

			eni = instance.getEmbedEni()
			if not eni then return

			eni_obj     = eni.toJSON()
			eni_obj.ips = eni.getIpArray()
			eni_obj.ips[0].unDeletable = true

			@set "eni", eni_obj
			@set "multi_enis", instance.connections("EniAttachment").length > 0
			null




		attachEip : ( eip_index, attach ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().setIp( eip_index, null, null, attach )
			@attributes.eni.ips[ eip_index ].hasEip = attach

			if attach
				Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway ).tryCreateIgw()
			null

		removeIp : ( index ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().removeIp( index )
			null

		addIp : () ->
			comp = Design.instance().component( @get("uid") ).getEmbedEni()
			comp.addIp()

			ips = comp.getIpArray()
			ips[0].unDeletable = true

			@get("eni").ips = ips
			null

		isValidIp : ( ip )->
			Design.instance().component( @get("uid") ).getEmbedEni().isValidIp( ip )

		canAddIP : ()->
			Design.instance().component( @get("uid") ).getEmbedEni().canAddIp()

		setIp : ( idx, ip, autoAssign )->
			Design.instance().component( @get("uid") ).getEmbedEni().setIp( idx, ip, autoAssign )
			null
	}

	new InstanceModel()
