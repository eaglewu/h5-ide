
define [ "./CanvasElement", "constant" ], ( CanvasElement, constant )->

  CeIgw = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeIgw, constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway )
  ChildElementProto = CeIgw.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "igw-tgt" : [ 78, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
  }

  ChildElementProto.draw = ( isCreate ) ->
    m = @model

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : "ide/icon/igw-canvas.png"
        imageX  : 10
        imageY  : 16
        imageW  : 60
        imageH  : 46
        label   : m.get("name")
      })

      node.append(
        # Port
        Canvon.path(this.constant.PATH_PORT_LEFT).attr({
          'class'      : 'port port-blue port-igw-tgt'
          'data-name'     : 'igw-tgt'
          'data-position' : 'right'
          'data-type'     : 'sg'
          'data-direction': 'in'
        })
      )

      # Move the node to right place
      @getLayer("node_layer").append node
      @initNode node, m.x(), m.y()


    # Update Resource State in app view
    #@updateAppState()

    # Update xGW Resource Attachment State in app view
    @updatexGWAppState()

    null

  null
