
define [ "../ComplexResModel", "./InstanceModel", "Design", "constant", "./VolumeModel", 'i18n!nls/lang.js' ], ( ComplexResModel, InstanceModel, Design, constant, VolumeModel, lang )->

  emptyArray = []

  Model = ComplexResModel.extend {

    defaults : ()->
      x        : 0
      y        : 0
      width    : 9
      height   : 9

      imageId      : ""
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""
      publicIp     : Design.instance().typeIsDefaultVpc()
      state        : undefined

      # RootDevice
      rdSize : 10
      rdIops : ""

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
    newNameTmpl : "launch-config-"

    constructor : ( attr, option )->
      if option and option.createByUser and attr.parent.get("lc")
          return

      ComplexResModel.call( this, attr, option )

    initialize : ( attr, option )->
      # Draw before create SgAsso
      @draw(true)

      if option and option.createByUser

        @initInstanceType()

        # Default Kp
        KpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )
        KpModel.getDefaultKP().assignTo( this )

        # Default Sg
        defaultSg = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).getDefaultSg()
        SgAsso = Design.modelClassForType( "SgAsso" )
        new SgAsso( defaultSg, this )

        #append root device
        @set("rdSize",@getAmiRootDeviceVolumeSize())

      null

    getNewName : ( base )->
      if not @newNameTmpl
        newName = if @defaults then @defaults.name
        return newName or ""

      if base is undefined
        myKinds = Design.modelClassForType( @type ).allObjects()
        base = myKinds.length

      # Collect all the resources name
      nameMap = {}
      @design().eachComponent ( comp )->
        if comp.get("name")
          nameMap[ comp.get("name") ] = true
        null

      if Design.instance().modeIsAppEdit()
        resource_list = MC.data.resource_list[Design.instance().region()]
        for id, rl of resource_list
          if rl.LaunchConfigurationName
            nameMap[ _.first rl.LaunchConfigurationName.split( '---' ) ] = true



      while true
        newName = @newNameTmpl + base
        if nameMap[ newName ]
          base += 1
        else
          break

      newName

    isRemovable : () ->
      if @design().modeIsAppEdit() and @get("appId")
        return error : lang.ide.CVS_MSG_ERR_DEL_LC

      state = @get("state")
      if state isnt undefined and state.length > 0
        return MC.template.NodeStateRemoveConfirmation(name: @get("name"))

      true

    isDefaultTenancy : ()-> true

    # Use by CanvasElement
    groupMembers : ()->
      resource_list = MC.data.resource_list[ Design.instance().region() ]
      if not resource_list then return []

      resource = resource_list[ @parent().get("appId") ]

      if resource and resource.Instances and resource.Instances.member
        amis = []
        for i in resource.Instances.member
          amis.push {
            id    : i.InstanceId
            appId : i.InstanceId
            state : i.HealthStatus
          }

      amis || []

    remove : ()->
      # Remove attached volumes
      for v in (@get("volumeList") or emptyArray).slice(0)
        v.remove()

      ComplexResModel.prototype.remove.call this
      null

    connect : ( cn )->
      if @parent() and cn.type is "SgRuleLine"
        # Create duplicate sgline for each expanded asg
        @parent().updateExpandedAsgSgLine( cn.getOtherTarget(@) )

      null

    disconnect : ( cn )->
      if @parent()
        if cn.type is "ElbAmiAsso"
          # No need to reset Asg's healthCheckType to EC2, when disconnected from Elb
          # Because user might just want to asso another Elb right after disconnected.
          # @parent().updateExpandedAsgAsso( cn.getOtherTarget(@), true )

        else if cn.type is "SgRuleLine"
          @parent().updateExpandedAsgSgLine( cn.getOtherTarget(@), true )
      null

    getStateData : () ->
      @get("state")

    setStateData : (stateAryData) ->
      @set("state", stateAryData)

    setAmi                : InstanceModel.prototype.setAmi
    getAmi                : InstanceModel.prototype.getAmi
    getDetailedOSFamily   : InstanceModel.prototype.getDetailedOSFamily
    setInstanceType       : InstanceModel.prototype.setInstanceType
    initInstanceType      : InstanceModel.prototype.initInstanceType
    isEbsOptimizedEnabled : InstanceModel.prototype.isEbsOptimizedEnabled
    getBlockDeviceMapping : InstanceModel.prototype.getBlockDeviceMapping
    getAmiRootDevice           : InstanceModel.prototype.getAmiRootDevice
    getAmiRootDeviceName       : InstanceModel.prototype.getAmiRootDeviceName
    getAmiRootDeviceVolumeSize : InstanceModel.prototype.getAmiRootDeviceVolumeSize

    serialize : ()->

      ami = @getAmi() || @get("cachedAmi")
      layout = @generateLayout()
      if ami
        layout.osType         = ami.osType
        layout.architecture   = ami.architecture
        layout.rootDeviceType = ami.rootDeviceType


      sgarray = _.map @connectionTargets("SgAsso"), ( sg )-> sg.createRef( "GroupId" )

      blockDevice = []
      for volume in @get("volumeList") or emptyArray

        #Check RootDevice
        if volume.get("name") is @getAmiRootDeviceName()
          hasRootDevice = true
          continue

        vd =
          DeviceName : volume.get("name")
          Ebs :
            VolumeSize : volume.get("volumeSize")
            VolumeType : volume.get("volumeType")

        if volume.get("volumeType") is "io1"
          vd.Ebs.Iops = volume.get("iops")

        if volume.get("snapshotId")
          vd.Ebs.SnapshotId = volume.get("snapshotId")

        blockDevice.push vd

      if !hasRootDevice
        # Append RootDevice
        rd = @getAmiRootDevice()
        if rd
          blockDevice.splice 0, 0, rd


      component =
        type : @type
        uid  : @id
        name : @get("name")
        state : @get("state")
        resource :
          UserData                 : @get("userData")
          LaunchConfigurationARN   : @get("appId")
          InstanceMonitoring       : @get("monitoring")
          ImageId                  : @get("imageId")
          EbsOptimized             : if @isEbsOptimizedEnabled() then @get("ebsOptimized") else false
          BlockDeviceMapping       : blockDevice
          KeyName                  : ""
          SecurityGroups           : sgarray
          LaunchConfigurationName  : @get("configName") or @get("name")
          InstanceType             : @get("instanceType")
          AssociatePublicIpAddress : @get("publicIp")


      { component : component, layout : layout }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

    deserialize : ( data, layout_data, resolve )->

      attr = {
        id    : data.uid
        name  : data.name
        state : data.state
        appId : data.resource.LaunchConfigurationARN

        imageId      : data.resource.ImageId
        ebsOptimized : data.resource.EbsOptimized
        instanceType : data.resource.InstanceType
        monitoring   : data.resource.InstanceMonitoring
        userData     : data.resource.UserData
        publicIp     : data.resource.AssociatePublicIpAddress
        configName   : data.resource.LaunchConfigurationName

        createdTime   : data.resource.CreatedTime

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      }

      if layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      model = new Model( attr )


      # Create Volume for
      for volume in data.resource.BlockDeviceMapping || []
        _attr =
          name       : volume.DeviceName
          snapshotId : volume.Ebs.SnapshotId
          volumeSize : volume.Ebs.VolumeSize
          owner      : model

        new VolumeModel(_attr, {noNeedGenName:true})

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.SecurityGroups || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

      # Add Keypair
      resolve( MC.extractID( data.resource.KeyName ) ).assignTo( model )
      null
  }

  Model

