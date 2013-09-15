#############################
#  View Mode for design/property/instance
#############################

define [ 'keypair_model', 'constant', 'event', 'backbone', 'jquery', 'underscore', 'MC' ], ( keypair_model, constant, ide_event) ->

  EbsMap =
    "m1.large"   : true
    "m1.xlarge"  : true
    "m2.2xlarge" : true
    "m2.4xlarge" : true
    "m3.xlarge"  : true
    "m3.2xlarge" : true
    "c1.xlarge"  : true

  LaunchConfigModel = Backbone.Model.extend {

    defaults :
      'uid'         : null
      'name'        : null
      'update_instance_title' : null
      'instance_type' : null
      'instance_ami' : null
      'instance_ami_property' : null
      'keypair' : null
      'component' : null
      'sg_display' : null
      'checkbox_display' : null
      'eni_display'   : null
      'ebs_optimized' : null
      'cloudwatch' : null
      'user_data' : null
      'base64'    :  null
      'eni_description' : null
      'source_check' : null
      'add_sg'   : null
      'remove_sg' : null

    listen : ->
      #listen
      this.listenTo this, 'change:name', this.setName
      this.listenTo this, 'change:ebs_optimized', this.setEbsOptimized
      this.listenTo this, 'change:cloudwatch', this.setCloudWatch
      this.listenTo this, 'change:user_data', this.setUserData
      this.listenTo this, 'change:eni_description' , this.setEniDescription
      this.listenTo this, 'change:source_check', this.setSourceCheck
      this.listenTo this, 'change:add_sg', this.addSGtoInstance
      this.listenTo this, 'change:remove_sg', this.removeSG

      me = this
      this.on 'EC2_KPDOWNLOAD_RETURN', ( result )->

        region_name = result.param[3]
        keypairname = result.param[4]

        curr_keypairname = me.get("lc")

        # The user has closed the dialog
        # Do nothing
        if curr_keypairname.KeyName isnt keypairname
            return

        ###
        # The EC2_KPDOWNLOAD_RETURN event won't fire when the result.is_error
        # is true. According to bugs in service models.
        ###

        me.trigger "KP_DOWNLOADED", result.resolved_data

        null


    downloadKP : ( keypairname ) ->
        username = $.cookie "usercode"
        session  = $.cookie "session_id"

        keypair_model.download {sender:@}, username, session, MC.canvas_data.region, keypairname
        null


    getUID  : ( uid ) ->
      console.log 'getUID'
      lsgUID = MC.canvas_data.component[ uid ].uid
      this.set 'get_uid', lsgUID
      this.set 'uid', lsgUID
      null

    setName  : () ->
      console.log 'setName'

      uid = this.get 'get_uid'

      name = this.get 'name'

      MC.canvas_data.component[ uid ].name = name

      MC.canvas.update(uid,'text','lc_name', name)

      # update lc in extended asg
      asg_uid = MC.canvas_data.layout.component.node[ uid ].groupUId

      _.each MC.canvas_data.layout.component.group, ( group, id ) ->
        if group.originalId is asg_uid
          MC.canvas.update id, 'text', 'node-label', name
      null


    getName  : () ->
      console.log 'getName'
      this.set 'name', MC.canvas_data.component[ this.get( 'get_uid' )].name
      null

    setInstanceType  : ( value ) ->
      uid = this.get 'get_uid'
      component = MC.canvas_data.component[ uid ]

      component.resource.InstanceType = value

      has_ebs = EbsMap.hasOwnProperty value
      if not has_ebs
        component.resource.EbsOptimized = "false"

      has_ebs

    setEbsOptimized : ( value )->

      uid = this.get 'get_uid'

      #console.log 'setEbsOptimized = ' + value

      MC.canvas_data.component[ uid ].resource.EbsOptimized = this.get 'ebs_optimized'

      null

    setCloudWatch : () ->

      #console.log 'setCloudWatch = ' + value

      uid = this.get 'get_uid'

      if this.get 'cloudwatch'

        MC.canvas_data.component[ uid ].resource.InstanceMonitoring = 'enabled'

      else
        MC.canvas_data.component[ uid ].resource.InstanceMonitoring = 'disabled'


      null

    setUserData : () ->

      #console.log 'setUserData = ' + value

      uid = this.get 'get_uid'

      MC.canvas_data.component[ uid ].resource.UserData = this.get 'user_data'

      null

    setEniDescription: () ->

      #console.log 'setEniDescription = ' + value

      uid = this.get 'get_uid'

      that = this

      _.map MC.canvas_data.component, ( val, key ) ->

        if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

          val.resource.Description = that.get 'eni_description'

        null

      null

    setSourceCheck : () ->

      #console.log 'setSourceCheck = ' + value
      me = this

      uid = this.get 'get_uid'

      _.map MC.canvas_data.component, ( val, key ) ->

        if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

          val.resource.SourceDestCheck = me.get 'source_check'

        null

      null

    unAssignSGToComp : (sg_uid) ->

      lcUID = this.get 'get_uid'

      originSGIdAry = MC.canvas_data.component[lcUID].resource.SecurityGroups

      currentSGId = '@' + sg_uid + '.resource.GroupId'

      originSGIdAry = _.filter originSGIdAry, (value) ->
        value isnt currentSGId

      MC.canvas_data.component[lcUID].resource.SecurityGroups = originSGIdAry


      null

    assignSGToComp : (sg_uid) ->

      instanceUID = this.get 'get_uid'

      originSGIdAry = MC.canvas_data.component[instanceUID].resource.SecurityGroups

      currentSGId = '@' + sg_uid + '.resource.GroupId'


      if !Boolean(currentSGId in originSGIdAry)
        originSGIdAry.push currentSGId

      MC.canvas_data.component[instanceUID].resource.SecurityGroups = originSGIdAry

      null

    getCheckBox : () ->

      uid = this.get 'get_uid'

      checkbox = {}

      resource = MC.canvas_data.component[ uid ].resource

      checkbox.ebsOptimized = "" + resource.EbsOptimized is 'true'
      checkbox.monitoring   = resource.InstanceMonitoring is 'enabled'

      watches = []
      asg = null
      monitorEnabled = true
      for id, comp of MC.canvas_data.component
        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch
          watches.push comp
        else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
          if comp.resource.LaunchConfigurationName.indexOf( uid ) != -1
            asg = comp

      for watch in watches
        if watch.resource.MetricName.indexOf("StatusCheckFailed") != -1
          for d in watch.resource.Dimensions
            if d.value and d.value.indexOf( asg.uid ) != -1
              monitorEnabled = false
              break

          if not monitorEnabled
            break

      checkbox.monitorEnabled = monitorEnabled

      this.set 'checkbox_display', checkbox

    getComponent : () ->

      this.set 'component', MC.canvas_data.component[ this.get( 'get_uid') ]

    getAmi : () ->

      uid = this.get 'get_uid'

      ami_id = MC.canvas_data.component[ uid ].resource.ImageId

      this.set 'instance_ami_property', JSON.stringify(MC.data.dict_ami[ami_id])

    getAmiDisp : () ->

      uid = this.get 'get_uid'

      disp = {}

      ami_id = MC.canvas_data.component[ uid ].resource.ImageId

      disp.name = MC.data.dict_ami[ami_id].name

      disp.icon = MC.data.dict_ami[ami_id].osType + '.' + MC.data.dict_ami[ami_id].architecture + '.' + MC.data.dict_ami[ami_id].rootDeviceType + ".png"

      this.set 'instance_ami', disp

    getKeyPair : ()->

      uid = this.get 'get_uid'
      keypair_id = MC.extractID MC.canvas_data.component[ uid ].resource.KeyName

      kp_list = MC.aws.kp.getList( keypair_id )

      this.set 'keypair', kp_list

      null

    addKP : ( kp_name ) ->

      result = MC.aws.kp.add kp_name

      if not result
        return result

      uid = @get 'get_uid'
      MC.canvas_data.component[ uid ].resource.KeyName = "@#{result}.resource.KeyName"
      true

    deleteKP : ( key_name ) ->

      MC.aws.kp.del key_name

      # Update data of this model
      for kp, idx in @attributes.keypair
        if kp.name is key_name
          @attributes.keypair.splice idx, 1
          break

      null

    setKP : ( key_name ) ->

      uid = this.get 'get_uid'
      MC.canvas_data.component[ uid ].resource.KeyName = "@#{MC.canvas_property.kp_list[key_name]}.resource.KeyName"

      null

    getInstanceType : () ->

      uid = this.get 'get_uid'

      ami_info = MC.canvas_data.layout.component.node[ uid ]

      current_instance_type = MC.canvas_data.component[ uid ].resource.InstanceType

      view_instance_type = _.map this._getInstanceType( ami_info ), ( value )->

        main     : constant.INSTANCE_TYPE[value][0]
        ecu      : constant.INSTANCE_TYPE[value][1]
        core     : constant.INSTANCE_TYPE[value][2]
        mem      : constant.INSTANCE_TYPE[value][3]
        name     : value
        selected : current_instance_type is value

      this.set 'instance_type', view_instance_type
      this.set 'can_set_ebs',   EbsMap.hasOwnProperty current_instance_type

    _getInstanceType : ( ami ) ->
      instance_type = MC.data.instance_type[MC.canvas_data.region]
      if ami.virtualizationType == 'hvm'
        instance_type = instance_type.windows
      else
        instance_type = instance_type.linux
      if ami.rootDeviceType == 'ebs'
        instance_type = instance_type.ebs
      else
        instance_type = instance_type['instance store']
      if ami.architecture == 'x86_64'
        instance_type = instance_type["64"]
      else
        instance_type = instance_type["32"]
      instance_type = instance_type[ami.virtualizationType]

      instance_type

    removeSG : () ->

      uid = this.get 'get_uid'

      sg_uid = this.get 'remove_sg'

      sg_id_ref = "@"+sg_uid+'.resource.GroupId'

      if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

        sg_ids = MC.canvas_data.component[ uid ].resource.SecurityGroupId

        if sg_ids.length != 1

          sg_ids.splice sg_ids.indexOf sg_id_ref, 1

          $.each MC.canvas_property.sg_list, ( key, value ) ->

            if value.uid == sg_uid

              index = value.member.indexOf uid

              value.member.splice index, 1

              # delete member 0 sg

              if value.member.length == 0 and value.name != 'DefaultSG'

                MC.canvas_property.sg_list.splice key, 1

                delete MC.canvas_data.component[sg_uid]

                $.each MC.canvas_data.component, ( key, comp ) ->

                  if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

                    $.each comp.resource.IpPermissions, ( i, rule ) ->

                      if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                        MC.canvas_data.component[key].resource.IpPermissions.splice i, 1

                    $.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

                      if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                        MC.canvas_data.component[key].resource.IpPermissionsEgress.splice i, 1

              return false

      else

        $.each MC.canvas_data.component, ( key, comp ) ->

          if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid and comp.resource.Attachment.DeviceIndex == '0'

            if comp.GroupId.length != 1

              $.each comp.GroupId, ( index, group) ->

                if group.GroupId == sg_id_ref

                  comp.GroupId.splice index, 1

                  return false

              $.each MC.canvas_property.sg_list, ( idx, value ) ->

                if value.uid == sg_uid

                  index = value.member.indexOf uid

                  value.member.splice index, 1

                  # delete member 0 sg

                  if value.member.length == 0 and value.name != 'DefaultSG'

                    MC.canvas_property.sg_list.splice idx, 1

                    delete MC.canvas_data.component[sg_uid]

                    $.each MC.canvas_data.component, ( key, comp ) ->

                      if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

                        $.each comp.resource.IpPermissions, ( i, rule ) ->

                          if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                            MC.canvas_data.component[key].resource.IpPermissions.splice i, 1

                        $.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

                          if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

                            MC.canvas_data.component[key].resource.IpPermissionsEgress.splice i, 1
            return false

      null

    getSGList : () ->

      uid = this.get 'get_uid'
      sgAry = MC.canvas_data.component[uid].resource.SecurityGroups

      sgUIDAry = []
      _.each sgAry, (value) ->
        sgUID = value.slice(1).split('.')[0]
        sgUIDAry.push sgUID
        null

      return sgUIDAry

    setIPList : (inputIPAry) ->

      # find eni0
      eniUID = ''
      currentInstanceUID = this.get 'get_uid'
      currentInstanceUIDRef = '@' + currentInstanceUID + '.resource.InstanceId'
      allComp = MC.canvas_data.component
      _.each allComp, (compObj) ->
        if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
          instanceUIDRef = compObj.resource.Attachment.InstanceId
          deviceIndex = compObj.resource.Attachment.DeviceIndex
          if (currentInstanceUIDRef is instanceUIDRef) and (deviceIndex is '0')
            eniUID = compObj.uid
        null

      if eniUID
        realIPAry = MC.aws.eni.generateIPList eniUID, inputIPAry
        MC.aws.eni.saveIPList eniUID, realIPAry

    getAppLaunch : ( uid ) ->

      component = MC.canvas_data.component[uid]
      lc_data   = MC.data.resource_list[MC.canvas_data.region][ component.resource.LaunchConfigurationARN ]

      this.set 'name', component.name
      this.set 'lc',   lc_data
      this.set 'get_uid',  uid

  }

  model = new LaunchConfigModel()

  return model
