
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js", "Design", "CloudResources" ], ( CanvasElement, constant, CanvasManager, lang, Design, CloudResources )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeOsExtNetwork"
    ### env:dev:end ###
    type : "OS::ExternalNetwork"

    parentType  : [ "SVG" ]
    defaultSize : [8,8]

    portPosMap : {
      "router" : [ 78, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/cvs-igw.png"
        imageX  : 10
        imageY  : 16
        imageW  : 60
        imageH  : 46
        label   : m.get("name")
      }).add(
        svg.use("port_left").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'router'
          'data-tooltip' : lang.IDE.PORT_TIP_C
        })
      )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl
  }