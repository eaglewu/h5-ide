
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  LineMaskToClear = null

  CeLine = CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeLine"
    ### env:dev:end ###
    type : "CeLine"

    node_line : true

    portName : ( targetId )-> @model.port( targetId, "name" )

    # Update the svg element
    render : ()->
      @$el.remove()
      @$el = $()

      item1 = @canvas.getItem( @model.port1Comp().id )
      item2 = @canvas.getItem( @model.port2Comp().id )

      initiator = @canvas.__popLineInitiator() || item1

      if item1.$el.length is 1 and item2.$el.length is 1
        @renderConnection( item1, item2, undefined, undefined, initiator )
      else
        for el1 in item1.$el
          for el2 in item2.$el
            @renderConnection( item1, item2, el1, el2, initiator )

      return

    update : ()->
      item1 = @canvas.getItem( @model.port1Comp().id )
      item2 = @canvas.getItem( @model.port2Comp().id )

      if item1.$el.length is 1 and item2.$el.length is 1
        @$el.children().attr( "d", @generatePath( item1, item2, undefined, undefined ) )
      else
        newLength = item1.$el.length * item2.$el.length
        if @$el.length < newLength
          while @$el.length < newLength
            svgEl = @createLine( "M0 0Z" )
            @addView svgEl

        else if @$el.length > newLength
          @$el.slice( newLength ).remove()
          @$el = @$el.slice( 0, newLength )

        i = 0
        for el1 in item1.$el
          for el2 in item2.$el
            @$el.eq(i).children().attr( "d", @generatePath( item1, item2, el1, el2 ) )
            ++i
      return

    createLine : ( pd )->
      svg = @canvas.svg
      svgEl = svg.group().add([
        svg.path(pd)
        svg.path(pd).classes("fill-line")
      ]).attr({"data-id":@cid}).classes("line " + @type.replace(/\./g, "-") )
      @canvas.appendLine( svgEl )

      svgEl

    renderConnection : ( item_from, item_to, element1, element2, initiator )->
      path = @generatePath( item_from, item_to, element1, element2 )
      # Create or redraw line
      svgEl = @createLine( path )
      @addView svgEl

      if not @canvas.initializing and initiator
        svg = @canvas.svg
        maskPath = svg.path( path )
        length = parseFloat(maskPath.node.getTotalLength()).toFixed(2)

        dirt = (if initiator is item_from then 1 else -1) * (@__lastDir || 1)

        maskPath.style({
          "stroke-dasharray"  : length + " " + length
          "stroke-dashoffset" : length * dirt
        })

        setTimeout ()->
          maskPath.classes("mask-line")
        , 20

        CeLine.cleanLineMask svgEl.maskWith( maskPath )
      return

    generatePath : ( item_from, item_to, element1, element2 )->
      connection = @model

      pos_from = item_from.pos( element1 )
      pos_to   = item_to.pos( element2 )

      pos_to.x   *= 10
      pos_to.y   *= 10
      pos_from.x *= 10
      pos_from.y *= 10

      from_port = connection.port1("name")
      to_port   = connection.port2("name")
      dirn_from = item_from.portDirection(from_port)
      dirn_to   = item_to.portDirection(to_port)

      if dirn_from and dirn_to
        if pos_from.x > pos_to.x
          from_port += "-left"
          to_port   += "-right"
        else
          from_port += "-right"
          to_port   += "-left"

        pos_port_from = item_from.portPosition( from_port, true )
        pos_port_to   = item_to.portPosition( to_port, true )

        pos_from.x += pos_port_from[0]
        pos_from.y += pos_port_from[1]
        pos_to.x   += pos_port_to[0]
        pos_to.y   += pos_port_to[1]

      else if dirn_from

        pos_port_to = item_to.portPosition( to_port, true )
        pos_to.x += pos_port_to[0]
        pos_to.y += pos_port_to[1]

        if dirn_from is "vertical"
          from_port += if pos_to.y > pos_from.y then "-bottom" else "-top"
        else if dirn_from is "horizontal"
          from_port += if pos_to.x > pos_from.x then "-right" else "-left"

        pos_port_from = item_from.portPosition( from_port, true )
        pos_from.x += pos_port_from[0]
        pos_from.y += pos_port_from[1]

      else if dirn_to
        pos_port_from = item_from.portPosition( from_port, true )
        pos_from.x += pos_port_from[0]
        pos_from.y += pos_port_from[1]

        if dirn_to is "vertical"
          to_port += if pos_from.y > pos_to.y then "-bottom" else "-top"
        else if dirn_to is "horizontal"
          to_port += if pos_from.x > pos_to.x then "-right" else "-left"

        pos_port_to = item_to.portPosition( to_port, true )
        pos_to.x += pos_port_to[0]
        pos_to.y += pos_port_to[1]

      else
        pos_port_from = item_from.portPosition( from_port, true )
        pos_port_to   = item_to.portPosition( to_port, true )

        pos_from.x += pos_port_from[0]
        pos_from.y += pos_port_from[1]
        pos_to.x   += pos_port_to[0]
        pos_to.y   += pos_port_to[1]

      start0 =
        x     : pos_from.x
        y     : pos_from.y
        angle : pos_port_from[2]
        type  : connection.port1Comp().type
        name  : from_port

      end0 =
        x     : pos_to.x
        y     : pos_to.y
        angle : pos_port_to[2]
        type  : connection.port2Comp().type
        name  : to_port


      @__lastDir = if start0.y >= end0.y then 1 else -1

      # Calculate line path
      if start0.x is end0.x or start0.y is end0.y
        path = "M#{start0.x} #{start0.y} L#{end0.x} #{end0.y}"
      else
        controlPoints = MC.canvas.route2( start0, end0 )
        if controlPoints
          switch @canvas.lineStyle()
            when 0
              path = "M#{controlPoints[0].x} #{controlPoints[0].y} L#{controlPoints[1].x} #{controlPoints[1].y} L#{controlPoints[controlPoints.length-2].x} #{controlPoints[controlPoints.length-2].y} L#{controlPoints[controlPoints.length-1].x} #{controlPoints[controlPoints.length-1].y}"
            when 1 then path = MC.canvas._round_corner(controlPoints)
            when 2 then path = MC.canvas._bezier_q_corner(controlPoints)
            when 3 then path = MC.canvas._bezier_qt_corner(controlPoints)
            when 777 then path = MC.canvas._round_corner(controlPoints)

      path

  }, {
    cleanLineMask : ( line )->
      if not LineMaskToClear
        LineMaskToClear = [ line ]
        setTimeout ()->
          CeLine.__cleanLineMask()
        , 340
      else
        LineMaskToClear.push line

    __cleanLineMask : ()->
      for line in LineMaskToClear
        if line.masker
          line.masker.remove()
      LineMaskToClear = null
      return
  }


  CeLine.extend {
    ### env:dev ###
    ClassName : "CeEniAttachment"
    ### env:dev:end ###
    type : "EniAttachment"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbAsso"
    ### env:dev:end ###
    type : "ElbAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeRtbAsso"
    ### env:dev:end ###
    type : "RTB_Asso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeRtbRoute"
    ### env:dev:end ###
    type : "RTB_Route"

    createLine : ( pd )->
      svg   = @canvas.svg
      svgEl = CeLine.prototype.createLine.call this, pd
      svgEl.add( svg.path(pd).classes("dash-line") )
      svgEl
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeVpn"
    ### env:dev:end ###
    type : constant.RESTYPE.VPN
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbSubnetAsso"
    ### env:dev:end ###
    type : "ElbSubnetAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbAmiAsso"
    ### env:dev:end ###
    type : "ElbAmiAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeDbReplication"
    ### env:dev:end ###
    type : "DbReplication"
  }

  CeLine
