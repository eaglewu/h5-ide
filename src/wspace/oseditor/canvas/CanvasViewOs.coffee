
define [
  "CanvasView"
  "constant"
  "i18n!/nls/lang.js"
  "CanvasManager"
  "Design"
  "./CpVolume"
], ( CanvasView, constant, lang, CanvasManager, Design, VolumePopup )->

  isPointInRect = ( point, rect )->
    rect.x1 <= point.x and rect.y1 <= point.y and rect.x2 >= point.x and rect.y2 >= point.y

  OsCanvasView = CanvasView.extend {

    events : ()->
      $.extend {
        "addVol_dragover"  : "__addVolDragOver"
        "addVol_dragleave" : "__addVolDragLeave"
        "addVol_drop"      : "__addVolDrop"

      }, CanvasView.prototype.events

    recreateStructure : ()->
      @svg.clear().add([
        @svg.group().classes("layer_network")
        @svg.group().classes("layer_groupLine")
        @svg.group().classes("layer_subnet")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_node")
      ])
      return

    appendNetwork   : ( svgEl )-> @__appendSvg(svgEl, ".layer_network")
    appendSubnet    : ( svgEl )-> @__appendSvg(svgEl, ".layer_subnet")
    appendGroupLine : ( svgEl )-> @__appendSvg(svgEl, ".layer_groupLine")

    fixConnection : ( coord, initiator, target )->

    errorMessageForDrop : ( type )->
      switch type
        when constant.RESTYPE.OSSUBNET   then return lang.CANVAS.WARN_NOTMATCH_OSSUBNET
        when constant.RESTYPE.OSLISTENER then return lang.CANVAS.WARN_NOTMATCH_LISTENER
        when constant.RESTYPE.OSPOOL     then return lang.CANVAS.WARN_NOTMATCH_POOL
        when constant.RESTYPE.OSELB      then return lang.CANVAS.WARN_NOTMATCH_LB
        when constant.RESTYPE.OSRT       then return lang.CANVAS.WARN_NOTMATCH_ROUTER
        when constant.RESTYPE.OSRT       then return lang.CANVAS.WARN_NOTMATCH_ROUTER
        when constant.RESTYPE.OSVOL      then return lang.CANVAS.WARN_NOTMATCH_OSVOL
        when constant.RESTYPE.OSSERVER   then return lang.CANVAS.WARN_NOTMATCH_SERVER

    selectVolume : ( volumeId )->
      @deselectItem( true )
      @triggerSelected( constant.RESTYPE.OSVOL, volumeId ) if volumeId
      @__selectedVolume = volumeId
      false

    isReadOnly : ()-> @design.modeIsApp()

    delSelectedItem : ()->
      if @isReadOnly() then return false

      if @__selectedVolume
        volume = @design.component( @__selectedVolume )
        res = volume.isRemovable()
        if _.isString( res )
          notification "error", res
          return

        s = @__selectedVolume
        @__selectedVolume = null
        volume.remove()
        nextVol = $( ".canvas-pp .popup-volume" ).children().eq(0)
        if nextVol.length
          nextVol.trigger("mousedown")
        else
          @deselectItem()
        return

      CanvasView.prototype.delSelectedItem.apply this, arguments

    __addVolDragOver : ( evt, data )->
      @__scrollOnDrag( data )

      if not data.volDropTargets
        data.hoverItem = null
        data.volDropTargets = dropzones = []

        for tgt in @design.componentsOfType( constant.RESTYPE.OSSERVER )
          tgt = @getItem( tgt.id )

          for el in tgt.$el
            r = tgt.rect( el )
            r.tgt = tgt
            r.el  = el
            dropzones.push r

      if not data.effect
        data.effect = true
        for tgt in data.volDropTargets || []
          CanvasManager.addClass tgt.tgt.$el, "droppable"

      pos = @__localToCanvasCoor(data.pageX - data.zoneDimension.x1, data.pageY - data.zoneDimension.y1)

      hoverItem = null
      for tgt in data.volDropTargets
        if isPointInRect( pos, tgt )
          hoverItem = tgt
          break

      if hoverItem isnt data.hoverItem
        if data.popup then data.popup.remove()

        data.hoverItem = hoverItem
        if hoverItem
          model = hoverItem.tgt.model
          data.popup = new VolumePopup {
            attachment : hoverItem.el
            host       : model
            models     : model.volumes()
            canvas     : @
          }

      return

    __addVolDragLeave : ( evt, data )->
      @__clearDragScroll()

      for tgt in data.volDropTargets || []
        CanvasManager.removeClass tgt.tgt.$el, "droppable"

      data.effect = false

      if data.popup then data.popup.remove()
      return

    __addVolDrop : ( evt, data )->
      if not data.hoverItem then return

      attr = data.dataTransfer || {}

      owner = data.hoverItem.tgt.model

      if attr.id
        # Moving volume
        volume = @design.component( attr.id )
        oldServer = volume.getOwner()
        doable = volume.isReparentable( owner )
        if _.isString( doable )
          return notification "error", doable
        else if doable
          volume.attachTo( owner )
          @selectItem( data.hoverItem.el )
        return

      attr.owner = owner

      VolumeModel = Design.modelClassForType( constant.RESTYPE.OSVOL )
      v = new VolumeModel( attr )

      if data.popup then data.popup.remove()
      new VolumePopup {
        attachment    : data.hoverItem.el
        host          : owner
        models        : owner.volumes()
        canvas        : @
        selectAtBegin : v
      }
      return
  }

  OsCanvasView
