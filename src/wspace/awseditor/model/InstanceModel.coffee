
define [ "ComplexResModel", "Design", "constant", "i18n!/nls/lang.js", 'CloudResources' ], ( ComplexResModel, Design, constant, lang, CloudResources )->

  emptyArray = []

  Model = ComplexResModel.extend {

    type        : constant.RESTYPE.INSTANCE
    newNameTmpl : "host-"

    defaults : ()->
      #servergroup
      count  : 1

      imageId      : ''
      tenancy      : 'default'
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""

      volumeList : []

      # RootDevice
      rdSize : 0
      rdIops : 0
      rdType : 'gp2'

      cachedAmi : null

      state : null

    initialize : ( attr, option )->

      option = option || {}

      if option.cloneSource
        attr.imageId = option.cloneSource.get("imageId")

      console.assert( attr.imageId, "Invalid attributes when creating InstanceModel", attr )


      @setAmi( attr.imageId )

      # Create Eni0 if necessary
      if option.createByUser or option.cloneSource
        #create eni0
        EniModel = Design.modelClassForType( constant.RESTYPE.ENI )
        @setEmbedEni( new EniModel({
          name : "eni0"
          assoPublicIp : false
        }, { instance: this }) )


      # Clone the attributes if cloneSource is supplied.
      if option.cloneSource
        @clone( option.cloneSource )
      else if option.createByUser
        @initInstanceType()


      # Set rdSize if it's empty
      if not @get("rdSize")
        #append root device
        volSize = @getAmiRootDeviceVolumeSize()
        if volSize > 0
          @set("rdSize",volSize)

          # < need add volume of ami like root device, not support now >
          # append other volume in ami
          # amiInfo = @.getAmi()
          # volList = amiInfo.blockDeviceMapping
          # for key, vol of volList
          #   if key is amiInfo.rootDeviceName
          #     continue
          #   attribute =
          #     name : key
          #     snapshotId : vol.snapshotId
          #     volumeSize : vol.volumeSize
          #     volumeType : vol.volumeType
          #   if vol.volumeType is "io1"
          #     attribute.iops = vol.iops
          #   attribute.owner = @
          #   VolumeModel = Design.modelClassForType( constant.RESTYPE.VOL )
          #   new VolumeModel( attribute, {noNeedGenName:true})


      # Create additonal association if the instance is created by user.
      if option.createByUser and not option.cloneSource

        #assign DefaultKP
        KpModel = Design.modelClassForType( constant.RESTYPE.KP )
        defaultKp = KpModel.getDefaultKP()
        if defaultKp
          defaultKp.assignTo( this )
        else
          console.error "No DefaultKP found when initialize InstanceModel"


        #assign DefaultSG
        SgModel = Design.modelClassForType( constant.RESTYPE.SG )
        defaultSg = SgModel.getDefaultSg()
        if defaultSg
          SgAsso = Design.modelClassForType( "SgAsso" )
          new SgAsso( this, defaultSg )
        else
          console.error "No DefaultSG found when initialize InstanceModel"


      # Always setTenancy to insure we don't have micro type for dedicated.
      tenancy = @get("tenancy")
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()
      if vpc and not vpc.isDefaultTenancy() then tenancy = "dedicated"

      @setTenancy( tenancy )
      null

    groupMembers : ()->
      if not @__groupMembers then @__groupMembers = []
      return @__groupMembers

    getAvailabilityZone : ()->
      p = @parent()
      if p.type is constant.RESTYPE.SUBNET
        return p.parent()
      else
        return p

    getOSFamily : ()->
      ami = @getAmi() || @get("cachedAmi")
      if not ami or not ami.osType or not ami.osFamily
        console.warn "Cannot find ami infomation for instance :", this
        return "linux"

      if ami.osFamily then return ami.osFamily
      CloudResources( @design.credentialId(), constant.RESTYPE.AMI, @design.region() ).getOSFamily( ami.id )

    initInstanceType : ()->
      for i in @getInstanceTypeList()
        # Do not return t1.micro, because if vpc is dedicated, the instance
        # should be m1.small
        if i.name isnt "t1.micro"
          type = i.name
          break

      @attributes.instanceType = type || "m1.small"
      return

    getCost : ( priceMap, currency )->
      if not priceMap.instance then return null

      ami = @getAmi() || @get("cachedAmi")
      osType   = if ami then ami.osType else "linux-other"
      osFamily = @getOSFamily()

      instanceType = @get("instanceType").split(".")
      unit = priceMap.instance.unit
      fee  = priceMap.instance[ instanceType[0] ][ instanceType[1] ]
      fee  = if fee then fee.onDemand

      if fee
        if fee[ osFamily ] is undefined and osFamily.indexOf("mswin") is 0
          osFamily = "mswin"
        fee = fee[osFamily]

      fee  = if fee then fee[ currency ]

      if not fee then return null

      if unit is "perhr"
        formatedFee = fee + "/hr"
        fee *= 24 * 30
      else
        formatedFee = fee + "/mo"

      count = @get("count") or 1
      name  = @get("name")
      if count > 1
        name += " (x#{count})"
        fee  *= count

      priceObj =
          resource    : name
          type        : @get("instanceType")
          fee         : fee
          formatedFee : formatedFee

      if @get("monitoring")
        for t in priceMap.cloudwatch.types
          if t.ec2Monitoring
            fee = t.ec2Monitoring[ currency ]
            cw_fee =
              resource    : @get("name") + "-monitoring"
              type        : "CloudWatch"
              fee         : fee * count
              formatedFee : fee + "/mo"

            return [ priceObj, cw_fee ]

      return priceObj

    isReparentable : ( newParent )->
      if newParent.type is constant.RESTYPE.ASG or newParent.type is "ExpandedAsg"
        return false

      if newParent.type is constant.RESTYPE.SUBNET
        if newParent.parent() isnt @parent().parent()
          check = true
      else
        check = true

      # If changing the parent results in changing Instance's AZ, then
      # We need to check if there's connected Eni to this Instance.
      if check and @connectionTargets("EniAttachment").length > 0
        return lang.CANVAS.ERR_MOVE_ATTACHED_ENI

      true

    connect : ( cn )->
      if cn.type is "EniAttachment"
        # Disable auto assign public ip when connects to another eni.
        eni = @getEmbedEni()
        if eni then eni.set("assoPublicIp", false)

    setPrimaryEip : ( toggle )->
      eni = @getEmbedEni()
      if eni
        eni.setPrimaryEip( toggle )
      else
        @set("hasEip", toggle)
        if toggle
          if not @attributes.eipData
            @attributes.eipData = {}
          if not @attributes.eipData.id
            @attributes.eipData.id = MC.guid()
      return

    hasPrimaryEip : ()->
      eni = @getEmbedEni()
      if eni
        eni.hasPrimaryEip()
      else
        @get("hasEip")

    hasAutoAssignPublicIp: () ->
      @getEmbedEni().get 'assoPublicIp'

    setCount : ( count )->
      @set "count", count

      if count > 1
        # Remove route to Embed Eni ( Embed Eni routes is conencted to instance )
        route = @connections('RTB_Route')[0]
        if route then route.remove()

      # Update my self and connected Eni
      for eni in @connectionTargets("EniAttachment")
        if count > 1
          c.remove() for c in eni.connections("RTB_Route")
      null

    isDefaultTenancy : ()->
      VpcModel = Design.modelClassForType( constant.RESTYPE.VPC )
      vpc = VpcModel.allObjects()[0]
      if vpc and not vpc.isDefaultTenancy()
        return false
      else
        return @get("tenancy") isnt "dedicated"
      null

    setAmi : ( amiId )->
      @set "imageId", amiId

      # Update cached ami
      ami    = @getAmi()
      cached = @get("cachedAmi")
      if ami and cached
        cached.osType         = ami.osType
        cached.architecture   = ami.architecture
        cached.rootDeviceType = ami.rootDeviceType

      # Update RootDevice Size
      if ami and ami.blockDeviceMapping and not $.isEmptyObject(ami.blockDeviceMapping)
        rdName = ami.rootDeviceName
        rdEbs  = ami.blockDeviceMapping[ rdName ]
        if not rdEbs
        #rootDeviceName is partition
          _.each ami.blockDeviceMapping, (value,key) ->
            if rdName.indexOf(key) isnt -1 and not rdEbs
              rdEbs = value
            null

        minRdSize  = if rdEbs then parseInt( rdEbs.volumeSize, 10 ) else 10
        if @get("rdSize") < minRdSize
          @set("rdSize", minRdSize)

      # Assume the new amiId supports current instancetype
      # Assume the new amiId is the same OS of current one.

      # Check If the new amiId is supports current type
      # instance_type_list = MC.aws.ami.get Instance Type( @getAmi() )
      # instanceType = @get("instanceType")
      # for v in instance_type_list or []
      #   if v is instanceType
      #     support = true
      #     break
      # if not support then @initInstanceType()
      null

    getAmi : ()->
      ami = CloudResources( @design().credentialId(), constant.RESTYPE.AMI, @design().region() ).get( @get("imageId") )
      if ami
        ami.toJSON()
      else
        null

    getBlockDeviceMapping : ()->
      #get root device of current instance
      ami = @getAmi() || @get("cachedAmi")
      if ami and ami.rootDeviceType is "ebs" and ami.blockDeviceMapping and not $.isEmptyObject(ami.blockDeviceMapping)

        rdName = ami.rootDeviceName
        rdEbs  = ami.blockDeviceMapping[rdName]
        if not rdEbs
        #rootDeviceName is partition
          _.each ami.blockDeviceMapping, (value,key) ->
            if rdName.indexOf(key) isnt -1 and not rdEbs
              rdEbs = value
              rdName = key
            null

        blockDeviceMapping = [{
          DeviceName : rdName
          Ebs : {
            SnapshotId : rdEbs.snapshotId
            VolumeSize : @get("rdSize") || rdEbs.volumeSize
            VolumeType : @get 'rdType'
          }
        }]

        if @get("rdIops") and parseInt( @get("rdSize"), 10 ) >= 10
          blockDeviceMapping[0].Ebs.Iops = @get("rdIops")

      blockDeviceMapping || []

    getAmiRootDevice : () ->
      #get root deivce of ami
      amiInfo = @getAmi() || @get("cachedAmi")
      rd = null
      if amiInfo and amiInfo.rootDeviceType is "ebs" and amiInfo.blockDeviceMapping
        rdName = amiInfo.rootDeviceName
        rdEbs = amiInfo.blockDeviceMapping[rdName]

        if rdName and not rdEbs
        #rootDeviceName is partition
          _.each amiInfo.blockDeviceMapping, (value,key) ->
            if rdName.indexOf(key) isnt -1 and not rdEbs
              rdEbs  = value
              rdName = key
            null

        if rdName and rdEbs
          rd =
            "DeviceName": rdName
            "Ebs":
              "VolumeSize": Number(rdEbs.volumeSize)
              "SnapshotId": rdEbs.snapshotId
              "VolumeType": rdEbs.volumeType

          if rdEbs.volumeType is "io1"
            rd.Ebs.Iops = rdEbs.iops
        else

          console.warn "getAmiRootDevice(): can not found root device of AMI(" + @get("imageId") + ")", this
      rd

    getAmiRootDeviceVolumeSize : () ->
      volSize = 0
      amiInfo = @getAmi()
      if amiInfo
        if amiInfo.osType is "windows"
          volumeSize = 30
        else
          volumeSize = 10

        rd = @getAmiRootDevice()
        if rd
          volSize = rd.Ebs.VolumeSize
        else
          console.warn "getAmiRootDeviceVolumeSize(): use default volumeSize " + volSize , this
      else
        console.warn "getAmiRootDeviceVolumeSize(): unknown volumeSize for " + @get("imageId")
      volSize

    getAmiRootDeviceName : () ->
      rd = @getAmiRootDevice()
      if rd and rd.DeviceName then rd.DeviceName else ""

    getInstanceTypeConfig : ( type )->
      config = App.model.getInstanceTypeConfig( @design().region() )
      if config
        return config[ type || @get("instanceType") ]
      return null

    getMaxEniCount : ()->
      config = @getInstanceTypeConfig()
      if config then config = config.max_eni

      config or 16


    isEbsOptimizedEnabled : ()->

      ami = @getAmi() || @get("cachedAmi")
      if ami and ami.rootDeviceType is "instance-store"
        return false

      instanceType = @getInstanceTypeConfig()
      if instanceType and instanceType.ebs_optimized
        return instanceType.ebs_optimized is 'Yes'

      #default
      EbsMap =
        "m1.large"   : true
        "m1.xlarge"  : true
        "m2.2xlarge" : true
        "m2.4xlarge" : true
        "m3.xlarge"  : true
        "m3.2xlarge" : true
        "c1.xlarge"  : true
        "c3.xlarge"   : true
        "c3.2xlarge"  : true
        "c3.4xlarge"  : true
        "g2.2xlarge"  : true
        "i2.xlarge"   : true
        "i2.2xlarge"  : true
        "i2.4xlarge"  : true

      !!EbsMap[ @get("instanceType") ]

    setInstanceType : ( type )->

      # Ensure type is not t1.micro when using dedicated tenancy
      if type is "t1.micro" and not @isDefaultTenancy()
        type = "m1.small"

      @set("instanceType", type)
      if not @isEbsOptimizedEnabled()
        @set("ebsOptimized", false)

      # change encryted volume to false
      volumeList = @get('volumeList')
      if volumeList
        _.each volumeList, (vol) ->
          if not vol.isSupportEncrypted()
            vol.set('encrypted', false)
          null

      # Well, LC borrows setInstanceType of Instance,
      # but LC doesn't have getEmbedEni
      if @getEmbedEni
        # Eni's IP address count is limited by instanceType
        enis = @connectionTargets("EniAttachment")
        enis.push( @getEmbedEni() )
        for eni in enis
          eni.limitIpAddress()
      null

    setTenancy : ( tenancy )->
      @set "tenancy", tenancy

      if tenancy is "dedicated" and @get("instanceType") is "t1.micro"
        @initInstanceType()
      null

    getInstanceType : ()-> Model.getInstanceType( @getAmi(), @design().region() )

    getInstanceTypeList : ()->

      tenancy      = @isDefaultTenancy()
      instanceType = @get("instanceType")
      region       = @design().region()

      return _.map @getInstanceType(), ( value )->
        configs = App.model.getInstanceTypeConfig( region )
        if not configs then return {}
        configs = configs[ value ].formated_desc

        main     : configs[0]
        ecu      : configs[1]
        core     : configs[2]
        mem      : configs[3]
        name     : value
        selected : instanceType is value
        hide     : not tenancy and value is "t1.micro"

    remove : ()->
      if this.__mainEni
        this.__mainEni.remove()

      # Remove attached volumes
      for v in (@get("volumeList") or emptyArray).slice(0)
        v.remove()

      # In AppEdit Mode, we need to delete all eni associated to this Instance.
      if Design.instance().modeIsAppEdit()
        for eni in @connectionTargets("EniAttachment")
          eni.remove()

      ComplexResModel.prototype.remove.call this
      null

    isRemovable : ()->
      state = @get("state")
      if (state and _.isArray(state) and state.length > 0) or
        ($('#state-editor-model').is(':visible') and $('#state-editor-model .state-list .state-item').length >= 1)
          return MC.template.NodeStateRemoveConfirmation(name: @get("name"))

      true

    clone : ( srcTarget )->
      @cloneAttributes srcTarget, {
        reserve : "volumeList"
        copyConnection : [ "KeypairUsage", "SgAsso", "ElbAmiAsso" ]
      }

      # Update states id
      for state in @get("state") or []
        state.id = "state-" + @design().guid()

      # Copy volume
      Volume = Design.modelClassForType( constant.RESTYPE.VOL )
      for v in srcTarget.get("volumeList") or []
        new Volume( { owner : this }, { cloneSource : v } )

      # Copy Eni
      @getEmbedEni().clone( srcTarget.getEmbedEni() )
      null

    setEmbedEni : ( eni )->
      this.__mainEni = eni
      null

    getEmbedEni : ()-> this.__mainEni

    getRealGroupMemberIds : ()->
      @ensureEnoughMember()

      c = @get("count")
      members = [ this.id ]

      for mem in @groupMembers()
        if members.length >= c then break
        members.push mem.id

      members

    ensureEnoughMember : ()->
      totalCount = @get("count") - 1
      while @groupMembers().length < totalCount
        @groupMembers().push {
          id      : MC.guid()
          appId   : ""
          eipData : { id : MC.guid() }
        }
      null

    onParentChanged : () ->

      eniModel = @getEmbedEni()
      eniModel.onParentChanged() if eniModel

    generateJSON : ()->
      tenancy = @get("tenancy")

      p = @parent()
      if p.type is constant.RESTYPE.SUBNET
        vpc      = p.parent().parent()
        if not vpc.isDefaultTenancy()
          tenancy = "dedicated"

      name = @get("name")
      if @get("count") > 1 then name += "-0"

      # Generate RootDevice
      blockDeviceMapping = @getBlockDeviceMapping()

      ## remove this reference because volume already reference to instance
      #for volume in @get("volumeList") or []
      #  blockDeviceMapping.push "#"+volume.id

      component =
        type   : @type
        uid    : @id
        name   : name
        description : @get("description") or ""
        index  : 0
        number : @get("count")
        serverGroupUid  : @id
        serverGroupName : @get("name")
        state : @get("state")
        resource :
          UserData : {
            Base64Encoded : false
            Data : @get("userData")
          }
          BlockDeviceMapping : blockDeviceMapping
          Placement : {
            Tenancy : if tenancy is "dedicated" then "dedicated" else ""
            AvailabilityZone : @getAvailabilityZone().createRef()
          }
          InstanceId            : @get("appId")
          ImageId               : @get("imageId")
          KeyName               : @get("keyName")
          EbsOptimized          : if @isEbsOptimizedEnabled() then @get("ebsOptimized") else false
          VpcId                 : @getVpcRef()
          SubnetId              : @getSubnetRef()
          Monitoring            : if @get("monitoring") then "enabled" else "disabled"
          NetworkInterface      : []
          InstanceType          : @get("instanceType")
          DisableApiTermination : false
          ShutdownBehavior      : "terminate"
          SecurityGroup         : []
          SecurityGroupId       : []

      component

    createEipJson : ( eipData, instanceId )->
      instanceId = instanceId or this.id

      {
        uid   : eipData.id
        type  : constant.RESTYPE.EIP
        index : 0
        name  : "EIP"
        resource :
          Domain : "standard"
          InstanceId         : @createRef( "InstanceId", instanceId )
          AllocationId       : eipData.allocationId or ""
          NetworkInterfaceId : ""
          PublicIp           : eipData.publicIp or ""
      }

    getStateData : () ->

      @get("state")

    setStateData : (stateAryData) ->

      @set("state", stateAryData)

    setKey: ( keyName, defaultKey ) ->
      KpModel = Design.modelClassForType( constant.RESTYPE.KP )
      defaultKp = KpModel.getDefaultKP()

      if defaultKey
        if defaultKp
          defaultKp.assignTo( this )
        else
          console.error "No DefaultKP found when initialize InstanceModel"
      else
        kp = @connectionTargets( "KeypairUsage" )[0]
        kp and kp.dissociate @
        @set 'keyName', keyName


    getKeyName: ->
      kp = @connectionTargets( "KeypairUsage" )[0]

      if kp
        if kp.isDefault() then '$DefaultKeyPair' else kp.get('name')
      else
         @get( 'keyName' ) or lang.PROP.INSTANCE_NO_KP

    isDefaultKey: ->
      kp = @connectionTargets( "KeypairUsage" )[0]
      kp and kp.isDefault()

    isNoKey: ->
      kp = @connectionTargets( "KeypairUsage" )[0]
      not kp and not @get( 'keyName' )


    serialize : ()->

      allResourceArray = []

      ami    = @getAmi() || @get("cachedAmi")
      layout = @generateLayout()
      if ami
        layout.osType         = ami.osType
        layout.architecture   = ami.architecture
        layout.rootDeviceType = ami.rootDeviceType

      # Add this instance' layout first.
      allResourceArray.push( { layout : layout } )

      # Generate instance member.
      instances = [ @generateJSON() ]
      i = instances.length
      @ensureEnoughMember()

      while i < @get("count")
        member = $.extend true, {}, instances[0]
        member.name  = @get("name") + "-" + i
        member.index = i
        memberObj = @groupMembers()[ instances.length - 1 ]
        member.uid      = memberObj.id
        member.resource.InstanceId = memberObj.appId

        ++i
        instances.push( member )


      # Generate Volume
      serverGroupOption = { number : instances.length, instanceId : "" }
      volumeModels = @get("volumeList") || emptyArray
      eniModels    = if @getEmbedEni() then [ @getEmbedEni() ] else []
      for attach in @connections("EniAttachment")
        eniModels[ attach.get("index") ] = attach.getOtherTarget( this )

      volumes = []
      enis    = []
      for instance, idx in instances

        serverGroupOption.instanceId   = instance.uid
        serverGroupOption.instanceName = instance.name + "-"

        for volume in volumeModels
          v = volume.generateJSON( idx, serverGroupOption )
          volumes.push( v )

        for eni, eniIndex in eniModels
          # The generate JSON might be something like : [ EniObject, EipObject, EipObject ]
          enis = enis.concat eni.generateJSON( idx, serverGroupOption, eniIndex )

      for res in instances.concat( volumes ).concat( enis )
        allResourceArray.push( { component : res } )

      return allResourceArray

  }, {

    handleTypes : constant.RESTYPE.INSTANCE

    getInstanceType : ( ami, region )->
      if not ami or not region then return []

      data = App.model.getOsFamilyConfig( region )
      try
        data = data[ ami.osFamily ] || data[ constant.OS_TYPE_MAPPING[ami.osType] ]
        data = if ami.rootDeviceType  is "ebs" then data.ebs else data.instance_store
        data = data[ ami.architecture ]
        data = data[ ami.virtualizationType || "paravirtual" ]
      catch e
        console.error "Invalid instance type list data", ami, App.model.getOsFamilyConfig( region )
        data = []

      data || []

    # parameter could be uid or aws id
    # return uid and mid( memberId )
    getEffectiveId : ( instance_id ) ->
      design = Design.instance()

      # The instance_id might be component uid or aws id
      if design.component( instance_id ) then return {uid:instance_id, mid:null}

      insAndEniAry = Design.modelClassForType( constant.RESTYPE.INSTANCE ).allObjects()
      insAndEniAry = insAndEniAry.concat(Design.modelClassForType( constant.RESTYPE.ENI ).allObjects())

      for instance in insAndEniAry
        if instance.get("appId") is instance_id
          return { uid : instance.id, mid : "#{instance.id}_0" }
        else if instance.groupMembers
          for member, index in instance.groupMembers()
            if member and member.appId is instance_id
              return { uid : instance.id, mid : "#{member.id}_#{index + 1}" }

      resource_list = CloudResources( design.credentialId(), constant.RESTYPE.ASG, design.region())
      for asg in Design.modelClassForType( constant.RESTYPE.ASG ).allObjects()
        data = resource_list.get(asg.get('appId'))?.toJSON()
        if not data or not data.Instances then continue
        data = data.Instances
        for obj in (data.member or data)
          if obj is instance_id or obj.InstanceId is instance_id
            return { uid : asg.getLc().id, mid : instance_id }

      {uid:null,mid:null}


    deserialize : ( data, layout_data, resolve )->

      # Compact instance for servergroup
      if data.serverGroupUid and data.serverGroupUid isnt data.uid
        members = resolve( data.serverGroupUid ).groupMembers()
        for m in members
          if m and m.id is data.uid
            console.debug "This instance servergroup member has already deserialized", data
            return

        if data.resource.EipResource
          eipData = {
            id            : data.resource.EipResource.uid
            allocationId  : data.resource.EipResource.resource.AllocationId
            publicIp      : data.resource.EipResource.resource.PublicIp
          }

        members[data.index-1] = {
          id      : data.uid
          appId   : data.resource.InstanceId
          eipData : eipData || { id : MC.guid() }
        }
        return


      rootDevice = data.resource.BlockDeviceMapping[0]
      if not rootDevice or _.isString( rootDevice )
        rootDevice =
          Ebs :
            VolumeSize : 0
            Iops : ""

      #old format state support
      if not (_.isArray(data.state) and data.state.length)
        data.state = null

      attr =
        id    : data.uid
        name  : data.serverGroupName or data.name
        description : data.description or ""
        appId : data.resource.InstanceId
        count : data.number

        imageId      : data.resource.ImageId
        tenancy      : data.resource.Placement.Tenancy
        ebsOptimized : data.resource.EbsOptimized
        instanceType : data.resource.InstanceType
        monitoring   : data.resource.Monitoring isnt "disabled"
        userData     : data.resource.UserData.Data or ""

        rdSize : rootDevice.Ebs.VolumeSize
        rdIops : rootDevice.Ebs.Iops
        rdType : rootDevice.Ebs.VolumeType

        parent : resolve( layout_data.groupUId )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

        state : data.state

      if data.resource.EipResource
        attr.hasEip  = true
        attr.eipData = {
          id : data.resource.EipResource.uid
          allocationId : data.resource.EipResource.resource.AllocationId
        }

      if layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        #patch for old windows ami
        if layout_data.osType is "win"
          layout_data.osType = "windows"

        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      model = new Model( attr )

      # Add Keypair
      kpUid = MC.extractID( data.resource.KeyName )
      if kpUid and kpUid isnt data.resource.KeyName
        KP = resolve( kpUid )

      if KP
        KP.assignTo( model )
      else
        model.set 'keyName', data.resource.KeyName

      null
  }

  Model
