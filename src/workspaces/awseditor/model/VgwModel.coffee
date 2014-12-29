
define [ "ComplexResModel", "Design", "constant" ], ( ComplexResModel, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      name : "VPN-gateway"

    type : constant.RESTYPE.VGW

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          Type         : "ipsec.1"
          VpnGatewayId : @get("appId")
          Attachments  : [{ VpcId : @parent().createRef( "VpcId" ) }]

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.VGW

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.VpnGatewayId
        parent : resolve( MC.extractID data.resource.Attachments[0].VpcId )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      null

  }

  Model

