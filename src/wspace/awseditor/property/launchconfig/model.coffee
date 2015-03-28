#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'Design', "CloudResources" ], ( PropertyModel, constant, Design, CloudResources ) ->

  LaunchConfigModel = PropertyModel.extend {

    initialize : ->
      me = this
      this.on 'EC2_KPDOWNLOAD_RETURN', ( result )->

        region_name = result.param[3]
        keypairname = result.param[4]

        # The user has closed the dialog
        # Do nothing
        if me.get("keyName") isnt keypairname
            return

        ###
        # The EC2_KPDOWNLOAD_RETURN event won't fire when the result.is_error
        # is true. According to bugs in service models.
        ###

        me.trigger "KP_DOWNLOADED", result.resolved_data

        null

    init  : ( uid ) ->
      @lc = Design.instance().component( uid )
      if not @lc then return false

      data = @lc.toJSON()
      data.uid = uid
      data.isEditable = @isAppEdit
      data.app_view = Design.instance().modeIsAppView()

      if @lc.isMesos()
        mesosData = {
          isMesos         : true
          mesosAttr       : @lc.getMesosAttributes()
          defaultMesosAttr: @lc.getDefaultMesosAttributes()
        }
        _.extend data, mesosData

      @set data

      @set "displayAssociatePublicIp", true
      @set "monitorEnabled", true
      @set "can_set_ebs", @lc.isEbsOptimizedEnabled()
      @getInstanceType()
      @getAmi()
      @getKeyPair()

      # if stack enable agent
      design = Design.instance()
      agentData = design.get('agent')
      @set "stackAgentEnable", agentData.enabled



      if @isApp
        @getAppLaunch( uid )
        kp = @lc.connectionTargets( 'KeypairUsage' )[ 0 ]
        @set 'keyName', kp and kp.get("appId") or @lc.get 'keyName'

        #RootDevice Data
        rootDevice = @lc.getBlockDeviceMapping()
        if rootDevice.length is 1
          @set "rootDevice", rootDevice[0]
        return



      null

    getInstanceType : ( uid, data ) ->

      instanceType = @lc.get 'instanceType'
      region = Design.instance().region()

      view_instance_type = _.map @lc.getInstanceType(), ( value )->
        configs = App.model.getInstanceTypeConfig( region )
        if not configs then return {}
        configs = configs[ value ].formated_desc

        main     : configs[0]
        ecu      : configs[1]
        core     : configs[2]
        mem      : configs[3]
        name     : value
        selected : instanceType is value

      @set "instance_type", view_instance_type
      null

    setEbsOptimized : ( value )->
      @lc.set 'ebsOptimized', value

    setCloudWatch : ( value ) ->
      @lc.set 'monitoring', value

    setUserData : ( value ) ->
      @lc.set 'userData', value

    setPublicIp : ( value )->
      @lc.set "publicIp", value
      if value
        Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()

    setInstanceType  : ( value ) ->
      @lc.setInstanceType( value )
      @lc.isEbsOptimizedEnabled()

    getAmi : () ->
      ami_id = @get("imageId")
      comp   = Design.instance().component( @get("uid") )
      ami    = @lc.getAmi()

      if not ami
        data = {
          name        : ami_id + " is not available."
          icon        : "ami-not-available.png"
          unavailable : true
        }
      else
        data = {
          name : ami.name or ami.description or ami.id
          icon : ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
        }

      @set 'instance_ami', data


      if ami and ami.blockDeviceMapping and not $.isEmptyObject(ami.blockDeviceMapping)
        rdName = ami.rootDeviceName
        rdEbs  = ami.blockDeviceMapping[ rdName ]
        if rdName and not rdEbs
        #rootDeviceName is partition
          _.each ami.blockDeviceMapping, (value,key) ->
            if rdName.indexOf(key) isnt -1 and not rdEbs
              rdEbs  = value
              rdName = key
              null
          null

        deviceType = comp.get("rdType")

        rootDevice =
          name : rdName
          size : parseInt( comp.get("rdSize"), 10 )
          iops : comp.get("rdIops")
          # encrypted : rdEbs.encrypted
          isStandard: deviceType is 'standard'
          isIo1 : deviceType is 'io1'
          isGp2 : deviceType is 'gp2'

        if rootDevice.size < 10
          rootDevice.iops = ""
          rootDevice.iopsDisabled = true
        @set "rootDevice", rootDevice

      @set "min_volume_size", comp.getAmiRootDeviceVolumeSize()

      null

    getKeyPair : ()->
      selectedKP = Design.instance().component(@get("uid")).connectionTargets("KeypairUsage")[0]
      if selectedKP
        @set "keypair", selectedKP.getKPList()
      null

    addKP : ( kp_name ) ->

      KpModel = Design.modelClassForType( constant.RESTYPE.KP )

      for kp in KpModel.allObjects()
        if kp.get("name") is kp_name
          return false

      kp = new KpModel( { name : kp_name } )
      kp.id

    setKP : ( kp_uid ) ->
      design  = Design.instance()
      instance = design.component( @get("uid") )
      design.component( kp_uid ).assignTo( instance )
      null

    isSGListReadOnly : ()->
      if @get 'appId'
        true

    getAppLaunch : ( uid ) ->
      lc_data = CloudResources(Design.instance().credentialId(), constant.RESTYPE.LC, Design.instance().region()).get(@lc.get('appId'))?.toJSON()

      this.set "ebsOptimized", @lc.get("ebsOptimized") + ""
      this.set 'name', @lc.get 'name'
      this.set 'lc',   lc_data
      this.set 'uid',  uid
      null

    getStateData : () ->
      Design.instance().component( @get("uid") ).getStateData()

    setIops : ( iops )->
      Design.instance().component( @get("uid") ).set("rdIops", iops)
      null

    setVolumeType: ( type ) ->
      Design.instance().component( @get("uid") ).set("rdType", type)
      null

    setVolumeSize : ( size )->
      Design.instance().component( @get("uid") ).set("rdSize", size)
      null

  }

  new LaunchConfigModel()
