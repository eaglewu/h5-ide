#############################
#  View Mode for design/property/cgw
#############################

define [ 'constant' ], ( constant ) ->

    CGWModel = Backbone.Model.extend {

        defaults :
            uid  : null
            name : null
            BGP  : null
            ip   : null

        setId : ( uid ) ->
            cgw_component = MC.canvas_data.component[ uid ]

            obj =
                uid  : uid
                name : cgw_component.name
                BGP  : cgw_component.resource.BgpAsn
                ip   : cgw_component.resource.IpAddress

            this.set obj

            null

        setName : ( name ) ->
            MC.canvas_data.component[ this.attributes.uid ].name = name
            null

        setIP   : ( ip ) ->
            MC.canvas_data.component[ this.attributes.uid ].resource.IpAddress = ip
            null

        setBGP  : ( bgp ) ->

            uid = this.attributes.uid
            MC.canvas_data.component[uid].resource.BgpAsn = bgp

            # The CGW is dynamic. clear all ips of vpn connection
            if bgp
                for key, comp of MC.canvas_data.component
                    if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
                        continue

                    if comp.resource.CustomerGatewayId and comp.resource.CustomerGatewayId.indexOf( uid ) isnt -1
                        comp.resource.Routes = []

            null
    }

    model = new CGWModel()

    return model
