
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  ComplexResModel.extend {

    type : constant.RESTYPE.OSSGRULE
    newNameTmpl : "SgRule-"

    defaults :
      direction : ""
      portMin   : ""
      portMax   : ""
      protocol  : ""
      sg        : null
      ip        : null
      appId     : ""

    setTarget : ( ipOrSgModel )->
      if typeof ip is "string"
        attr = {
          ip : ipOrSgModel
          sg : null
        }
      else
        attr = {
          ip : null
          sg : ipOrSgModel
        }

      @set attr
      return

    toJSON : ()->
      sg = @get("sg")
      {
        direction        : @get( "direction" )
        port_range_min   : @get( "portMin" )
        port_range_max   : @get( "portMax" )
        protocol         : @get( "protocol" )
        remote_group_id  : if sg then sg.createRef( "id" ) else ""
        remote_ip_prefix : @get( "ip" )
        id               : @get( "appId" )
      }

    fromJSON : ( json )->
      attr = @attributes

      attr.direction = json.direction
      attr.portMin   = json.port_range_min
      attr.portMax   = json.port_range_max
      attr.protocol  = json.protocol
      attr.appId     = json.id

      attr.sg = if json.remote_group_id  then json.remote_group_id else null
      attr.ip = if json.remote_ip_prefix then json.remote_ip_prefix else null

      return

    isEqualToData : ( data )->
      attr = @attributes
      if attr.direction isnt json.direction then return false
      if attr.portMin   isnt json.portMin   then return false
      if attr.portMax   isnt json.portMax   then return false
      if attr.protocol  isnt json.protocol  then return false
      if attr.sg        isnt json.sg        then return false
      if attr.ip        isnt json.ip        then return false

      true
  }
