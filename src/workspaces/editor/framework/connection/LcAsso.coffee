
define [ "constant", "../ConnectionModel", "i18n!nls/lang.js" ], ( constant, ConnectionModel, lang )->

  ConnectionModel.extend
    # offset of asg
    offset:
      x: 2
      y: 3

    type : "Lc_Asso"

    ceType: "Lc_Asso"

    node_line: false

    oneToMany : constant.RESTYPE.LC

    defaults:
      x        : 0
      y        : 0
      width    : 9
      height   : 9

    isVisual : () -> true


    remove: () ->
      lc = @getLc()

      ConnectionModel.prototype.remove.call this

      if lc.getUsage().length is 0
        lc.remove()

      null


    initialize: ( attr, option ) ->
      # Draw before create SgAsso
      @draw(true)

    x: ()-> @getAsg().x() + @offset.x || 0
    y: ()-> @getAsg().y() + @offset.y || 0

    width: ()-> @attributes.width || 0
    height: ()-> @attributes.height || 0

    getLc: -> @getTarget(constant.RESTYPE.LC)
    getAsg: -> @getTarget(constant.RESTYPE.ASG)

    connections: ->
      @getLc().connections()


