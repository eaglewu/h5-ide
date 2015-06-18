
define [
  "CanvasElement"
  "constant"
  "CanvasManager"
  "./CpVolume"
  "./CpInstance"
  "i18n!/nls/lang.js"
  "CloudResources"
  "eip_selector"
  "event"
  "UI.notification"
], ( CanvasElement, constant, CanvasManager, VolumePopup, InstancePopup, lang, CloudResources, EipSelector, ide_event )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeInstance"
    ### env:dev:end ###
    type : constant.RESTYPE.INSTANCE

    parentType  : [ constant.RESTYPE.AZ, constant.RESTYPE.SUBNET, constant.RESTYPE.ASG, "ExpandedAsg" ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "instance-sg-left"  : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "instance-sg-right" : [ 80, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "instance-attach"   : [ 78, 50, CanvasElement.constant.PORT_RIGHT_ANGLE, 80, 50 ]
      "instance-rtb"      : [ 45, 2,  CanvasElement.constant.PORT_UP_ANGLE  ]
    }
    portDirMap : {
      "instance-sg" : "horizontal"
    }

    events :
      "mousedown .eip-status"          : "toggleEip"
      "mousedown .volume-image"        : "showVolume"
      "mousedown .server-number-group" : "showGroup"
      "click .eip-status"              : "suppressEvent"
      "click .volume-image"            : "suppressEvent"
      "click .server-number-group"     : "suppressEvent"

    suppressEvent : ()-> false

    iconUrl : ()->
      if @model.isMesosMaster()
        url = 'ide/ami/mesos-master.png'
      else if @model.isMesosSlave()
        url = 'ide/ami/mesos-slave.png'
      else
        ami = @model.getAmi() || @model.get("cachedAmi")

        if not ami
          m = @model
          instance = CloudResources( m.design().credentialId(), m.type, m.design().region() ).get( m.get("appId") )
          if instance
            instance = instance.attributes
            if instance.platform and instance.platform is "windows"
              url = "ide/ami/windows.#{instance.architecture}.#{instance.rootDeviceType}.png"
            else
              url = "ide/ami/linux-other.#{instance.architecture}.#{instance.rootDeviceType}.png"
          else
            url = "ide/ami/ami-not-available.png"
        else
          url = "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"

      url

    listenModelEvents : ()->
      @listenTo @model, "change:primaryEip", @render
      @listenTo @model, "change:imageId", @render
      @listenTo @model, "change:volumeList", @render
      @listenTo @model, "change:count", @updateServerCount

      @listenTo @canvas, "switchMode", @render # For Eip Tooltip
      @listenTo @canvas, "change:externalData", @render # For Instance State
      return

    updateServerCount : ()->
      @render()
      @canvas.getItem( eni.id )?.render() for eni in @model.connectionTargets( "EniAttachment" )
      return

    toggleEip : ()->
      if @canvas.design.modeIsApp() then return false

      toggle = !@model.hasPrimaryEip()
      if @canvas.design.modeIsAppEdit() and toggle
        @selectEip()
        return false
      @model.setPrimaryEip( toggle )

      if toggle
        Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()

      CanvasManager.updateEip @$el.children(".eip-status"), @model

      ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
      false

    selectEip: ()->
      self = @
      if not @canvas.design.modeIsAppEdit or @model.hasPrimaryEip()
        return false
      selector = new EipSelector(self.model)
      selector.on "assign", ()->
        Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()
        CanvasManager.updateEip self.$el.children(".eip-status"), self.model
        ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
        selector.off "assign"
        false

    select : ( selectedDomElement )->
      type = @type
      if @model.get("appId") and @canvas.design.modeIsAppEdit()
        type = "component_server_group"
      @canvas.triggerSelected type, @model.id
      return

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/cvs-instance.png"
        imageX  : 15
        imageY  : 11
        imageW  : 61
        imageH  : 62
        label   : true
        labelBg : true
        sg      : true
      }).add([
        # Ami Icon
        svg.image( MC.IMG_URL + @iconUrl(), 39, 27 ).move(27, 15).classes("ami-image")
        # Volume Image
        svg.image( MC.IMG_URL + "ide/icon/icn-vol.png", 29, 24 ).move(21, 46).classes('volume-image')
        # Volume Label
        svg.text( "" ).move(35, 58).classes('volume-number')
        # Eip
        svg.image( "", 12, 14).move(53, 49).classes('eip-status tooltip')

        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'instance-sg'
          'data-alias'   : 'instance-sg-left'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_right").attr({
          'class'        : 'port port-green tooltip'
          'data-name'    : 'instance-attach'
          'data-tooltip' : lang.IDE.PORT_TIP_E
        })
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'instance-sg'
          'data-alias'   : 'instance-sg-right'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_bottom").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'instance-rtb'
          'data-tooltip' : lang.IDE.PORT_TIP_C
        })

        # Servergroup
        svg.group().add([
          svg.rect(20,14).move(36,2).radius(3).classes("server-number-bg")
          svg.plain("0").move(46,13).classes("server-number")
        ]).classes("server-number-group")
      ])

      if not @model.design().modeIsStack() and m.get("appId")
        svgEl.add( svg.circle(8).move(63, 14).classes('res-state unknown') )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      m = @model

      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")

      # Update Image
      CanvasManager.update @$el.children(".ami-image"), @iconUrl(), "href"

      # Update Server number
      numberGroup = @$el.children(".server-number-group")
      statusIcon  = @$el.children(".res-state")
      if m.get("count") > 1
        CanvasManager.toggle statusIcon, false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), m.get("count")

      else
        CanvasManager.toggle statusIcon, true
        CanvasManager.toggle numberGroup, false

        if statusIcon.length
          instance = CloudResources( m.design().credentialId(), m.type, m.design().region() ).get( m.get("appId") )
          state    = instance?.get("instanceState").name || "unknown"
          statusIcon.data("tooltip", state).attr("data-tooltip", state).attr("class", "res-state tooltip #{state}")

      # Update EIP
      CanvasManager.updateEip @$el.children(".eip-status"), m

      # Update Volume
      volumeCount = if m.get("volumeList") then m.get("volumeList").length else 0
      CanvasManager.update @$el.children(".volume-number"), volumeCount

    showVolume : ()->

      # Only show volume if not in app mode nor servergroup
      if @canvas.design.modeIsApp() and @model.get("count") > 1
        return false

      if @volPopup then return false
      self = @
      @volPopup = new VolumePopup {
        attachment    : @$el[0]
        host          : @model
        models        : @model.get("volumeList")
        selectAtBegin : @model.get("volumeList")[0]
        canvas        : @canvas
        onRemove      : ()-> _.defer ()-> self.volPopup = null; return
      }
      false

    showGroup : ()->
      # Only show server group list in app mode.
      if not @canvas.design.modeIsApp() then return

      insCln = CloudResources( @model.design().credentialId(), @type, @model.design().region() )
      members = (@model.groupMembers() || []).slice(0)
      members.unshift( { appId : @model.get("appId") } )

      name = @model.get("name")
      gm   = []
      icon = @iconUrl()
      for m, idx in members
        ins = insCln.get( m.appId )
        if not ins
          console.warn "Cannot find instance of `#{m.appId}`"
          continue
        ins = ins.attributes

        volume = ins.blockDeviceMapping.length
        for bdm in ins.blockDeviceMapping
          if bdm.deviceName is ins.rootDeviceName
            --volume
            break

        gm.push {
          name   : "#{name}-#{idx}"
          id     : m.appId
          icon   : icon
          volume : volume
          state  : ins.instanceState?.name || "unknown"
        }

      new InstancePopup {
        attachment : @$el[0]
        host       : @model
        models     : gm
        canvas     : @canvas
      }
      return

  }, {
    isDirectParentType : ( t )-> return t isnt constant.RESTYPE.AZ

    createResource : ( type, attr, option )->
      if not attr.parent then return

      switch attr.parent.type
        when constant.RESTYPE.SUBNET
          return CanvasElement.createResource( type, attr, option )

        when constant.RESTYPE.ASG, "ExpandedAsg"
          if option.cloneSource # Deny copy instance to an asg.
            notification 'error', lang.CANVAS.LAUNCH_CONFIGURATION_MUST_BE_CREATED_FROM_AMI_IN_RESOURCE_PANEL
            return

          TYPE_LC = constant.RESTYPE.LC
          return CanvasElement.getClassByType( TYPE_LC ).createResource( TYPE_LC, attr, option )

        when constant.RESTYPE.AZ
          # Auto add subnet for instance
          attr.parent = CanvasElement.createResource( constant.RESTYPE.SUBNET, {
            x      : attr.x + 1
            y      : attr.y + 1
            width  : 11
            height : 11
            parent : attr.parent
          } , option )

          attr.x += 2
          attr.y += 2

          return CanvasElement.createResource( constant.RESTYPE.INSTANCE, attr, option )

      return
  }

