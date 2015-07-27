
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js", "./CpVolume", "./CpInstance", "CloudResources" ], ( CanvasElement, constant, CanvasManager, lang, VolumePopup, InstancePopup, CloudResources )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeLc"
    ### env:dev:end ###
    type : constant.RESTYPE.LC

    portPosMap : {
      "launchconfig-sg-left"  : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "launchconfig-sg-right" : [ 80, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }
    portDirMap : {
      "launchconfig-sg" : "horizontal"
    }

    defaultSize : [9,9]

    events :
      "mousedown .server-number-group" : "showGroup"
      "mousedown .volume-image"        : "showVolume"
      "click .volume-image"            : "suppressEvent"
      "click .server-number-group"     : "suppressEvent"

    # Bring LC's view up when hovering, so that it won't
    # be blocked by lines.
    hover      : ( evt )->
      $lc    = $( evt.currentTarget )
      $asg   = $lc.parent()
      asgPos = $asg[0].instance.transform()

      if not CanvasManager.hasClass( $asg, "AWS-AutoScaling-Group" ) and not CanvasManager.hasClass( $asg, "ExpandedAsg" )
        return

      $lcLayer = @canvas.getLayer("layer_lc")
      $lcLayer.attr {
        "transform" : "translate(#{asgPos.x} #{asgPos.y})"
        "data-id"   : $asg.attr("data-id")
      }
      $lcLayer.append( $lc )

      CanvasManager.addClass(cn.$el, "hover") for cn in @connections()
      return


    hoverOut   : ( evt )->
      $lc = $( evt.currentTarget )
      $layer = $lc.parent()

      if not CanvasManager.hasClass( $layer, "layer_lc" )
        return

      id = $layer.attr("data-id")
      $layer.attr("data-id", "")

      @canvas.getItem( id ).$el.children().eq(0).after( $lc[0] )
      CanvasManager.removeClass(cn.$el, "hover") for cn in @connections()
      return

    suppressEvent : ()-> false

    listenModelEvents : ()->
      @listenTo @model, "change:connections", @render
      @listenTo @model, "change:volumeList", @render
      @listenTo @model, "change:imageId", @render
      @listenTo @canvas, "switchMode", @render # For Eip Tooltip
      @listenTo @canvas, "change:externalData", @render

      # This event is triggered by expanded asg
      @listenTo @model, "change:expandedList", ()->
        self = @
        setTimeout ()->
          if not self.model.isRemoved() then self.render()
        , 0
      return

    iconUrl : ( imageId )->
      if @model.isMesos() then return 'ide/ami/mesos-slave.png'

      ami = @model.getAmi(imageId) || @model.get("cachedAmi")

      if not ami
        "ide/ami/ami-not-available.png"
      else
        "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"

    pos : ( el )->
      if el
        parentItem = @canvas.getItem( el.parentNode.getAttribute("data-id") )
      else
        console.warn "Accessing LC' position without svg element"
        parentItem = parentItem = @canvas.getItem( @model.connectionTargets("LcUsage")[0].id )

      if parentItem
        p = parentItem.pos()
        p.x += 2
        p.y += 3
        p
      else
        { x : 0, y : 0 }

    isTopLevel : ()-> false

    ensureLcView : ()->
      elementChanged = false

      lcParentMap = {}
      for asg in @model.connectionTargets("LcUsage")
        lcParentMap[ asg.id ] = asg
        for expanded in asg.get("expandedList")
          lcParentMap[ expanded.id ] = expanded

      views = []
      views.push(subview) for subview in @$el

      for subview in views
        parentCid = $(subview.parentNode).attr("data-id")
        parentItem = @canvas.getItem( parentCid )
        if not parentItem
          @removeView( subview )
          elementChanged = true
        else
          parentModel = parentItem.model
          if not lcParentMap[ parentModel.id ]
            @removeView( subview )
            elementChanged = true
          else
            delete lcParentMap[ parentModel.id ]

      svg = @canvas.svg
      for uid, parentModel of lcParentMap
        isOriginalAsg = parentModel.type isnt "ExpandedAsg"
        svgEl = @createNode({
          image   : "ide/icon/cvs-instance.png"
          imageX  : 15
          imageY  : 11
          imageW  : 61
          imageH  : 62
          label   : true
          labelBg : true
          sg      : isOriginalAsg
        }).add([
          # Ami Icon
          svg.image( MC.IMG_URL + @iconUrl(), 39, 27 ).move(27, 15).classes("ami-image")

          svg.use("port_diamond").move( 10, 20 ).attr({
            'class'        : 'port port-blue tooltip'
            'data-name'    : 'launchconfig-sg'
            'data-alias'   : 'launchconfig-sg-left'
            'data-tooltip' : lang.IDE.PORT_TIP_D
          })
          svg.use("port_diamond").move( 80, 20 ).attr({
            'class'        : 'port port-blue tooltip'
            'data-name'    : 'launchconfig-sg'
            'data-alias'   : 'launchconfig-sg-right'
            'data-tooltip' : lang.IDE.PORT_TIP_D
          })

          # Volume Image
          svg.image( MC.IMG_URL + "ide/icon/icn-vol.png", 29, 24 ).move(31, 46).classes('volume-image')
          # Volume Label
          svg.plain( "" ).move(45, 58).classes('volume-number')

          # Servergroup
          svg.group().add([
            svg.rect(20,14).move(36,2).radius(3).classes("server-number-bg")
            svg.plain("0").move(46,13).classes("server-number")
          ]).classes("server-number-group")
        ]).classes("canvasel fixed AWS-AutoScaling-LaunchConfiguration").move( 20, 30 )

        @addView( svgEl )
        @canvas.getItem( uid ).$el.children().eq(0).after( svgEl.node )
        elementChanged = true

      if elementChanged then @updateConnections()

      return

    # Update the svg element
    render : ( force )->
      if @canvas.initializing and not force then return

      @ensureLcView()
      m = @model
      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")
      # Update Image
      CanvasManager.update @$el.children(".ami-image"), @iconUrl(), "href"
      # Update Volume
      volumeCount = if m.get("volumeList") then m.get("volumeList").length else 0
      CanvasManager.update @$el.children(".volume-number"), volumeCount

      @$el.children(".server-number-group").hide()
      if m.design().modeIsApp()
        @$el.children(".server-number-group").show()
        asgCln = CloudResources( m.design().credentialId(), constant.RESTYPE.ASG, m.design().region() )
        for el in @$el
          asg = @canvas.getItem( el.parentNode.getAttribute("data-id") ).model
          asg = asgCln.get (asg.get("originalAsg") || asg).get("appId")
          if not asg then continue
          asg = asg.attributes
          numberGroup = $( el ).children(".server-number-group").show()
          CanvasManager.update numberGroup.children("text"), asg.Instances?.length or 0
      return


    destroy : ( selectedDomElement )->
      if @model.connections("LcUsage").length > 1
        # Just need to delete lc usage
        parentItem = @canvas.getItem( selectedDomElement.parentNode.getAttribute("data-id") )
        if not parentItem then return
        LcUsage = Design.modelClassForType("LcUsage")

        parentModel = parentItem.model
        if parentModel.type is "ExpandedAsg"
          parentModel = parentModel.get("originalAsg")
        (new LcUsage(parentModel, @model)).remove()
        return

      CanvasElement.prototype.destroy.apply this, arguments

    doDestroyModel : ()-> @model.connections("LcUsage")[0]?.remove()

    showVolume : ( evt )->
      if @volPopup then return false
      self = @

      if @canvas.design.modeIsApp() then return false

      @volPopup = new VolumePopup {
        attachment : $( evt.currentTarget ).closest("g")[0]
        host       : @model
        models     : @model.get("volumeList")
        canvas     : @canvas
        onRemove   : ()-> _.defer ()-> self.volPopup = null; return
      }
      false

    showGroup : ( evt )->
      insCln  = CloudResources( @model.design().credentialId(), constant.RESTYPE.INSTANCE, @model.design().region() )

      name = @model.get("name")
      gm   = []

      el = evt.currentTarget.parentNode.parentNode
      asg = @canvas.getItem( el.getAttribute("data-id") ).model
      for m, idx in @model.groupMembers( asg )
        ins = insCln.get( m.appId )
        icon = @iconUrl ins?.get('imageId')
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
        attachment : $( evt.currentTarget ).closest(".canvasel")[0]
        host       : @model
        models     : gm
        canvas     : @canvas
      }
      return

  }, {
    render : ( canvas )->
      for lc in canvas.design.componentsOfType( constant.RESTYPE.LC )
        canvas.getItem( lc.id ).render( true )

    createResource : ( t, attr, option )->
      if not attr.parent then return
      if attr.parent.getLc() then return

      asg = attr.parent.get("originalAsg") || attr.parent
      delete attr.parent

      lcModel = CanvasElement.createResource( @type, attr, option )
      asg.setLc( lcModel )
      lcModel
  }
